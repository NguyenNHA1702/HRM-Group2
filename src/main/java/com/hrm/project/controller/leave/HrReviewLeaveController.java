package com.hrm.project.controller.leave;

import com.hrm.project.dao.DepartmentDAO;
import com.hrm.project.dao.impl.DepartmentDAOImpl;

import com.hrm.project.service.LeaveRequestService;
import com.hrm.project.service.impl.LeaveRequestServiceImpl;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/hr/leave-request/action")
public class HrReviewLeaveController extends HttpServlet {

    private final LeaveRequestService leaveRequestService = new LeaveRequestServiceImpl();
    private final DepartmentDAO departmentDAO = new DepartmentDAOImpl();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        String roleGroup = (String) session.getAttribute("roleGroup");
        Integer reviewerId = (Integer) session.getAttribute("employeeId");
        if (reviewerId == null || (!"HR".equals(roleGroup) && !"MANAGER".equals(roleGroup))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int requestId = Integer.parseInt(request.getParameter("id"));
        String action = request.getParameter("action");

        // If manager, ensure they operate within their department
        if ("MANAGER".equalsIgnoreCase(roleGroup)) {
            Integer managerDeptId = departmentDAO.getDepartmentIdByManagerId(reviewerId);
            // Retrieve the leave request to get employeeId
                        com.hrm.project.model.LeaveRequest leaveReq = leaveRequestService.getById(requestId);
            Integer employeeIdFromReq = (leaveReq != null) ? leaveReq.getEmployeeId() : null;
            // Simple check: ensure the employee belongs to manager's department via DAO
            List<com.hrm.project.model.UserAccountDTO> members = departmentDAO.getMembersByDepartment(managerDeptId);
            boolean allowed = false;
            if (employeeIdFromReq != null) {
                for (com.hrm.project.model.UserAccountDTO member : members) {
                    if (member.getId() == employeeIdFromReq) {
                        allowed = true;
                        break;
                    }
                }
            }

            if (!allowed) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Not authorized for this request");
                return;
            }
        }

        if ("approve".equals(action)) {
            leaveRequestService.approveRequest(requestId, reviewerId);
        } else if ("reject".equals(action)) {
            leaveRequestService.rejectRequest(requestId, reviewerId);
        }

        response.sendRedirect(request.getContextPath() + "/hr/leave-requests");
    }
}