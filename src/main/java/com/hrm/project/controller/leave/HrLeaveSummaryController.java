package com.hrm.project.controller.leave;

import com.hrm.project.model.Department;
import com.hrm.project.model.dtos.response.LeaveSummaryDto;
import com.hrm.project.service.DepartmentService;
import com.hrm.project.service.LeaveRequestService;
import com.hrm.project.service.impl.DepartmentServiceImpl;
import com.hrm.project.service.impl.LeaveRequestServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@WebServlet("/hr/leave-summary")
public class HrLeaveSummaryController extends HttpServlet {

    private final LeaveRequestService leaveRequestService = new LeaveRequestServiceImpl();
    private final DepartmentService departmentService = new DepartmentServiceImpl();

    /** Nhóm dữ liệu theo từng nhân viên để hiển thị dropdown */
    public static class EmployeeSummaryRow {
        private final int    employeeId;
        private final String employeeCode;
        private final String fullName;
        private final String departmentName;
        private final List<LeaveSummaryDto> leaveData;

        public EmployeeSummaryRow(int employeeId, String employeeCode,
                                  String fullName, String departmentName,
                                  List<LeaveSummaryDto> leaveData) {
            this.employeeId     = employeeId;
            this.employeeCode   = employeeCode;
            this.fullName       = fullName;
            this.departmentName = departmentName;
            this.leaveData      = leaveData;
        }

        public int    getEmployeeId()     { return employeeId; }
        public String getEmployeeCode()   { return employeeCode; }
        public String getFullName()       { return fullName; }
        public String getDepartmentName() { return departmentName; }
        public List<LeaveSummaryDto> getLeaveData() { return leaveData; }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
        String roleGroup = (String) session.getAttribute("roleGroup");
        Integer userId = (Integer) session.getAttribute("employeeId");
        if (!"HR".equals(roleGroup) && !"MANAGER".equals(roleGroup)) {
            response.sendRedirect(request.getContextPath() + "/login"); return;
        }

        // Parse filter params
        String fromStr = request.getParameter("fromDate");
        String toStr   = request.getParameter("toDate");
        String deptStr = request.getParameter("deptId");

        LocalDate today = LocalDate.now();
        Date fromDate = (fromStr != null && !fromStr.isBlank())
                ? Date.valueOf(fromStr) : Date.valueOf(today.withDayOfYear(1));
        Date toDate   = (toStr != null && !toStr.isBlank())
                ? Date.valueOf(toStr)   : Date.valueOf(today);

        Integer deptId = null;
        if (deptStr != null && !deptStr.isBlank()) {
            try { deptId = Integer.parseInt(deptStr); } catch (NumberFormatException ignored) {}
        }

        // Lấy dữ liệu phẳng
        List<LeaveSummaryDto> flat = leaveRequestService.getLeaveSummaryReport(fromDate, toDate, deptId, roleGroup, userId);

        // Group theo employee_id, giữ thứ tự
        Map<Integer, List<LeaveSummaryDto>> grouped = flat.stream()
                .collect(Collectors.groupingBy(
                        LeaveSummaryDto::getEmployeeId,
                        LinkedHashMap::new,
                        Collectors.toList()
                ));

        List<EmployeeSummaryRow> summaryRows = new ArrayList<>();
        for (Map.Entry<Integer, List<LeaveSummaryDto>> e : grouped.entrySet()) {
            LeaveSummaryDto first = e.getValue().get(0);
            summaryRows.add(new EmployeeSummaryRow(
                    e.getKey(),
                    first.getEmployeeCode(),
                    first.getFullName(),
                    first.getDepartmentName(),
                    e.getValue()
            ));
        }

        List<Department> departments = departmentService.getAllDepartments();

        request.setAttribute("summaryRows",   summaryRows);
        request.setAttribute("departments",   departments);
        request.setAttribute("fromDate",      fromDate.toString());
        request.setAttribute("toDate",        toDate.toString());
        request.setAttribute("selectedDeptId", deptId);

        request.getRequestDispatcher("/WEB-INF/views/hr/leave-summary.jsp")
                .forward(request, response);
    }
}
