package com.hrm.project.service;

import com.hrm.project.model.Department;
import com.hrm.project.model.UserAccountDTO;
import java.util.List;

public interface DepartmentService {
    List<Department> getAllDepartments();
    boolean addDepartment(Department d);
    boolean updateDepartment(Department d);
    
    boolean deactivateDepartment(int id);
    boolean activateDepartment(int id);
    int countActiveEmployees(int departmentId);
    List<UserAccountDTO> getMembersByDepartment(int departmentId);
    boolean bulkTransferEmployees(int targetDepartmentId, List<Integer> employeeIds);
}