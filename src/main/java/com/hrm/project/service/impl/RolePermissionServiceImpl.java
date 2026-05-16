package com.hrm.project.service.impl;

import com.hrm.project.dao.RolePermissionDAO;
import com.hrm.project.dao.impl.RolePermissionDAOImpl;
import com.hrm.project.model.dtos.response.ModulePermissionDTO;
import com.hrm.project.service.RolePermissionService;
import java.util.List;

public class RolePermissionServiceImpl implements RolePermissionService {

    private final RolePermissionDAO rolePermissionDAO = new RolePermissionDAOImpl();

    @Override
    public List<ModulePermissionDTO> getPermissionsByRoleId(int roleId) {
        return rolePermissionDAO.getPermissionsByRoleId(roleId);
    }

    // THÊM ĐOẠN NÀY: Bắn dữ liệu từ Controller xuống thẳng DAO
    @Override
    public boolean savePermissions(int roleId, List<ModulePermissionDTO> permissions) {
        return rolePermissionDAO.savePermissions(roleId, permissions);
    }
}