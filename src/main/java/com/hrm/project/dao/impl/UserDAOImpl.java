package com.hrm.project.dao.impl;

import com.hrm.project.dao.UserDAO;
import com.hrm.project.model.Department;
import com.hrm.project.model.Position;
import com.hrm.project.model.Role;
import com.hrm.project.model.UserAccount;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UserDAOImpl implements UserDAO {

    @Override
    public UserAccount getUserById(int id) {
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

    @Override
    public List<Department> getAllDepartments() {
        List<Department> list = new ArrayList<>();
        String sql = "SELECT id, code, name FROM departments WHERE is_active = 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Department(
                    rs.getInt("id"),
                    rs.getString("code"),
                    rs.getString("name")
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<Position> getAllPositions() {
        List<Position> list = new ArrayList<>();
        String sql = "SELECT id, code, name, department_id FROM positions WHERE is_active = 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Position(
                    rs.getInt("id"),
                    rs.getString("code"),
                    rs.getString("name"),
                    rs.getInt("department_id")
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<Role> getAllRoles() {
        List<Role> list = new ArrayList<>();
        String sql = "SELECT id, group_id, name, description, is_active, created_at, updated_at FROM roles WHERE is_active = 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Role(
                    rs.getInt("id"),
                    rs.getInt("group_id"),
                    rs.getString("name"),
                    rs.getString("description"),
                    rs.getBoolean("is_active"),
                    rs.getTimestamp("created_at"),
                    rs.getTimestamp("updated_at")
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public UserAccount getUserForAdminUpdate(int id) {
        String sql = "SELECT e.id AS employee_id, e.employee_code, e.full_name, e.phone, e.work_email, e.personal_email, " +
                     "e.date_of_birth, e.gender, e.status, e.department_id, e.position_id, ua.role_id, ua.is_active " +
                     "FROM employees e " +
                     "LEFT JOIN user_accounts ua ON e.id = ua.employee_id " +
                     "WHERE e.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    UserAccount user = new UserAccount();
                    user.setEmployeeId(rs.getInt("employee_id"));
                    user.setEmployeeCode(rs.getString("employee_code"));
                    user.setFullName(rs.getString("full_name"));
                    user.setPhone(rs.getString("phone"));
                    user.setWorkEmail(rs.getString("work_email"));
                    user.setPersonalEmail(rs.getString("personal_email"));
                    user.setDateOfBirth(rs.getString("date_of_birth"));
                    user.setGender(rs.getString("gender"));
                    user.setStatus(rs.getString("status"));
                    user.setDepartmentId(rs.getInt("department_id"));
                    user.setPositionId(rs.getInt("position_id"));
                    user.setRoleId(rs.getInt("role_id"));
                    user.setActive(rs.getBoolean("is_active"));
                    return user;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public boolean updateUserByAdmin(UserAccount user) {
        String updateEmployeeSql = "UPDATE employees SET full_name = ?, phone = ?, personal_email = ?, date_of_birth = ?, gender = ?, department_id = ?, position_id = ?, status = ? WHERE id = ?";
        String updateUserAccountSql = "UPDATE user_accounts SET role_id = ?, is_active = ? WHERE employee_id = ?";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement psEmp = conn.prepareStatement(updateEmployeeSql)) {
                psEmp.setString(1, user.getFullName());
                psEmp.setString(2, user.getPhone());
                psEmp.setString(3, user.getPersonalEmail());
                psEmp.setString(4, user.getDateOfBirth());
                psEmp.setString(5, user.getGender());
                if (user.getDepartmentId() > 0) {
                    psEmp.setInt(6, user.getDepartmentId());
                } else {
                    psEmp.setNull(6, java.sql.Types.INTEGER);
                }
                if (user.getPositionId() > 0) {
                    psEmp.setInt(7, user.getPositionId());
                } else {
                    psEmp.setNull(7, java.sql.Types.INTEGER);
                }
                psEmp.setString(8, user.getStatus());
                psEmp.setInt(9, user.getEmployeeId());
                psEmp.executeUpdate();
            }

            try (PreparedStatement psAcc = conn.prepareStatement(updateUserAccountSql)) {
                psAcc.setInt(1, user.getRoleId());
                psAcc.setBoolean(2, user.isActive());
                psAcc.setInt(3, user.getEmployeeId());
                psAcc.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        return false;
    }

    @Override
    public boolean updateUserActiveStatus(int employeeId, boolean isActive) {
        String sql = "UPDATE user_accounts SET is_active = ? WHERE employee_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, isActive);
            ps.setInt(2, employeeId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public UserAccount getUserByEmail(String email) {
        String sql = "SELECT e.id AS employee_id, e.work_email, e.personal_email, e.full_name " +
                     "FROM employees e " +
                     "JOIN user_accounts ua ON e.id = ua.employee_id " +
                     "WHERE e.work_email = ? OR e.personal_email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    UserAccount user = new UserAccount();
                    user.setEmployeeId(rs.getInt("employee_id"));
                    user.setFullName(rs.getString("full_name"));
                    user.setWorkEmail(rs.getString("work_email"));
                    user.setPersonalEmail(rs.getString("personal_email"));
                    return user;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
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
