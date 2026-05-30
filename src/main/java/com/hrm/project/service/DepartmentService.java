package com.hrm.project.service;

import com.hrm.project.model.Department;
import java.util.List;

public interface DepartmentService {
    List<Department> getAllDepartments();
    boolean addDepartment(Department d);
    boolean updateDepartment(Department d);
}