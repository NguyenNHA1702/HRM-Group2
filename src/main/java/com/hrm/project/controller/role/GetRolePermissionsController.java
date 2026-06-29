package com.hrm.project.controller.role;

import com.google.gson.Gson;
import com.hrm.project.model.dtos.response.ModulePermissionDTO;
import com.hrm.project.service.RolePermissionService;
import com.hrm.project.service.impl.RolePermissionServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin/api/role-permissions")
public class GetRolePermissionsController extends HttpServlet {

    private final RolePermissionService rolePermissionService;
    private final Gson gson;

    public GetRolePermissionsController() {
        this.rolePermissionService = new RolePermissionServiceImpl();
        this.gson = new Gson();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Thiết lập kiểu dữ liệu trả về là JSON và hỗ trợ font UTF-8
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // Kiểm tra quyền Admin trước khi trả dữ liệu phân quyền
        HttpSession session = request.getSession(false);
        if (session == null || !"ADMIN".equals(session.getAttribute("roleGroup"))) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().write("{\"error\": \"Chỉ Admin mới có quyền truy cập thông tin phân quyền.\"}" );
            return;
        }

        String roleIdStr = request.getParameter("roleId");

        if (roleIdStr == null || roleIdStr.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\": \"Missing roleId parameter\"}");
            return;
        }

        try {
            int roleId = Integer.parseInt(roleIdStr);

            // Lấy danh sách ma trận quyền từ Service xử lý DB
            List<ModulePermissionDTO> permissions = rolePermissionService.getPermissionsByRoleId(roleId);

            // Chuyển đổi List Object trong Java thành chuỗi JSON text
            String jsonResponse = this.gson.toJson(permissions);

            // Xuất chuỗi JSON về lại phía giao diện Client (Javascript fetch)
            response.getWriter().write(jsonResponse);

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\": \"Invalid roleId format\"}");
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\": \"Internal server error: " + e.getMessage() + "\"}");
        }
    }
}