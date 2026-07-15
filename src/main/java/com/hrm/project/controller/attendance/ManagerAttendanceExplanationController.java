package com.hrm.project.controller.attendance;

import com.hrm.project.model.AttendanceExplanation;
import com.hrm.project.service.AttendanceService;
import com.hrm.project.service.impl.AttendanceServiceImpl;
import com.hrm.project.dao.DepartmentDAO;
import com.hrm.project.dao.impl.DepartmentDAOImpl;
import com.hrm.project.dao.impl.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.List;
import java.util.logging.Logger;

/**
 * ManagerAttendanceExplanationController — Quản lý giải trình chấm công phía Manager
 * URL: GET  /manager-attendance-explanations
 *      POST /manager-attendance-explanations/action
 */
@WebServlet(urlPatterns = {"/manager-attendance-explanations", "/manager-attendance-explanations/action"})
public class ManagerAttendanceExplanationController extends HttpServlet {

    private static final Logger logger = Logger.getLogger(ManagerAttendanceExplanationController.class.getName());
    private static final int PAGE_SIZE = 10;

    private final AttendanceService attendanceService = new AttendanceServiceImpl();
    private final DepartmentDAO departmentDAO = new DepartmentDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        if (!isManager(session)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ Manager mới có quyền truy cập.");
            return;
        }

        int managerId = (Integer) session.getAttribute("employeeId");
        Integer departmentId = departmentDAO.getDepartmentIdByManagerId(managerId);

        if (departmentId == null) {
            req.setAttribute("noDepartment", true);
            req.getRequestDispatcher("/WEB-INF/views/manager/attendance-explanations.jsp")
                    .forward(req, resp);
            return;
        }

