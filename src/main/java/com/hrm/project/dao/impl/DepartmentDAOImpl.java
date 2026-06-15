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
}