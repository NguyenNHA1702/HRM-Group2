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
        if (success && d.getManagerId() != null) {
            triggerManagerHook(d.getManagerId());
        }
        return success;
    }

    @Override
    public boolean updateDepartment(Department d) {
        boolean success = departmentDAO.updateDepartment(d);
        if (success && d.getManagerId() != null) {
            triggerManagerHook(d.getManagerId());
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

    private void triggerManagerHook(int managerId) {
        CompletableFuture.runAsync(() -> {
            try (Connection conn = DBConnection.getConnection()) {
                // Find correct Manager role dynamically from database (fallback to ID 7)
                int managerRoleId = 7;
                try (Statement stmt = conn.createStatement();
                     ResultSet rs = stmt.executeQuery("SELECT id FROM roles WHERE name = 'Manager' OR name = 'Trưởng phòng' LIMIT 1")) {
                    if (rs.next()) {
                        managerRoleId = rs.getInt("id");
                    }
                } catch (Exception e) {
                    // Ignore and use fallback
                }

                // Update user_accounts role
                try (PreparedStatement ps = conn.prepareStatement("UPDATE user_accounts SET role_id = ? WHERE employee_id = ?")) {
                    ps.setInt(1, managerRoleId);
                    ps.setInt(2, managerId);
                    ps.executeUpdate();
                }

                // Find manager position dynamically from database
                Integer managerPositionId = null;
                try (Statement stmt = conn.createStatement();
                     ResultSet rs = stmt.executeQuery("SELECT id FROM positions WHERE name LIKE '%Manager%' OR name LIKE '%Trưởng phòng%' LIMIT 1")) {
                    if (rs.next()) {
                        managerPositionId = rs.getInt("id");
                    }
                } catch (Exception e) {
                    // Ignore
                }

                // Update employees position/designation
                if (managerPositionId != null) {
                    try (PreparedStatement ps = conn.prepareStatement("UPDATE employees SET position_id = ? WHERE id = ?")) {
                        ps.setInt(1, managerPositionId);
                        ps.setInt(2, managerId);
                        ps.executeUpdate();
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        });
    }
}