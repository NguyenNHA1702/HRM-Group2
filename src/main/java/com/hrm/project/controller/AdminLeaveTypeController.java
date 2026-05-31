package com.hrm.project.controller;

import com.hrm.project.service.LeaveTypeService;
import com.hrm.project.service.impl.LeaveTypeServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import java.io.IOException;

@WebServlet("/admin/leave-types")
public class AdminLeaveTypeController extends HttpServlet {

    private final LeaveTypeService leaveTypeService =
            new LeaveTypeServiceImpl();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setAttribute(
                "leaveTypes",
                leaveTypeService.getAll());

        request.getRequestDispatcher(
                        "/WEB-INF/views/admin/leave-types.jsp")
                .forward(request, response);
    }
}