package com.hrm.project.dao.impl;

import com.hrm.project.dao.DashboardDao;
import com.hrm.project.model.dtos.response.*;
import com.hrm.project.dao.impl.DBConnection;

import java.sql.*;
import java.util.*;

public class DashboardDaoImpl implements DashboardDao {

    // ── ADMIN ─────────────────────────────────────────────────────

    @Override
    public AdminStatsDto fetchAdminStats() throws Exception {
        String sql = "SELECT total_active_users, active_today, total_roles, " +
                "       total_employees, growth_percent " +
                "FROM vw_dashboard_admin_stats LIMIT 1";
        try (Connection con = DBConnection.getConnection();
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            AdminStatsDto dto = new AdminStatsDto();
            if (rs.next()) {
                dto.setTotalActiveUsers(rs.getInt("total_active_users"));
                dto.setActiveToday(rs.getInt("active_today"));
                dto.setTotalRoles(rs.getInt("total_roles"));
                dto.setTotalEmployees(rs.getInt("total_employees"));
                dto.setGrowthPercent(rs.getDouble("growth_percent"));
            }
            return dto;
        }
    }

    @Override
    public List<Map<String, Object>> fetchRecentActivity(int limit) throws Exception {
        String sql = "SELECT full_name, avatar_url, action, module_code, minutes_ago " +
                "FROM vw_recent_activity LIMIT ?";
        return queryToList(sql, limit);
    }

    @Override
    public List<Map<String, Object>> fetchDailyLogins() throws Exception {
        String sql = "SELECT login_date, total_logins, unique_users FROM vw_daily_logins";
        return queryToList(sql);
    }

    @Override
    public List<Map<String, Object>> fetchUsersByRoleGroup() throws Exception {
        String sql = "SELECT group_code, group_name, user_count FROM vw_users_by_role_group";
        return queryToList(sql);
    }

    // ── HR ────────────────────────────────────────────────────────

    @Override
    public HrStatsDto fetchHrStats() throws Exception {
        HrStatsDto dto = new HrStatsDto();
        try (Connection con = DBConnection.getConnection()) {
            // Tổng + mới + nghỉ việc
            String sql1 = "SELECT " +
                    "  SUM(status IN ('ACTIVE','PROBATION')) AS total, " +
                    "  SUM(status IN ('ACTIVE','PROBATION') AND MONTH(hire_date)=MONTH(CURDATE()) AND YEAR(hire_date)=YEAR(CURDATE())) AS new_cnt, " +
                    "  SUM(status='TERMINATED' AND MONTH(termination_date)=MONTH(CURDATE()) AND YEAR(termination_date)=YEAR(CURDATE())) AS term_cnt " +
                    "FROM employees";
            try (Statement st = con.createStatement(); ResultSet rs = st.executeQuery(sql1)) {
                if (rs.next()) {
                    dto.setTotalEmployees(rs.getInt("total"));
                    dto.setNewThisMonth(rs.getInt("new_cnt"));
                    dto.setTerminated(rs.getInt("term_cnt"));
                }
            }
            // Quỹ lương
            String sql2 = "SELECT COALESCE(SUM(pd.net_salary),0) AS fund " +
                    "FROM payroll_details pd " +
                    "JOIN payroll_periods pp ON pp.id = pd.payroll_period_id " +
                    "WHERE pp.year = YEAR(CURDATE()) AND pp.month = MONTH(CURDATE())";
            try (Statement st = con.createStatement(); ResultSet rs = st.executeQuery(sql2)) {
                if (rs.next()) dto.setPayrollFund(rs.getLong("fund"));
            }
        }
        return dto;
    }

    @Override
    public List<Map<String, Object>> fetchHeadcountByDept() throws Exception {
        String sql = "SELECT department_name, total_employees, active_count " +
                "FROM vw_headcount_by_dept ORDER BY total_employees DESC";
        return queryToList(sql);
    }

    @Override
    public List<Map<String, Object>> fetchRecruitmentTrend() throws Exception {
        String sql = "SELECT MONTH(hire_date) AS month_num, COUNT(*) AS count " +
                "FROM employees " +
                "WHERE hire_date >= DATE_SUB(CURDATE(), INTERVAL 5 MONTH) " +
                "GROUP BY MONTH(hire_date) " +
                "ORDER BY MONTH(hire_date)";
        return queryToList(sql);
    }

