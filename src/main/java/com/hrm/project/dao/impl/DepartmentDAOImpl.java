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
                "LEFT JOIN employees e ON e.department_id = d1.id " + // JOIN sang bảng nhân viên
                "GROUP BY d1.id " +
                "ORDER BY d1.id DESC";

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
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public boolean addDepartment(Department d) {
        String sql = "INSERT INTO departments (code, name, manager_id, parent_id, description, is_active) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, d.getCode());
            ps.setString(2, d.getName());
            if (d.getManagerId() != null) ps.setInt(3, d.getManagerId()); else ps.setNull(3, Types.INTEGER);
            if (d.getParentId() != null) ps.setInt(4, d.getParentId()); else ps.setNull(4, Types.INTEGER);
            ps.setString(5, d.getDescription());
            ps.setInt(6, d.getIsActive());

            return ps.executeUpdate() > 0;
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
                     "WHERE e.department_id = ? AND UPPER(e.status) = 'ACTIVE' " +
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
            // Find distinct source department IDs before updating
            List<Integer> sourceDeptIds = new ArrayList<>();
            String findSourceSql = "SELECT DISTINCT department_id FROM employees WHERE id IN (" + placeholders + ")";
            try (PreparedStatement psFind = conn.prepareStatement(findSourceSql)) {
                for (int i = 0; i < employeeIds.size(); i++) {
                    psFind.setInt(i + 1, employeeIds.get(i));
                }
                try (ResultSet rs = psFind.executeQuery()) {
                    while (rs.next()) {
                        int deptId = rs.getInt("department_id");
                        if (!rs.wasNull()) {
                            sourceDeptIds.add(deptId);
                        }
                    }
                }
            }
            
            // Perform the bulk transfer update
            String updateSql = "UPDATE employees SET department_id = ? WHERE id IN (" + placeholders + ")";
            boolean success = false;
            try (PreparedStatement psUpdate = conn.prepareStatement(updateSql)) {
                psUpdate.setInt(1, targetDepartmentId);
                for (int i = 0; i < employeeIds.size(); i++) {
                    psUpdate.setInt(i + 2, employeeIds.get(i));
                }
                success = psUpdate.executeUpdate() > 0;
            }
            
            // Check if any source department became empty, and clear manager if so
            if (success) {
                String countSql = "SELECT COUNT(*) FROM employees WHERE department_id = ? AND UPPER(status) = 'ACTIVE'";
                String clearManagerSql = "UPDATE departments SET manager_id = NULL WHERE id = ?";
                
                for (int sourceDeptId : sourceDeptIds) {
                    if (sourceDeptId != targetDepartmentId) {
                        try (PreparedStatement psCount = conn.prepareStatement(countSql)) {
                            psCount.setInt(1, sourceDeptId);
                            try (ResultSet rs = psCount.executeQuery()) {
                                if (rs.next() && rs.getInt(1) == 0) {
                                    try (PreparedStatement psClear = conn.prepareStatement(clearManagerSql)) {
                                        psClear.setInt(1, sourceDeptId);
                                        psClear.executeUpdate();
                                    }
                                }
                            }
                        }
                    }
                }
            }
            return success;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}