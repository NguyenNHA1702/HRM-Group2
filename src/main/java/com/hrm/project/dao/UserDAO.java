package com.hrm.project.dao;

import com.hrm.project.model.Department;
import com.hrm.project.model.Position;
import com.hrm.project.model.Role;
import com.hrm.project.model.UserAccount;
import java.util.List;

public interface UserDAO {
    UserAccount getUserById(int id);
    boolean updateProfile(UserAccount user);

    List<Department> getAllDepartments();
    List<Position> getAllPositions();
    List<Role> getAllRoles();
    UserAccount getUserForAdminUpdate(int id);
    boolean updateUserByAdmin(UserAccount user);
    boolean updateUserActiveStatus(int employeeId, boolean isActive);
    UserAccount getUserByEmail(String email);
    boolean updatePassword(int employeeId, String hashedPassword);
}
