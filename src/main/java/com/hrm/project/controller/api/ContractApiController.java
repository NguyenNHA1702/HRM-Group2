package com.hrm.project.controller.api;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.hrm.project.enums.ContractStatus;
import com.hrm.project.model.Contract;
import com.hrm.project.service.ContractService;
import com.hrm.project.service.impl.ContractServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.sql.Date;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

@WebServlet(name = "ContractApiController", urlPatterns = {"/hr/api/contracts"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,      // 1 MB
        maxFileSize       = 10 * 1024 * 1024,  // 10 MB
        maxRequestSize    = 15 * 1024 * 1024   // 15 MB
)
public class ContractApiController extends HttpServlet {

    private final ContractService contractService = new ContractServiceImpl();
    private final Gson gson = new Gson();

    private static final String UPLOAD_DIR = "uploads/contracts";
    private static final List<String> ALLOWED_EXTENSIONS = Arrays.asList(".pdf", ".jpg", ".jpeg", ".png");

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // Kiểm tra quyền: chỉ ADMIN và HR
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("employeeId") == null) {
            sendJson(response, HttpServletResponse.SC_UNAUTHORIZED,
                    "error", "Phiên làm việc đã hết hạn. Vui lòng đăng nhập lại.");
            return;
        }

        String roleGroup = (String) session.getAttribute("roleGroup");
        if (roleGroup == null || (!"ADMIN".equals(roleGroup) && !"HR".equals(roleGroup))) {
            sendJson(response, HttpServletResponse.SC_FORBIDDEN,
                    "error", "Bạn không có quyền thực hiện thao tác này.");
            return;
        }

        String action = request.getParameter("action");

        try {
            switch (action == null ? "" : action) {

                case "create":
                    handleCreate(request, response);
                    break;

                case "terminate":
                    handleTerminate(request, response);
                    break;

                case "renew":
                    handleRenew(request, response);
                    break;

                default:
                    sendJson(response, HttpServletResponse.SC_BAD_REQUEST,
                            "error", "Hành động không hợp lệ: " + action);
            }
        } catch (Exception e) {
            e.printStackTrace();
            sendJson(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "error", "Lỗi hệ thống: " + e.getMessage());
        }
    }

    // ── action=create ────────────────────────────────────────────────────
    private void handleCreate(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        String employeeIdStr  = request.getParameter("employeeId");
        String contractNumber = request.getParameter("contractNumber");
        String contractTypeStr = request.getParameter("contractType");
        String startDateStr   = request.getParameter("startDate");
        String endDateStr     = request.getParameter("endDate");
        String baseSalaryStr  = request.getParameter("baseSalary");
        String description    = request.getParameter("description");

        // Validate bắt buộc
        if (isBlank(employeeIdStr) || isBlank(contractNumber) ||
                isBlank(contractTypeStr) || isBlank(startDateStr) || isBlank(baseSalaryStr)) {
            sendJson(response, HttpServletResponse.SC_BAD_REQUEST,
                    "error", "Vui lòng điền đầy đủ các trường bắt buộc.");
            return;
        }

        // ── File upload: bắt buộc khi tạo hợp đồng ──────────────────────
        Part filePart = request.getPart("contractFile");
        if (filePart == null || filePart.getSize() == 0) {
            sendJson(response, HttpServletResponse.SC_BAD_REQUEST,
                    "error", "Vui lòng upload file hợp đồng scan (PDF, JPG, JPEG hoặc PNG).");
            return;
        }

        String originalFileName = extractFileName(filePart);
        String fileExtension = getFileExtension(originalFileName).toLowerCase();

        if (!ALLOWED_EXTENSIONS.contains(fileExtension)) {
            sendJson(response, HttpServletResponse.SC_BAD_REQUEST,
                    "error", "Định dạng file không hợp lệ. Chỉ chấp nhận: PDF, JPG, JPEG, PNG.");
            return;
        }

        // Save file to server
        String savedFileUrl = saveUploadedFile(filePart, fileExtension);

        Contract contract = new Contract();
        contract.setEmployeeId(Integer.parseInt(employeeIdStr));
        contract.setContractNumber(contractNumber.trim());
        contract.setContractType(Integer.parseInt(contractTypeStr));
        contract.setStartDate(Date.valueOf(startDateStr));

        if (!isBlank(endDateStr)) {
            contract.setEndDate(Date.valueOf(endDateStr));
        }

        contract.setBaseSalary(parseDouble(baseSalaryStr));
        contract.setStatus(ContractStatus.ACTIVE.getValue()); // Mặc định Active
        contract.setDescription(description);
        contract.setFileUrl(savedFileUrl);

        try {
            boolean success = contractService.createContract(contract);
            if (success) {
                sendJson(response, HttpServletResponse.SC_OK,
                        "success", "Tạo hợp đồng thành công!");
            } else {
                sendJson(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                        "error", "Lỗi hệ thống khi tạo hợp đồng. Vui lòng thử lại.");
            }
        } catch (RuntimeException e) {
            // Business rule: nhân viên đã có hợp đồng Active
            sendJson(response, HttpServletResponse.SC_CONFLICT,
                    "error", e.getMessage());
        }
    }

    // ── action=terminate ─────────────────────────────────────────────────
    private void handleTerminate(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String contractIdStr = request.getParameter("contractId");
        String reason        = request.getParameter("reason");

        if (isBlank(contractIdStr)) {
            sendJson(response, HttpServletResponse.SC_BAD_REQUEST,
                    "error", "Thiếu thông tin mã hợp đồng.");
            return;
        }

        int contractId = Integer.parseInt(contractIdStr);
        Date terminateDate = new Date(System.currentTimeMillis()); // Ngày hiện tại

        boolean success = contractService.terminateContract(contractId, terminateDate, reason);

        if (success) {
            sendJson(response, HttpServletResponse.SC_OK,
                    "success", "Chấm dứt hợp đồng thành công!");
        } else {
            sendJson(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "error", "Lỗi hệ thống khi chấm dứt hợp đồng.");
        }
    }

    // ── action=renew ─────────────────────────────────────────────────────
    private void handleRenew(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String oldContractIdStr = request.getParameter("oldContractId");
        String employeeIdStr    = request.getParameter("employeeId");
        String contractNumber   = request.getParameter("contractNumber");
        String contractTypeStr  = request.getParameter("contractType");
        String startDateStr     = request.getParameter("startDate");
        String endDateStr       = request.getParameter("endDate");
        String baseSalaryStr    = request.getParameter("baseSalary");
        String description      = request.getParameter("description");

        if (isBlank(oldContractIdStr) || isBlank(employeeIdStr) || isBlank(contractNumber) ||
                isBlank(contractTypeStr) || isBlank(startDateStr) || isBlank(baseSalaryStr)) {
            sendJson(response, HttpServletResponse.SC_BAD_REQUEST,
                    "error", "Vui lòng điền đầy đủ thông tin gia hạn hợp đồng.");
            return;
        }

        int oldContractId = Integer.parseInt(oldContractIdStr);

        Contract newContract = new Contract();
        newContract.setEmployeeId(Integer.parseInt(employeeIdStr));
        newContract.setContractNumber(contractNumber.trim());
        newContract.setContractType(Integer.parseInt(contractTypeStr));
        newContract.setStartDate(Date.valueOf(startDateStr));

        if (!isBlank(endDateStr)) {
            newContract.setEndDate(Date.valueOf(endDateStr));
        }

        newContract.setBaseSalary(parseDouble(baseSalaryStr));
        newContract.setStatus(ContractStatus.ACTIVE.getValue());
        newContract.setDescription(description);

        try {
            boolean success = contractService.renewContract(oldContractId, newContract);

            if (success) {
                sendJson(response, HttpServletResponse.SC_OK,
                        "success", "Gia hạn hợp đồng thành công! Hợp đồng cũ đã chuyển sang trạng thái Expired.");
            } else {
                sendJson(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                        "error", "Lỗi hệ thống khi gia hạn hợp đồng. Vui lòng thử lại.");
            }
        } catch (RuntimeException e) {
            sendJson(response, HttpServletResponse.SC_CONFLICT,
                    "error", e.getMessage());
        }
    }

    // ── Utilities ────────────────────────────────────────────────────────

    private void sendJson(HttpServletResponse response, int httpStatus,
                          String status, String message) throws IOException {
        response.setStatus(httpStatus);
        JsonObject json = new JsonObject();
        json.addProperty("status", status);
        json.addProperty("message", message);
        response.getWriter().write(gson.toJson(json));
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private double parseDouble(String s) {
        try {
            return Double.parseDouble(s.trim().replace(",", ""));
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    // ── File Upload Helpers ──────────────────────────────────────────────

    /**
     * Extract filename from Part's Content-Disposition header.
     */
    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        if (contentDisp != null) {
            for (String token : contentDisp.split(";")) {
                if (token.trim().startsWith("filename")) {
                    return token.substring(token.indexOf('=') + 1).trim()
                            .replace("\"", "");
                }
            }
        }
        return "unknown";
    }

    /**
     * Get file extension (e.g. ".pdf", ".jpg").
     */
    private String getFileExtension(String fileName) {
        int dotIndex = fileName.lastIndexOf('.');
        return (dotIndex >= 0) ? fileName.substring(dotIndex) : "";
    }

    /**
     * Save uploaded file to server and return the relative URL path.
     * Files are stored under: {webapp}/uploads/contracts/{uuid}.{ext}
     */
    private String saveUploadedFile(Part filePart, String extension) throws IOException {
        // Resolve absolute path: webapp root / uploads / contracts
        String appPath = getServletContext().getRealPath("");
        String uploadPath = appPath + File.separator + UPLOAD_DIR;

        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        // Generate unique filename
        String uniqueFileName = UUID.randomUUID().toString() + extension;
        Path filePath = Paths.get(uploadPath, uniqueFileName);

        // Write file to deployed target
        try (InputStream input = filePart.getInputStream()) {
            Files.copy(input, filePath, StandardCopyOption.REPLACE_EXISTING);
        }

        // Workspace fallback to persist uploaded file across rebuilds/redeploys
        String srcFallbackPath = "d:\\FU_Document\\SWP\\TestSWP\\src\\main\\webapp" + File.separator + UPLOAD_DIR;
        File srcFallbackDir = new File(srcFallbackPath);
        if (srcFallbackDir.exists() || srcFallbackDir.mkdirs()) {
            Path srcFilePath = Paths.get(srcFallbackPath, uniqueFileName);
            try (InputStream input = filePart.getInputStream()) {
                Files.copy(input, srcFilePath, StandardCopyOption.REPLACE_EXISTING);
            } catch (Exception e) {
                // Non-blocking log if writing copy to source fails
                System.err.println("[ContractAPI] Source fallback copy failed: " + e.getMessage());
            }
        }

        // Return relative URL for serving via browser
        return UPLOAD_DIR + "/" + uniqueFileName;
    }
}
