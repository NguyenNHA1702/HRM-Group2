package com.hrm.project.controller;

import com.hrm.project.dao.ScheduleDAO;
import com.hrm.project.dao.UserDAO;
import com.hrm.project.dao.WorkShiftDAO;
import com.hrm.project.dao.impl.ScheduleDAOImpl;
import com.hrm.project.dao.impl.UserDAOImpl;
import com.hrm.project.dao.impl.WorkShiftDAOImpl;
import com.hrm.project.model.Department;
import com.hrm.project.model.EmployeeSchedule;
import com.hrm.project.model.ScheduleHistory;
import com.hrm.project.model.UserAccount;
import com.hrm.project.model.WorkShift;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

@WebServlet(name = "ScheduleController", urlPatterns = {
        "/schedule/view",
        "/schedule/assign",
        "/schedule/update",
        "/schedule/employee",
        "/schedule/delete"
})
public class ScheduleController extends HttpServlet {

    private final ScheduleDAO scheduleDAO = new ScheduleDAOImpl();
    private final UserDAO userDAO = new UserDAOImpl();
    private final WorkShiftDAO workShiftDAO = new WorkShiftDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String path = req.getServletPath();
        HttpSession session = req.getSession();
        String roleGroup = (String) session.getAttribute("roleGroup");

