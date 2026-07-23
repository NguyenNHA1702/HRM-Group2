package com.hrm.project.controller.leave;

import com.hrm.project.service.LeaveRequestService;
import com.hrm.project.service.impl.LeaveRequestServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import java.io.IOException;

@WebServlet("/hr/leave-requests")
public class HrLeaveRequestController extends HttpServlet {

    private final LeaveRequestService leaveRequestService =
            new LeaveRequestServiceImpl();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String roleGroup = session != null ? (String) session.getAttribute("roleGroup") : null;
        Integer employeeId = session != null ? (Integer) session.getAttribute("employeeId") : null;

        java.util.List<com.hrm.project.model.LeaveRequest> requests;
        if ("MANAGER".equalsIgnoreCase(roleGroup) && employeeId != null) {
            requests = leaveRequestService.getRequestsForManager(employeeId);
        } else {
            requests = leaveRequestService.getAllRequests();
        }

        request.setAttribute(
                "requests",
                requests);

        request.getRequestDispatcher(
                        "/WEB-INF/views/hr/leave-requests.jsp")
                .forward(request, response);
    }
}