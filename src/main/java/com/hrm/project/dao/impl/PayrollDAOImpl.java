package com.hrm.project.dao.impl;

import com.hrm.project.dao.PayrollDAO;
import com.hrm.project.model.Payroll;
import com.hrm.project.model.PayrollDetail;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PayrollDAOImpl implements PayrollDAO {

    // ── Biểu thuế lũy tiến VN 7 bậc ──
    // Giảm trừ bản thân: 11,000,000 VND/tháng
    // Giảm trừ người phụ thuộc: 4,400,000 VND/người/tháng
    private static final double PERSONAL_DEDUCTION = 11_000_000;
    private static final double DEPENDENT_DEDUCTION = 4_400_000;

    private static final double[] TAX_BRACKETS = {5_000_000, 10_000_000, 18_000_000, 32_000_000, 52_000_000, 80_000_000};
    private static final double[] TAX_RATES = {0.05, 0.10, 0.15, 0.20, 0.25, 0.30, 0.35};

    /**
     * Tính thuế TNCN theo biểu lũy tiến 7 bậc.
     * @param taxableIncome Thu nhập chịu thuế (sau giảm trừ)
     */
    private double calculatePersonalIncomeTax(double taxableIncome) {
        if (taxableIncome <= 0) return 0;
        double tax = 0;
        double remaining = taxableIncome;
        double prevBracket = 0;
        for (int i = 0; i < TAX_BRACKETS.length; i++) {
            double bracketSize = TAX_BRACKETS[i] - prevBracket;
            if (remaining <= bracketSize) {
                tax += remaining * TAX_RATES[i];
                return tax;
            }
            tax += bracketSize * TAX_RATES[i];
            remaining -= bracketSize;
            prevBracket = TAX_BRACKETS[i];
        }
        // Bậc 7: phần trên 80 triệu
        tax += remaining * TAX_RATES[6];
        return tax;
    }

    // ── Helper: read Payroll from ResultSet ──
    private Payroll readPayroll(ResultSet rs) throws SQLException {
        Payroll p = new Payroll();
        p.setId(rs.getInt("id"));
        p.setMonth(rs.getInt("month"));
        p.setYear(rs.getInt("year"));
        p.setStatus(rs.getString("status"));
        p.setTotalEmployees(rs.getInt("total_employees"));
        p.setTotalAmount(rs.getDouble("total_amount"));
        p.setCreatedBy(rs.getInt("created_by"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        p.setUpdatedAt(rs.getTimestamp("updated_at"));
        // Legacy columns
        try { p.setApprovedBy(rs.getInt("approved_by")); } catch (SQLException ignored) {}
        try { p.setApprovedAt(rs.getTimestamp("approved_at")); } catch (SQLException ignored) {}
        try { p.setPaidBy(rs.getInt("paid_by")); } catch (SQLException ignored) {}
        try { p.setPaidAt(rs.getTimestamp("paid_at")); } catch (SQLException ignored) {}
        // New flow columns
        try { p.setManagerConfirmedBy(rs.getInt("manager_confirmed_by")); } catch (SQLException ignored) {}
        try { p.setManagerConfirmedAt(rs.getTimestamp("manager_confirmed_at")); } catch (SQLException ignored) {}
        try { p.setHrConfirmedBy(rs.getInt("hr_confirmed_by")); } catch (SQLException ignored) {}
        try { p.setHrConfirmedAt(rs.getTimestamp("hr_confirmed_at")); } catch (SQLException ignored) {}
        try { p.setFinalizedBy(rs.getInt("finalized_by")); } catch (SQLException ignored) {}
        try { p.setFinalizedAt(rs.getTimestamp("finalized_at")); } catch (SQLException ignored) {}
        return p;
    }

    private Payroll readPayrollWithNames(ResultSet rs) throws SQLException {
        Payroll p = readPayroll(rs);
        try { p.setCreatedByName(rs.getString("created_name")); } catch (SQLException ignored) {}
        try { p.setManagerConfirmedByName(rs.getString("mgr_confirmed_name")); } catch (SQLException ignored) {}
        try { p.setHrConfirmedByName(rs.getString("hr_confirmed_name")); } catch (SQLException ignored) {}
        try { p.setFinalizedByName(rs.getString("finalized_name")); } catch (SQLException ignored) {}
        // Legacy
        try { p.setApprovedByName(rs.getString("approved_name")); } catch (SQLException ignored) {}
        try { p.setPaidByName(rs.getString("paid_name")); } catch (SQLException ignored) {}
        return p;
    }

    private static final String PAYROLL_SELECT_WITH_NAMES =
            "SELECT p.*, " +
            "e1.full_name as created_name, " +
            "e2.full_name as approved_name, " +
            "e3.full_name as paid_name, " +
            "e4.full_name as mgr_confirmed_name, " +
            "e5.full_name as hr_confirmed_name, " +
            "e6.full_name as finalized_name " +
            "FROM payrolls p " +
            "LEFT JOIN employees e1 ON p.created_by = e1.id " +
            "LEFT JOIN employees e2 ON p.approved_by = e2.id " +
            "LEFT JOIN employees e3 ON p.paid_by = e3.id " +
            "LEFT JOIN employees e4 ON p.manager_confirmed_by = e4.id " +
            "LEFT JOIN employees e5 ON p.hr_confirmed_by = e5.id " +
            "LEFT JOIN employees e6 ON p.finalized_by = e6.id ";

    // ── Helper: read PayrollDetail from ResultSet ──
    private PayrollDetail readDetail(ResultSet rs) throws SQLException {
        PayrollDetail d = new PayrollDetail();
        d.setId(rs.getInt("id"));
        d.setPayrollId(rs.getInt("payroll_id"));
        d.setEmployeeId(rs.getInt("employee_id"));
        // Block 1
        d.setBasicSalary(rs.getDouble("basic_salary"));
        try { d.setStandardDays(rs.getDouble("standard_days")); } catch (SQLException ignored) {}
        try { d.setActualWorkedDays(rs.getDouble("actual_worked_days")); } catch (SQLException ignored) {}
        try { d.setPaidLeaveDays(rs.getDouble("paid_leave_days")); } catch (SQLException ignored) {}
        try { d.setUnpaidLeaveDays(rs.getDouble("unpaid_leave_days")); } catch (SQLException ignored) {}
        try { d.setSickLeaveDays(rs.getDouble("sick_leave_days")); } catch (SQLException ignored) {}
        d.setUnpaidLeaveDeduction(rs.getDouble("unpaid_leave_deduction"));
        // Block 2
        d.setAllowanceAmount(rs.getDouble("allowance_amount"));
        try { d.setBhxhDeduction(rs.getDouble("bhxh_deduction")); } catch (SQLException ignored) {}
        try { d.setBhytDeduction(rs.getDouble("bhyt_deduction")); } catch (SQLException ignored) {}
        try { d.setBhtnDeduction(rs.getDouble("bhtn_deduction")); } catch (SQLException ignored) {}
        d.setInsuranceDeduction(rs.getDouble("insurance_deduction"));
        // Block 3
        try { d.setGrossSalary(rs.getDouble("gross_salary")); } catch (SQLException ignored) {}
        d.setTaxDeduction(rs.getDouble("tax_deduction"));
        d.setNetSalary(rs.getDouble("net_salary"));
        // Metadata
        d.setNotes(rs.getString("notes"));
        try { d.setDepartmentId(rs.getInt("department_id")); } catch (SQLException ignored) {}
        try { d.setPositionId(rs.getInt("position_id")); } catch (SQLException ignored) {}
        return d;
    }

    @Override
    public List<Payroll> getAllPayrolls() {
        List<Payroll> list = new ArrayList<>();
        String sql = PAYROLL_SELECT_WITH_NAMES + "ORDER BY p.year DESC, p.month DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(readPayrollWithNames(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public Payroll getPayrollById(int id) {
        String sql = PAYROLL_SELECT_WITH_NAMES + "WHERE p.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return readPayrollWithNames(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public Payroll getPayrollByMonthYear(int month, int year) {
        String sql = "SELECT * FROM payrolls WHERE month = ? AND year = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, month);
            ps.setInt(2, year);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return readPayroll(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public List<PayrollDetail> getPayrollDetails(int payrollId) {
        return getPayrollDetailsByDepartment(payrollId, -1);
    }

    @Override
    public List<PayrollDetail> getPayrollDetailsByDepartment(int payrollId, int departmentId) {
        List<PayrollDetail> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT pd.*, e.full_name, e.employee_code, d.name as dept_name, pos.name as pos_name " +
            "FROM payroll_details pd " +
            "JOIN employees e ON pd.employee_id = e.id " +
            "LEFT JOIN departments d ON pd.department_id = d.id " +
            "LEFT JOIN positions pos ON pd.position_id = pos.id " +
            "WHERE pd.payroll_id = ? ");
        if (departmentId > 0) {
            sql.append("AND pd.department_id = ? ");
        }
        sql.append("ORDER BY d.name, e.employee_code ASC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            ps.setInt(1, payrollId);
            if (departmentId > 0) {
                ps.setInt(2, departmentId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PayrollDetail d = readDetail(rs);
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
        String sql = "SELECT pd.*, p.month, p.year, p.status, e.full_name, e.employee_code, " +
                     "d.name as dept_name, pos.name as pos_name " +
                     "FROM payroll_details pd " +
                     "JOIN payrolls p ON pd.payroll_id = p.id " +
                     "JOIN employees e ON pd.employee_id = e.id " +
                     "LEFT JOIN departments d ON pd.department_id = d.id " +
                     "LEFT JOIN positions pos ON pd.position_id = pos.id " +
                     "WHERE pd.employee_id = ? AND p.status IN ('HR_FINALIZED', 'APPROVED', 'PAID') " +
                     "ORDER BY p.year DESC, p.month DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PayrollDetail d = readDetail(rs);
                    d.setEmployeeName(rs.getString("full_name"));
                    d.setEmployeeCode(rs.getString("employee_code"));
                    d.setDepartmentName(rs.getString("dept_name"));
                    d.setPositionName(rs.getString("pos_name"));
                    d.setMonth(rs.getInt("month"));
                    d.setYear(rs.getInt("year"));
                    d.setStatus(rs.getString("status"));
                    list.add(d);
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
        return list;
    }

    @Override
    public PayrollDetail getPayrollDetailById(int detailId) {
        String sql = "SELECT pd.*, p.month, p.year, p.status, e.full_name, e.employee_code, " +
                     "d.name as dept_name, pos.name as pos_name " +
                     "FROM payroll_details pd " +
                     "JOIN payrolls p ON pd.payroll_id = p.id " +
                     "JOIN employees e ON pd.employee_id = e.id " +
                     "LEFT JOIN departments d ON pd.department_id = d.id " +
                     "LEFT JOIN positions pos ON pd.position_id = pos.id " +
                     "WHERE pd.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, detailId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    PayrollDetail d = readDetail(rs);
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
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    private void syncAttendanceSummary(int month, int year) {
        try (Connection conn = DBConnection.getConnection()) {
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
            conn.setAutoCommit(false);

            // 1. Check existing payroll
            String checkSql = "SELECT id, status FROM payrolls WHERE month = ? AND year = ?";
            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setInt(1, month);
                checkPs.setInt(2, year);
                try (ResultSet rs = checkPs.executeQuery()) {
                    if (rs.next()) {
                        String existingStatus = rs.getString("status");
                        if ("HR_FINALIZED".equals(existingStatus) || "APPROVED".equals(existingStatus) || "PAID".equals(existingStatus)) {
                            conn.rollback();
                            return false;
                        }
                        // Delete old DRAFT/MANAGER_CONFIRMED to regenerate
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
                    if (rsKeys.next()) payrollId = rsKeys.getInt(1);
                }
            }

            // 3. Fetch active employees with:
            //    - Lương từ hợp đồng (contracts.base_salary WHERE status = 1)
            //    - Phụ cấp từ position (position_allowances → allowance_types)
            //    - Bảo hiểm từ insurance_config
            //    - Ngày công từ attendance_summary
            //    - Số người phụ thuộc cho tính thuế
            String employeeDataSql =
                "SELECT e.id, e.department_id, e.position_id, " +
                "       COALESCE(e.num_dependents, 0) as num_dependents, " +
                "       COALESCE(c.base_salary, 0) as basic_salary, " +
                "       COALESCE(pa_sum.total_allowance, 0) as allowance_amount, " +
                "       COALESCE(ic.bhxh_rate, 0) as bhxh_rate, " +
                "       COALESCE(ic.bhyt_rate, 0) as bhyt_rate, " +
                "       COALESCE(ic.bhtn_rate, 0) as bhtn_rate, " +
                "       COALESCE(ic.base_salary, c.base_salary, 0) as insurance_base_salary, " +
                "       COALESCE(ats.standard_days, 26.0) as standard_days, " +
                "       COALESCE(ats.actual_worked_days, 0) as actual_worked_days, " +
                "       COALESCE(ats.paid_leave_days, 0) as paid_leave_days, " +
                "       COALESCE(ats.unpaid_leave_days, 0) as unpaid_leave_days " +
                "FROM employees e " +
                "JOIN user_accounts ua ON e.id = ua.employee_id " +
                // Lấy lương từ hợp đồng active
                "LEFT JOIN contracts c ON c.employee_id = e.id AND c.status = 1 " +
                // Lấy tổng phụ cấp theo position
                "LEFT JOIN (" +
                "    SELECT pa.position_id, SUM(at.amount) as total_allowance " +
                "    FROM position_allowances pa " +
                "    JOIN allowance_types at ON pa.allowance_type_id = at.id AND at.is_active = 1 " +
                "    GROUP BY pa.position_id" +
                ") pa_sum ON pa_sum.position_id = e.position_id " +
                // Bảo hiểm
                "LEFT JOIN insurance_config ic ON e.id = ic.employee_id AND ic.is_active = 1 " +
                // Ngày công
                "LEFT JOIN attendance_summary ats ON ats.employee_id = e.id AND ats.month = ? AND ats.year = ? " +
                "WHERE ua.is_active = 1 AND e.status != 'TERMINATED'";

            int totalEmployees = 0;
            double grandTotalAmount = 0;

            String insDetailSql = "INSERT INTO payroll_details (" +
                "payroll_id, employee_id, basic_salary, " +
                "standard_days, actual_worked_days, paid_leave_days, unpaid_leave_days, sick_leave_days, unpaid_leave_deduction, " +
                "allowance_amount, bhxh_deduction, bhyt_deduction, bhtn_deduction, insurance_deduction, " +
                "gross_salary, tax_deduction, net_salary, " +
                "department_id, position_id" +
                ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            try (PreparedStatement empPs = conn.prepareStatement(employeeDataSql);
                 PreparedStatement detPs = conn.prepareStatement(insDetailSql)) {
                empPs.setInt(1, month);
                empPs.setInt(2, year);

                try (ResultSet rs = empPs.executeQuery()) {
                    while (rs.next()) {
                        int empId = rs.getInt("id");
                        int deptId = rs.getInt("department_id");
                        int posId = rs.getInt("position_id");
                        int numDependents = rs.getInt("num_dependents");

                        // Block 1: Lương & Ngày công
                        double basicSalary = rs.getDouble("basic_salary");
                        double standardDays = rs.getDouble("standard_days");
                        double actualWorkedDays = rs.getDouble("actual_worked_days");
                        double paidLeaveDays = rs.getDouble("paid_leave_days");
                        double unpaidLeaveDays = rs.getDouble("unpaid_leave_days");
                        double sickLeaveDays = 0; // TODO: integrate sick leave from attendance if tracked separately
                        double unpaidDeduction = standardDays > 0 ? (basicSalary / standardDays) * unpaidLeaveDays : 0;

                        // Block 2: Phụ cấp & Bảo hiểm
                        double allowance = rs.getDouble("allowance_amount");
                        double insuranceBaseSalary = rs.getDouble("insurance_base_salary");
                        double bhxhRate = rs.getDouble("bhxh_rate");
                        double bhytRate = rs.getDouble("bhyt_rate");
                        double bhtnRate = rs.getDouble("bhtn_rate");
                        double bhxh = insuranceBaseSalary * bhxhRate / 100.0;
                        double bhyt = insuranceBaseSalary * bhytRate / 100.0;
                        double bhtn = insuranceBaseSalary * bhtnRate / 100.0;
                        double totalInsurance = bhxh + bhyt + bhtn;

                        // Block 3: Thuế & Lương thực nhận
                        double grossSalary = basicSalary + allowance - unpaidDeduction;
                        // Thu nhập chịu thuế = Gross - Bảo hiểm - Giảm trừ bản thân - Giảm trừ người phụ thuộc
                        double taxableIncome = grossSalary - totalInsurance - PERSONAL_DEDUCTION - (numDependents * DEPENDENT_DEDUCTION);
                        double tax = calculatePersonalIncomeTax(taxableIncome);
                        double netSalary = grossSalary - totalInsurance - tax;
                        if (netSalary < 0) netSalary = 0;

                        // Insert detail
                        int idx = 1;
                        detPs.setInt(idx++, payrollId);
                        detPs.setInt(idx++, empId);
                        detPs.setDouble(idx++, basicSalary);
                        // Block 1 attendance
                        detPs.setDouble(idx++, standardDays);
                        detPs.setDouble(idx++, actualWorkedDays);
                        detPs.setDouble(idx++, paidLeaveDays);
                        detPs.setDouble(idx++, unpaidLeaveDays);
                        detPs.setDouble(idx++, sickLeaveDays);
                        detPs.setDouble(idx++, unpaidDeduction);
                        // Block 2
                        detPs.setDouble(idx++, allowance);
                        detPs.setDouble(idx++, bhxh);
                        detPs.setDouble(idx++, bhyt);
                        detPs.setDouble(idx++, bhtn);
                        detPs.setDouble(idx++, totalInsurance);
                        // Block 3
                        detPs.setDouble(idx++, grossSalary);
                        detPs.setDouble(idx++, tax);
                        detPs.setDouble(idx++, netSalary);
                        // Metadata
                        detPs.setInt(idx++, deptId);
                        detPs.setInt(idx++, posId);
                        detPs.addBatch();

                        totalEmployees++;
                        grandTotalAmount += netSalary;
                    }
                    detPs.executeBatch();
                }
            }

            // 4. Update totals
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
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }

    @Override
    public boolean updatePayrollStatus(int id, String newStatus, int userId) {
        String expectedOldStatus = null;
        String sql = "";

        switch (newStatus) {
            case "MANAGER_CONFIRMED":
                expectedOldStatus = "DRAFT";
                sql = "UPDATE payrolls SET status = ?, manager_confirmed_by = ?, manager_confirmed_at = NOW(), updated_at = NOW() WHERE id = ? AND status = ?";
                break;
            case "HR_FINALIZED":
                sql = "UPDATE payrolls SET status = ?, hr_confirmed_by = ?, hr_confirmed_at = NOW(), finalized_by = ?, finalized_at = NOW(), updated_at = NOW() WHERE id = ? AND status IN ('DRAFT', 'MANAGER_CONFIRMED')";
                break;
            // Legacy support
            case "APPROVED":
                expectedOldStatus = "DRAFT";
                sql = "UPDATE payrolls SET status = ?, approved_by = ?, approved_at = NOW(), updated_at = NOW() WHERE id = ? AND status = ?";
                break;
            default:
                return false;
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if ("HR_FINALIZED".equals(newStatus)) {
                ps.setString(1, newStatus);
                ps.setInt(2, userId);
                ps.setInt(3, userId);
                ps.setInt(4, id);
                // No expectedOldStatus needed because of IN clause
            } else {
                ps.setString(1, newStatus);
                ps.setInt(2, userId);
                ps.setInt(3, id);
                ps.setString(4, expectedOldStatus);
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public List<Payroll> getPayrolls(Integer year, String searchKeyword, int offset, int limit) {
        List<Payroll> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(PAYROLL_SELECT_WITH_NAMES);
        sql.append("WHERE 1=1 ");

        List<Object> params = new ArrayList<>();
        if (year != null) {
            sql.append("AND p.year = ? ");
            params.add(year);
        }
        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            String kw = searchKeyword.trim().toLowerCase();
            String numKw = kw.replace("tháng", "").trim();
            
            sql.append("AND (p.month LIKE ? OR p.year LIKE ? ");
            params.add("%" + numKw + "%");
            params.add("%" + kw + "%");
            
            List<String> statuses = new ArrayList<>();
            if ("bản nháp".contains(kw) || "nháp".contains(kw) || "draft".equals(kw)) statuses.add("DRAFT");
            if ("manager đã xác nhận".contains(kw) || "manager".contains(kw)) statuses.add("MANAGER_CONFIRMED");
            if ("đã chốt lương".contains(kw) || "chốt".contains(kw) || "hr_finalized".equals(kw)) statuses.add("HR_FINALIZED");
            if ("đã duyệt".contains(kw) || "duyệt".contains(kw) || "approved".equals(kw)) statuses.add("APPROVED");
            if ("đã thanh toán".contains(kw) || "thanh toán".contains(kw) || "paid".equals(kw)) statuses.add("PAID");
            
            if (!statuses.isEmpty()) {
                sql.append("OR p.status IN (");
                for (int i = 0; i < statuses.size(); i++) {
                    sql.append(i == 0 ? "?" : ", ?");
                    params.add(statuses.get(i));
                }
                sql.append(") ");
            }
            
            sql.append("OR LOWER(p.status) LIKE ?) ");
            params.add("%" + kw + "%");
        }
        sql.append("ORDER BY p.year DESC, p.month DESC LIMIT ? OFFSET ?");
        params.add(limit); params.add(offset);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(readPayrollWithNames(rs));
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
            String kw = searchKeyword.trim().toLowerCase();
            String numKw = kw.replace("tháng", "").trim();
            
            sql.append("AND (p.month LIKE ? OR p.year LIKE ? ");
            params.add("%" + numKw + "%");
            params.add("%" + kw + "%");
            
            List<String> statuses = new ArrayList<>();
            if ("bản nháp".contains(kw) || "nháp".contains(kw) || "draft".equals(kw)) statuses.add("DRAFT");
            if ("manager đã xác nhận".contains(kw) || "manager".contains(kw)) statuses.add("MANAGER_CONFIRMED");
            if ("đã chốt lương".contains(kw) || "chốt".contains(kw) || "hr_finalized".equals(kw)) statuses.add("HR_FINALIZED");
            if ("đã duyệt".contains(kw) || "duyệt".contains(kw) || "approved".equals(kw)) statuses.add("APPROVED");
            if ("đã thanh toán".contains(kw) || "thanh toán".contains(kw) || "paid".equals(kw)) statuses.add("PAID");
            
            if (!statuses.isEmpty()) {
                sql.append("OR p.status IN (");
                for (int i = 0; i < statuses.size(); i++) {
                    sql.append(i == 0 ? "?" : ", ?");
                    params.add(statuses.get(i));
                }
                sql.append(") ");
            }
            
            sql.append("OR LOWER(p.status) LIKE ?) ");
            params.add("%" + kw + "%");
        }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public double getTotalAmountYTD(int year) {
        String sql = "SELECT SUM(total_amount) FROM payrolls WHERE year = ? AND status IN ('HR_FINALIZED', 'APPROVED', 'PAID')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, year);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getDouble(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }
}
