package com.hrm.project.controller;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.hrm.project.model.dtos.response.ModulePermissionDTO;
import com.hrm.project.service.RolePermissionService;
import com.hrm.project.service.impl.RolePermissionServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

// Đường dẫn API nhận lệnh POST từ nút "Lưu thay đổi" ngoài giao diện JSP
@WebServlet("/admin/api/role-permissions/save")
public class SaveRolePermissionsController extends HttpServlet {

    private final RolePermissionService rolePermissionService;
    private final Gson gson;

    public SaveRolePermissionsController() {
        this.rolePermissionService = new RolePermissionServiceImpl();
        this.gson = new Gson();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Thiết lập kiểu trả về là JSON và hỗ trợ tiếng Việt
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            // 1. Đọc toàn bộ dữ liệu chuỗi JSON thô (Payload) do Fetch API truyền lên
            StringBuilder sb = new StringBuilder();
            String line;
            try (BufferedReader reader = request.getReader()) {
                while ((line = reader.readLine()) != null) {
                    sb.append(line);
                }
            }

            // Kiểm tra nếu dữ liệu truyền lên trống
            if (sb.toString().trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\": \"Dữ liệu yêu cầu trống (Empty body)\"}");
                return;
            }

            // 2. Phân tích chuỗi JSON thô thành đối tượng JsonObject của Gson
            JsonObject jsonPayload = gson.fromJson(sb.toString(), JsonObject.class);
            int roleId = jsonPayload.get("roleId").getAsInt();
            JsonArray permsArray = jsonPayload.getAsJsonArray("permissions");

            // 3. Duyệt mảng JSON để bóc tách từng ô tích chọn đổi về List DTO trong Java
            List<ModulePermissionDTO> permissions = new ArrayList<>();
            for (JsonElement el : permsArray) {
                JsonObject obj = el.getAsJsonObject();
                ModulePermissionDTO dto = new ModulePermissionDTO();

                dto.setModuleId(obj.get("moduleId").getAsInt());

                // Hỗ trợ đọc cả hai kiểu đặt tên 'isView' hoặc 'view' để tuyệt đối không bị dính null/false ngầm
                boolean view = obj.has("isView") ? obj.get("isView").getAsBoolean() : obj.get("view").getAsBoolean();
                boolean create = obj.has("isCreate") ? obj.get("isCreate").getAsBoolean() : obj.get("create").getAsBoolean();
                boolean edit = obj.has("isEdit") ? obj.get("isEdit").getAsBoolean() : obj.get("edit").getAsBoolean();
                boolean delete = obj.has("isDelete") ? obj.get("isDelete").getAsBoolean() : obj.get("delete").getAsBoolean();

                dto.setView(view);
                dto.setCreate(create);
                dto.setEdit(edit);
                dto.setDelete(delete);

                permissions.add(dto);
            }

            // 4. Gọi Service thực thi xóa quyền cũ và chèn loạt quyền mới vào MySQL
            boolean success = rolePermissionService.savePermissions(roleId, permissions);

            // 5. Trả kết quả phản hồi về lại phía giao diện
            if (success) {
                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().write("{\"status\": \"success\", \"message\": \"Cập nhật ma trận thành công!\"}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\": \"Lỗi hệ thống: Không thể ghi dữ liệu vào MySQL Server.\"}");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\": \"Lỗi xử lý dữ liệu: " + e.getMessage() + "\"}");
        }
    }
}