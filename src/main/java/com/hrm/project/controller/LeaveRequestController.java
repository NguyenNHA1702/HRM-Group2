package com.hrm.project.controller;

import com.hrm.project.service.LeaveRequestService;
import com.hrm.project.service.LeaveTypeService;
import com.hrm.project.service.impl.LeaveRequestServiceImpl;
import com.hrm.project.service.impl.LeaveTypeServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import java.io.IOException;

@WebServlet("/nghi-phep")
public class LeaveRequestController extends HttpServlet {

    private final LeaveRequestService leaveRequestService =
            new LeaveRequestServiceImpl();

    private final LeaveTypeService leaveTypeService =
            new LeaveTypeServiceImpl();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        Integer employeeId =
                (Integer) request.getSession()
                        .getAttribute("employeeId");

        // Danh sách đơn của nhân viên
        request.setAttribute(
                "requests",
                leaveRequestService.getEmployeeRequests(employeeId));

        // Danh sách loại nghỉ — cần cho dropdown trong modal "Tạo đơn"
        request.setAttribute(
                "leaveTypes",
                leaveTypeService.getAll());

        request.getRequestDispatcher(
                        "/WEB-INF/views/employee/leave-request.jsp")
                .forward(request, response);
    }
}