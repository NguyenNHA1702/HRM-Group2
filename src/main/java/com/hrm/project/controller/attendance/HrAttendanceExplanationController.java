package com.hrm.project.controller.attendance;

import com.hrm.project.model.AttendanceExplanation;
import com.hrm.project.service.AttendanceService;
import com.hrm.project.service.impl.AttendanceServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.logging.Logger;

/**
 * HrAttendanceExplanationController — Quản lý giải trình chấm công phía HR
 * URL: GET  /hr/attendance-explanations
 *      POST /hr/attendance-explanations/action
 */
@WebServlet(urlPatterns = {"/hr/attendance-explanations", "/hr/attendance-explanations/action"})
public class HrAttendanceExplanationController extends HttpServlet {

    private static final Logger logger = Logger.getLogger(HrAttendanceExplanationController.class.getName());
    private static final int PAGE_SIZE = 10;

    private final AttendanceService attendanceService = new AttendanceServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        if (!isHr(session)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ HR mới có quyền truy cập.");
            return;
        }

        String statusFilter = req.getParameter("status");
        int page = parsePositiveInt(req.getParameter("page"), 1);

        if (statusFilter != null && statusFilter.isBlank()) statusFilter = null;

        try {
            int total      = attendanceService.countExplanations(statusFilter);
            int totalPages = Math.max(1, (int) Math.ceil((double) total / PAGE_SIZE));
            if (page > totalPages) page = totalPages;

            List<AttendanceExplanation> explanations =
                    attendanceService.getExplanations(statusFilter, page, PAGE_SIZE);

            req.setAttribute("explanations", explanations);
            req.setAttribute("total", total);
            req.setAttribute("currentPage", page);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("statusFilter", statusFilter != null ? statusFilter : "");

            req.getRequestDispatcher("/WEB-INF/views/hr/attendance-explanations.jsp")
                    .forward(req, resp);
        } catch (Exception e) {
            logger.severe("Error loading explanations: " + e.getMessage());
            req.getSession().setAttribute("flash_error", "Lỗi tải dữ liệu giải trình.");
            resp.sendRedirect(req.getContextPath() + "/hr/attendance-explanations");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        if (!isHr(session)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ HR mới có quyền thực hiện.");
            return;
        }

        String action       = req.getParameter("action");
        String idParam      = req.getParameter("id");
        String reviewComment = req.getParameter("reviewComment");
        int reviewedBy      = (Integer) session.getAttribute("employeeId");

        try {
            if (idParam == null || idParam.isBlank()) {
                flash(session, "error", "ID giải trình không hợp lệ.");
                resp.sendRedirect(req.getContextPath() + "/hr/attendance-explanations");
                return;
            }

            long id = Long.parseLong(idParam.trim());

            if ("approve".equalsIgnoreCase(action)) {
                boolean ok = attendanceService.reviewExplanation(id, "APPROVED", reviewedBy,
                        reviewComment != null ? reviewComment.trim() : "");
                flash(session, ok ? "success" : "error",
                        ok ? "Đã chấp nhận giải trình. Trạng thái công của nhân viên đã được cập nhật thành Đủ công."
                           : "Không thể chấp nhận giải trình.");
            } else if ("reject".equalsIgnoreCase(action)) {
                if (reviewComment == null || reviewComment.trim().isEmpty()) {
                    flash(session, "error", "Vui lòng nhập lý do từ chối.");
                    resp.sendRedirect(req.getContextPath() + "/hr/attendance-explanations");
                    return;
                }
                boolean ok = attendanceService.reviewExplanation(id, "REJECTED", reviewedBy,
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

        resp.sendRedirect(req.getContextPath() + "/hr/attendance-explanations");
    }

    private boolean isHr(HttpSession session) {
        if (session == null) return false;
        String role = (String) session.getAttribute("roleGroup");
        return "HR".equalsIgnoreCase(role);
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

    private void flash(HttpSession session, String type, String message) {
        session.setAttribute("flash_" + type, message);
    }
}
