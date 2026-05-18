// UserDAO.java
package com.hrm.project.dao;

import com.hrm.project.model.UserAccountDTO;
import com.hrm.project.model.UserStatDTO;

import java.sql.SQLException;
import java.util.List;

public interface UserDAO {

    int findEmployeeIdByEmail(String email) throws SQLException;

    void createUser(String fullName, String email,
                    int roleId, String rawPassword) throws SQLException;

    List<UserAccountDTO> getUsers(String keyword,
                                  String roleGroup,
                                  String status) throws SQLException;

    UserStatDTO getStats() throws SQLException;

    List<Object[]> getRoleGroups() throws SQLException;

    void toggleActive(int userId, boolean active) throws SQLException;

    void forceResetPassword(int userId) throws SQLException;

    void deleteUser(int userId) throws SQLException;
}