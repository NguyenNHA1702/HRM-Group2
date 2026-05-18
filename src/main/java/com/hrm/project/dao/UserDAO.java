package com.hrm.project.dao;

import com.hrm.project.model.UserAccount;

public interface UserDAO {
    UserAccount getUserById(int id);
    boolean updateProfile(UserAccount user);
    String getPasswordHashByEmployeeId(int employeeId);

    List<Department> getAllDepartments();
    List<Position> getAllPositions();
    List<Role> getAllRoles();
    UserAccount getUserForAdminUpdate(int id);
    boolean updateUserByAdmin(UserAccount user);
    boolean updateUserActiveStatus(int employeeId, boolean isActive);
    UserAccount getUserByEmail(String email);
    boolean updatePassword(int employeeId, String hashedPassword);
}
