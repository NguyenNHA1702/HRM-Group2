package com.hrm.project.service.impl;

import com.hrm.project.dao.DepartmentDAO;
import com.hrm.project.dao.impl.DepartmentDAOImpl;
import com.hrm.project.model.Department;
import com.hrm.project.service.DepartmentService;
import java.util.List;

public class DepartmentServiceImpl implements DepartmentService {

    // Gọi sang tầng DAO thông qua Interface
    private final DepartmentDAO departmentDAO = new DepartmentDAOImpl();

    @Override
    public List<Department> getAllDepartments() {
        return departmentDAO.getAllDepartments();
    }

    @Override
    public boolean addDepartment(Department d) {
        return departmentDAO.addDepartment(d);
    }

    @Override
    public boolean updateDepartment(Department d) {
        return departmentDAO.updateDepartment(d);
    }
}