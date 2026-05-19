package com.hrm.project.service.impl;

import com.hrm.project.dao.RoleDAO;
import com.hrm.project.dao.impl.RoleDAOImpl;
import com.hrm.project.model.dtos.response.RoleWithCountDTO;
import com.hrm.project.service.RoleService;
import java.util.List;

public class RoleServiceImpl implements RoleService {

    // Khởi tạo trực tiếp đối tượng DAO do không sử dụng Dependency Injection của Spring
    private final RoleDAO roleDAO;

    public RoleServiceImpl() {
        this.roleDAO = new RoleDAOImpl();
    }

    @Override
    public List<RoleWithCountDTO> getAllRolesWithCount() {
        // Gọi xuống tầng DAO để lấy dữ liệu trực tiếp từ MySQL
        return roleDAO.getAllRolesWithCount();
    }

    @Override
    public boolean updateRole(int id, String name, String description) {
        if (name == null || name.trim().isEmpty()) {
            throw new IllegalArgumentException("Tên vai trò không được để trống.");
        }
        if (isRoleNameExists(name.trim(), id)) {
            throw new IllegalArgumentException("Tên vai trò đã tồn tại.");
        }
        return roleDAO.updateRole(id, name.trim(), description);
    }

    @Override
    public boolean toggleRoleStatus(int id, boolean isActive) {
        if (id == 1 && !isActive) {
            throw new IllegalArgumentException("Không thể vô hiệu hóa vai trò Admin mặc định.");
        }
        return roleDAO.toggleRoleStatus(id, isActive);
    }

    @Override
    public boolean isRoleNameExists(String name, int excludeId) {
        if (name == null || name.trim().isEmpty()) {
            return false;
        }
        return roleDAO.isRoleNameExists(name.trim(), excludeId);
    }
}