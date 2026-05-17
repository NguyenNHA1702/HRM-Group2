package com.hrm.project.service;

import com.hrm.project.model.dtos.response.RoleWithCountDTO;
import java.util.List;

public interface RoleService {
    /**
     * Nghiệp vụ lấy danh sách vai trò hệ thống kèm số lượng nhân sự tương ứng.
     * @return Danh sách các đối tượng RoleWithCountDTO phục vụ giao diện
     */
    List<RoleWithCountDTO> getAllRolesWithCount();

    /**
     * Cập nhật thông tin vai trò chi tiết
     */
    boolean updateRole(int id, String name, String description, int groupId);

    /**
     * Kích hoạt hoặc vô hiệu hóa vai trò
     */
    boolean toggleRoleActive(int id, boolean isActive);

    /**
     * Tạo mới một vai trò
     */
    boolean createRole(String name, String description, int groupId);
}