package com.hrm.project.controller;

import com.hrm.project.model.LeaveBalance;
import com.hrm.project.model.LeaveType;
import com.hrm.project.model.UserAccount;
import com.hrm.project.dao.UserDAO;
import com.hrm.project.dao.impl.UserDAOImpl;
import com.hrm.project.service.LeaveBalanceService;
import com.hrm.project.service.LeaveTypeService;
import com.hrm.project.service.impl.LeaveBalanceServiceImpl;
import com.hrm.project.service.impl.LeaveTypeServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.LinkedHashMap;
import java.util.stream.Collectors;

@WebServlet("/hr/leave-balance")
public class HrLeaveBalanceController extends HttpServlet {

    private final LeaveBalanceService leaveBalanceService =
            new LeaveBalanceServiceImpl();

    private final LeaveTypeService leaveTypeService =
            new LeaveTypeServiceImpl();

    private final UserDAO userDAO = new UserDAOImpl();

    public static class EmployeeBalanceRow {
        private int employeeId;
        private String employeeName;
        private List<LeaveBalance> balances;

        public EmployeeBalanceRow(int employeeId, String employeeName, List<LeaveBalance> balances) {
            this.employeeId = employeeId;
            this.employeeName = employeeName;
            this.balances = balances;
        }

        public int getEmployeeId() {
            return employeeId;
        }

        public String getEmployeeName() {
            return employeeName;
        }

        public List<LeaveBalance> getBalances() {
            return balances;
        }
    }

    /* ─── GET: Hiển thị danh sách quỹ phép ─── */
    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        // Kiểm tra quyền HR
        HttpSession session = request.getSession(false);
        if (session == null || !"HR".equals(session.getAttribute("roleGroup"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<LeaveBalance> balances   = leaveBalanceService.getAll();
        List<LeaveType>    leaveTypes = leaveTypeService.getAll();
        List<UserAccount>  employees;
        try {
            employees = userDAO.getAllEmployees();
        } catch (Exception e) {
            employees = new java.util.ArrayList<>();
        }

        // Group by employee
        Map<Integer, List<LeaveBalance>> grouped = balances.stream()
                .collect(Collectors.groupingBy(
                        LeaveBalance::getEmployeeId,
                        LinkedHashMap::new,
                        Collectors.toList()
                ));

        List<EmployeeBalanceRow> balanceRows = new ArrayList<>();
        for (Map.Entry<Integer, List<LeaveBalance>> entry : grouped.entrySet()) {
            String empName = entry.getValue().get(0).getEmployeeName();
            balanceRows.add(new EmployeeBalanceRow(entry.getKey(), empName, entry.getValue()));
        }

        request.setAttribute("balanceRows", balanceRows);
        request.setAttribute("leaveTypes",  leaveTypes);
        request.setAttribute("employees",   employees);

        String msg = request.getParameter("msg");
        if (msg != null) request.setAttribute("msg", msg);

        request.getRequestDispatcher(
                        "/WEB-INF/views/hr/leave-balance.jsp")
                .forward(request, response);
    }

    /* ─── POST: Xử lý các action ─── */
    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // Kiểm tra quyền HR
        HttpSession session = request.getSession(false);
        if (session == null || !"HR".equals(session.getAttribute("roleGroup"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        String redirectUrl = request.getContextPath() + "/hr/leave-balance";

        if ("update".equals(action)) {
            // ── Chỉnh sửa quỹ phép ──
            try {
                int    id            = Integer.parseInt(request.getParameter("id"));
                double usedDays      = Double.parseDouble(request.getParameter("usedDays"));
                double remainingDays = Double.parseDouble(request.getParameter("remainingDays"));

                boolean ok = leaveBalanceService.updateBalance(id, usedDays, remainingDays);
                response.sendRedirect(redirectUrl + "?msg=" + (ok ? "update_ok" : "update_fail"));

            } catch (NumberFormatException e) {
                response.sendRedirect(redirectUrl + "?msg=invalid_input");
            }

        } else if ("reset".equals(action)) {
            // ── Reset toàn bộ quỹ phép đầu năm ──
            int rows = leaveBalanceService.resetAll();
            response.sendRedirect(redirectUrl + "?msg=" + (rows > 0 ? "reset_ok" : "reset_fail"));

        } else if ("create".equals(action)) {
            // ── Thêm quỹ phép mới cho nhân viên ──
            try {
                int    employeeId  = Integer.parseInt(request.getParameter("employeeId"));
                int    leaveTypeId = Integer.parseInt(request.getParameter("leaveTypeId"));
                double totalDays   = Double.parseDouble(request.getParameter("totalDays"));

                if (leaveBalanceService.exists(employeeId, leaveTypeId)) {
                    response.sendRedirect(redirectUrl + "?msg=duplicate");
                    return;
                }

                boolean ok = leaveBalanceService.create(employeeId, leaveTypeId, totalDays);
                response.sendRedirect(redirectUrl + "?msg=" + (ok ? "create_ok" : "create_fail"));

            } catch (NumberFormatException e) {
                response.sendRedirect(redirectUrl + "?msg=invalid_input");
            }

        } else {
            response.sendRedirect(redirectUrl);
        }
    }
}
