package com.hrm.project.controller.role;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.hrm.project.service.RoleService;
import com.hrm.project.service.impl.RoleServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.BufferedReader;
import java.io.IOException;

@WebServlet("/admin/api/roles/update")
public class AdminUpdateRoleController extends HttpServlet {

    private final RoleService roleService;
    private final Gson gson;

    public AdminUpdateRoleController() {
        this.roleService = new RoleServiceImpl();
        this.gson = new Gson();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Đặt encoding UTF-8 để xử lý đúng tiếng Việt trong tên và mô tả vai trò
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // Kiểm tra quyền Admin trước khi cho phép thao tác
        HttpSession session = request.getSession(false);
        if (session == null || !"ADMIN".equals(session.getAttribute("roleGroup"))) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().write("{\"error\": \"Chỉ Admin mới có quyền thực hiện thao tác này.\"}" );
            return;
        }

        try {
            StringBuilder sb = new StringBuilder();
            String line;
            try (BufferedReader reader = request.getReader()) {
                while ((line = reader.readLine()) != null) {
                    sb.append(line);
                }
            }

            if (sb.toString().trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\": \"Dữ liệu yêu cầu trống.\"}");
                return;
            }

            JsonObject payload = gson.fromJson(sb.toString(), JsonObject.class);
            int roleId = payload.get("roleId").getAsInt();
            String name = payload.get("name").getAsString();
            String description = payload.get("description").getAsString();

            boolean success = roleService.updateRole(roleId, name, description);

            if (success) {
                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().write("{\"status\": \"success\", \"message\": \"Cập nhật vai trò thành công!\"}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\": \"Lỗi lưu trữ: Không thể cập nhật vai trò.\"}");
            }
        } catch (IllegalArgumentException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\": \"" + e.getMessage() + "\"}");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\": \"Lỗi hệ thống: " + e.getMessage() + "\"}");
        }
    }
}
