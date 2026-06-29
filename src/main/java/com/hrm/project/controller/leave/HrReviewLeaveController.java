package com.hrm.project.controller.leave;

import com.hrm.project.service.LeaveRequestService;
import com.hrm.project.service.impl.LeaveRequestServiceImpl;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import java.io.IOException;

@WebServlet("/hr/leave-request/action")
public class HrReviewLeaveController extends HttpServlet {

    private final LeaveRequestService leaveRequestService =
            new LeaveRequestServiceImpl();

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        int requestId =
                Integer.parseInt(request.getParameter("id"));

        String action =
                request.getParameter("action");

        Integer reviewerId =
                (Integer) request.getSession()
                        .getAttribute("employeeId");

        if ("approve".equals(action)) {

            leaveRequestService.approveRequest(
                    requestId,
                    reviewerId);

        } else if ("reject".equals(action)) {

            leaveRequestService.rejectRequest(
                    requestId,
                    reviewerId);
        }

        response.sendRedirect(
                request.getContextPath()
                        + "/hr/leave-requests");
    }
}