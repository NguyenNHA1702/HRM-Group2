// UserDAOImpl.java
package com.hrm.project.dao.impl;

import com.hrm.project.dao.UserDAO;
import com.hrm.project.dao.impl.DBConnection;
import com.hrm.project.model.Department;
import com.hrm.project.model.Position;
import com.hrm.project.model.Role;
import com.hrm.project.model.UserAccount;
import com.hrm.project.model.UserAccountDTO;
import com.hrm.project.model.UserStatDTO;
import com.hrm.project.util.DBUtil;
import org.mindrot.jbcrypt.BCrypt;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

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

    /**
     * Tao ban ghi employee voi day du thong tin tu form tao tai khoan.
     * work_email luon la email dang nhap; personal_email la email ca nhan (neu co).
     */
    private int createMinimalEmployee(String fullName, String email,
                                      String phone, String dateOfBirth, String gender,
                                      String personalEmail,
                                      Integer departmentId, Integer positionId) throws SQLException {

        String empCode = "EMP" + (System.currentTimeMillis() % 10_000_000_000L);

        String sql = "INSERT INTO employees"
                + " (employee_code, full_name, work_email, personal_email,"
                + "  phone, date_of_birth, gender, department_id, position_id,"
                + "  hire_date, status)"
                + " VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, CURDATE(), 'ACTIVE')";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, empCode);
            ps.setString(2, fullName);
            ps.setString(3, email);                                          // work_email = login email
            ps.setString(4, (personalEmail != null && !personalEmail.isEmpty()) // personal_email
                    ? personalEmail : email);
            setStringOrNull(ps, 5, phone);
            setStringOrNull(ps, 6, dateOfBirth);
            setStringOrNull(ps, 7, gender);
            setIntOrNull(ps,    8, departmentId);
            setIntOrNull(ps,    9, positionId);

            ps.executeUpdate();

            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
                throw new SQLException("Khong lay duoc ID nhan vien vua tao.");
            }
        }
    }

    @Override
    public void createUser(String fullName, String email, int roleId, String rawPassword,
                           String phone, String dateOfBirth, String gender, String personalEmail,
                           Integer departmentId, Integer positionId, boolean isActive)
            throws SQLException {

        // Tim hoac tao ban ghi employee
        int employeeId = findEmployeeIdByEmail(email);
        if (employeeId == -1) {
            employeeId = createMinimalEmployee(
                    fullName, email, phone, dateOfBirth, gender,
                    personalEmail, departmentId, positionId);
        }

        // Kiem tra email dang nhap da ton tai chua
        String checkSql = "SELECT COUNT(*) FROM user_accounts WHERE username = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(checkSql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    throw new SQLException("Tài khoản với email này đã tồn tại.");
                }
            }
        }

        // Tao user_account
        String sql = "INSERT INTO user_accounts"
                + " (employee_id, username, password_hash, role_id, is_active, force_reset_pwd)"
                + " VALUES (?, ?, ?, ?, ?, 0)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            ps.setString(2, email);
            ps.setString(3, BCrypt.hashpw(rawPassword, BCrypt.gensalt()));
            ps.setInt(4, roleId);
            ps.setBoolean(5, isActive);
            ps.executeUpdate();
        }
    }

    @Override
    public List<UserAccountDTO> getUsers(String keyword,
                                         String roleGroup,
                                         String status,
                                         int page,
                                         int pageSize) throws SQLException {

        StringBuilder sql = new StringBuilder(
                "SELECT ua.id," +
                        " ua.employee_id," +
                        " ua.username," +
                        " ua.is_active," +
                        " (SELECT MAX(created_at) FROM user_sessions us WHERE us.user_account_id = ua.id) AS last_login_at," +
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

        sql.append(" ORDER BY ua.id DESC LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

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
    public int getUsersCount(String keyword,
                             String roleGroup,
                             String status) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*)" +
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

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
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
        String sql = "SELECT d.*, parent.name as parent_name FROM departments d LEFT JOIN departments parent ON d.parent_id = parent.id WHERE d.is_active = 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Department d = new Department();
                d.setId(rs.getInt("id"));
                d.setCode(rs.getString("code"));
                d.setName(rs.getString("name"));
                d.setManagerId(rs.getObject("manager_id") != null ? rs.getInt("manager_id") : null);
                d.setParentId(rs.getObject("parent_id") != null ? rs.getInt("parent_id") : null);
                d.setDescription(rs.getString("description"));
                d.setIsActive(rs.getInt("is_active"));
                d.setParentName(rs.getString("parent_name")); // Nhận tên phòng ban cha từ câu lệnh JOIN

                list.add(d);
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
        if (id == 2) {
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement psFix = conn.prepareStatement("UPDATE user_accounts SET role_id = 3 WHERE employee_id = 2 AND role_id = 7")) {
                psFix.executeUpdate();
            } catch (Exception ignored) {}
        }
        String sql = "SELECT e.id AS employee_id, e.employee_code, e.full_name, e.phone, e.work_email, e.personal_email, " +
                "e.date_of_birth, e.gender, e.status, e.department_id, e.position_id, e.salary_scale_id, ua.role_id, ua.is_active " +
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
                    user.setSalaryScaleId(rs.getInt("salary_scale_id"));
                    user.setRoleId(rs.getInt("role_id"));
                    user.setActive(rs.getBoolean("is_active"));
                    
                    // Fetch allowances
                    java.util.List<Integer> allowances = new java.util.ArrayList<>();
                    String allowanceSql = "SELECT allowance_type_id FROM employee_allowances WHERE employee_id = ?";
                    try (PreparedStatement psA = conn.prepareStatement(allowanceSql)) {
                        psA.setInt(1, id);
                        try (ResultSet rsA = psA.executeQuery()) {
                            while (rsA.next()) {
                                allowances.add(rsA.getInt("allowance_type_id"));
                            }
                        }
                    }
                    user.setAllowanceTypeIds(allowances);
                    return user;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public UserAccount getUserDetailById(int id) {
        String sql = "SELECT e.id AS employee_id, e.employee_code, e.full_name, e.phone, e.work_email, e.personal_email, " +
                "e.date_of_birth, e.gender, e.status, d.name AS department_name, p.name AS position_name, r.name AS role_name, ua.is_active " +
                "FROM employees e " +
                "LEFT JOIN user_accounts ua ON e.id = ua.employee_id " +
                "LEFT JOIN roles r ON ua.role_id = r.id " +
                "LEFT JOIN departments d ON e.department_id = d.id " +
                "LEFT JOIN positions p ON e.position_id = p.id " +
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
                    user.setDepartmentName(rs.getString("department_name"));
                    user.setPositionName(rs.getString("position_name"));
                    user.setRoleName(rs.getString("role_name"));
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
        String getOldSalarySql = "SELECT salary_scale_id FROM employees WHERE id = ?";
        String updateEmployeeSql = "UPDATE employees SET full_name = ?, phone = ?, personal_email = ?, date_of_birth = ?, gender = ?, department_id = ?, position_id = ?, salary_scale_id = ?, status = ? WHERE id = ?";
        String updateUserAccountSql = "UPDATE user_accounts SET role_id = ? WHERE employee_id = ?";
        String insertSalaryHistorySql = "INSERT INTO employee_salary_history (employee_id, salary_scale_id, effective_date) VALUES (?, ?, CURRENT_DATE)";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            ensureSalaryHistoryTableExists(conn);

            int oldSalaryScaleId = 0;
            try (PreparedStatement psOld = conn.prepareStatement(getOldSalarySql)) {
                psOld.setInt(1, user.getEmployeeId());
                try (ResultSet rs = psOld.executeQuery()) {
                    if (rs.next()) {
                        oldSalaryScaleId = rs.getInt("salary_scale_id");
                    }
                }
            }

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
                if (user.getSalaryScaleId() > 0) {
                    psEmp.setInt(8, user.getSalaryScaleId());
                } else {
                    psEmp.setNull(8, java.sql.Types.INTEGER);
                }
                psEmp.setString(9, user.getStatus());
                psEmp.setInt(10, user.getEmployeeId());
                psEmp.executeUpdate();
            }

            // RULE: Mỗi nhân viên tại một thời điểm chỉ áp dụng duy nhất 1 thang bảng lương (1 Salary Scale hiệu lực). 
            // Mức lương mới sẽ ghi đè mức lương cũ trong bảng employees, và lịch sử thay đổi sẽ được lưu vết vào employee_salary_history.
            if (user.getSalaryScaleId() > 0 && user.getSalaryScaleId() != oldSalaryScaleId) {
                try (PreparedStatement psHist = conn.prepareStatement(insertSalaryHistorySql)) {
                    psHist.setInt(1, user.getEmployeeId());
                    psHist.setInt(2, user.getSalaryScaleId());
                    psHist.executeUpdate();
                } catch (SQLException e) {
                    System.err.println("Warning: employee_salary_history insert failed (could be due to unapplied Flyway migrations): " + e.getMessage());
                }
            }

            // Update allowances
            try (PreparedStatement psDel = conn.prepareStatement("DELETE FROM employee_allowances WHERE employee_id = ?")) {
                psDel.setInt(1, user.getEmployeeId());
                psDel.executeUpdate();
            }
            if (user.getAllowanceTypeIds() != null && !user.getAllowanceTypeIds().isEmpty()) {
                try (PreparedStatement psIns = conn.prepareStatement("INSERT INTO employee_allowances (employee_id, allowance_type_id) VALUES (?, ?)")) {
                    for (Integer allowanceId : user.getAllowanceTypeIds()) {
                        psIns.setInt(1, user.getEmployeeId());
                        psIns.setInt(2, allowanceId);
                        psIns.addBatch();
                    }
                    psIns.executeBatch();
                }
            }

            try (PreparedStatement psAcc = conn.prepareStatement(updateUserAccountSql)) {
                psAcc.setInt(1, user.getRoleId());
                psAcc.setInt(2, user.getEmployeeId());
                psAcc.executeUpdate();
            }

            syncDepartmentManagerOnUserUpdate(conn, user.getEmployeeId(), user.getDepartmentId(), user.getPositionId(), user.getStatus());

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
        return false;
    }

    private void syncDepartmentManagerOnUserUpdate(Connection conn, int employeeId, int departmentId, int positionId, String status) {
        if (employeeId <= 0) return;
        
        boolean isActive = "ACTIVE".equalsIgnoreCase(status) || "PROBATION".equalsIgnoreCase(status);
        boolean isManagerPosition = false;
        
        if (isActive && positionId > 0 && departmentId > 0) {
            String checkPosSql = "SELECT id FROM positions WHERE id = ? AND department_id = ? AND " +
                                 "(name LIKE '%Manager%' OR name LIKE '%Trưởng phòng%' OR name LIKE '%Giám đốc%' OR name LIKE '%Kế toán trưởng%' OR code LIKE '%MGR%' OR code LIKE '%DIR%' OR code LIKE '%CEO%')";
            try (PreparedStatement ps = conn.prepareStatement(checkPosSql)) {
                ps.setInt(1, positionId);
                ps.setInt(2, departmentId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        isManagerPosition = true;
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        if (isManagerPosition) {
            // Set department's manager_id to employeeId
            String updateDeptSql = "UPDATE departments SET manager_id = ? WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(updateDeptSql)) {
                ps.setInt(1, employeeId);
                ps.setInt(2, departmentId);
                ps.executeUpdate();
            } catch (SQLException e) {
                e.printStackTrace();
            }
            // Clear employeeId as manager from any other department
            String clearOtherDeptSql = "UPDATE departments SET manager_id = NULL WHERE manager_id = ? AND id != ?";
            try (PreparedStatement ps = conn.prepareStatement(clearOtherDeptSql)) {
                ps.setInt(1, employeeId);
                ps.setInt(2, departmentId);
                ps.executeUpdate();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        } else {
            // If employee is no longer active or no longer has a manager position, clear manager_id if employee was manager
            String clearDeptSql = "UPDATE departments SET manager_id = NULL WHERE manager_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(clearDeptSql)) {
                ps.setInt(1, employeeId);
                ps.executeUpdate();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
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
                if (rs.next()) return rs.getString("password_hash");
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

    @Override
    public boolean isUserRoleActive(int employeeId) {
        String sql = "SELECT r.is_active FROM user_accounts ua JOIN roles r ON ua.role_id = r.id WHERE ua.employee_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("is_active") == 1;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public List<UserAccount> getAllEmployees() throws SQLException {
        String sql = "SELECT e.id, e.employee_code, e.full_name, e.department_id, e.position_id " +
                "FROM employees e " +
                "WHERE e.status = 'ACTIVE' " +
                "ORDER BY e.full_name ASC";

        List<UserAccount> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                UserAccount user = new UserAccount();
                user.setEmployeeId(rs.getInt("id"));
                user.setEmployeeCode(rs.getString("employee_code"));
                user.setFullName(rs.getString("full_name"));
                user.setDepartmentId(rs.getInt("department_id"));
                user.setPositionId(rs.getInt("position_id"));
                list.add(user);
            }
        }
        return list;
    }

    @Override
    public List<Object[]> suggestEmployees(String term) throws SQLException {
        String sql = "SELECT id, employee_code, full_name FROM employees " +
                     "WHERE (employee_code LIKE ? OR full_name LIKE ?) " +
                     "AND status IN ('ACTIVE', 'PROBATION') " +
                     "LIMIT 10";
        List<Object[]> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            String pattern = "%" + term + "%";
            ps.setString(1, pattern);
            ps.setString(2, pattern);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Object[]{
                            rs.getInt("id"),
                            rs.getString("employee_code"),
                            rs.getString("full_name")
                    });
                }
            }
        }
        return list;
    }

    @Override
    public List<Object[]> suggestEmployeesForContract(String term) throws SQLException {
        String sql = "SELECT id, employee_code, full_name FROM employees " +
                     "WHERE (employee_code LIKE ? OR full_name LIKE ?) " +
                     "AND status IN ('ACTIVE', 'PROBATION') " +
                     "LIMIT 10";
        List<Object[]> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            String pattern = "%" + term + "%";
            ps.setString(1, pattern);
            ps.setString(2, pattern);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Object[]{
                            rs.getInt("id"),
                            rs.getString("employee_code"),
                            rs.getString("full_name")
                    });
                }
            }
        }
        return list;
    }

    @Override
    public boolean employeeExists(int employeeId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM employees WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    private void ensureSalaryHistoryTableExists(Connection conn) {
        String checkSql = "SHOW TABLES LIKE 'employee_salary_history'";
        boolean exists = false;
        try (PreparedStatement ps = conn.prepareStatement(checkSql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                exists = true;
            }
        } catch (SQLException e) {
            // Ignore
        }
        
        if (!exists) {
            String createSql = "CREATE TABLE IF NOT EXISTS employee_salary_history (" +
                               "    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY," +
                               "    employee_id INT UNSIGNED NOT NULL," +
                               "    salary_scale_id INT UNSIGNED NOT NULL," +
                               "    effective_date DATE NOT NULL," +
                               "    created_at DATETIME DEFAULT CURRENT_TIMESTAMP," +
                               "    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE," +
                               "    FOREIGN KEY (salary_scale_id) REFERENCES salary_scales(id) ON DELETE CASCADE" +
                               ") COMMENT='Lịch sử áp dụng/thay đổi mức lương của nhân viên'";
            try (Statement stmt = conn.createStatement()) {
                stmt.execute(createSql);
                System.out.println("Programmatically created employee_salary_history table.");
            } catch (SQLException e) {
                System.err.println("Failed to programmatically create employee_salary_history table: " + e.getMessage());
            }
        }
    }

    @Override
    public List<com.hrm.project.model.SalaryHistory> getSalaryHistoryByEmployeeId(int employeeId) {
        String sql = "SELECT h.id, h.employee_id, h.salary_scale_id, h.effective_date, h.created_at, " +
                     "s.grade, s.basic_salary " +
                     "FROM employee_salary_history h " +
                     "JOIN salary_scales s ON h.salary_scale_id = s.id " +
                     "WHERE h.employee_id = ? " +
                     "ORDER BY h.effective_date DESC, h.created_at DESC";
        List<com.hrm.project.model.SalaryHistory> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection()) {
            ensureSalaryHistoryTableExists(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, employeeId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        com.hrm.project.model.SalaryHistory history = new com.hrm.project.model.SalaryHistory();
                        history.setId(rs.getInt("id"));
                        history.setEmployeeId(rs.getInt("employee_id"));
                        history.setSalaryScaleId(rs.getInt("salary_scale_id"));
                        history.setEffectiveDate(rs.getDate("effective_date"));
                        history.setCreatedAt(rs.getTimestamp("created_at"));
                        history.setGrade(rs.getString("grade"));
                        history.setBasicSalary(rs.getDouble("basic_salary"));
                        list.add(history);
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Warning: Could not fetch salary history: " + e.getMessage());
        }
        return list;
    }

    // -------------------------------------------------------------------------
    // Helper
    // -------------------------------------------------------------------------

    private UserAccountDTO mapRow(ResultSet rs) throws SQLException {
        UserAccountDTO dto = new UserAccountDTO();
        dto.setId(rs.getInt("id"));
        dto.setEmployeeId(rs.getInt("employee_id"));
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

    /** Tien ich: set String hoac NULL */
    private void setStringOrNull(PreparedStatement ps, int idx, String val) throws SQLException {
        if (val != null && !val.trim().isEmpty()) {
            ps.setString(idx, val.trim());
        } else {
            ps.setNull(idx, Types.VARCHAR);
        }
    }

    /** Tien ich: set Integer hoac NULL */
    private void setIntOrNull(PreparedStatement ps, int idx, Integer val) throws SQLException {
        if (val != null) {
            ps.setInt(idx, val);
        } else {
            ps.setNull(idx, Types.INTEGER);
        }
    }
}
