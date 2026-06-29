package com.hrm.project.dao.impl;

import com.hrm.project.dao.PayrollDAO;
import com.hrm.project.model.Payroll;
import com.hrm.project.model.PayrollDetail;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PayrollDAOImpl implements PayrollDAO {

    @Override
    public List<Payroll> getAllPayrolls() {
        List<Payroll> list = new ArrayList<>();
        String sql = "SELECT p.*, e1.full_name as created_name, e2.full_name as approved_name, e3.full_name as paid_name " +
                     "FROM payrolls p " +
                     "LEFT JOIN employees e1 ON p.created_by = e1.id " +
                     "LEFT JOIN employees e2 ON p.approved_by = e2.id " +
                     "LEFT JOIN employees e3 ON p.paid_by = e3.id " +
                     "ORDER BY p.year DESC, p.month DESC";
        try (Connection conn = DBConnection.getConnection()) {
            ensureApprovedPaidMetadataColumnsExist(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Payroll p = new Payroll();
                    p.setId(rs.getInt("id"));
                    p.setMonth(rs.getInt("month"));
                    p.setYear(rs.getInt("year"));
                    p.setStatus(rs.getString("status"));
                    p.setTotalEmployees(rs.getInt("total_employees"));
                    p.setTotalAmount(rs.getDouble("total_amount"));
                    p.setCreatedBy(rs.getInt("created_by"));
                    p.setApprovedBy(rs.getInt("approved_by"));
                    p.setApprovedAt(rs.getTimestamp("approved_at"));
                    p.setPaidBy(rs.getInt("paid_by"));
                    p.setPaidAt(rs.getTimestamp("paid_at"));
                    p.setCreatedAt(rs.getTimestamp("created_at"));
                    p.setUpdatedAt(rs.getTimestamp("updated_at"));
                    p.setCreatedByName(rs.getString("created_name"));
                    p.setApprovedByName(rs.getString("approved_name"));
                    p.setPaidByName(rs.getString("paid_name"));
                    list.add(p);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public Payroll getPayrollById(int id) {
        String sql = "SELECT p.*, e1.full_name as created_name, e2.full_name as approved_name, e3.full_name as paid_name " +
                     "FROM payrolls p " +
                     "LEFT JOIN employees e1 ON p.created_by = e1.id " +
                     "LEFT JOIN employees e2 ON p.approved_by = e2.id " +
                     "LEFT JOIN employees e3 ON p.paid_by = e3.id " +
                     "WHERE p.id = ?";
        try (Connection conn = DBConnection.getConnection()) {
            ensureApprovedPaidMetadataColumnsExist(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        Payroll p = new Payroll();
                        p.setId(rs.getInt("id"));
                        p.setMonth(rs.getInt("month"));
                        p.setYear(rs.getInt("year"));
                        p.setStatus(rs.getString("status"));
                        p.setTotalEmployees(rs.getInt("total_employees"));
                        p.setTotalAmount(rs.getDouble("total_amount"));
                        p.setCreatedBy(rs.getInt("created_by"));
                        p.setApprovedBy(rs.getInt("approved_by"));
                        p.setApprovedAt(rs.getTimestamp("approved_at"));
                        p.setPaidBy(rs.getInt("paid_by"));
                        p.setPaidAt(rs.getTimestamp("paid_at"));
                        p.setCreatedAt(rs.getTimestamp("created_at"));
                        p.setUpdatedAt(rs.getTimestamp("updated_at"));
                        p.setCreatedByName(rs.getString("created_name"));
                        p.setApprovedByName(rs.getString("approved_name"));
                        p.setPaidByName(rs.getString("paid_name"));
                        return p;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public Payroll getPayrollByMonthYear(int month, int year) {
        String sql = "SELECT * FROM payrolls WHERE month = ? AND year = ?";
        try (Connection conn = DBConnection.getConnection()) {
            ensureApprovedPaidMetadataColumnsExist(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, month);
                ps.setInt(2, year);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        Payroll p = new Payroll();
                        p.setId(rs.getInt("id"));
                        p.setStatus(rs.getString("status"));
                        return p;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<PayrollDetail> getPayrollDetails(int payrollId) {
        List<PayrollDetail> list = new ArrayList<>();
        String sql = "SELECT pd.*, e.full_name, e.employee_code, d.name as dept_name, pos.name as pos_name " +
                     "FROM payroll_details pd " +
                     "JOIN employees e ON pd.employee_id = e.id " +
                     "LEFT JOIN departments d ON e.department_id = d.id " +
                     "LEFT JOIN positions pos ON e.position_id = pos.id " +
                     "WHERE pd.payroll_id = ? " +
                     "ORDER BY e.employee_code ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, payrollId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PayrollDetail d = new PayrollDetail();
                    d.setId(rs.getInt("id"));
                    d.setPayrollId(rs.getInt("payroll_id"));
                    d.setEmployeeId(rs.getInt("employee_id"));
                    d.setBasicSalary(rs.getDouble("basic_salary"));
                    d.setAllowanceAmount(rs.getDouble("allowance_amount"));
                    d.setInsuranceDeduction(rs.getDouble("insurance_deduction"));
                    d.setTaxDeduction(rs.getDouble("tax_deduction"));
                    d.setUnpaidLeaveDeduction(rs.getDouble("unpaid_leave_deduction"));
                    d.setNetSalary(rs.getDouble("net_salary"));
                    d.setNotes(rs.getString("notes"));
                    d.setEmployeeName(rs.getString("full_name"));
                    d.setEmployeeCode(rs.getString("employee_code"));
                    d.setDepartmentName(rs.getString("dept_name"));
                    d.setPositionName(rs.getString("pos_name"));
                    list.add(d);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<PayrollDetail> getEmployeeSalaryHistory(int employeeId) {
        List<PayrollDetail> list = new ArrayList<>();
        String sql = "SELECT pd.*, p.month, p.year, p.status, e.full_name, e.employee_code, d.name as dept_name, pos.name as pos_name, ats.standard_days, ats.actual_worked_days " +
                     "FROM payroll_details pd " +
                     "JOIN payrolls p ON pd.payroll_id = p.id " +
                     "JOIN employees e ON pd.employee_id = e.id " +
                     "LEFT JOIN departments d ON e.department_id = d.id " +
                     "LEFT JOIN positions pos ON e.position_id = pos.id " +
                     "LEFT JOIN attendance_summary ats ON ats.employee_id = e.id AND ats.month = p.month AND ats.year = p.year " +
                     "WHERE pd.employee_id = ? AND p.status IN ('APPROVED', 'PAID') " +
                     "ORDER BY p.year DESC, p.month DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PayrollDetail d = new PayrollDetail();
                    d.setId(rs.getInt("id"));
                    d.setPayrollId(rs.getInt("payroll_id"));
                    d.setEmployeeId(rs.getInt("employee_id"));
                    d.setBasicSalary(rs.getDouble("basic_salary"));
                    d.setAllowanceAmount(rs.getDouble("allowance_amount"));
                    d.setInsuranceDeduction(rs.getDouble("insurance_deduction"));
                    d.setTaxDeduction(rs.getDouble("tax_deduction"));
                    d.setUnpaidLeaveDeduction(rs.getDouble("unpaid_leave_deduction"));
                    d.setNetSalary(rs.getDouble("net_salary"));
                    d.setNotes(rs.getString("notes"));
                    d.setEmployeeName(rs.getString("full_name"));
                    d.setEmployeeCode(rs.getString("employee_code"));
                    d.setDepartmentName(rs.getString("dept_name"));
                    d.setPositionName(rs.getString("pos_name"));
                    d.setMonth(rs.getInt("month"));
                    d.setYear(rs.getInt("year"));
                    d.setStatus(rs.getString("status"));
                    d.setStandardDays(rs.getInt("standard_days"));
                    d.setActualDays(rs.getInt("actual_worked_days"));
                    list.add(d);
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return list;
    }

    @Override
    public int countEmployeesMissingAttendanceSummary(int month, int year) {
        String sql = "SELECT COUNT(*) FROM employees e " +
                     "JOIN user_accounts ua ON e.id = ua.employee_id " +
                     "WHERE ua.is_active = 1 AND e.status != 'TERMINATED' " +
                     "AND NOT EXISTS (" +
                     "   SELECT 1 FROM attendance_summary ats " +
                     "   WHERE ats.employee_id = e.id AND ats.month = ? AND ats.year = ?" +
                     ")";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, month);
            ps.setInt(2, year);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1; // Indicate error
    }

    @Override
    public PayrollDetail getPayrollDetailById(int detailId) {
        String sql = "SELECT pd.*, p.month, p.year, p.status, e.full_name, e.employee_code, d.name as dept_name, pos.name as pos_name " +
                     "FROM payroll_details pd " +
                     "JOIN payrolls p ON pd.payroll_id = p.id " +
                     "JOIN employees e ON pd.employee_id = e.id " +
                     "LEFT JOIN departments d ON e.department_id = d.id " +
                     "LEFT JOIN positions pos ON e.position_id = pos.id " +
                     "WHERE pd.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, detailId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    PayrollDetail d = new PayrollDetail();
                    d.setId(rs.getInt("id"));
                    d.setPayrollId(rs.getInt("payroll_id"));
                    d.setEmployeeId(rs.getInt("employee_id"));
                    d.setBasicSalary(rs.getDouble("basic_salary"));
                    d.setAllowanceAmount(rs.getDouble("allowance_amount"));
                    d.setInsuranceDeduction(rs.getDouble("insurance_deduction"));
                    d.setTaxDeduction(rs.getDouble("tax_deduction"));
                    d.setUnpaidLeaveDeduction(rs.getDouble("unpaid_leave_deduction"));
                    d.setNetSalary(rs.getDouble("net_salary"));
                    d.setNotes(rs.getString("notes"));
                    d.setEmployeeName(rs.getString("full_name"));
                    d.setEmployeeCode(rs.getString("employee_code"));
                    d.setDepartmentName(rs.getString("dept_name"));
                    d.setPositionName(rs.getString("pos_name"));
                    d.setMonth(rs.getInt("month"));
                    d.setYear(rs.getInt("year"));
                    d.setStatus(rs.getString("status"));
                    return d;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    private void syncAttendanceSummary(int month, int year) {
        try (Connection conn = DBConnection.getConnection()) {
            ensureAttendanceSummaryTableExists(conn);
            String sql = "INSERT INTO attendance_summary (employee_id, month, year, standard_days, actual_worked_days, paid_leave_days, unpaid_leave_days) " +
                         "SELECT e.id, ?, ?, 26.00, " +
                         "       COALESCE(SUM(CASE WHEN a.status IN ('PRESENT', 'LATE', 'EARLY_LEAVE') THEN 1 ELSE 0 END), 0) AS actual_worked, " +
                         "       COALESCE(SUM(CASE WHEN a.status IN ('LEAVE', 'HOLIDAY') THEN 1 ELSE 0 END), 0) AS paid_leave, " +
                         "       GREATEST(0, 26.00 - COALESCE(SUM(CASE WHEN a.status IN ('PRESENT', 'LATE', 'EARLY_LEAVE') THEN 1 ELSE 0 END), 0) - COALESCE(SUM(CASE WHEN a.status IN ('LEAVE', 'HOLIDAY') THEN 1 ELSE 0 END), 0)) AS unpaid_leave " +
                         "FROM employees e " +
                         "JOIN user_accounts ua ON e.id = ua.employee_id " +
                         "LEFT JOIN attendance a ON e.id = a.employee_id AND MONTH(a.date) = ? AND YEAR(a.date) = ? " +
                         "WHERE ua.is_active = 1 AND e.status != 'TERMINATED' " +
                         "GROUP BY e.id " +
                         "ON DUPLICATE KEY UPDATE " +
                         "actual_worked_days = VALUES(actual_worked_days), " +
                         "paid_leave_days = VALUES(paid_leave_days), " +
                         "unpaid_leave_days = GREATEST(0, standard_days - VALUES(actual_worked_days) - VALUES(paid_leave_days))";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, month);
                ps.setInt(2, year);
                ps.setInt(3, month);
                ps.setInt(4, year);
                ps.executeUpdate();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    @Override
    public boolean generatePayroll(int month, int year, int createdBy) throws Exception {
        syncAttendanceSummary(month, year);
        
        int missingCount = countEmployeesMissingAttendanceSummary(month, year);
        if (missingCount < 0) {
            throw new Exception("Lỗi hệ thống khi kiểm tra bảng công.");
        } else if (missingCount > 0) {
            throw new Exception("Không thể tính lương vì thiếu bảng công của " + missingCount + " nhân viên.");
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            ensureAttendanceSummaryTableExists(conn);
            conn.setAutoCommit(false);

            // 1. Check if payroll already exists for this month/year
            String checkSql = "SELECT id, status FROM payrolls WHERE month = ? AND year = ?";
            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setInt(1, month);
                checkPs.setInt(2, year);
                try (ResultSet rs = checkPs.executeQuery()) {
                    if (rs.next()) {
                        String existingStatus = rs.getString("status");
                        if ("APPROVED".equals(existingStatus) || "PAID".equals(existingStatus)) {
                            // Block generation
                            if (conn != null) conn.rollback();
                            return false;
                        }
                        // Delete old DRAFT payroll and its details to regenerate
                        int oldId = rs.getInt("id");
                        try (PreparedStatement delPs = conn.prepareStatement("DELETE FROM payrolls WHERE id = ?")) {
                            delPs.setInt(1, oldId);
                            delPs.executeUpdate();
                        }
                    }
                }
            }

            // 2. Insert new draft payroll
            String insPayroll = "INSERT INTO payrolls (month, year, status, created_by) VALUES (?, ?, 'DRAFT', ?)";
            int payrollId = 0;
            try (PreparedStatement psIns = conn.prepareStatement(insPayroll, Statement.RETURN_GENERATED_KEYS)) {
                psIns.setInt(1, month);
                psIns.setInt(2, year);
                psIns.setInt(3, createdBy);
                psIns.executeUpdate();
                try (ResultSet rsKeys = psIns.getGeneratedKeys()) {
                    if (rsKeys.next()) {
                        payrollId = rsKeys.getInt(1);
                    }
                }
            }

            // 3. Fetch all active employees with their basic salaries, allowances, insurances, and unpaid leaves
            String employeeDataSql = 
                "SELECT e.id, " +
                "       COALESCE(ss.basic_salary, ic.base_salary, 0) as basic_salary, " +
                "       (SELECT COALESCE(SUM(at.amount), 0) FROM employee_allowances ea JOIN allowance_types at ON ea.allowance_type_id = at.id WHERE ea.employee_id = e.id) as allowance_amount, " +
                "       COALESCE(ic.total_amount, 0) as insurance_deduction, " +
                "       COALESCE(ats.unpaid_leave_days, 0) as unpaid_leave_days, " +
                "       COALESCE(ats.standard_days, 26.0) as standard_days " +
                "FROM employees e " +
                "JOIN user_accounts ua ON e.id = ua.employee_id " +
                "LEFT JOIN salary_scales ss ON e.salary_scale_id = ss.id " +
                "LEFT JOIN insurance_config ic ON e.id = ic.employee_id " +
                "LEFT JOIN attendance_summary ats ON ats.employee_id = e.id AND ats.month = ? AND ats.year = ? " +
                "WHERE ua.is_active = 1 AND e.status != 'TERMINATED'";

            int totalEmployees = 0;
            double grandTotalAmount = 0;

            String insDetailSql = "INSERT INTO payroll_details (payroll_id, employee_id, basic_salary, allowance_amount, insurance_deduction, tax_deduction, unpaid_leave_deduction, net_salary) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement empPs = conn.prepareStatement(employeeDataSql);
                 PreparedStatement detPs = conn.prepareStatement(insDetailSql)) {
                empPs.setInt(1, month);
                empPs.setInt(2, year);
                
                try (ResultSet rs = empPs.executeQuery()) {
                    while (rs.next()) {
                        int empId = rs.getInt("id");
                        double basicSalary = rs.getDouble("basic_salary");
                        double allowance = rs.getDouble("allowance_amount");
                        double insurance = rs.getDouble("insurance_deduction");
                        double unpaidDays = rs.getDouble("unpaid_leave_days");
                        double standardDays = rs.getDouble("standard_days");
                        
                        double unpaidDeduction = (basicSalary / standardDays) * unpaidDays;
                        double tax = 0; // Skip tax for now
                        
                        double netSalary = basicSalary + allowance - insurance - unpaidDeduction - tax;
                        if (netSalary < 0) netSalary = 0; // Prevent negative salary
                        
                        detPs.setInt(1, payrollId);
                        detPs.setInt(2, empId);
                        detPs.setDouble(3, basicSalary);
                        detPs.setDouble(4, allowance);
                        detPs.setDouble(5, insurance);
                        detPs.setDouble(6, tax);
                        detPs.setDouble(7, unpaidDeduction);
                        detPs.setDouble(8, netSalary);
                        detPs.addBatch();
                        
                        totalEmployees++;
                        grandTotalAmount += netSalary;
                    }
                    detPs.executeBatch();
                }
            }

            // 4. Update total numbers in payrolls table
            String updatePayroll = "UPDATE payrolls SET total_employees = ?, total_amount = ? WHERE id = ?";
            try (PreparedStatement upPs = conn.prepareStatement(updatePayroll)) {
                upPs.setInt(1, totalEmployees);
                upPs.setDouble(2, grandTotalAmount);
                upPs.setInt(3, payrollId);
                upPs.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    @Override
    public boolean updatePayrollStatus(int id, String status, int userId) {
        String expectedOldStatus = "DRAFT";
        String sql = "";
        if ("APPROVED".equals(status)) {
            expectedOldStatus = "DRAFT";
            sql = "UPDATE payrolls SET status = ?, approved_by = ?, approved_at = NOW(), updated_at = NOW() WHERE id = ? AND status = ?";
        } else if ("PAID".equals(status)) {
            expectedOldStatus = "APPROVED";
            sql = "UPDATE payrolls SET status = ?, paid_by = ?, paid_at = NOW(), updated_at = NOW() WHERE id = ? AND status = ?";
        } else {
            return false;
        }

        try (Connection conn = DBConnection.getConnection()) {
            ensureApprovedPaidMetadataColumnsExist(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, status);
                ps.setInt(2, userId);
                ps.setInt(3, id);
                ps.setString(4, expectedOldStatus);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public List<Payroll> getPayrolls(Integer year, String searchKeyword, int offset, int limit) {
        List<Payroll> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT p.*, e1.full_name as created_name, e2.full_name as approved_name, e3.full_name as paid_name ");
        sql.append("FROM payrolls p ");
        sql.append("LEFT JOIN employees e1 ON p.created_by = e1.id ");
        sql.append("LEFT JOIN employees e2 ON p.approved_by = e2.id ");
        sql.append("LEFT JOIN employees e3 ON p.paid_by = e3.id ");
        sql.append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();
        if (year != null) {
            sql.append("AND p.year = ? ");
            params.add(year);
        }
        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            sql.append("AND (p.month LIKE ? OR p.year LIKE ? OR p.status LIKE ?) ");
            String kw = "%" + searchKeyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        sql.append("ORDER BY p.year DESC, p.month DESC LIMIT ? OFFSET ?");
        params.add(limit);
        params.add(offset);

        try (Connection conn = DBConnection.getConnection()) {
            ensureApprovedPaidMetadataColumnsExist(conn);
            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                for (int i = 0; i < params.size(); i++) {
                    ps.setObject(i + 1, params.get(i));
                }
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Payroll p = new Payroll();
                        p.setId(rs.getInt("id"));
                        p.setMonth(rs.getInt("month"));
                        p.setYear(rs.getInt("year"));
                        p.setStatus(rs.getString("status"));
                        p.setTotalEmployees(rs.getInt("total_employees"));
                        p.setTotalAmount(rs.getDouble("total_amount"));
                        p.setCreatedBy(rs.getInt("created_by"));
                        p.setApprovedBy(rs.getInt("approved_by"));
                        p.setApprovedAt(rs.getTimestamp("approved_at"));
                        p.setPaidBy(rs.getInt("paid_by"));
                        p.setPaidAt(rs.getTimestamp("paid_at"));
                        p.setCreatedAt(rs.getTimestamp("created_at"));
                        p.setUpdatedAt(rs.getTimestamp("updated_at"));
                        p.setCreatedByName(rs.getString("created_name"));
                        p.setApprovedByName(rs.getString("approved_name"));
                        p.setPaidByName(rs.getString("paid_name"));
                        list.add(p);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public int getTotalPayrollsCount(Integer year, String searchKeyword) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM payrolls p WHERE 1=1 ");
        List<Object> params = new ArrayList<>();
        if (year != null) {
            sql.append("AND p.year = ? ");
            params.add(year);
        }
        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            sql.append("AND (p.month LIKE ? OR p.year LIKE ? OR p.status LIKE ?) ");
            String kw = "%" + searchKeyword.trim() + "%";
            params.add(kw);
            params.add(kw);
            params.add(kw);
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public double getTotalAmountYTD(int year) {
        String sql = "SELECT SUM(total_amount) FROM payrolls WHERE year = ? AND status IN ('APPROVED', 'PAID')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    private void ensureAttendanceSummaryTableExists(Connection conn) {
        String checkSql = "SHOW TABLES LIKE 'attendance_summary'";
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
            String createSql = "CREATE TABLE IF NOT EXISTS attendance_summary (" +
                               "    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY," +
                               "    employee_id INT UNSIGNED NOT NULL," +
                               "    month INT NOT NULL," +
                               "    year INT NOT NULL," +
                               "    standard_days DECIMAL(5,2) NOT NULL DEFAULT 26.00," +
                               "    actual_worked_days DECIMAL(5,2) NOT NULL DEFAULT 0.00," +
                               "    paid_leave_days DECIMAL(5,2) NOT NULL DEFAULT 0.00," +
                               "    unpaid_leave_days DECIMAL(5,2) NOT NULL DEFAULT 0.00," +
                               "    created_at DATETIME DEFAULT CURRENT_TIMESTAMP," +
                               "    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP," +
                               "    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE," +
                               "    UNIQUE KEY uq_employee_month_year (employee_id, month, year)" +
                               ") COMMENT='Tổng hợp công theo tháng của nhân viên'";
            try (Statement stmt = conn.createStatement()) {
                stmt.execute(createSql);
                System.out.println("Programmatically created attendance_summary table.");
                
                // Seed dummy data
                String seedSql1 = "INSERT INTO attendance_summary (employee_id, month, year, standard_days, actual_worked_days, paid_leave_days, unpaid_leave_days) " +
                                  "SELECT id, 6, 2026, 26.00, 24.00, 1.00, 1.00 FROM employees " +
                                  "ON DUPLICATE KEY UPDATE actual_worked_days=24.00";
                String seedSql2 = "INSERT INTO attendance_summary (employee_id, month, year, standard_days, actual_worked_days, paid_leave_days, unpaid_leave_days) " +
                                  "SELECT id, 5, 2026, 26.00, 26.00, 0.00, 0.00 FROM employees " +
                                  "ON DUPLICATE KEY UPDATE actual_worked_days=26.00";
                stmt.execute(seedSql1);
                stmt.execute(seedSql2);
                System.out.println("Programmatically seeded attendance_summary dummy data.");
            } catch (SQLException e) {
                System.err.println("Failed to programmatically create or seed attendance_summary table: " + e.getMessage());
            }
        }
        ensureApprovedPaidMetadataColumnsExist(conn);
    }

    private void ensureApprovedPaidMetadataColumnsExist(Connection conn) {
        boolean approvedAtExists = false;
        try (ResultSet rs = conn.getMetaData().getColumns(null, null, "payrolls", "approved_at")) {
            if (rs.next()) {
                approvedAtExists = true;
            }
        } catch (SQLException e) {
            // Ignore
        }
        
        if (!approvedAtExists) {
            try (Statement stmt = conn.createStatement()) {
                stmt.execute("ALTER TABLE payrolls ADD COLUMN approved_at DATETIME NULL AFTER approved_by");
                stmt.execute("ALTER TABLE payrolls ADD COLUMN paid_by INT UNSIGNED NULL AFTER approved_at");
                stmt.execute("ALTER TABLE payrolls ADD COLUMN paid_at DATETIME NULL AFTER paid_by");
                stmt.execute("ALTER TABLE payrolls ADD CONSTRAINT fk_payroll_paid_by FOREIGN KEY (paid_by) REFERENCES employees(id) ON DELETE SET NULL");
                System.out.println("Programmatically added approved_at, paid_by, paid_at columns to payrolls.");
            } catch (SQLException e) {
                System.err.println("Failed to programmatically add approved/paid metadata columns: " + e.getMessage());
            }
        }
    }
}

