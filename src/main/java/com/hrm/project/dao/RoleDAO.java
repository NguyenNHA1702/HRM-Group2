package com.hrm.project.dao;

import com.hrm.project.model.dtos.response.RoleWithCountDTO;
import java.util.List;

public interface RoleDAO {
    /**
     * Lấy toàn bộ danh sách vai trò (Roles) kèm số lượng người dùng thuộc vai trò đó
     * phục vụ cho việc hiển thị lên các thẻ Card ở giao diện Admin.
     * * @return Danh sách các đối tượng RoleWithCountDTO công khai
     */
    List<RoleWithCountDTO> getAllRolesWithCount();

    /**
     * Cập nhật thông tin vai trò chi tiết
     * @return true nếu thành công
     */
    boolean updateRole(int id, String name, String description, int groupId);

    /**
     * Kích hoạt hoặc vô hiệu hóa vai trò
     * @return true nếu thành công
     */
    boolean toggleRoleActive(int id, boolean isActive);

    /**
     * Tạo mới một vai trò
     * @return true nếu thành công
     */
    boolean createRole(String name, String description, int groupId);
}