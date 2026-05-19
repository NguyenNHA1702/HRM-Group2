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

    boolean updateRole(int id, String name, String description);

    boolean toggleRoleStatus(int id, boolean isActive);

    boolean isRoleNameExists(String name, int excludeId);
}