    // ── MANAGER ───────────────────────────────────────────────────

    @Override
    public ManagerStatsDto fetchManagerStats(int managerId) throws Exception {
        ManagerStatsDto dto = new ManagerStatsDto();
        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT " +
                    "  COUNT(*)                                             AS team_size, " +
                    "  SUM(a.status IN ('PRESENT','LATE'))                 AS present_today, " +
                    "  SUM(a.status = 'ON_LEAVE')                         AS on_leave, " +
                    "  (SELECT COUNT(*) FROM leave_requests lr2 " +
                    "   JOIN employees e2 ON e2.id = lr2.employee_id " +
                    "   WHERE e2.direct_manager_id = ? AND lr2.status = 'PENDING') AS pending " +
                    "FROM employees e " +
                    "LEFT JOIN attendance_records a ON a.employee_id = e.id AND a.work_date = CURDATE() " +
                    "WHERE e.direct_manager_id = ? AND e.status IN ('ACTIVE','PROBATION')";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, managerId);
                ps.setInt(2, managerId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        dto.setTeamSize(rs.getInt("team_size"));
                        dto.setPresentToday(rs.getInt("present_today"));
                        dto.setOnLeave(rs.getInt("on_leave"));
                        dto.setPendingApprovals(rs.getInt("pending"));
                    }
                }
            }
        }
        return dto;
    }

    @Override
    public List<Map<String, Object>> fetchTeamStatusToday(int managerId) throws Exception {
        String sql = "SELECT e.full_name, e.avatar_url, " +
                "  DATE_FORMAT(a.check_in_time,'%H:%i')  AS check_in, " +
                "  DATE_FORMAT(a.check_out_time,'%H:%i') AS check_out, " +
                "  COALESCE(a.status,'ABSENT')            AS status, " +
                "  COALESCE(k.actual_score, 0)            AS kpi_score " +
                "FROM employees e " +
                "LEFT JOIN attendance_records a ON a.employee_id = e.id AND a.work_date = CURDATE() " +
                "LEFT JOIN kpi_records k ON k.employee_id = e.id " +
                "  AND k.year = YEAR(CURDATE()) AND k.month = MONTH(CURDATE()) " +
                "WHERE e.direct_manager_id = ? AND e.status IN ('ACTIVE','PROBATION') " +
                "ORDER BY e.full_name";
        return queryToList(sql, managerId);
    }

    @Override
    public List<Map<String, Object>> fetchPendingLeavesForManager(int managerId) throws Exception {
        String sql = "SELECT lr.id, e.full_name AS employee_name, lt.name AS leave_type_name, " +
                "  lr.start_date, lr.end_date, lr.reason " +
                "FROM leave_requests lr " +
                "JOIN employees e    ON e.id  = lr.employee_id " +
                "JOIN leave_types lt ON lt.id = lr.leave_type_id " +
                "WHERE e.direct_manager_id = ? AND lr.status = 'PENDING' " +
                "ORDER BY lr.created_at DESC LIMIT 10";
        return queryToList(sql, managerId);
    }

    @Override
    public List<Map<String, Object>> fetchTeamKpi(int managerId) throws Exception {
        String sql = "SELECT e.full_name, COALESCE(k.actual_score, 0) AS score " +
                "FROM employees e " +
                "LEFT JOIN kpi_records k ON k.employee_id = e.id " +
                "  AND k.year = YEAR(CURDATE()) AND k.month = MONTH(CURDATE()) " +
                "WHERE e.direct_manager_id = ? AND e.status IN ('ACTIVE','PROBATION')";
        return queryToList(sql, managerId);
    }

    // ── EMPLOYEE ──────────────────────────────────────────────────

    @Override
    public EmployeeStatsDto fetchEmployeeStats(int employeeId) throws Exception {
        EmployeeStatsDto dto = new EmployeeStatsDto();
        try (Connection con = DBConnection.getConnection()) {
            // Ngày công tháng này
            String sql1 = "SELECT COUNT(*) AS cnt FROM attendance_records " +
                    "WHERE employee_id = ? AND MONTH(work_date)=MONTH(CURDATE()) " +
                    "AND YEAR(work_date)=YEAR(CURDATE()) AND status IN ('PRESENT','LATE','HALF_DAY')";
            try (PreparedStatement ps = con.prepareStatement(sql1)) {
                ps.setInt(1, employeeId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) dto.setWorkDays(rs.getInt("cnt"));
                }
            }
            // Phép còn lại
            String sql2 = "SELECT COALESCE(SUM(remaining_days),0) AS rem " +
                    "FROM vw_leave_balance_current WHERE employee_id = ?";
            try (PreparedStatement ps = con.prepareStatement(sql2)) {
                ps.setInt(1, employeeId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) dto.setLeaveRemain(rs.getDouble("rem"));
                }
            }
            // Lương dự kiến
            String sql3 = "SELECT COALESCE(net_salary,0) AS sal FROM payroll_details pd " +
                    "JOIN payroll_periods pp ON pp.id = pd.payroll_period_id " +
                    "WHERE pd.employee_id = ? AND pp.year=YEAR(CURDATE()) AND pp.month=MONTH(CURDATE()) LIMIT 1";
            try (PreparedStatement ps = con.prepareStatement(sql3)) {
                ps.setInt(1, employeeId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) dto.setEstimatedSalary(rs.getLong("sal"));
                }
            }
            // Giờ tuần này
            String sql4 = "SELECT COALESCE(SUM(work_minutes)/60.0, 0) AS hrs FROM attendance_records " +
                    "WHERE employee_id = ? AND work_date >= DATE_SUB(CURDATE(), INTERVAL WEEKDAY(CURDATE()) DAY)";
            try (PreparedStatement ps = con.prepareStatement(sql4)) {
                ps.setInt(1, employeeId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) dto.setWeekHours(rs.getDouble("hrs"));
                }
            }
        }
        return dto;
    }

    @Override
    public Map<String, Object> fetchTodayAttendance(int employeeId) throws Exception {
        String sql = "SELECT DATE_FORMAT(check_in_time,'%H:%i') AS check_in_time, " +
                "  DATE_FORMAT(check_out_time,'%H:%i') AS check_out_time, status " +
                "FROM attendance_records " +
                "WHERE employee_id = ? AND work_date = CURDATE() LIMIT 1";
        List<Map<String, Object>> rows = queryToList(sql, employeeId);
        return rows.isEmpty() ? null : rows.get(0);
    }

    @Override
    public List<Map<String, Object>> fetchMyRecentLeaves(int employeeId, int limit) throws Exception {
        String sql = "SELECT lt.name AS leave_type_name, lr.start_date, lr.end_date, " +
                "  lr.reason, lr.status " +
                "FROM leave_requests lr " +
                "JOIN leave_types lt ON lt.id = lr.leave_type_id " +
                "WHERE lr.employee_id = ? ORDER BY lr.created_at DESC LIMIT ?";
        return queryToList(sql, employeeId, limit);
    }

    // ── Helpers ───────────────────────────────────────────────────

    /** Query không tham số */
    private List<Map<String, Object>> queryToList(String sql) throws Exception {
        try (Connection con = DBConnection.getConnection();
             Statement st = con.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            return resultSetToList(rs);
        }
    }

    /** Query với các tham số int */
    private List<Map<String, Object>> queryToList(String sql, int... params) throws Exception {
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            for (int i = 0; i < params.length; i++) ps.setInt(i + 1, params[i]);
            try (ResultSet rs = ps.executeQuery()) {
                return resultSetToList(rs);
            }
        }
    }

    private List<Map<String, Object>> resultSetToList(ResultSet rs) throws Exception {
        List<Map<String, Object>> list = new ArrayList<>();
        ResultSetMetaData meta = rs.getMetaData();
        int cols = meta.getColumnCount();
        while (rs.next()) {
            Map<String, Object> row = new LinkedHashMap<>();
            for (int i = 1; i <= cols; i++) {
                row.put(meta.getColumnLabel(i), rs.getObject(i));
            }
            list.add(row);
        }
        return list;
    }
}