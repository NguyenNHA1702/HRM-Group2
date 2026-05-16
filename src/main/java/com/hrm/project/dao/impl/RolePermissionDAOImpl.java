package com.hrm.project.dao.impl;

import com.hrm.project.dao.RolePermissionDAO;
import com.hrm.project.model.dtos.response.ModulePermissionDTO;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class RolePermissionDAOImpl implements RolePermissionDAO {

    // 1. HÀM ĐỌC DỮ LIỆU (Giữ nguyên bản chuẩn của Tiến)
    @Override
    public List<ModulePermissionDTO> getPermissionsByRoleId(int roleId) {
        List<ModulePermissionDTO> list = new ArrayList<>();

        String sql = "SELECT m.id AS module_id, m.name AS module_name, " +
                "       COALESCE(rp.can_view, 0) AS can_view, " +
                "       COALESCE(rp.can_create, 0) AS can_create, " +
                "       COALESCE(rp.can_edit, 0) AS can_edit, " +
                "       COALESCE(rp.can_delete, 0) AS can_delete " +
                "FROM modules m " +
                "LEFT JOIN role_permissions rp ON m.id = rp.module_id AND rp.role_id = ? " +
                "ORDER BY m.id ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roleId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ModulePermissionDTO dto = new ModulePermissionDTO();
                    dto.setModuleId(rs.getInt("module_id"));
                    dto.setModuleName(rs.getString("module_name"));

                    dto.setView(rs.getBoolean("can_view"));
                    dto.setCreate(rs.getBoolean("can_create"));
                    dto.setEdit(rs.getBoolean("can_edit"));
                    dto.setDelete(rs.getBoolean("can_delete"));

                    list.add(dto);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi truy vấn DAO: " + e.getMessage(), e);
        }
        return list;
    }

    // 2. HÀM GHI DỮ LIỆU MỚI (Tiến bổ sung đoạn này vào cuối file)
    @Override
    public boolean savePermissions(int roleId, List<ModulePermissionDTO> permissions) {
        String deleteSql = "DELETE FROM role_permissions WHERE role_id = ?";
        String insertSql = "INSERT INTO role_permissions (role_id, module_id, can_view, can_create, can_edit, can_delete) VALUES (?, ?, ?, ?, ?, ?)";

        // Mở kết nối mới và độc lập
        try (Connection conn = DBConnection.getConnection()) {
            // Tắt chế độ tự động lưu để kích hoạt cơ chế kiểm soát Transaction an toàn
            conn.setAutoCommit(false);

            // Bước A: Xóa sạch toàn bộ cấu hình quyền cũ của vai trò này
            try (PreparedStatement psDel = conn.prepareStatement(deleteSql)) {
                psDel.setInt(1, roleId);
                psDel.executeUpdate();
            }

            // Bước B: Duyệt qua mảng dữ liệu mới để gom lệnh nạp vào MySQL
            try (PreparedStatement psIns = conn.prepareStatement(insertSql)) {
                for (ModulePermissionDTO perm : permissions) {
                    psIns.setInt(1, roleId);
                    psIns.setInt(2, perm.getModuleId());

                    // Chuyển đổi dữ liệu kiểu boolean từ Java sang dạng số 1/0 tương ứng trong MySQL
                    psIns.setInt(3, perm.isView() ? 1 : 0);
                    psIns.setInt(4, perm.isCreate() ? 1 : 0);
                    psIns.setInt(5, perm.isEdit() ? 1 : 0);
                    psIns.setInt(6, perm.isDelete() ? 1 : 0);

                    psIns.addBatch(); // Cho lệnh vào hàng đợi trung gian
                }
                psIns.executeBatch(); // Kích nổ chạy đồng loạt loạt lệnh insert
            }

            // Nếu toàn bộ tiến trình trơn tru, chính thức lưu dữ liệu vĩnh viễn xuống ổ đĩa
            conn.commit();
            return true;

        } catch (SQLException e) {
            System.err.println(">>> LỖI nghiêm trọng khi cập nhật dữ liệu ma trận phân quyền!");
            e.printStackTrace();
            return false;
        }
    }
}