        if (roleGroup == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            switch (path) {
                case "/schedule/view":
                    if (!"ADMIN".equals(roleGroup) && !"HR".equals(roleGroup) && !"MANAGER".equals(roleGroup)) {
                        resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập trang này.");
                        return;
                    }
                    handleViewSchedules(req, resp);
                    break;
                case "/schedule/assign":
                    if (!"ADMIN".equals(roleGroup) && !"HR".equals(roleGroup)) {
                        resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập trang này.");
                        return;
                    }
                    handleAssignForm(req, resp);
                    break;
                case "/schedule/update":
                    if (!"ADMIN".equals(roleGroup) && !"HR".equals(roleGroup)) {
                        resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập trang này.");
                        return;
                    }
                    handleUpdateForm(req, resp);
                    break;
                case "/schedule/employee":
                    handleEmployeeDashboard(req, resp);
                    break;
                default:
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("errorMessage", e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String path = req.getServletPath();
        HttpSession session = req.getSession();
        String roleGroup = (String) session.getAttribute("roleGroup");

        if (roleGroup == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            switch (path) {
                case "/schedule/assign":
                    if (!"ADMIN".equals(roleGroup) && !"HR".equals(roleGroup)) {
                        resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền thực hiện hành động này.");
                        return;
                    }
                    handlePostAssign(req, resp);
                    break;
                case "/schedule/update":
                    if (!"ADMIN".equals(roleGroup) && !"HR".equals(roleGroup)) {
                        resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền thực hiện hành động này.");
                        return;
                    }
                    handlePostUpdate(req, resp);
                    break;
                case "/schedule/delete":
                    if (!"ADMIN".equals(roleGroup) && !"HR".equals(roleGroup)) {
                        resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền thực hiện hành động này.");
                        return;
                    }
                    handlePostDelete(req, resp);
                    break;
                default:
                    resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                    break;
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("flash_error", "Đã xảy ra lỗi: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/schedule/view");
        }
    }

    private void handleViewSchedules(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException, SQLException {
        String keyword = req.getParameter("keyword");
        if (keyword == null) keyword = "";

        String deptIdStr = req.getParameter("departmentId");
        Integer departmentId = (deptIdStr != null && !deptIdStr.trim().isEmpty()) ? Integer.parseInt(deptIdStr.trim()) : null;

        String shiftIdStr = req.getParameter("workShiftId");
        Integer workShiftId = (shiftIdStr != null && !shiftIdStr.trim().isEmpty()) ? Integer.parseInt(shiftIdStr.trim()) : null;

        String startDate = req.getParameter("startDate");
        String endDate = req.getParameter("endDate");

        // Defaults to current month date range if not specified
        if ((startDate == null || startDate.isEmpty()) && (endDate == null || endDate.isEmpty())) {
            LocalDate today = LocalDate.now();
            startDate = today.withDayOfMonth(1).format(DateTimeFormatter.ISO_LOCAL_DATE);
            endDate = today.withDayOfMonth(today.lengthOfMonth()).format(DateTimeFormatter.ISO_LOCAL_DATE);
        }

        String pageStr = req.getParameter("page");
        int page = 1;
        if (pageStr != null && !pageStr.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageStr.trim());
                if (page < 1) page = 1;
            } catch (NumberFormatException e) {
                page = 1;
            }
        }

        String pageSizeStr = req.getParameter("pageSize");
        int pageSize = 10;
        if (pageSizeStr != null && !pageSizeStr.trim().isEmpty()) {
            try {
                pageSize = Integer.parseInt(pageSizeStr.trim());
                if (pageSize < 1) pageSize = 10;
            } catch (NumberFormatException e) {
                pageSize = 10;
            }
        }

        int totalRecords = scheduleDAO.getSchedulesCount(keyword, departmentId, workShiftId, startDate, endDate);
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;

        List<EmployeeSchedule> list = scheduleDAO.getSchedules(keyword, departmentId, workShiftId, startDate, endDate, page, pageSize);
        List<Department> departments = userDAO.getAllDepartments();
        List<WorkShift> shifts = workShiftDAO.getAllWorkShifts();

        // Top statistic counts
        int totalEmployees = userDAO.getAllEmployees().size();
        int assignedShifts = totalRecords;
        // Mock pending request count for demo
        int pendingRequests = 3; 
        int overtimeHours = 120;

        req.setAttribute("schedules", list);
        req.setAttribute("departments", departments);
        req.setAttribute("workShifts", shifts);
        req.setAttribute("page", page);
        req.setAttribute("pageSize", pageSize);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalRecords", totalRecords);
        req.setAttribute("keyword", keyword);
        req.setAttribute("departmentId", departmentId);
        req.setAttribute("workShiftId", workShiftId);
        req.setAttribute("startDate", startDate);
        req.setAttribute("endDate", endDate);

        req.setAttribute("statTotalEmployees", totalEmployees);
        req.setAttribute("statAssignedShifts", assignedShifts);
        req.setAttribute("statPendingRequests", pendingRequests);
        req.setAttribute("statOvertimeHours", overtimeHours);

        req.getRequestDispatcher("/WEB-INF/views/schedule/view.jsp").forward(req, resp);
    }

    private void handleAssignForm(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException, SQLException {
        List<UserAccount> employees = userDAO.getAllEmployees();
        List<WorkShift> shifts = workShiftDAO.getAllWorkShifts();

        String selectedEmpIdStr = req.getParameter("employeeId");
        if (selectedEmpIdStr != null && !selectedEmpIdStr.trim().isEmpty()) {
            int empId = Integer.parseInt(selectedEmpIdStr);
            UserAccount emp = userDAO.getUserDetailById(empId);
            req.setAttribute("selectedEmployee", emp);
        }

        req.setAttribute("employees", employees);
        req.setAttribute("workShifts", shifts);
        req.getRequestDispatcher("/WEB-INF/views/schedule/assign.jsp").forward(req, resp);
    }

    private void handlePostAssign(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession();
        String ctx = req.getContextPath();

        try {
            int employeeId = Integer.parseInt(req.getParameter("employeeId"));
            int workShiftId = Integer.parseInt(req.getParameter("workShiftId"));
            String dateStr = req.getParameter("scheduleDate");
            String notes = req.getParameter("notes");

            EmployeeSchedule schedule = new EmployeeSchedule();
            schedule.setEmployeeId(employeeId);
            schedule.setWorkShiftId(workShiftId);
            schedule.setScheduleDate(Date.valueOf(dateStr));
            schedule.setNotes(notes);

            if (scheduleDAO.assignSchedule(schedule)) {
                session.setAttribute("flash_success", "Phân lịch làm việc thành công!");
            } else {
                session.setAttribute("flash_error", "Có lỗi xảy ra khi phân lịch làm việc.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("flash_error", "Dữ liệu không hợp lệ: " + e.getMessage());
        }

        resp.sendRedirect(ctx + "/schedule/view");
    }

    private void handleUpdateForm(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int id = Integer.parseInt(req.getParameter("id"));
        EmployeeSchedule schedule = scheduleDAO.getScheduleById(id);
        if (schedule == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy lịch làm việc.");
            return;
        }

        List<WorkShift> shifts = workShiftDAO.getAllWorkShifts();
        List<ScheduleHistory> history = scheduleDAO.getHistoryByEmployee(schedule.getEmployeeId());

        req.setAttribute("schedule", schedule);
        req.setAttribute("workShifts", shifts);
        req.setAttribute("history", history);
        req.getRequestDispatcher("/WEB-INF/views/schedule/update.jsp").forward(req, resp);
    }

    private void handlePostUpdate(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession();
        String ctx = req.getContextPath();
        String changedBy = (String) session.getAttribute("fullName");
        if (changedBy == null) changedBy = "Hệ thống";

        try {
            int id = Integer.parseInt(req.getParameter("id"));
            int employeeId = Integer.parseInt(req.getParameter("employeeId"));
            int workShiftId = Integer.parseInt(req.getParameter("workShiftId"));
            String dateStr = req.getParameter("scheduleDate");
            String notes = req.getParameter("notes");
            String changeReason = req.getParameter("changeReason");

            EmployeeSchedule schedule = new EmployeeSchedule();
            schedule.setId(id);
            schedule.setEmployeeId(employeeId);
            schedule.setWorkShiftId(workShiftId);
            schedule.setScheduleDate(Date.valueOf(dateStr));
            schedule.setNotes(notes);

            if (scheduleDAO.updateSchedule(schedule, changedBy, changeReason)) {
                session.setAttribute("flash_success", "Cập nhật lịch làm việc thành công!");
            } else {
                session.setAttribute("flash_error", "Có lỗi xảy ra khi cập nhật lịch làm việc.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("flash_error", "Lỗi cập nhật: " + e.getMessage());
        }

        resp.sendRedirect(ctx + "/schedule/view");
    }

    private void handlePostDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession();
        String ctx = req.getContextPath();
        int id = Integer.parseInt(req.getParameter("id"));

        if (scheduleDAO.deleteSchedule(id)) {
            session.setAttribute("flash_success", "Đã xóa lịch làm việc thành công!");
        } else {
            session.setAttribute("flash_error", "Có lỗi xảy ra khi xóa lịch làm việc.");
        }

        resp.sendRedirect(ctx + "/schedule/view");
    }

    private void handleEmployeeDashboard(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        Integer employeeId = (Integer) session.getAttribute("employeeId");

        if (employeeId == null) {
            // Check if logged in employee id is present, if not fall back to a default (e.g. employee 1 for demonstration)
            employeeId = 1;
        }

        String yearMonth = req.getParameter("yearMonth");
        if (yearMonth == null || yearMonth.trim().isEmpty()) {
            yearMonth = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM"));
        }

        List<EmployeeSchedule> mySchedules = scheduleDAO.getEmployeeSchedulesForMonth(employeeId, yearMonth);
        List<ScheduleHistory> history = scheduleDAO.getHistoryByEmployee(employeeId);

        // Employee stats
        int totalWorkingDays = mySchedules.size();
        int overtimeHours = 0; // Mocked or logic
        double attendanceRate = 98.5; // Mocked rate

        req.setAttribute("mySchedules", mySchedules);
        req.setAttribute("history", history);
        req.setAttribute("yearMonth", yearMonth);
        req.setAttribute("totalWorkingDays", totalWorkingDays);
        req.setAttribute("overtimeHours", overtimeHours);
        req.setAttribute("attendanceRate", attendanceRate);

        req.getRequestDispatcher("/WEB-INF/views/schedule/employee.jsp").forward(req, resp);
    }
}
