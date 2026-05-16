package com.hrm.project.service;

import com.hrm.project.model.dtos.response.RoleWithCountDTO;
import java.util.List;

public interface RoleService {
    /**
     * Nghiệp vụ lấy danh sách vai trò hệ thống kèm số lượng nhân sự tương ứng.
     * @return Danh sách các đối tượng RoleWithCountDTO phục vụ giao diện
     */
    List<RoleWithCountDTO> getAllRolesWithCount();
}