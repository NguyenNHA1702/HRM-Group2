package com.hrm.project.service;

import com.hrm.project.model.dtos.response.ModulePermissionDTO;
import java.util.List;

public interface RolePermissionService {
    /**
     * Nghiệp vụ lấy ma trận phân quyền chi tiết của từng module theo mã vai trò.
     * @param roleId Mã ID định danh của vai trò trong hệ thống
     * @return Danh sách ma trận quyền hạn ModulePermissionDTO
     */
    List<ModulePermissionDTO> getPermissionsByRoleId(int roleId);

    boolean savePermissions(int roleId, List<ModulePermissionDTO> permissions);
}