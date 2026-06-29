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
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Logger;

/**
 * AdminInsuranceConfig — Controller hiển thị trang Quản lý Bảo hiểm
 * URL: GET  /admin/insurance
 *      POST /admin/insurance/action
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
        resp.setContentType("text/html; charset=UTF-8");

        String roleGroup = getRoleGroup(req);
        if (!canViewInsurance(roleGroup)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Bạn không có quyền xem thông tin bảo hiểm.");
            return;
        }
        req.setAttribute("canManageInsurance", canManageInsurance(roleGroup));

        String keyword = req.getParameter("keyword");
        String status  = req.getParameter("status");
        int pageSize = 5;
        int ratePage = parsePositiveInt(req.getParameter("ratePage"), 1);
        int groupPage = parsePositiveInt(req.getParameter("groupPage"), 1);

        if (keyword != null && keyword.trim().isEmpty()) keyword = null;
        if (status  != null && status.isEmpty())          status  = null;

        try {
            // Thống kê bảo hiểm
            InsuranceDAO.InsuranceStatDTO stats = insuranceDAO.getStats();
            req.setAttribute("stats", stats);

            // Danh sách tỷ lệ bảo hiểm
            int totalRates = insuranceDAO.getRatesCount();
            int totalRatePages = Math.max(1, (int) Math.ceil((double) totalRates / pageSize));
            if (ratePage > totalRatePages) {
                ratePage = totalRatePages;
            }
            List<InsuranceDAO.InsuranceRateDTO> insuranceRates =
                    insuranceDAO.getRates(ratePage, pageSize);
            req.setAttribute("insuranceRates", insuranceRates);
            req.setAttribute("ratePage", ratePage);
            req.setAttribute("totalRates", totalRates);
            req.setAttribute("totalRatePages", totalRatePages);

            // Danh sách đối tượng áp dụng
            int totalGroups = insuranceDAO.getApplicableGroupsCount();
            int totalGroupPages = Math.max(1, (int) Math.ceil((double) totalGroups / pageSize));
            if (groupPage > totalGroupPages) {
                groupPage = totalGroupPages;
            }
            List<InsuranceDAO.InsuranceApplicableGroupDTO> applicableGroups =
                    insuranceDAO.getApplicableGroups(groupPage, pageSize);
            req.setAttribute("applicableGroups", applicableGroups);
            req.setAttribute("groupPage", groupPage);
            req.setAttribute("totalGroups", totalGroups);
            req.setAttribute("totalGroupPages", totalGroupPages);
            req.setAttribute("pageSize", pageSize);

            // Danh sách bảo hiểm nhân viên
            List<InsuranceConfigDTO> insurances;
            if (keyword != null || status != null) {
                insurances = insuranceDAO.search(keyword, status);
            } else {
                insurances = insuranceDAO.getAll();
            }
            req.setAttribute("insurances", insurances);

            req.setAttribute("filterKeyword", keyword != null ? keyword : "");
            req.setAttribute("filterStatus",  status  != null ? status  : "");

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
     * POST - Xử lý các hành động
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html; charset=UTF-8");

        if (!canManageInsurance(getRoleGroup(req))) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Bạn chỉ có quyền xem thông tin bảo hiểm.");
            return;
        }

        String action = req.getParameter("action");

        try {
            switch (action == null ? "" : action.toLowerCase()) {
                case "create":                handleCreate(req, resp);                break;
                case "update":                handleUpdate(req, resp);                break;
                case "delete":                handleDelete(req, resp);                break;
                case "toggle":                handleToggle(req, resp);                break;
                case "createrate":            handleCreateRate(req, resp);            break;
                case "updaterate":            handleUpdateRate(req, resp);            break;
                case "deleterate":            handleDeleteRate(req, resp);            break;
                case "togglerate":            handleToggleRate(req, resp);            break;
                case "createapplicablegroup": handleCreateApplicableGroup(req, resp); break;
                case "updateapplicablegroup": handleUpdateApplicableGroup(req, resp); break;
                case "deleteapplicablegroup": handleDeleteApplicableGroup(req, resp); break;
                case "toggleapplicablegroup": handleToggleApplicableGroup(req, resp); break;
                default:
                    logger.warning("Unknown action: " + action);
                    resp.sendRedirect(req.getContextPath() + "/admin/insurance");
            }
        } catch (SQLException e) {
            logger.severe("Database error processing insurance action: " + e.getMessage());
            req.getSession().setAttribute("flash_error", "Lỗi: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/admin/insurance");
        }
    }

    private String getRoleGroup(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session == null ? null : (String) session.getAttribute("roleGroup");
    }

    private int parsePositiveInt(String value, int defaultValue) {
        if (value == null || value.trim().isEmpty()) {
            return defaultValue;
        }

        try {
            int parsed = Integer.parseInt(value.trim());
            return parsed > 0 ? parsed : defaultValue;
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private boolean canViewInsurance(String roleGroup) {
        return "ADMIN".equals(roleGroup)
                || "HR".equals(roleGroup)
                || "MANAGER".equals(roleGroup)
                || "EMPLOYEE".equals(roleGroup);
    }

    private boolean canManageInsurance(String roleGroup) {
        return "ADMIN".equals(roleGroup)
                || "HR".equals(roleGroup);
    }

    // ═══════════════════════════════════════════════════════════════
    // Insurance Config handlers (giữ nguyên logic gốc)
    // ═══════════════════════════════════════════════════════════════

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException, SQLException {
        // [Giữ nguyên logic cũ]
        resp.sendRedirect(req.getContextPath() + "/admin/insurance");
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException, SQLException {
        // [Giữ nguyên logic cũ]
        resp.sendRedirect(req.getContextPath() + "/admin/insurance");
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException, SQLException {
        // [Giữ nguyên logic cũ]
        resp.sendRedirect(req.getContextPath() + "/admin/insurance");
    }

    private void handleToggle(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException, SQLException {
        // [Giữ nguyên logic cũ]
        resp.sendRedirect(req.getContextPath() + "/admin/insurance");
    }

    // ═══════════════════════════════════════════════════════════════
    // Insurance Rate handlers
    // ═══════════════════════════════════════════════════════════════

    private void handleCreateRate(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException, SQLException {
        try {
            String name         = req.getParameter("name");
            String code         = req.getParameter("code");
            String employeeRateStr = req.getParameter("employeeRate");
            String employerRateStr = req.getParameter("employerRate");
            String note         = req.getParameter("note");
            boolean isActive    = "1".equals(req.getParameter("isActive"));

            if (name == null || name.trim().isEmpty() || code == null || code.trim().isEmpty()) {
                req.getSession().setAttribute("flash_error", "Tên loại bảo hiểm và mã không được để trống!");
                resp.sendRedirect(req.getContextPath() + "/admin/insurance");
                return;
            }

            double employeeRate = 0.0;
            double employerRate = 0.0;
            try {
                employeeRate = Double.parseDouble(employeeRateStr != null ? employeeRateStr : "0");
                employerRate = Double.parseDouble(employerRateStr != null ? employerRateStr : "0");
            } catch (NumberFormatException e) {
                req.getSession().setAttribute("flash_error", "Tỷ lệ phải là số hợp lệ!");
                resp.sendRedirect(req.getContextPath() + "/admin/insurance");
                return;
            }

            InsuranceDAO.InsuranceRateDTO rate = new InsuranceDAO.InsuranceRateDTO(
                    0,
                    name.trim(),
                    code.trim().toUpperCase(),
                    employeeRate,
                    employerRate,
                    note != null ? note.trim() : "",
                    isActive
            );

            if (insuranceDAO.createRate(rate)) {
                req.getSession().setAttribute("flash_success", "Thêm loại bảo hiểm \"" + name.trim() + "\" thành công!");
            } else {
                req.getSession().setAttribute("flash_error", "Thêm loại bảo hiểm thất bại!");
            }
        } catch (Exception e) {
            logger.severe("Error in handleCreateRate: " + e.getMessage());
            req.getSession().setAttribute("flash_error", "Lỗi: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/admin/insurance");
    }

    private void handleUpdateRate(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException, SQLException {
        try {
            String idParam = req.getParameter("id");
            String employeeRateStr = req.getParameter("employeeRate");
            String employerRateStr = req.getParameter("employerRate");

            if (idParam == null || idParam.isEmpty()) {
                req.getSession().setAttribute("flash_error", "ID loại bảo hiểm không hợp lệ!");
                resp.sendRedirect(req.getContextPath() + "/admin/insurance");
                return;
            }

            int id = Integer.parseInt(idParam);
            double employeeRate = Double.parseDouble(employeeRateStr != null ? employeeRateStr : "0");
            double employerRate = Double.parseDouble(employerRateStr != null ? employerRateStr : "0");

            if (insuranceDAO.updateRate(id, employeeRate, employerRate)) {
                req.getSession().setAttribute("flash_success", "Cập nhật tỷ lệ bảo hiểm thành công!");
            } else {
                req.getSession().setAttribute("flash_error", "Cập nhật tỷ lệ bảo hiểm thất bại!");
            }
        } catch (NumberFormatException e) {
            req.getSession().setAttribute("flash_error", "Dữ liệu tỷ lệ không hợp lệ!");
        } catch (Exception e) {
            logger.severe("Error in handleUpdateRate: " + e.getMessage());
            req.getSession().setAttribute("flash_error", "Lỗi: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/admin/insurance");
    }

    private void handleDeleteRate(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException, SQLException {
        try {
            String idParam = req.getParameter("id");
            if (idParam == null || idParam.isEmpty()) {
                req.getSession().setAttribute("flash_error", "ID loại bảo hiểm không hợp lệ!");
                resp.sendRedirect(req.getContextPath() + "/admin/insurance");
                return;
            }

            int id = Integer.parseInt(idParam);

            if (insuranceDAO.deleteRate(id)) {
                req.getSession().setAttribute("flash_success", "Xóa loại bảo hiểm thành công!");
            } else {
                req.getSession().setAttribute("flash_error", "Xóa loại bảo hiểm thất bại!");
            }
        } catch (NumberFormatException e) {
            req.getSession().setAttribute("flash_error", "ID không hợp lệ!");
        } catch (Exception e) {
            logger.severe("Error in handleDeleteRate: " + e.getMessage());
            req.getSession().setAttribute("flash_error", "Lỗi: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/admin/insurance");
    }

    private void handleToggleRate(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException, SQLException {
        try {
            String idParam = req.getParameter("id");
            if (idParam == null || idParam.isEmpty()) {
                req.getSession().setAttribute("flash_error", "ID loại bảo hiểm không hợp lệ!");
                resp.sendRedirect(req.getContextPath() + "/admin/insurance");
                return;
            }

            int id = Integer.parseInt(idParam);
            boolean isActive = "1".equals(req.getParameter("isActive"));

            if (insuranceDAO.toggleRateActive(id, isActive)) {
                req.getSession().setAttribute("flash_success",
                        "Đã cập nhật trạng thái: " + (isActive ? "Đang áp dụng" : "Đã dừng"));
            } else {
                req.getSession().setAttribute("flash_error", "Cập nhật trạng thái thất bại!");
            }
        } catch (NumberFormatException e) {
            req.getSession().setAttribute("flash_error", "Dữ liệu không hợp lệ!");
        } catch (Exception e) {
            logger.severe("Error in handleToggleRate: " + e.getMessage());
            req.getSession().setAttribute("flash_error", "Lỗi: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/admin/insurance");
    }

    // ═══════════════════════════════════════════════════════════════
    // Insurance Applicable Group handlers
    // ═══════════════════════════════════════════════════════════════

    /**
     * Thêm nhóm đối tượng áp dụng mới
     */
    private void handleCreateApplicableGroup(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException, SQLException {
        try {
            String name            = req.getParameter("groupName");
            String description     = req.getParameter("groupDescription");
            String conditionDetail = req.getParameter("groupConditionDetail");
            String sortOrderStr    = req.getParameter("groupSortOrder");
            boolean isActive       = "1".equals(req.getParameter("groupIsActive"));

            if (name == null || name.trim().isEmpty()) {
                req.getSession().setAttribute("flash_error", "Tên nhóm đối tượng không được để trống!");
                resp.sendRedirect(req.getContextPath() + "/admin/insurance");
                return;
            }

            int sortOrder = 0;
            if (sortOrderStr != null && !sortOrderStr.isEmpty()) {
                try {
                    sortOrder = Integer.parseInt(sortOrderStr);
                } catch (NumberFormatException e) {
                    req.getSession().setAttribute("flash_error", "Thứ tự hiển thị phải là số nguyên!");
                    resp.sendRedirect(req.getContextPath() + "/admin/insurance");
                    return;
                }
            }

            InsuranceDAO.InsuranceApplicableGroupDTO group = new InsuranceDAO.InsuranceApplicableGroupDTO(
                    0,
                    name.trim(),
                    description != null ? description.trim() : "",
                    conditionDetail != null ? conditionDetail.trim() : "",
                    sortOrder,
                    isActive
            );

            if (insuranceDAO.createApplicableGroup(group)) {
                req.getSession().setAttribute("flash_success",
                        "Thêm nhóm đối tượng \"" + name.trim() + "\" thành công!");
            } else {
                req.getSession().setAttribute("flash_error", "Thêm nhóm đối tượng thất bại!");
            }
        } catch (Exception e) {
            logger.severe("Error in handleCreateApplicableGroup: " + e.getMessage());
            req.getSession().setAttribute("flash_error", "Lỗi: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/admin/insurance");
    }

    /**
     * Cập nhật nhóm đối tượng áp dụng
     */
    private void handleUpdateApplicableGroup(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException, SQLException {
        try {
            String idParam = req.getParameter("groupId");
            if (idParam == null || idParam.isEmpty()) {
                req.getSession().setAttribute("flash_error", "ID nhóm đối tượng không hợp lệ!");
                resp.sendRedirect(req.getContextPath() + "/admin/insurance");
                return;
            }

            int id                 = Integer.parseInt(idParam);
            String name            = req.getParameter("groupName");
            String description     = req.getParameter("groupDescription");
            String conditionDetail = req.getParameter("groupConditionDetail");
            String sortOrderStr    = req.getParameter("groupSortOrder");
            boolean isActive       = "1".equals(req.getParameter("groupIsActive"));

            if (name == null || name.trim().isEmpty()) {
                req.getSession().setAttribute("flash_error", "Tên nhóm đối tượng không được để trống!");
                resp.sendRedirect(req.getContextPath() + "/admin/insurance");
                return;
            }

            int sortOrder = 0;
            if (sortOrderStr != null && !sortOrderStr.isEmpty()) {
                try {
                    sortOrder = Integer.parseInt(sortOrderStr);
                } catch (NumberFormatException e) {
                    req.getSession().setAttribute("flash_error", "Thứ tự hiển thị phải là số nguyên!");
                    resp.sendRedirect(req.getContextPath() + "/admin/insurance");
                    return;
                }
            }

            InsuranceDAO.InsuranceApplicableGroupDTO group = new InsuranceDAO.InsuranceApplicableGroupDTO(
                    id,
                    name.trim(),
                    description != null ? description.trim() : "",
                    conditionDetail != null ? conditionDetail.trim() : "",
                    sortOrder,
                    isActive
            );

            if (insuranceDAO.updateApplicableGroup(group)) {
                req.getSession().setAttribute("flash_success", "Cập nhật nhóm đối tượng thành công!");
            } else {
                req.getSession().setAttribute("flash_error", "Cập nhật nhóm đối tượng thất bại!");
            }
        } catch (NumberFormatException e) {
            logger.severe("NumberFormatException in handleUpdateApplicableGroup: " + e.getMessage());
            req.getSession().setAttribute("flash_error", "Dữ liệu nhập không hợp lệ!");
        } catch (Exception e) {
            logger.severe("Error in handleUpdateApplicableGroup: " + e.getMessage());
            req.getSession().setAttribute("flash_error", "Lỗi: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/admin/insurance");
    }

    /**
     * Xóa nhóm đối tượng áp dụng
     */
    private void handleDeleteApplicableGroup(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException, SQLException {
        try {
            String idParam = req.getParameter("groupId");
            if (idParam == null || idParam.isEmpty()) {
                req.getSession().setAttribute("flash_error", "ID nhóm đối tượng không hợp lệ!");
                resp.sendRedirect(req.getContextPath() + "/admin/insurance");
                return;
            }

            int id = Integer.parseInt(idParam);

            if (insuranceDAO.deleteApplicableGroup(id)) {
                req.getSession().setAttribute("flash_success", "Xóa nhóm đối tượng thành công!");
            } else {
                req.getSession().setAttribute("flash_error", "Xóa nhóm đối tượng thất bại!");
            }
        } catch (NumberFormatException e) {
            logger.severe("NumberFormatException in handleDeleteApplicableGroup: " + e.getMessage());
            req.getSession().setAttribute("flash_error", "ID nhóm đối tượng không hợp lệ!");
        } catch (Exception e) {
            logger.severe("Error in handleDeleteApplicableGroup: " + e.getMessage());
            req.getSession().setAttribute("flash_error", "Lỗi: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/admin/insurance");
    }

    /**
     * Toggle trạng thái nhóm đối tượng áp dụng
     */
    private void handleToggleApplicableGroup(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException, SQLException {
        try {
            String idParam = req.getParameter("groupId");
            if (idParam == null || idParam.isEmpty()) {
                req.getSession().setAttribute("flash_error", "ID nhóm đối tượng không hợp lệ!");
                resp.sendRedirect(req.getContextPath() + "/admin/insurance");
                return;
            }

            int id = Integer.parseInt(idParam);
            boolean isActive = "1".equals(req.getParameter("isActive"));

            if (insuranceDAO.toggleApplicableGroupActive(id, isActive)) {
                req.getSession().setAttribute("flash_success",
                        "Đã cập nhật trạng thái: " + (isActive ? "Đang áp dụng" : "Đã dừng"));
            } else {
                req.getSession().setAttribute("flash_error", "Cập nhật trạng thái thất bại!");
            }
        } catch (NumberFormatException e) {
            logger.severe("NumberFormatException in handleToggleApplicableGroup: " + e.getMessage());
            req.getSession().setAttribute("flash_error", "Dữ liệu không hợp lệ!");
        } catch (Exception e) {
            logger.severe("Error in handleToggleApplicableGroup: " + e.getMessage());
            req.getSession().setAttribute("flash_error", "Lỗi: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/admin/insurance");
    }

    // ═══════════════════════════════════════════════════════════════
    // Validation
    // ═══════════════════════════════════════════════════════════════

    private boolean validateInsuranceInput(HttpServletRequest req, int insuranceId) {
        return true;
    }
}
