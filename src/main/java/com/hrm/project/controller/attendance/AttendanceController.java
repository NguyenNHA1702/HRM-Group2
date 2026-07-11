package com.hrm.project.controller.attendance;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonElement;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializationContext;
import com.google.gson.JsonSerializer;
import com.hrm.project.model.Attendance;
import com.hrm.project.model.AttendanceImportResult;
import com.hrm.project.service.AttendanceService;
import com.hrm.project.service.impl.AttendanceServiceImpl;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.lang.reflect.Type;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

@WebServlet("/cham-cong")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 10 * 1024 * 1024,
        maxRequestSize = 12 * 1024 * 1024
)
public class AttendanceController extends HttpServlet {

    private static final int MAX_IMPORT_ERRORS = 10;

    private final AttendanceService attendanceService = new AttendanceServiceImpl();
    private final Gson gson = new GsonBuilder()
            .registerTypeAdapter(LocalDate.class, new JsonSerializer<LocalDate>() {
                @Override
                public JsonElement serialize(LocalDate src, Type typeOfSrc, JsonSerializationContext context) {
                    return new JsonPrimitive(src.toString());
                }
            })
            .registerTypeAdapter(LocalDateTime.class, new JsonSerializer<LocalDateTime>() {
                @Override
                public JsonElement serialize(LocalDateTime src, Type typeOfSrc, JsonSerializationContext context) {
                    return new JsonPrimitive(src.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME));
                }
            })
            .create();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = requireSession(request, response);
        if (session == null) {
            return;
        }
        if (!canAccessAttendance((String) session.getAttribute("roleGroup"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Ban khong co quyen truy cap chuc nang cham cong.");
            return;
        }

        int month = parseIntOrDefault(request.getParameter("month"), LocalDate.now().getMonthValue());
        int year = parseIntOrDefault(request.getParameter("year"), LocalDate.now().getYear());
        if (month < 1 || month > 12 || year < 2000 || year > 2100) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thang hoac nam khong hop le.");
            return;
        }

        int employeeId = (Integer) session.getAttribute("employeeId");
        List<Attendance> attendances = attendanceService.getAttendanceByMonth(year, month, employeeId);

        // Tải trạng thái giải trình để hiển thị badge trên calendar
        Map<String, com.hrm.project.model.AttendanceExplanation> explanationDetailsMap =
                attendanceService.getExplanationsByMonth(employeeId, year, month);
        Map<String, String> explanationStatusMap = new java.util.HashMap<>();
        for (Map.Entry<String, com.hrm.project.model.AttendanceExplanation> entry : explanationDetailsMap.entrySet()) {
            explanationStatusMap.put(entry.getKey(), entry.getValue().getStatus());
        }
        request.setAttribute("explanationStatusMap", explanationStatusMap);
        request.setAttribute("explanationStatusJson", gson.toJson(explanationStatusMap));
        request.setAttribute("explanationDetailsJson", gson.toJson(explanationDetailsMap));

        boolean isLocked = attendanceService.isAttendanceLocked(year, month);
        request.setAttribute("isLocked", isLocked);
        request.setAttribute("canLockAttendance", "HR".equalsIgnoreCase((String) session.getAttribute("roleGroup")));

        request.setAttribute("currentMonth", month);
        request.setAttribute("currentYear", year);
        request.setAttribute("attendanceJson", gson.toJson(toCalendarData(attendances)));
        request.setAttribute("canImportAttendance", canImportAttendance(
                (String) session.getAttribute("roleGroup")));
        request.setAttribute("canViewSystemStatistics", canViewSystemStatistics(
                (String) session.getAttribute("roleGroup")));
        request.getRequestDispatcher("/WEB-INF/views/hr/attendance.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = requireSession(request, response);
        if (session == null) {
            return;
        }
        if (!canAccessAttendance((String) session.getAttribute("roleGroup"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Ban khong co quyen truy cap chuc nang cham cong.");
            return;
        }

        String action = request.getParameter("action");
        int month = parseIntOrDefault(request.getParameter("month"), LocalDate.now().getMonthValue());
        int year = parseIntOrDefault(request.getParameter("year"), LocalDate.now().getYear());

        try {
            if ("stageImport".equals(action)) {
                stageExcel(request, session, month, year);
            } else if ("commitImport".equals(action)) {
                commitExcel(session);
            } else if ("submitExplanation".equals(action)) {
                submitExplanation(request, session);
            } else if ("lockAttendance".equals(action)) {
                lockAttendance(request, session, year, month);
            } else if ("unlockAttendance".equals(action)) {
                unlockAttendance(request, session, year, month);
            } else {
                flash(session, "error", "Nguoi dung khong duoc phep dieu chinh du lieu cham cong.");
            }
        } catch (IllegalArgumentException e) {
            flash(session, "error", e.getMessage());
        } catch (Exception e) {
            flash(session, "error", "Da xay ra loi khi xu ly cham cong.");
        }

        response.sendRedirect(request.getContextPath()
                + "/cham-cong?month=" + month + "&year=" + year);
    }

    private void stageExcel(HttpServletRequest request, HttpSession session, int month, int year)
            throws IOException, ServletException {
        requireImportPermission(session);

        Part filePart = request.getPart("attendanceFile");
        String fileName = filePart == null ? null : filePart.getSubmittedFileName();
        if (filePart == null || filePart.getSize() == 0 || fileName == null) {
            throw new IllegalArgumentException("Vui long chon file Excel.");
        }
        if (!fileName.toLowerCase(Locale.ROOT).endsWith(".xlsx")) {
            throw new IllegalArgumentException("Chi chap nhan file co dinh dang .xlsx.");
        }

        byte[] fileData;
        try (java.io.InputStream inputStream = filePart.getInputStream()) {
            fileData = inputStream.readAllBytes();
        }

        // Validate tháng/năm của file Excel phải khớp với tháng/năm đang xem
        int[] detected = attendanceService.detectImportMonthYear(fileData);
        if (detected != null) {
            int fileYear  = detected[0];
            int fileMonth = detected[1];
            if (fileYear != year || fileMonth != month) {
                throw new IllegalArgumentException(
                        "File Excel chứa dữ liệu tháng " + fileMonth + "/" + fileYear
                        + ", không khớp với tháng đang xem ("
                        + month + "/" + year + "). Vui lòng kiểm tra lại file.");
            }
        }

        session.setAttribute("pendingAttendanceFile", fileData);
        session.setAttribute("pendingAttendanceFileName", sanitizeFileName(fileName));
        flash(session, "success",
                "Da tai file Excel len. Nhan \"Insert du lieu\" de ghi vao he thong.");
    }

    private void commitExcel(HttpSession session) {
        requireImportPermission(session);
        byte[] fileData = (byte[]) session.getAttribute("pendingAttendanceFile");
        if (fileData == null || fileData.length == 0) {
            throw new IllegalArgumentException("Khong co file Excel nao dang cho insert.");
        }

        AttendanceImportResult result = attendanceService.importFromExcel(
                new ByteArrayInputStream(fileData));

        if (result.isSuccess()) {
            session.removeAttribute("pendingAttendanceFile");
            session.removeAttribute("pendingAttendanceFileName");
            flash(session, "success",
                    "Insert thanh cong " + result.getImportedRows() + " dong cham cong vao he thong.");
        } else {
            flash(session, "error", summarizeImportErrors(result.getErrors()));
        }
    }

    private String summarizeImportErrors(List<String> errors) {
        int displayedErrors = Math.min(errors.size(), MAX_IMPORT_ERRORS);
        String message = String.join(" | ", errors.subList(0, displayedErrors));
        int hiddenErrors = errors.size() - displayedErrors;
        if (hiddenErrors > 0) {
            message += " | ... và " + hiddenErrors + " lỗi khác.";
        }
        return message;
    }

    private void submitExplanation(HttpServletRequest request, HttpSession session) {
        int employeeId = (Integer) session.getAttribute("employeeId");
        String dateStr = request.getParameter("date");
        String reason  = request.getParameter("reason");

        if (dateStr == null || dateStr.isBlank()) {
            flash(session, "error", "Ngày giải trình không hợp lệ.");
            return;
        }

        try {
            LocalDate date = LocalDate.parse(dateStr);
            if (attendanceService.isAttendanceLocked(date.getYear(), date.getMonthValue())) {
                flash(session, "error", "Tháng chấm công này đã bị khóa. Không thể gửi giải trình.");
                return;
            }
        } catch (Exception e) {
            flash(session, "error", "Ngày giải trình không hợp lệ.");
            return;
        }

        if (reason == null || reason.trim().isEmpty()) {
            flash(session, "error", "Vui lòng nhập nội dung giải trình.");
            return;
        }

        boolean submitted = attendanceService.submitExplanation(employeeId, dateStr, reason.trim());
        flash(session, submitted ? "success" : "error",
                submitted
                        ? "Gửi giải trình chấm công thành công. HR sẽ xem xét và phản hồi sớm."
                        : "Không thể gửi giải trình chấm công.");
    }

    private void lockAttendance(HttpServletRequest request, HttpSession session, int year, int month) {
        String role = (String) session.getAttribute("roleGroup");
        if (!"HR".equalsIgnoreCase(role)) {
            throw new IllegalArgumentException("Chỉ HR mới có quyền khóa chấm công.");
        }
        int employeeId = (Integer) session.getAttribute("employeeId");
        boolean ok = attendanceService.lockAttendance(year, month, employeeId);
        flash(session, ok ? "success" : "error",
                ok ? "Khóa chấm công thành công tháng " + month + "/" + year
                   : "Không thể khóa chấm công.");
    }

    private void unlockAttendance(HttpServletRequest request, HttpSession session, int year, int month) {
        String role = (String) session.getAttribute("roleGroup");
        if (!"HR".equalsIgnoreCase(role)) {
            throw new IllegalArgumentException("Chỉ HR mới có quyền mở khóa chấm công.");
        }
        boolean ok = attendanceService.unlockAttendance(year, month);
        flash(session, ok ? "success" : "error",
                ok ? "Mở khóa chấm công thành công tháng " + month + "/" + year
                   : "Không thể mở khóa chấm công.");
    }

    private void requireImportPermission(HttpSession session) {
        String role = (String) session.getAttribute("roleGroup");
        if (!canImportAttendance(role)) {
            throw new IllegalArgumentException("Ban khong co quyen import du lieu cham cong.");
        }
    }

    private boolean isIncompleteStatus(String status) {
        return "LATE".equals(status) || "EARLY_LEAVE".equals(status) || "ABSENT".equals(status);
    }

    private String sanitizeFileName(String fileName) {
        String normalized = fileName.replace("\\", "/");
        return normalized.substring(normalized.lastIndexOf('/') + 1);
    }

    private List<Map<String, Object>> toCalendarData(List<Attendance> attendances) {
        List<Map<String, Object>> data = new ArrayList<>();
        DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm");

        for (Attendance attendance : attendances) {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("id", attendance.getId());
            item.put("date", attendance.getDate().toString());
            item.put("checkIn", attendance.getCheckIn() == null
                    ? "--:--" : attendance.getCheckIn().format(timeFormatter));
            item.put("checkOut", attendance.getCheckOut() == null
                    ? "--:--" : attendance.getCheckOut().format(timeFormatter));
            item.put("status", toUiStatus(attendance.getStatus()));
            item.put("note", attendance.getNote());
            data.add(item);
        }
        return data;
    }

    private String toUiStatus(String status) {
        if ("LATE".equals(status) || "EARLY_LEAVE".equals(status)) {
            return "late";
        }
        if ("ABSENT".equals(status)) {
            return "absent";
        }
        if ("LEAVE".equals(status) || "HOLIDAY".equals(status)) {
            return "leave";
        }
        return "present";
    }

    private HttpSession requireSession(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("employeeId") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED,
                    "Phien lam viec da het han. Vui long dang nhap lai.");
            return null;
        }
        return session;
    }

    private boolean canImportAttendance(String role) {
        return "HR".equalsIgnoreCase(role);
    }

    private boolean canAccessAttendance(String role) {
        return "EMPLOYEE".equalsIgnoreCase(role) || "HR".equalsIgnoreCase(role);
    }

    private boolean canViewSystemStatistics(String role) {
        return "HR".equalsIgnoreCase(role);
    }

    private int parseIntOrDefault(String value, int defaultValue) {
        if (value == null || value.isBlank()) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private void flash(HttpSession session, String type, String message) {
        session.setAttribute("flash_" + type, message);
    }
}
