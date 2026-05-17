package com.hrm.project.dao.impl;

import com.hrm.project.dao.UserDAO;
import com.hrm.project.model.UserAccount;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserDAOImpl implements UserDAO {

    @Override
    public UserAccount getUserById(int id) {
        // Sử dụng VIEW xịn của nhóm để lấy đầy đủ thông tin
        String sql = "SELECT * FROM vw_my_profile WHERE employee_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    UserAccount user = new UserAccount();
                    user.setEmployeeId(rs.getInt("employee_id"));
                    user.setEmployeeCode(rs.getString("employee_code"));
                    user.setFullName(rs.getString("full_name"));
                    user.setAvatarUrl(rs.getString("avatar_url"));
                    user.setPhone(rs.getString("phone"));
                    user.setWorkEmail(rs.getString("work_email"));
                    user.setPersonalEmail(rs.getString("personal_email"));
                    user.setDepartmentName(rs.getString("department_name"));
                    user.setPositionName(rs.getString("position_name"));
                    user.setRoleName(rs.getString("role_name"));
                    user.setManagerName(rs.getString("manager_name"));
                    user.setStatus(rs.getString("status"));
                    return user;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public boolean updateProfile(UserAccount user) {
        // Cập nhật thông tin vào bảng employees
        String sql = "UPDATE employees SET full_name = ?, phone = ?, personal_email = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, user.getFullName());
            ps.setString(2, user.getPhone());
            ps.setString(3, user.getPersonalEmail());
            ps.setInt(4, user.getEmployeeId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public String getPasswordHashByEmployeeId(int employeeId) {
        String sql = "SELECT password_hash FROM user_accounts WHERE employee_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("password_hash");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updatePassword(int employeeId, String newPasswordHash) {
        String sql = "UPDATE user_accounts SET password_hash = ? WHERE employee_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newPasswordHash);
            ps.setInt(2, employeeId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