        int month = parseIntOrDefault(req.getParameter("month"), LocalDate.now().getMonthValue());
        int year = parseIntOrDefault(req.getParameter("year"), LocalDate.now().getYear());
        if (month < 1 || month > 12 || year < 2000 || year > 2100) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Tháng hoặc năm không hợp lệ.");
            return;
        }

        String statusFilter = req.getParameter("status");
        int page = parsePositiveInt(req.getParameter("page"), 1);

        if (statusFilter != null && statusFilter.isBlank()) statusFilter = null;

        try {
            int total      = attendanceService.countExplanations(departmentId, statusFilter);
            int totalPages = Math.max(1, (int) Math.ceil((double) total / PAGE_SIZE));
            if (page > totalPages) page = totalPages;

            List<AttendanceExplanation> explanations =
                    attendanceService.getExplanations(departmentId, statusFilter, page, PAGE_SIZE);

            boolean isDeptLocked = attendanceService.isDepartmentAttendanceLocked(departmentId, year, month);
            boolean isGlobalLocked = attendanceService.isAttendanceLocked(year, month);

            req.setAttribute("explanations", explanations);
            req.setAttribute("total", total);
            req.setAttribute("currentPage", page);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("statusFilter", statusFilter != null ? statusFilter : "");
            req.setAttribute("currentMonth", month);
            req.setAttribute("currentYear", year);
            req.setAttribute("isDeptLocked", isDeptLocked);
            req.setAttribute("isGlobalLocked", isGlobalLocked);
            req.setAttribute("noDepartment", false);

            req.getRequestDispatcher("/WEB-INF/views/manager/attendance-explanations.jsp")
                    .forward(req, resp);
        } catch (Exception e) {
            logger.severe("Error loading explanations: " + e.getMessage());
            req.getSession().setAttribute("flash_error", "Lỗi tải dữ liệu giải trình.");
            resp.sendRedirect(req.getContextPath() + "/manager-attendance-explanations");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        if (!isManager(session)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ Manager mới có quyền thực hiện.");
            return;
        }

        int managerId = (Integer) session.getAttribute("employeeId");
        Integer departmentId = departmentDAO.getDepartmentIdByManagerId(managerId);

        if (departmentId == null) {
            flash(session, "error", "Bạn không có phòng ban quản lý để thực hiện hành động này.");
            resp.sendRedirect(req.getContextPath() + "/manager-attendance-explanations");
            return;
        }

        String action        = req.getParameter("action");
        String idParam       = req.getParameter("id");
        String reviewComment = req.getParameter("reviewComment");
        
        int month = parseIntOrDefault(req.getParameter("month"), LocalDate.now().getMonthValue());
        int year = parseIntOrDefault(req.getParameter("year"), LocalDate.now().getYear());

        try {
            if ("lockDeptAttendance".equalsIgnoreCase(action)) {
                boolean ok = attendanceService.lockDepartmentAttendance(departmentId, year, month, managerId);
                flash(session, ok ? "success" : "error",
                        ok ? "Khóa chấm công phòng ban thành công tháng " + month + "/" + year
                           : "Không thể khóa chấm công phòng ban.");
                resp.sendRedirect(req.getContextPath() + "/manager-attendance-explanations?month=" + month + "&year=" + year);
                return;
            } else if ("unlockDeptAttendance".equalsIgnoreCase(action)) {
                // Kiểm tra xem hệ thống có bị khóa không
                if (attendanceService.isAttendanceLocked(year, month)) {
                    flash(session, "error", "Bảng công hệ thống đã bị khóa bởi HR. Không thể mở khóa ở cấp phòng ban.");
                } else {
                    boolean ok = attendanceService.unlockDepartmentAttendance(departmentId, year, month);
                    flash(session, ok ? "success" : "error",
                            ok ? "Mở khóa chấm công phòng ban thành công tháng " + month + "/" + year
                               : "Không thể mở khóa chấm công phòng ban.");
                }
                resp.sendRedirect(req.getContextPath() + "/manager-attendance-explanations?month=" + month + "&year=" + year);
                return;
            }

            if (idParam == null || idParam.isBlank()) {
                flash(session, "error", "ID giải trình không hợp lệ.");
                resp.sendRedirect(req.getContextPath() + "/manager-attendance-explanations");
                return;
            }

            long id = Long.parseLong(idParam.trim());
            AttendanceExplanation exp = attendanceService.getExplanationById(id);

            if (exp == null) {
                flash(session, "error", "Không tìm thấy giải trình.");
                resp.sendRedirect(req.getContextPath() + "/manager-attendance-explanations");
                return;
            }

            // Bảo mật: Xác nhận nhân viên của giải trình thuộc bộ phận của manager
            if (!isEmployeeInDepartment(exp.getEmployeeId(), departmentId)) {
                flash(session, "error", "Nhân viên không thuộc phòng ban bạn quản lý.");
                resp.sendRedirect(req.getContextPath() + "/manager-attendance-explanations");
                return;
            }

            // Kiểm tra trạng thái khóa chấm công (của phòng ban hoặc toàn hệ thống)
            boolean isLocked = attendanceService.isAttendanceLockedForEmployee(
                    exp.getEmployeeId(), exp.getAttendanceDate().getYear(), exp.getAttendanceDate().getMonthValue());
            if (isLocked) {
                flash(session, "error", "Tháng chấm công này đã bị khóa. Không thể duyệt hay từ chối giải trình.");
                resp.sendRedirect(req.getContextPath() + "/manager-attendance-explanations?month=" + month + "&year=" + year);
                return;
            }

            if ("approve".equalsIgnoreCase(action)) {
                boolean ok = attendanceService.reviewExplanation(id, "APPROVED", managerId,
                        reviewComment != null ? reviewComment.trim() : "");
                flash(session, ok ? "success" : "error",
                        ok ? "Đã chấp nhận giải trình. Trạng thái công của nhân viên đã được cập nhật thành Đủ công."
                           : "Không thể chấp nhận giải trình.");
            } else if ("reject".equalsIgnoreCase(action)) {
                if (reviewComment == null || reviewComment.trim().isEmpty()) {
                    flash(session, "error", "Vui lòng nhập lý do từ chối.");
                    resp.sendRedirect(req.getContextPath() + "/manager-attendance-explanations?month=" + month + "&year=" + year);
                    return;
                }
                boolean ok = attendanceService.reviewExplanation(id, "REJECTED", managerId,
                        reviewComment.trim());
                flash(session, ok ? "success" : "error",
                        ok ? "Đã từ chối giải trình." : "Không thể từ chối giải trình.");
            } else {
                flash(session, "error", "Hành động không hợp lệ.");
            }
        } catch (NumberFormatException e) {
            flash(session, "error", "ID giải trình không hợp lệ.");
        } catch (Exception e) {
            logger.severe("Error reviewing explanation: " + e.getMessage());
            flash(session, "error", "Lỗi xử lý giải trình: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/manager-attendance-explanations?month=" + month + "&year=" + year);
    }

    private boolean isManager(HttpSession session) {
        if (session == null) return false;
        String role = (String) session.getAttribute("roleGroup");
        return "MANAGER".equalsIgnoreCase(role);
    }

    private boolean isEmployeeInDepartment(int employeeId, int departmentId) {
        String sql = "SELECT 1 FROM employees WHERE id = ? AND department_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            ps.setInt(2, departmentId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private int parsePositiveInt(String value, int defaultValue) {
        if (value == null || value.isBlank()) return defaultValue;
        try {
            int v = Integer.parseInt(value.trim());
            return v > 0 ? v : defaultValue;
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private int parseIntOrDefault(String value, int defaultValue) {
        if (value == null || value.isBlank()) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private void flash(HttpSession session, String type, String message) {
        session.setAttribute("flash_" + type, message);
    }
}
