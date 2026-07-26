package com.hrm.project.controller.role;

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
import javax.servlet.http.HttpSession;
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
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // Kiểm tra quyền Admin trước khi cho phép lưu ma trận phân quyền
        HttpSession session = request.getSession(false);
        if (session == null || !"ADMIN".equals(session.getAttribute("roleGroup"))) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().write("{\"error\": \"Chỉ Admin mới có quyền cấu hình phân quyền.\"}" );
            return;
        }

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
            if (jsonPayload == null || !jsonPayload.has("roleId") || !jsonPayload.has("permissions")) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                JsonObject errObj = new JsonObject();
                errObj.addProperty("error", "Dữ liệu JSON không đúng cấu trúc.");
                response.getWriter().write(gson.toJson(errObj));
                return;
            }

            int roleId = jsonPayload.get("roleId").getAsInt();
            JsonArray permsArray = jsonPayload.getAsJsonArray("permissions");

            // 3. Duyệt mảng JSON để bóc tách từng ô tích chọn đổi về List DTO trong Java
            List<ModulePermissionDTO> permissions = new ArrayList<>();
            if (permsArray != null) {
                for (JsonElement el : permsArray) {
                    if (el == null || !el.isJsonObject()) continue;
                    JsonObject obj = el.getAsJsonObject();
                    ModulePermissionDTO dto = new ModulePermissionDTO();

                    if (obj.has("moduleId") && !obj.get("moduleId").isJsonNull()) {
                        dto.setModuleId(obj.get("moduleId").getAsInt());
                    }

                    boolean view = getBooleanSafely(obj, "isView", "view");
                    boolean create = getBooleanSafely(obj, "isCreate", "create");
                    boolean edit = getBooleanSafely(obj, "isEdit", "edit");
                    boolean delete = getBooleanSafely(obj, "isDelete", "delete");

                    dto.setView(view);
                    dto.setCreate(create);
                    dto.setEdit(edit);
                    dto.setDelete(delete);

                    permissions.add(dto);
                }
            }

            // 4. Gọi Service thực thi xóa quyền cũ và chèn loạt quyền mới vào MySQL
            boolean success = rolePermissionService.savePermissions(roleId, permissions);

            // 5. Trả kết quả phản hồi về lại phía giao diện
            JsonObject resultObj = new JsonObject();
            if (success) {
                response.setStatus(HttpServletResponse.SC_OK);
                resultObj.addProperty("status", "success");
                resultObj.addProperty("message", "Cập nhật ma trận thành công!");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                resultObj.addProperty("error", "Lỗi hệ thống: Không thể ghi dữ liệu vào MySQL Server.");
            }
            response.getWriter().write(gson.toJson(resultObj));

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            JsonObject errObj = new JsonObject();
            errObj.addProperty("error", "Lỗi xử lý dữ liệu: " + (e.getMessage() != null ? e.getMessage() : e.getClass().getSimpleName()));
            response.getWriter().write(gson.toJson(errObj));
        }
    }

    private boolean getBooleanSafely(JsonObject obj, String... keys) {
        for (String key : keys) {
            if (obj.has(key) && !obj.get(key).isJsonNull()) {
                try {
                    return obj.get(key).getAsBoolean();
                } catch (Exception ignored) {}
            }
        }
        return false;
    }
}