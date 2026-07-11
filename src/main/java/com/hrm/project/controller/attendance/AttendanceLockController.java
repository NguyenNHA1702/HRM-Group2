package com.hrm.project.controller.attendance;

import com.hrm.project.dao.AttendanceDAO;
import com.hrm.project.dao.DepartmentDAO;
import com.hrm.project.dao.impl.AttendanceDAOImpl;
import com.hrm.project.dao.impl.DepartmentDAOImpl;
import com.hrm.project.model.Department;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * Chốt công theo phòng ban.
 * - Manager: chốt/mở công cho phòng ban mình
 * - HR: xem tổng quan, chốt/mở tất cả
 */
@WebServlet(name = "AttendanceLockController", urlPatterns = {"/admin/attendance/lock"})
public class AttendanceLockController extends HttpServlet {
    private AttendanceDAO attendanceDAO;
    private DepartmentDAO departmentDAO;

    @Override
    public void init() throws ServletException {
        attendanceDAO = new AttendanceDAOImpl();
        departmentDAO = new DepartmentDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String roleGroup = (String) session.getAttribute("roleGroup");

        int currentMonth = java.time.LocalDate.now().getMonthValue();
        int currentYear = java.time.LocalDate.now().getYear();

        String monthParam = request.getParameter("month");
        String yearParam = request.getParameter("year");
        int month = monthParam != null ? Integer.parseInt(monthParam) : currentMonth;
        int year = yearParam != null ? Integer.parseInt(yearParam) : currentYear;

        List<Department> departments = departmentDAO.getAllDepartments();
        List<Integer> lockedDeptIds = attendanceDAO.getLockedDepartmentIds(year, month);

        request.setAttribute("departments", departments);
        request.setAttribute("lockedDeptIds", lockedDeptIds);
        request.setAttribute("selectedMonth", month);
        request.setAttribute("selectedYear", year);
        request.setAttribute("roleGroup", roleGroup);

        request.getRequestDispatcher("/WEB-INF/views/admin/attendance-lock.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer employeeId = (Integer) session.getAttribute("employeeId");
        String roleGroup = (String) session.getAttribute("roleGroup");

        if (employeeId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Chỉ MANAGER và HR được chốt công
        if (!"MANAGER".equals(roleGroup) && !"HR".equals(roleGroup)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try {
            int month = Integer.parseInt(request.getParameter("month"));
            int year = Integer.parseInt(request.getParameter("year"));
            int departmentId = Integer.parseInt(request.getParameter("departmentId"));
            String action = request.getParameter("action"); // "lock" or "unlock"

            boolean success;
            if ("lock".equals(action)) {
                success = attendanceDAO.lockAttendanceByDepartment(year, month, departmentId, employeeId);
            } else {
                success = attendanceDAO.unlockAttendanceByDepartment(year, month, departmentId);
            }

            String status = success ? "success" : "error";
            response.sendRedirect(request.getContextPath() + "/admin/attendance/lock?month=" + month + "&year=" + year + "&" + status + "=true");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/attendance/lock?error=true");
        }
    }
}
