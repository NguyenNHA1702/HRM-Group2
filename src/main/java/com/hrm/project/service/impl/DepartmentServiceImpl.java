package com.hrm.project.service.impl;

import com.hrm.project.dao.DepartmentDAO;
import com.hrm.project.dao.impl.DepartmentDAOImpl;
import com.hrm.project.model.Department;
import com.hrm.project.service.DepartmentService;
import com.hrm.project.dao.impl.DBConnection;
import com.hrm.project.model.UserAccountDTO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.List;
import java.util.concurrent.CompletableFuture;

public class DepartmentServiceImpl implements DepartmentService {

    // Gọi sang tầng DAO thông qua Interface
    private final DepartmentDAO departmentDAO = new DepartmentDAOImpl();

    @Override
    public List<Department> getAllDepartments() {
        return departmentDAO.getAllDepartments();
    }

    @Override
    public boolean addDepartment(Department d) {
        boolean success = departmentDAO.addDepartment(d);
        if (success && d.getManagerId() != null && d.getManagerId() > 0 && d.getId() > 0) {
            triggerManagerHook(d.getManagerId(), d.getId());
        }
        return success;
    }

    @Override
    public boolean updateDepartment(Department d) {
        boolean success = departmentDAO.updateDepartment(d);
        if (success && d.getManagerId() != null && d.getManagerId() > 0) {
            triggerManagerHook(d.getManagerId(), d.getId());
        }
        return success;
    }

    @Override
    public boolean deactivateDepartment(int id) {
        return departmentDAO.deactivateDepartment(id);
    }

    @Override
    public boolean activateDepartment(int id) {
        return departmentDAO.activateDepartment(id);
    }

    @Override
    public int countActiveEmployees(int departmentId) {
        return departmentDAO.countActiveEmployees(departmentId);
    }

    @Override
    public List<UserAccountDTO> getMembersByDepartment(int departmentId) {
        return departmentDAO.getMembersByDepartment(departmentId);
    }

    @Override
    public boolean bulkTransferEmployees(int targetDepartmentId, List<Integer> employeeIds) {
        return departmentDAO.bulkTransferEmployees(targetDepartmentId, employeeIds);
    }

