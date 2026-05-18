// UserDAOImpl.java
package com.hrm.project.dao.impl;

import com.hrm.project.dao.UserDAO;
import com.hrm.project.model.UserAccount;
import com.hrm.project.model.UserAccountDTO;
import com.hrm.project.model.UserStatDTO;
import com.hrm.project.util.DBUtil;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserDAOImpl implements UserDAO {

    // -------------------------------------------------------------------------
    // Admin: CRUD user accounts
    // -------------------------------------------------------------------------

    @Override
    public int findEmployeeIdByEmail(String email) throws SQLException {
        String sql = "SELECT id FROM employees WHERE work_email = ? OR personal_email = ? LIMIT 1";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt("id") : -1;
            }
        }
    }

    private int createMinimalEmployee(String fullName, String email) throws SQLException {
        String empCode = "EMP" + (System.currentTimeMillis() % 10_000_000_000L);

        String sql = "INSERT INTO employees"
                + " (employee_code, full_name, personal_email, hire_date, status)"
                + " VALUES (?, ?, ?, CURDATE(), 'ACTIVE')";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, empCode);
            ps.setString(2, fullName);
            ps.setString(3, email);
            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
                throw new SQLException("Khong lay duoc ID nhan vien vua tao.");
            }
        }
    }

    @Override
    public void createUser(String fullName, String email,
                           int roleId, String rawPassword) throws SQLException {

        int employeeId = findEmployeeIdByEmail(email);
        if (employeeId == -1) {
            employeeId = createMinimalEmployee(fullName, email);
        }

        String checkSql = "SELECT COUNT(*) FROM user_accounts WHERE username = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(checkSql)) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    throw new SQLException("Tai khoan voi email nay da ton tai.");
                }
            }
        }

        String sql = "INSERT INTO user_accounts"
                + " (employee_id, username, password_hash, role_id, is_active, force_reset_pwd)"
                + " VALUES (?, ?, ?, ?, 1, 0)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, employeeId);
            ps.setString(2, email);
            ps.setString(3, hashPassword(rawPassword));
            ps.setInt(4, roleId);
            ps.executeUpdate();
        }
    }

    @Override
    public List<UserAccountDTO> getUsers(String keyword,
                                         String roleGroup,
                                         String status) throws SQLException {

        StringBuilder sql = new StringBuilder(
                "SELECT ua.id," +
                        " ua.username," +
                        " ua.is_active," +
                        " ua.last_login_at," +
                        " ua.force_reset_pwd," +
                        " e.full_name," +
                        " e.employee_code," +
                        " r.name AS role_name," +
                        " rg.code AS role_group_code" +
                        " FROM user_accounts ua" +
                        " JOIN roles r ON r.id = ua.role_id" +
                        " JOIN role_groups rg ON rg.id = r.group_id" +
                        " LEFT JOIN employees e ON e.id = ua.employee_id" +
                        " WHERE 1 = 1"
        );

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (ua.username LIKE ? OR e.full_name LIKE ?)");
            params.add("%" + keyword.trim() + "%");
            params.add("%" + keyword.trim() + "%");
        }

        if (roleGroup != null && !roleGroup.trim().isEmpty()) {
            sql.append(" AND rg.code = ?");
            params.add(roleGroup.trim());
        }

        if ("1".equals(status)) {
            sql.append(" AND ua.is_active = 1");
        } else if ("0".equals(status)) {
            sql.append(" AND ua.is_active = 0");
        }

        sql.append(" ORDER BY ua.id DESC");

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                List<UserAccountDTO> list = new ArrayList<>();
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
                return list;
            }
        }
    }

    @Override
    public UserStatDTO getStats() throws SQLException {
        String sql = "SELECT"
                + " COUNT(*) AS total,"
                + " SUM(CASE WHEN ua.is_active = 1 THEN 1 ELSE 0 END) AS active,"
                + " SUM(CASE WHEN ua.is_active = 0 THEN 1 ELSE 0 END) AS inactive,"
                + " SUM(CASE WHEN rg.code = 'ADMIN' THEN 1 ELSE 0 END) AS admins"
                + " FROM user_accounts ua"
                + " JOIN roles r ON r.id = ua.role_id"
                + " JOIN role_groups rg ON rg.id = r.group_id";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            UserStatDTO dto = new UserStatDTO();

            if (rs.next()) {
                dto.setTotalUsers(rs.getInt("total"));
                dto.setActiveUsers(rs.getInt("active"));
                dto.setInactiveUsers(rs.getInt("inactive"));
                dto.setAdminUsers(rs.getInt("admins"));
            }

            return dto;
        }
    }

    @Override
    public List<Object[]> getRoleGroups() throws SQLException {
        String sql = "SELECT r.id, CONCAT(rg.name, ' - ', r.name) AS display"
                + " FROM roles r"
                + " JOIN role_groups rg ON rg.id = r.group_id"
                + " ORDER BY rg.id, r.id";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            List<Object[]> list = new ArrayList<>();

            while (rs.next()) {
                list.add(new Object[]{
                        rs.getInt("id"),
                        rs.getString("display")
                });
            }

            return list;
        }
    }

    @Override
    public void toggleActive(int userId, boolean active) throws SQLException {
        String sql = "UPDATE user_accounts SET is_active = ? WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setBoolean(1, active);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    @Override
    public void forceResetPassword(int userId) throws SQLException {
        String sql = "UPDATE user_accounts SET force_reset_pwd = 1 WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }

    @Override
    public void deleteUser(int userId) throws SQLException {
        String sql = "DELETE FROM user_accounts WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }

    // -------------------------------------------------------------------------
    // Profile: xem & cap nhat thong tin ca nhan
    // -------------------------------------------------------------------------

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

    // -------------------------------------------------------------------------
    // Helper
    // -------------------------------------------------------------------------

    private UserAccountDTO mapRow(ResultSet rs) throws SQLException {
        UserAccountDTO dto = new UserAccountDTO();

        dto.setId(rs.getInt("id"));
        dto.setUsername(rs.getString("username"));
        dto.setActive(rs.getBoolean("is_active"));
        dto.setForceResetPwd(rs.getBoolean("force_reset_pwd"));
        dto.setFullName(rs.getString("full_name"));
        dto.setEmployeeCode(rs.getString("employee_code"));
        dto.setRoleName(rs.getString("role_name"));
        dto.setRoleGroupCode(rs.getString("role_group_code"));

        Timestamp ts = rs.getTimestamp("last_login_at");
        if (ts != null) {
            dto.setLastLoginAt(ts.toLocalDateTime());
        }


        return dto;
    }

    private String hashPassword(String raw) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] bytes = md.digest(raw.getBytes(java.nio.charset.StandardCharsets.UTF_8));

            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) {
                sb.append(String.format("%02x", b));
            }

            return sb.toString();

        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 not available", e);
        }
    }
}