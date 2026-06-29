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

@WebServlet("/admin/api/roles/toggle")
public class AdminToggleRoleActiveController extends HttpServlet {

    private final RoleService roleService;
    private final Gson gson;

    public AdminToggleRoleActiveController() {
        this.roleService = new RoleServiceImpl();
        this.gson = new Gson();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Đặt encoding UTF-8 để xử lý đúng tiếng Việt
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // Kiểm tra quyền Admin trước khi cho phép thao tác
        HttpSession session = request.getSession(false);
        if (session == null || !"ADMIN".equals(session.getAttribute("roleGroup"))) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().write("{\"error\": \"Chỉ Admin mới có quyền thay đổi trạng thái vai trò.\"}" );
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
            boolean isActive = payload.get("isActive").getAsBoolean();

            boolean success = roleService.toggleRoleStatus(roleId, isActive);

            if (success) {
                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().write("{\"status\": \"success\", \"message\": \"Thay đổi trạng thái vai trò thành công!\"}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\": \"Lỗi lưu trữ: Không thể thay đổi trạng thái vai trò.\"}");
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