    private int getOrCreateManagerPosition(Connection conn, int departmentId) throws Exception {
        // 1. Check existing manager position for this department
        String posSql = "SELECT id FROM positions WHERE department_id = ? AND " +
                        "(name LIKE '%Manager%' OR name LIKE '%Trưởng phòng%' OR name LIKE '%Giám đốc%' OR name LIKE '%Kế toán trưởng%' OR code LIKE '%MGR%' OR code LIKE '%DIR%' OR code LIKE '%CEO%') LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(posSql)) {
            ps.setInt(1, departmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("id");
                }
            }
        }

        // 2. Check any position for this department
        try (PreparedStatement ps = conn.prepareStatement("SELECT id FROM positions WHERE department_id = ? LIMIT 1")) {
            ps.setInt(1, departmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("id");
                }
            }
        }

        // 3. If no position exists for this department, get department details to create one
        String deptCode = "DEPT";
        String deptName = "Phòng ban";
        try (PreparedStatement ps = conn.prepareStatement("SELECT code, name FROM departments WHERE id = ?")) {
            ps.setInt(1, departmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    if (rs.getString("code") != null) deptCode = rs.getString("code").trim();
                    if (rs.getString("name") != null) deptName = rs.getString("name").trim();
                }
            }
        }

        String newCode = (deptCode + "_MGR").toUpperCase();
        String newName = "Trưởng phòng " + deptName;

        // Create new manager position for this department
        String insertSql = "INSERT INTO positions (code, name, department_id, base_salary, allowance, is_active) VALUES (?, ?, ?, 20000000.00, 2000000.00, 1)";
        try (PreparedStatement ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, newCode);
            ps.setString(2, newName);
            ps.setInt(3, departmentId);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }
        return -1;
    }

    private int getStaffPosition(Connection conn, int departmentId) throws Exception {
        // Find any non-manager position in this department
        String sql = "SELECT id FROM positions WHERE department_id = ? AND " +
                     "name NOT LIKE '%Trưởng%' AND name NOT LIKE '%Giám đốc%' AND name NOT LIKE '%Manager%' AND name NOT LIKE '%Kế toán trưởng%' AND code NOT LIKE '%MGR%' AND code NOT LIKE '%DIR%' LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, departmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("id");
                }
            }
        }
        // Fallback: find any position in this department that is not manager position
        int managerPosId = getOrCreateManagerPosition(conn, departmentId);
        try (PreparedStatement ps = conn.prepareStatement("SELECT id FROM positions WHERE department_id = ? AND id != ? LIMIT 1")) {
            ps.setInt(1, departmentId);
            ps.setInt(2, managerPosId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("id");
                }
            }
        }
        // Fallback 2: create a default staff position if none exists
        String deptCode = "DEPT";
        String deptName = "Phòng ban";
        try (PreparedStatement ps = conn.prepareStatement("SELECT code, name FROM departments WHERE id = ?")) {
            ps.setInt(1, departmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    if (rs.getString("code") != null) deptCode = rs.getString("code").trim();
                    if (rs.getString("name") != null) deptName = rs.getString("name").trim();
                }
            }
        }
        String insertSql = "INSERT INTO positions (code, name, department_id, base_salary, allowance, is_active) VALUES (?, ?, ?, 10000000.00, 0.00, 1)";
        try (PreparedStatement ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, (deptCode + "_EXE").toUpperCase());
            ps.setString(2, "Chuyên viên " + deptName);
            ps.setInt(3, departmentId);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }
        return managerPosId;
    }

    private void triggerManagerHook(int managerId, int departmentId) {
        try (Connection conn = DBConnection.getConnection()) {
            // Clear manager_id from any other department where managerId was assigned
            try (PreparedStatement ps = conn.prepareStatement("UPDATE departments SET manager_id = NULL WHERE manager_id = ? AND id != ?")) {
                ps.setInt(1, managerId);
                ps.setInt(2, departmentId);
                ps.executeUpdate();
            }

            // Check current role group (ADMIN group 1 and HR group 2 should NOT be downgraded to MANAGER role 7)
            int currentGroupId = 4;
            String checkRoleSql = "SELECT r.group_id FROM user_accounts ua JOIN roles r ON ua.role_id = r.id WHERE ua.employee_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(checkRoleSql)) {
                ps.setInt(1, managerId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        currentGroupId = rs.getInt("group_id");
                    }
                }
            } catch (Exception e) {
                // Ignore
            }

            // Only update user_accounts role if user was previously a standard Employee (group_id = 4)
            if (currentGroupId == 4) {
                int managerRoleId = 7;
                try (Statement stmt = conn.createStatement();
                     ResultSet rs = stmt.executeQuery("SELECT id FROM roles WHERE name = 'Manager' OR name = 'Trưởng phòng' LIMIT 1")) {
                    if (rs.next()) {
                        managerRoleId = rs.getInt("id");
                    }
                } catch (Exception e) {
                    // Ignore and use fallback
                }

                try (PreparedStatement ps = conn.prepareStatement("UPDATE user_accounts SET role_id = ? WHERE employee_id = ?")) {
                    ps.setInt(1, managerRoleId);
                    ps.setInt(2, managerId);
                    ps.executeUpdate();
                }
            }

            // Update employee's department_id
            try (PreparedStatement ps = conn.prepareStatement("UPDATE employees SET department_id = ? WHERE id = ?")) {
                ps.setInt(1, departmentId);
                ps.setInt(2, managerId);
                ps.executeUpdate();
            }

            // Find or create manager position dynamically for THIS specific department
            int managerPositionId = getOrCreateManagerPosition(conn, departmentId);
            int staffPositionId = getStaffPosition(conn, departmentId);

            // Demote any previous manager or duplicate manager position holder for this department
            java.util.List<Integer> oldManagersToDemote = new java.util.ArrayList<>();
            String findOldMgrsSql = "SELECT id FROM employees WHERE (department_id = ? OR id IN (SELECT manager_id FROM departments WHERE id = ?)) AND position_id = ? AND id != ?";
            try (PreparedStatement ps = conn.prepareStatement(findOldMgrsSql)) {
                ps.setInt(1, departmentId);
                ps.setInt(2, departmentId);
                ps.setInt(3, managerPositionId);
                ps.setInt(4, managerId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        oldManagersToDemote.add(rs.getInt("id"));
                    }
                }
            }

            if (!oldManagersToDemote.isEmpty()) {
                String demotePosSql = "UPDATE employees SET position_id = ? WHERE id = ?";
                try (PreparedStatement ps = conn.prepareStatement(demotePosSql)) {
                    for (int oldId : oldManagersToDemote) {
                        ps.setInt(1, staffPositionId);
                        ps.setInt(2, oldId);
                        ps.executeUpdate();

                        // If old manager is not manager of any other department, revert role_id 7 to 9
                        String countDeptsSql = "SELECT COUNT(*) FROM departments WHERE manager_id = ?";
                        int deptsCount = 0;
                        try (PreparedStatement psCount = conn.prepareStatement(countDeptsSql)) {
                            psCount.setInt(1, oldId);
                            try (ResultSet rsCount = psCount.executeQuery()) {
                                if (rsCount.next()) deptsCount = rsCount.getInt(1);
                            }
                        }
                        if (deptsCount <= 1) {
                            try (PreparedStatement psRoleRevert = conn.prepareStatement("UPDATE user_accounts SET role_id = 9 WHERE employee_id = ? AND role_id = 7")) {
                                psRoleRevert.setInt(1, oldId);
                                psRoleRevert.executeUpdate();
                            }
                        }
                    }
                }
            }

            // Set departments.manager_id
            try (PreparedStatement ps = conn.prepareStatement("UPDATE departments SET manager_id = ? WHERE id = ?")) {
                ps.setInt(1, managerId);
                ps.setInt(2, departmentId);
                ps.executeUpdate();
            }

            // Update employees position_id if a valid department position was found/created
            if (managerPositionId > 0) {
                try (PreparedStatement ps = conn.prepareStatement("UPDATE employees SET position_id = ? WHERE id = ?")) {
                    ps.setInt(1, managerPositionId);
                    ps.setInt(2, managerId);
                    ps.executeUpdate();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}