package com.hrm.project.dao;

import com.hrm.project.model.Department;
import java.util.List;

public interface DepartmentDAO {
    List<Department> getAllDepartments();
    boolean addDepartment(Department d);
    boolean updateDepartment(Department d);
}