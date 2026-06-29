package com.hrm.project.dao.impl;

import com.hrm.project.dao.ContractDAO;
import com.hrm.project.enums.ContractStatus;
import com.hrm.project.enums.ContractType;
import com.hrm.project.model.Contract;
import com.hrm.project.model.dtos.response.ContractDTO;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ContractDAOImpl implements ContractDAO {

    @Override
    public List<ContractDTO> getAllContracts() {

        List<ContractDTO> list = new ArrayList<>();

        // file_url column may not exist yet if V18 migration hasn't run
        boolean hasFileUrl = checkColumnExists("contracts", "file_url");

        String sql =
                "SELECT c.id, c.contract_number, c.employee_id, c.contract_type, " +
                        "c.start_date, c.end_date, c.base_salary, c.status, c.description, " +
                        (hasFileUrl ? "c.file_url, " : "") +
                        "e.employee_code, e.full_name, " +
                        "d.name AS department_name " +
                        "FROM contracts c " +
                        "LEFT JOIN employees e ON c.employee_id = e.id " +
                        "LEFT JOIN departments d ON e.department_id = d.id " +
                        "ORDER BY c.id DESC";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()
        ) {

            while (rs.next()) {
                try {
                    ContractDTO dto = new ContractDTO();

                    dto.setId(rs.getInt("id"));
                    dto.setContractNumber(rs.getString("contract_number"));
                    dto.setEmployeeId(rs.getInt("employee_id"));
                    dto.setEmployeeCode(rs.getString("employee_code"));       // NULL-safe (LEFT JOIN)
                    dto.setEmployeeFullName(rs.getString("full_name"));       // NULL-safe (LEFT JOIN)
                    dto.setDepartmentName(rs.getString("department_name"));   // NULL-safe (LEFT JOIN)

                    // ── Contract Type: null-safe mapping ─────────────────
                    int contractTypeValue = rs.getInt("contract_type");
                    if (rs.wasNull()) {
                        dto.setContractType(0);
                        dto.setContractTypeLabel("Không xác định");
                    } else {
                        dto.setContractType(contractTypeValue);
                        try {
                            dto.setContractTypeLabel(
                                    ContractType.fromValue(contractTypeValue).getLabel());
                        } catch (IllegalArgumentException e) {
                            dto.setContractTypeLabel("Không xác định");
                        }
                    }

                    dto.setStartDate(rs.getDate("start_date"));
                    dto.setEndDate(rs.getDate("end_date"));
                    dto.setBaseSalary(rs.getDouble("base_salary"));

                    // ── Status: null-safe mapping ────────────────────────
                    int statusValue = rs.getInt("status");
                    if (rs.wasNull()) {
                        dto.setStatus(0);
                        dto.setStatusLabel("Không xác định");
                    } else {
                        dto.setStatus(statusValue);
                        try {
                            dto.setStatusLabel(
                                    ContractStatus.fromValue(statusValue).getLabel());
                        } catch (IllegalArgumentException e) {
                            dto.setStatusLabel("Không xác định");
                        }
                    }

                    dto.setDescription(rs.getString("description"));
                    dto.setFileUrl(hasFileUrl ? rs.getString("file_url") : null);

                    list.add(dto);

                } catch (Exception rowEx) {
                    // Log but NEVER skip the rest of the result set
                    System.err.println("[ContractDAO] Skipping bad row: " + rowEx.getMessage());
                    rowEx.printStackTrace();
                }
            }

        } catch (Exception e) {
            System.err.println("[ContractDAO] getAllContracts query failed:");
            e.printStackTrace();
        }

        return list;
    }

    /**
     * Check if a column exists in a table (MySQL INFORMATION_SCHEMA).
     * Used to safely handle schema changes before migration runs.
     */
    private boolean checkColumnExists(String tableName, String columnName) {
        String sql = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS " +
                "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?";
        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, tableName);
            ps.setString(2, columnName);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean createContract(Contract contract) {

        boolean hasFileUrl = checkColumnExists("contracts", "file_url");

        String sql;
        if (hasFileUrl) {
            sql = "INSERT INTO contracts " +
                    "(contract_number, employee_id, contract_type, start_date, end_date, " +
                    "base_salary, status, description, file_url) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        } else {
            sql = "INSERT INTO contracts " +
                    "(contract_number, employee_id, contract_type, start_date, end_date, " +
                    "base_salary, status, description) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        }

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setString(1, contract.getContractNumber());
            ps.setInt(2, contract.getEmployeeId());
            ps.setInt(3, contract.getContractType());
            ps.setDate(4, contract.getStartDate());

            if (contract.getEndDate() != null) {
                ps.setDate(5, contract.getEndDate());
            } else {
                ps.setNull(5, Types.DATE);
            }

            ps.setDouble(6, contract.getBaseSalary());
            ps.setInt(7, contract.getStatus());

            if (contract.getDescription() != null && !contract.getDescription().trim().isEmpty()) {
                ps.setString(8, contract.getDescription());
            } else {
                ps.setNull(8, Types.VARCHAR);
            }

            if (hasFileUrl) {
                if (contract.getFileUrl() != null && !contract.getFileUrl().trim().isEmpty()) {
                    ps.setString(9, contract.getFileUrl());
                } else {
                    ps.setNull(9, Types.VARCHAR);
                }
            }

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public boolean checkActiveContractExists(int employeeId) {

        String sql =
                "SELECT COUNT(*) FROM contracts " +
                        "WHERE employee_id = ? AND status = 1";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setInt(1, employeeId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public String getActiveContractNumber(int employeeId) {

        String sql =
                "SELECT contract_number FROM contracts " +
                        "WHERE employee_id = ? AND status = 1 LIMIT 1";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setInt(1, employeeId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getString("contract_number");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    @Override
    public boolean terminateContract(int contractId, Date terminateDate, String reason) {

        String sql =
                "UPDATE contracts " +
                        "SET status = 3, " +
                        "end_date = ?, " +
                        "description = CASE " +
                        "  WHEN description IS NULL THEN ? " +
                        "  ELSE CONCAT(description, '\\n[Terminated] ', ?) " +
                        "END " +
                        "WHERE id = ?";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setDate(1, terminateDate);

            String terminateNote = (reason != null && !reason.trim().isEmpty())
                    ? "[Terminated] " + reason.trim()
                    : "[Terminated]";

            ps.setString(2, terminateNote);
            ps.setString(3, reason != null ? reason.trim() : "");
            ps.setInt(4, contractId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public boolean updateStatus(int contractId, int newStatus) {

        String sql =
                "UPDATE contracts SET status = ? WHERE id = ?";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setInt(1, newStatus);
            ps.setInt(2, contractId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public int getContractTypeById(int contractId) {

        String sql = "SELECT contract_type FROM contracts WHERE id = ?";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, contractId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("contract_type");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return -1; // not found
    }

    @Override
    public boolean renewContract(int oldContractId, Contract newContract) {

        boolean hasFileUrl = checkColumnExists("contracts", "file_url");

        String expireOldSql =
                "UPDATE contracts SET status = 2 WHERE id = ?";

        String insertNewSql;
        if (hasFileUrl) {
            insertNewSql = "INSERT INTO contracts " +
                    "(contract_number, employee_id, contract_type, start_date, end_date, " +
                    "base_salary, status, description, file_url) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        } else {
            insertNewSql = "INSERT INTO contracts " +
                    "(contract_number, employee_id, contract_type, start_date, end_date, " +
                    "base_salary, status, description) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        }

        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            // 1. Expire old contract
            try (PreparedStatement psExpire = con.prepareStatement(expireOldSql)) {
                psExpire.setInt(1, oldContractId);
                psExpire.executeUpdate();
            }

            // 2. Insert new contract
            try (PreparedStatement psInsert = con.prepareStatement(insertNewSql)) {
                psInsert.setString(1, newContract.getContractNumber());
                psInsert.setInt(2, newContract.getEmployeeId());
                psInsert.setInt(3, newContract.getContractType());
                psInsert.setDate(4, newContract.getStartDate());

                if (newContract.getEndDate() != null) {
                    psInsert.setDate(5, newContract.getEndDate());
                } else {
                    psInsert.setNull(5, Types.DATE);
                }

                psInsert.setDouble(6, newContract.getBaseSalary());
                psInsert.setInt(7, newContract.getStatus());

                if (newContract.getDescription() != null && !newContract.getDescription().trim().isEmpty()) {
                    psInsert.setString(8, newContract.getDescription());
                } else {
                    psInsert.setNull(8, Types.VARCHAR);
                }

                if (hasFileUrl) {
                    if (newContract.getFileUrl() != null && !newContract.getFileUrl().trim().isEmpty()) {
                        psInsert.setString(9, newContract.getFileUrl());
                    } else {
                        psInsert.setNull(9, Types.VARCHAR);
                    }
                }

                psInsert.executeUpdate();
            }

            con.commit();
            return true;

        } catch (Exception e) {
            if (con != null) {
                try { con.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
            throw new RuntimeException(
                    "Thất bại hệ thống: Không thể xử lý quy trình gia hạn hợp đồng.");
        } finally {
            if (con != null) {
                try { con.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }
}
//Test commit, error can not see my commit