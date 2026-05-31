package com.hrm.project.controller;

import com.hrm.project.service.LeaveRequestService;
import com.hrm.project.service.impl.LeaveRequestServiceImpl;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import java.io.IOException;

@WebServlet("/nghi-phep/cancel")
public class CancelLeaveRequestController extends HttpServlet {

    private final LeaveRequestService leaveRequestService =
            new LeaveRequestServiceImpl();

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        int requestId =
                Integer.parseInt(request.getParameter("id"));

        leaveRequestService.cancelRequest(requestId);

        response.sendRedirect(
                request.getContextPath() + "/nghi-phep");
    }
}