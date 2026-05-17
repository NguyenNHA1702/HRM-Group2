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
    public boolean updateRole(int id, String name, String description, int groupId) {
        return roleDAO.updateRole(id, name, description, groupId);
    }

    @Override
    public boolean toggleRoleActive(int id, boolean isActive) {
        return roleDAO.toggleRoleActive(id, isActive);
    }

    @Override
    public boolean createRole(String name, String description, int groupId) {
        return roleDAO.createRole(name, description, groupId);
    }
}