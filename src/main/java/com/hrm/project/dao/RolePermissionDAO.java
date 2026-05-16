package com.hrm.project.dao;

import com.hrm.project.model.dtos.response.ModulePermissionDTO;
import java.util.List;

public interface RolePermissionDAO {
    /**
     * Lấy danh sách toàn bộ các module và quyền tương ứng (Xem/Tạo/Sửa/Xóa) của một vai trò cụ thể.
     * Nếu module chưa từng được cấu hình quyền cho vai trò đó, giá trị mặc định trả về sẽ là false (0).
     * * @param roleId ID của vai trò cần tra cứu quyền hạn
     * @return Danh sách các bản ghi ma trận ModulePermissionDTO
     */
    List<ModulePermissionDTO> getPermissionsByRoleId(int roleId);

    boolean savePermissions(int roleId, List<ModulePermissionDTO> permissions);
}