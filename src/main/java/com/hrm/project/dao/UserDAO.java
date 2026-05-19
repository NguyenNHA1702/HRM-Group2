package com.hrm.project.dao;

import com.hrm.project.model.UserAccount;
import com.hrm.project.model.Department;
import com.hrm.project.model.Position;
import com.hrm.project.model.Role;
import com.hrm.project.model.UserAccountDTO;
import com.hrm.project.model.UserStatDTO;

import java.sql.SQLException;
import java.util.List;

public interface UserDAO {
    UserAccount getUserById(int id);
    boolean updateProfile(UserAccount user);
    String getPasswordHashByEmployeeId(int employeeId);

    // Teammate's methods (main)
    int findEmployeeIdByEmail(String email) throws SQLException;
    void createUser(String fullName, String email, int roleId, String rawPassword) throws SQLException;
    List<UserAccountDTO> getUsers(String keyword, String roleGroup, String status) throws SQLException;
    UserStatDTO getStats() throws SQLException;
    List<Object[]> getRoleGroups() throws SQLException;
    void toggleActive(int userId, boolean active) throws SQLException;
    void forceResetPassword(int userId) throws SQLException;
    void deleteUser(int userId) throws SQLException;

    // Your methods (tung)
    List<Department> getAllDepartments();
    List<Position> getAllPositions();
    List<Role> getAllRoles();
    UserAccount getUserForAdminUpdate(int id);
    boolean updateUserByAdmin(UserAccount user);
    boolean updateUserActiveStatus(int employeeId, boolean isActive);
    UserAccount getUserByEmail(String email);
    boolean updatePassword(int employeeId, String hashedPassword);
    boolean isUserRoleActive(int employeeId);
}
