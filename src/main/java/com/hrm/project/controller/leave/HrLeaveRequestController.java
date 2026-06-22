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

        request.setAttribute(
                "requests",
                leaveRequestService.getAllRequests());

        request.getRequestDispatcher(
                        "/WEB-INF/views/hr/leave-requests.jsp")
                .forward(request, response);
    }
}