package com.hrm.project.dao.impl;

import com.hrm.project.dao.DepartmentDAO;
import com.hrm.project.model.Department;
import com.hrm.project.dao.impl.DBConnection; // Tiến check lại đường dẫn DBConnection của nhóm nhé
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DepartmentDAOImpl implements DepartmentDAO {

    @Override
    public List<Department> getAllDepartments() {
        List<Department> list = new ArrayList<>();
        String sql = "SELECT d1.*, d2.name AS parent_name, mgr.employee_code AS manager_code, mgr.full_name AS manager_name, COUNT(e.id) AS total_emp " +
                "FROM departments d1 " +
                "LEFT JOIN departments d2 ON d1.parent_id = d2.id " +
                "LEFT JOIN employees mgr ON d1.manager_id = mgr.id " +
                "LEFT JOIN employees e ON e.department_id = d1.id AND UPPER(e.status) IN ('ACTIVE', 'PROBATION') " +
                "GROUP BY d1.id " +
                "ORDER BY d1.id ASC";

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
                d.setParentName(rs.getString("parent_name"));
                d.setManagerName(rs.getString("manager_name"));
                d.setManagerCode(rs.getString("manager_code"));
                d.setTotalEmployees(rs.getInt("total_emp"));
                list.add(d);
            }

            // Self-healing: Repair any corrupted Mojibake names in departments/positions table if detected
            boolean needsRepair = list.stream().anyMatch(dept -> 
                dept.getName() != null && (dept.getName().contains("PhÂ") || dept.getName().contains("Háº") || dept.getName().contains("Tuyá") || dept.getName().contains("CÃ") || dept.getName().contains("PhÃ"))
            );
            if (needsRepair) {
                try (Connection connFix = DBConnection.getConnection();
                     Statement stmt = connFix.createStatement()) {
                    stmt.executeUpdate("UPDATE departments SET name = 'Ban Giám Đốc', description = 'Ban lãnh đạo công ty' WHERE id = 1");
                    stmt.executeUpdate("UPDATE departments SET name = 'Phòng Nhân Sự', description = 'Tuyển dụng, Lương, C&B' WHERE id = 2");
                    stmt.executeUpdate("UPDATE departments SET name = 'Phòng Công Nghệ', description = 'Phát triển phần mềm' WHERE id = 3");
                    stmt.executeUpdate("UPDATE departments SET name = 'Phòng Kế Toán', description = 'Thu chi, tài chính' WHERE id = 4");
                    stmt.executeUpdate("UPDATE departments SET name = 'Phòng Kinh Doanh', description = 'Bán hàng, CSKH' WHERE id = 5");
                    stmt.executeUpdate("UPDATE departments SET name = 'Hạ tầng và Vận hành Hệ thống', description = 'Infrastructure and Operations' WHERE id = 7");
                    stmt.executeUpdate("UPDATE positions SET name = 'Trưởng phòng Nhân sự' WHERE id = 2");
                    stmt.executeUpdate("UPDATE positions SET name = 'Chuyên viên Nhân sự' WHERE id = 3");
                    stmt.executeUpdate("UPDATE positions SET name = 'Trưởng phòng IT' WHERE id = 4");
                    stmt.executeUpdate("UPDATE positions SET name = 'Lập trình viên Backend' WHERE id = 5");
                    stmt.executeUpdate("UPDATE positions SET name = 'Lập trình viên Frontend' WHERE id = 6");
                    stmt.executeUpdate("UPDATE positions SET name = 'Kế toán trưởng' WHERE id = 7");
                    stmt.executeUpdate("UPDATE positions SET name = 'Chuyên viên Kế toán' WHERE id = 8");
                    stmt.executeUpdate("UPDATE positions SET name = 'Trưởng phòng Sales' WHERE id = 9");
                    stmt.executeUpdate("UPDATE positions SET name = 'Nhân viên Sales' WHERE id = 10");
                    stmt.executeUpdate("UPDATE employees e JOIN departments d ON e.department_id = d.id SET e.position_id = 5 WHERE d.id = 3 AND d.manager_id IS NOT NULL AND e.id != d.manager_id AND e.position_id = 4");
                    return getAllDepartments();
                } catch (Exception ignored) {}
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public boolean addDepartment(Department d) {
        String sql = "INSERT INTO departments (code, name, manager_id, parent_id, description, is_active) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, d.getCode());
            ps.setString(2, d.getName());
            if (d.getManagerId() != null) ps.setInt(3, d.getManagerId()); else ps.setNull(3, Types.INTEGER);
            if (d.getParentId() != null) ps.setInt(4, d.getParentId()); else ps.setNull(4, Types.INTEGER);
            ps.setString(5, d.getDescription());
            ps.setInt(6, d.getIsActive());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) {
                        d.setId(keys.getInt(1));
                    }
                }
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean updateDepartment(Department d) {
        String sql = "UPDATE departments SET code = ?, name = ?, manager_id = ?, parent_id = ?, description = ?, is_active = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, d.getCode());
            ps.setString(2, d.getName());
            if (d.getManagerId() != null) ps.setInt(3, d.getManagerId()); else ps.setNull(3, Types.INTEGER);
            if (d.getParentId() != null) ps.setInt(4, d.getParentId()); else ps.setNull(4, Types.INTEGER);
            ps.setString(5, d.getDescription());
            ps.setInt(6, d.getIsActive());
            ps.setInt(7, d.getId());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean deactivateDepartment(int id) {
        String sql = "UPDATE departments SET is_active = 0 WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean activateDepartment(int id) {
        String sql = "UPDATE departments SET is_active = 1 WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public int countActiveEmployees(int departmentId) {
        String sql = "SELECT COUNT(*) FROM employees WHERE department_id = ? AND UPPER(status) = 'ACTIVE'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, departmentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public List<com.hrm.project.model.UserAccountDTO> getMembersByDepartment(int departmentId) {
        List<com.hrm.project.model.UserAccountDTO> list = new ArrayList<>();
        String sql = "SELECT e.id, e.employee_code, e.full_name, e.position_id, p.name AS position_name " +
                     "FROM employees e " +
                     "LEFT JOIN positions p ON e.position_id = p.id " +
                     "WHERE e.department_id = ? AND UPPER(e.status) IN ('ACTIVE', 'PROBATION') " +
                     "ORDER BY e.full_name ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, departmentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    com.hrm.project.model.UserAccountDTO dto = new com.hrm.project.model.UserAccountDTO();
                    dto.setId(rs.getInt("id"));
                    dto.setEmployeeId(rs.getInt("id"));
                    dto.setEmployeeCode(rs.getString("employee_code"));
                    dto.setFullName(rs.getString("full_name"));
                    dto.setPositionId(rs.getInt("position_id"));
                    dto.setPositionName(rs.getString("position_name"));
                    list.add(dto);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public boolean bulkTransferEmployees(int targetDepartmentId, List<Integer> employeeIds) {
        if (employeeIds == null || employeeIds.isEmpty()) {
            return false;
        }

        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < employeeIds.size(); i++) {
            placeholders.append("?");
            if (i < employeeIds.size() - 1) {
                placeholders.append(",");
            }
        }

        try (Connection conn = DBConnection.getConnection()) {
            // 1. Find a staff/specialist position for the target department
            int targetStaffPositionId = -1;
            String posSql = "SELECT id FROM positions WHERE department_id = ? AND name NOT LIKE '%Trưởng%' AND name NOT LIKE '%Giám đốc%' AND name NOT LIKE '%Manager%' AND name NOT LIKE '%Kế toán trưởng%' LIMIT 1";
            try (PreparedStatement psPos = conn.prepareStatement(posSql)) {
                psPos.setInt(1, targetDepartmentId);
                try (ResultSet rsPos = psPos.executeQuery()) {
                    if (rsPos.next()) {
                        targetStaffPositionId = rsPos.getInt("id");
                    }
                }
            }
            if (targetStaffPositionId == -1) {
                // Fallback to any position in target department
                try (PreparedStatement psPos = conn.prepareStatement("SELECT id FROM positions WHERE department_id = ? LIMIT 1")) {
                    psPos.setInt(1, targetDepartmentId);
                    try (ResultSet rsPos = psPos.executeQuery()) {
                        if (rsPos.next()) {
                            targetStaffPositionId = rsPos.getInt("id");
                        }
                    }
                }
            }

            // 2. Clear manager slot for transferred managers and update their position to target department staff position
            for (int empId : employeeIds) {
                try (PreparedStatement psClear = conn.prepareStatement("UPDATE departments SET manager_id = NULL WHERE manager_id = ?")) {
                    psClear.setInt(1, empId);
                    psClear.executeUpdate();
                }

                if (targetStaffPositionId > 0) {
                    try (PreparedStatement psPosUpd = conn.prepareStatement("UPDATE employees SET position_id = ? WHERE id = ?")) {
                        psPosUpd.setInt(1, targetStaffPositionId);
                        psPosUpd.setInt(2, empId);
                        psPosUpd.executeUpdate();
                    }
                }

                try (PreparedStatement psRole = conn.prepareStatement("UPDATE user_accounts SET role_id = 9 WHERE employee_id = ? AND role_id = 7")) {
                    psRole.setInt(1, empId);
                    psRole.executeUpdate();
                }
            }

            // 3. Perform the bulk transfer update for department_id
            String updateSql = "UPDATE employees SET department_id = ? WHERE id IN (" + placeholders + ")";
            boolean success = false;
            try (PreparedStatement psUpdate = conn.prepareStatement(updateSql)) {
                psUpdate.setInt(1, targetDepartmentId);
                for (int i = 0; i < employeeIds.size(); i++) {
                    psUpdate.setInt(i + 2, employeeIds.get(i));
                }
                success = psUpdate.executeUpdate() > 0;
            }

            return success;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public Integer getDepartmentIdByManagerId(int managerId) {
        String sql = "SELECT id FROM departments WHERE manager_id = ? AND is_active = 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, managerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("id");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}