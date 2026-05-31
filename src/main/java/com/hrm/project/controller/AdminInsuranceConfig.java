package com.hrm.project.controller;

import com.hrm.project.dao.InsuranceDAO;
import com.hrm.project.dao.UserDAO;
import com.hrm.project.dao.impl.InsuranceDAOImpl;
import com.hrm.project.dao.impl.UserDAOImpl;
import com.hrm.project.model.InsuranceConfig;
import com.hrm.project.model.InsuranceConfigDTO;
import com.hrm.project.model.UserAccount;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Logger;

/**
 * AdminInsuranceConfig — Controller hiển thị trang Quản lý Bảo hiểm
 * URL: GET  /admin/insurance
 *      POST /admin/insurance/action
 *
 * Các tham số (params):
 * - keyword: Tìm kiếm theo mã nhân viên, tên, số bảo hiểm
 * - status: Lọc theo trạng thái (active, inactive)
 */
public class AdminInsuranceConfig extends HttpServlet {

    private static final Logger logger = Logger.getLogger(AdminInsuranceConfig.class.getName());

    private final InsuranceDAO insuranceDAO = new InsuranceDAOImpl();
    private final UserDAO userDAO = new UserDAOImpl();

    /**
     * GET - Hiển thị trang danh sách bảo hiểm
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html; charset=UTF-8");  // FIX: Added Content-Type

        String keyword = req.getParameter("keyword");
        String status = req.getParameter("status");

        // FIX: Normalize empty strings to null
        if (keyword != null && keyword.trim().isEmpty()) {
            keyword = null;
        }
        if (status != null && status.isEmpty()) {
            status = null;
        }

        try {
            // Lấy thống kê bảo hiểm
            InsuranceDAO.InsuranceStatDTO stats = insuranceDAO.getStats();
            req.setAttribute("stats", stats);

            // Lấy danh sách cấu hình tỷ lệ bảo hiểm
            List<InsuranceDAO.InsuranceRateDTO> insuranceRates = insuranceDAO.getAllRates();
            req.setAttribute("insuranceRates", insuranceRates);

            // Lấy danh sách bảo hiểm
            List<InsuranceConfigDTO> insurances;
            if ((keyword != null) || (status != null)) {
                insurances = insuranceDAO.search(keyword, status);
            } else {
                insurances = insuranceDAO.getAll();
            }
            req.setAttribute("insurances", insurances);

            // Lưu lại các giá trị filter
            req.setAttribute("filterKeyword", keyword != null ? keyword : "");
            req.setAttribute("filterStatus", status != null ? status : "");


            List<UserAccount> employees = userDAO.getAllEmployees();
            req.setAttribute("employees", employees != null ? employees : List.of());

            req.getRequestDispatcher("/WEB-INF/views/admin/insurance-config.jsp")
                    .forward(req, resp);

        } catch (SQLException e) {
            logger.severe("Database error loading insurance data: " + e.getMessage());
            req.getSession().setAttribute("flash_error", "Lỗi tải dữ liệu bảo hiểm: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/admin/insurance");
        }
    }

    /**
     * POST - Xử lý các hành động: create, update, delete, toggle
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html; charset=UTF-8");  // FIX: Added Content-Type

        String action = req.getParameter("action");

        try {
            if ("create".equalsIgnoreCase(action)) {
                handleCreate(req, resp);
            } else if ("update".equalsIgnoreCase(action)) {
                handleUpdate(req, resp);
            } else if ("delete".equalsIgnoreCase(action)) {
                handleDelete(req, resp);
            } else if ("toggle".equalsIgnoreCase(action)) {
                handleToggle(req, resp);
            } else if ("createRate".equalsIgnoreCase(action)) {
                handleCreateRate(req, resp);
            } else if ("updateRate".equalsIgnoreCase(action)) {
                handleUpdateRate(req, resp);
            } else if ("deleteRate".equalsIgnoreCase(action)) {
                handleDeleteRate(req, resp);
            } else if ("toggleRate".equalsIgnoreCase(action)) {
                handleToggleRate(req, resp);
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/insurance");
            }
        } catch (SQLException e) {
            logger.severe("Database error processing insurance action: " + e.getMessage());
            req.getSession().setAttribute("flash_error", "Lỗi: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/admin/insurance");
        }
    }

    /**
     * Xử lý tạo mới bảo hiểm
     */
    private void handleCreate(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException, SQLException {

        try {
            // FIX: Added validation before parsing
            if (!validateInsuranceInput(req, -1)) {
                resp.sendRedirect(req.getContextPath() + "/admin/insurance");
                return;
            }

            int employeeId = Integer.parseInt(req.getParameter("employeeId"));
            String insuranceNumber = req.getParameter("insuranceNumber").trim();
            double bhxhRate = Double.parseDouble(req.getParameter("bhxhRate"));
            double bhytRate = Double.parseDouble(req.getParameter("bhytRate"));
            double bhtnRate = Double.parseDouble(req.getParameter("bhtnRate"));
            double baseSalary = Double.parseDouble(req.getParameter("baseSalary"));
            boolean isActive = "1".equals(req.getParameter("isActive"));

            // FIX: Validate insurance rates are within valid range (0-100)
            if (bhxhRate < 0 || bhxhRate > 100 || bhytRate < 0 || bhytRate > 100 ||
                    bhtnRate < 0 || bhtnRate > 100) {
                req.getSession().setAttribute("flash_error", "Tỷ lệ bảo hiểm phải nằm trong khoảng 0-100%!");
                resp.sendRedirect(req.getContextPath() + "/admin/insurance");
                return;
            }

            // FIX: Validate base salary is positive
            if (baseSalary <= 0) {
                req.getSession().setAttribute("flash_error", "Mức lương cơ bản phải lớn hơn 0!");
                resp.sendRedirect(req.getContextPath() + "/admin/insurance");
                return;
            }

            // Kiểm tra số bảo hiểm đã tồn tại
            if (insuranceDAO.isInsuranceNumberExists(insuranceNumber, 0)) {
                req.getSession().setAttribute("flash_error", "Số bảo hiểm đã tồn tại!");
                resp.sendRedirect(req.getContextPath() + "/admin/insurance");
                return;
            }

            // Kiểm tra nhân viên đã có bảo hiểm chưa
            InsuranceConfig existing = insuranceDAO.getByEmployeeId(employeeId);
            if (existing != null) {
                req.getSession().setAttribute("flash_error", "Nhân viên này đã có cấu hình bảo hiểm!");
                resp.sendRedirect(req.getContextPath() + "/admin/insurance");
                return;
            }

            // Tạo mới
            InsuranceConfig config = new InsuranceConfig(
                    employeeId, insuranceNumber,
                    bhxhRate, bhytRate, bhtnRate,
                    baseSalary, isActive
            );

            if (insuranceDAO.create(config)) {
                req.getSession().setAttribute("flash_success", "Thêm cấu hình bảo hiểm thành công!");
            } else {
                req.getSession().setAttribute("flash_error", "Thêm cấu hình bảo hiểm thất bại!");
            }

        } catch (NumberFormatException e) {
            logger.warning("Invalid number format in create request: " + e.getMessage());
            req.getSession().setAttribute("flash_error", "Dữ liệu nhập không hợp lệ!");
        }

        resp.sendRedirect(req.getContextPath() + "/admin/insurance");
    }

    /**
     * Xử lý cập nhật bảo hiểm
     */
    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException, SQLException {

        try {
            int id = Integer.parseInt(req.getParameter("id"));

            // FIX: Added validation before parsing
            if (!validateInsuranceInput(req, id)) {
                resp.sendRedirect(req.getContextPath() + "/admin/insurance");
                return;
            }

            String insuranceNumber = req.getParameter("insuranceNumber").trim();
            double bhxhRate = Double.parseDouble(req.getParameter("bhxhRate"));
            double bhytRate = Double.parseDouble(req.getParameter("bhytRate"));
            double bhtnRate = Double.parseDouble(req.getParameter("bhtnRate"));
            double baseSalary = Double.parseDouble(req.getParameter("baseSalary"));
            boolean isActive = "1".equals(req.getParameter("isActive"));

            // FIX: Validate insurance rates
            if (bhxhRate < 0 || bhxhRate > 100 || bhytRate < 0 || bhytRate > 100 ||
                    bhtnRate < 0 || bhtnRate > 100) {
                req.getSession().setAttribute("flash_error", "Tỷ lệ bảo hiểm phải nằm trong khoảng 0-100%!");
                resp.sendRedirect(req.getContextPath() + "/admin/insurance");
                return;
            }

            // FIX: Validate base salary
            if (baseSalary <= 0) {
                req.getSession().setAttribute("flash_error", "Mức lương cơ bản phải lớn hơn 0!");
                resp.sendRedirect(req.getContextPath() + "/admin/insurance");
                return;
            }

            // Kiểm tra số bảo hiểm đã tồn tại (loại trừ record hiện tại)
            if (insuranceDAO.isInsuranceNumberExists(insuranceNumber, id)) {
                req.getSession().setAttribute("flash_error", "Số bảo hiểm đã tồn tại!");
                resp.sendRedirect(req.getContextPath() + "/admin/insurance");
                return;
            }

            // Cập nhật
            InsuranceConfig config = insuranceDAO.getById(id);
            if (config == null) {
                req.getSession().setAttribute("flash_error", "Không tìm thấy cấu hình bảo hiểm!");
                resp.sendRedirect(req.getContextPath() + "/admin/insurance");
                return;
            }

            config.setInsuranceNumber(insuranceNumber);
            config.setBhxhRate(bhxhRate);
            config.setBhytRate(bhytRate);
            config.setBhtnRate(bhtnRate);
            config.setBaseSalary(baseSalary);
            config.setActive(isActive);
            config.calculateAmounts();

            if (insuranceDAO.update(config)) {
                req.getSession().setAttribute("flash_success", "Cập nhật cấu hình bảo hiểm thành công!");
            } else {
                req.getSession().setAttribute("flash_error", "Cập nhật cấu hình bảo hiểm thất bại!");
            }

        } catch (NumberFormatException e) {
            logger.warning("Invalid number format in update request: " + e.getMessage());
            req.getSession().setAttribute("flash_error", "Dữ liệu nhập không hợp lệ!");
        }

        resp.sendRedirect(req.getContextPath() + "/admin/insurance");
    }

    /**
     * Xử lý xóa bảo hiểm
     */
    private void handleDelete(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException, SQLException {

        try {
            String idParam = req.getParameter("id");

            // FIX: Null check before parsing
            if (idParam == null || idParam.isEmpty()) {
                req.getSession().setAttribute("flash_error", "ID không hợp lệ!");
                resp.sendRedirect(req.getContextPath() + "/admin/insurance");
                return;
            }

            int id = Integer.parseInt(idParam);

            if (insuranceDAO.delete(id)) {
                req.getSession().setAttribute("flash_success", "Xóa cấu hình bảo hiểm thành công!");
            } else {
                req.getSession().setAttribute("flash_error", "Xóa cấu hình bảo hiểm thất bại!");
            }

        } catch (NumberFormatException e) {
            logger.warning("Invalid ID format in delete request: " + e.getMessage());
            req.getSession().setAttribute("flash_error", "Dữ liệu không hợp lệ!");
        }

        resp.sendRedirect(req.getContextPath() + "/admin/insurance");
    }

    /**
     * Xử lý thay đổi trạng thái hoạt động
     */
    private void handleToggle(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException, SQLException {

        try {
            String idParam = req.getParameter("id");

            // FIX: Null check before parsing
            if (idParam == null || idParam.isEmpty()) {
                req.getSession().setAttribute("flash_error", "ID không hợp lệ!");
                resp.sendRedirect(req.getContextPath() + "/admin/insurance");
                return;
            }

            int id = Integer.parseInt(idParam);
            boolean isActive = "1".equals(req.getParameter("isActive"));

            if (insuranceDAO.toggleActive(id, isActive)) {
                String status = isActive ? "Đang áp dụng" : "Đã dừng";
                req.getSession().setAttribute("flash_success", "Cập nhật trạng thái thành: " + status);
            } else {
                req.getSession().setAttribute("flash_error", "Cập nhật trạng thái thất bại!");
            }

        } catch (NumberFormatException e) {
            logger.warning("Invalid ID format in toggle request: " + e.getMessage());
            req.getSession().setAttribute("flash_error", "Dữ liệu không hợp lệ!");
        }

        resp.sendRedirect(req.getContextPath() + "/admin/insurance");
    }

    /**
     * Xử lý tạo loại bảo hiểm mới
     */
    private void handleCreateRate(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException, SQLException {
        try {
            String name        = req.getParameter("name");
            String code        = req.getParameter("code");
            String noteParam   = req.getParameter("note");
            double empRate     = Double.parseDouble(req.getParameter("employeeRate"));
            double empRate2    = Double.parseDouble(req.getParameter("employerRate"));
            boolean isActive   = "1".equals(req.getParameter("isActive"));

            if (name == null || name.trim().isEmpty() || code == null || code.trim().isEmpty()) {
                req.getSession().setAttribute("flash_error", "Tên và mã loại bảo hiểm không được trống!");
                resp.sendRedirect(req.getContextPath() + "/admin/insurance");
                return;
            }

            InsuranceDAO.InsuranceRateDTO rate = new InsuranceDAO.InsuranceRateDTO(
                    0, name.trim(), code.trim().toUpperCase(),
                    empRate, empRate2,
                    noteParam != null ? noteParam.trim() : "",
                    isActive
            );

            if (insuranceDAO.createRate(rate)) {
                req.getSession().setAttribute("flash_success", "Thêm loại bảo hiểm \"" + name.trim() + "\" thành công!");
            } else {
                req.getSession().setAttribute("flash_error", "Thêm loại bảo hiểm thất bại!");
            }
        } catch (NumberFormatException e) {
            req.getSession().setAttribute("flash_error", "Tỷ lệ % phải là số hợp lệ!");
        }
        resp.sendRedirect(req.getContextPath() + "/admin/insurance");
    }

    /**
     * Xử lý cập nhật tỷ lệ % của loại bảo hiểm
     */
    private void handleUpdateRate(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException, SQLException {
        try {
            int id          = Integer.parseInt(req.getParameter("id"));
            double empRate  = Double.parseDouble(req.getParameter("employeeRate"));
            double empRate2 = Double.parseDouble(req.getParameter("employerRate"));

            if (empRate < 0 || empRate > 100 || empRate2 < 0 || empRate2 > 100) {
                req.getSession().setAttribute("flash_error", "Tỷ lệ bảo hiểm phải nằm trong khoảng 0–100%!");
                resp.sendRedirect(req.getContextPath() + "/admin/insurance");
                return;
            }

            if (insuranceDAO.updateRate(id, empRate, empRate2)) {
                req.getSession().setAttribute("flash_success", "Cập nhật tỷ lệ bảo hiểm thành công!");
            } else {
                req.getSession().setAttribute("flash_error", "Cập nhật tỷ lệ thất bại!");
            }
        } catch (NumberFormatException e) {
            req.getSession().setAttribute("flash_error", "Dữ liệu nhập không hợp lệ!");
        }
        resp.sendRedirect(req.getContextPath() + "/admin/insurance");
    }

    /**
     * Xử lý xóa loại bảo hiểm
     */
    private void handleDeleteRate(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException, SQLException {
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            if (insuranceDAO.deleteRate(id)) {
                req.getSession().setAttribute("flash_success", "Xóa loại bảo hiểm thành công!");
            } else {
                req.getSession().setAttribute("flash_error", "Xóa loại bảo hiểm thất bại!");
            }
        } catch (NumberFormatException e) {
            req.getSession().setAttribute("flash_error", "ID không hợp lệ!");
        }
        resp.sendRedirect(req.getContextPath() + "/admin/insurance");
    }

    /**
     * Xử lý thay đổi trạng thái hoạt động của loại bảo hiểm
     */
    private void handleToggleRate(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException, SQLException {
        try {
            String idParam = req.getParameter("id");
            if (idParam == null || idParam.isEmpty()) {
                req.getSession().setAttribute("flash_error", "ID không hợp lệ!");
                resp.sendRedirect(req.getContextPath() + "/admin/insurance");
                return;
            }

            int id = Integer.parseInt(idParam);
            boolean isActive = "1".equals(req.getParameter("isActive"));

            if (insuranceDAO.toggleRateActive(id, isActive)) {
                String label = isActive ? "Đang áp dụng" : "Đã dừng";
                req.getSession().setAttribute("flash_success", "Đã cập nhật trạng thái: " + label);
            } else {
                req.getSession().setAttribute("flash_error", "Cập nhật trạng thái thất bại!");
            }
        } catch (NumberFormatException e) {
            logger.warning("Invalid ID format in handleToggleRate: " + e.getMessage());
            req.getSession().setAttribute("flash_error", "Dữ liệu không hợp lệ!");
        }
        resp.sendRedirect(req.getContextPath() + "/admin/insurance");
    }

    /**
     * FIX: Added validation method for insurance input
     * Validates that all required fields are present and in correct format
     *
     * @param req The servlet request
     * @param insuranceId The insurance ID being updated (-1 for new records)
     * @return true if all validations pass, false otherwise
     */
    private boolean validateInsuranceInput(HttpServletRequest req, int insuranceId) {
        String employeeId = req.getParameter("employeeId");
        String insuranceNumber = req.getParameter("insuranceNumber");
        String bhxhRate = req.getParameter("bhxhRate");
        String bhytRate = req.getParameter("bhytRate");
        String bhtnRate = req.getParameter("bhtnRate");
        String baseSalary = req.getParameter("baseSalary");

        // Check for null or empty required fields
        if (employeeId == null || employeeId.isEmpty()) {
            req.getSession().setAttribute("flash_error", "Vui lòng chọn nhân viên!");
            return false;
        }

        if (insuranceNumber == null || insuranceNumber.trim().isEmpty()) {
            req.getSession().setAttribute("flash_error", "Số bảo hiểm không được để trống!");
            return false;
        }

        // FIX: Validate insurance number format (example: XXX-XXX-XXX)
        if (!insuranceNumber.trim().matches("\\d{3}-\\d{3}-\\d{3}")) {
            req.getSession().setAttribute("flash_error", "Số bảo hiểm phải có định dạng: XXX-XXX-XXX!");
            return false;
        }

        if (bhxhRate == null || bhxhRate.isEmpty()) {
            req.getSession().setAttribute("flash_error", "Tỷ lệ BHXH không được để trống!");
            return false;
        }

        if (bhytRate == null || bhytRate.isEmpty()) {
            req.getSession().setAttribute("flash_error", "Tỷ lệ BHYT không được để trống!");
            return false;
        }

        if (bhtnRate == null || bhtnRate.isEmpty()) {
            req.getSession().setAttribute("flash_error", "Tỷ lệ BHTN không được để trống!");
            return false;
        }

        if (baseSalary == null || baseSalary.isEmpty()) {
            req.getSession().setAttribute("flash_error", "Mức lương cơ bản không được để trống!");
            return false;
        }

        // Try to parse numbers to ensure they're valid
        try {
            Double.parseDouble(bhxhRate);
            Double.parseDouble(bhytRate);
            Double.parseDouble(bhtnRate);
            Double.parseDouble(baseSalary);
        } catch (NumberFormatException e) {
            req.getSession().setAttribute("flash_error", "Tỷ lệ và lương phải là số!");
            return false;
        }

        return true;
    }
}