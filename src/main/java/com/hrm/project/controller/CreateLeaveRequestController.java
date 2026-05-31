package com.hrm.project.controller;

import com.hrm.project.model.LeaveRequest;
import com.hrm.project.service.LeaveRequestService;
import com.hrm.project.service.LeaveTypeService;
import com.hrm.project.service.impl.LeaveRequestServiceImpl;
import com.hrm.project.service.impl.LeaveTypeServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import java.io.IOException;
import java.sql.Date;
import java.time.temporal.ChronoUnit;

@WebServlet("/nghi-phep/create")
public class CreateLeaveRequestController extends HttpServlet {

    private final LeaveRequestService leaveRequestService =
            new LeaveRequestServiceImpl();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        LeaveTypeService leaveTypeService =
                new LeaveTypeServiceImpl();

        request.setAttribute(
                "leaveTypes",
                leaveTypeService.getAll());

        request.getRequestDispatcher(
                        "/WEB-INF/views/employee/create-leave.jsp")
                .forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        Integer employeeId =
                (Integer) request.getSession()
                        .getAttribute("employeeId");

        int leaveTypeId =
                Integer.parseInt(request.getParameter("leaveTypeId"));

        Date startDate =
                Date.valueOf(request.getParameter("startDate"));

        Date endDate =
                Date.valueOf(request.getParameter("endDate"));

        String reason =
                request.getParameter("reason");

        long days =
                ChronoUnit.DAYS.between(
                        startDate.toLocalDate(),
                        endDate.toLocalDate()) + 1;

        LeaveRequest leaveRequest = new LeaveRequest();

        leaveRequest.setEmployeeId(employeeId);
        leaveRequest.setLeaveTypeId(leaveTypeId);
        leaveRequest.setStartDate(startDate);
        leaveRequest.setEndDate(endDate);
        leaveRequest.setTotalDays(days);
        leaveRequest.setReason(reason);

        leaveRequestService.createRequest(leaveRequest);

        response.sendRedirect(
                request.getContextPath() + "/nghi-phep");
    }
}