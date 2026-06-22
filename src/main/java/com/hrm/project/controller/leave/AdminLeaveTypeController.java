package com.hrm.project.controller.leave;

import com.hrm.project.model.LeaveType;
import com.hrm.project.service.LeaveTypeService;
import com.hrm.project.service.impl.LeaveTypeServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/leave-types")
public class AdminLeaveTypeController extends HttpServlet {

    private final LeaveTypeService leaveTypeService = new LeaveTypeServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Kiểm tra quyền ADMIN hoặc HR
        HttpSession session = request.getSession(false);
        if (session == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
        String roleGroup = (String) session.getAttribute("roleGroup");
        if (!"ADMIN".equals(roleGroup) && !"HR".equals(roleGroup)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String msg = request.getParameter("msg");
        if (msg != null) request.setAttribute("msg", msg);

        request.setAttribute("leaveTypes", leaveTypeService.getAll());
        request.getRequestDispatcher("/WEB-INF/views/admin/leave-types.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Kiểm tra quyền
        HttpSession session = request.getSession(false);
        if (session == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
        String roleGroup = (String) session.getAttribute("roleGroup");
        if (!"ADMIN".equals(roleGroup) && !"HR".equals(roleGroup)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        String redirectUrl = request.getContextPath() + "/admin/leave-types";

        try {
            if ("create".equals(action)) {
                LeaveType lt = buildFromRequest(request);
                lt.setActive(true); // mặc định khi tạo mới là active
                boolean ok = leaveTypeService.create(lt);
                response.sendRedirect(redirectUrl + "?msg=" + (ok ? "create_ok" : "error"));

            } else if ("update".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                LeaveType lt = buildFromRequest(request);
                lt.setId(id);
                boolean ok = leaveTypeService.update(lt);
                response.sendRedirect(redirectUrl + "?msg=" + (ok ? "update_ok" : "error"));

            } else if ("toggle".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                boolean ok = leaveTypeService.toggleStatus(id);
                response.sendRedirect(redirectUrl + "?msg=" + (ok ? "toggle_ok" : "error"));

            } else {
                response.sendRedirect(redirectUrl + "?msg=error");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(redirectUrl + "?msg=invalid_input");
        }
    }

    /** Đọc các trường form và tạo đối tượng LeaveType */
    private LeaveType buildFromRequest(HttpServletRequest request) {
        LeaveType lt = new LeaveType();
        lt.setCode(request.getParameter("code").trim().toUpperCase());
        lt.setName(request.getParameter("name").trim());

        String daysStr = request.getParameter("daysPerYear");
        if (daysStr != null && !daysStr.isBlank()) {
            lt.setDaysPerYear(Double.parseDouble(daysStr));
        } else {
            lt.setDaysPerYear(null); // Không giới hạn (unlimited)
        }

        lt.setPaid("on".equals(request.getParameter("isPaid")) || "true".equals(request.getParameter("isPaid")));
        lt.setDescription(request.getParameter("description") != null ? request.getParameter("description").trim() : "");
        return lt;
    }
}