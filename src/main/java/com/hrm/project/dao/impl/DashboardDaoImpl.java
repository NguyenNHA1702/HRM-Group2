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
                "       total_employees " +
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
            String sql2 =
                    "SELECT COALESCE(SUM(pd.net_salary),0) AS fund " +
                            "FROM payroll_details pd " +
                            "JOIN payrolls p ON p.id = pd.payroll_id " +
                            "WHERE p.year = YEAR(CURDATE()) " +
                            "AND p.month = MONTH(CURDATE())";
            try (Statement st = con.createStatement(); ResultSet rs = st.executeQuery(sql2)) {
                if (rs.next()) dto.setPayrollFund(rs.getLong("fund"));
            }
            // Đơn nghỉ phép chờ duyệt
            String sql3 = "SELECT COUNT(*) AS cnt FROM leave_requests WHERE status = 'PENDING'";
            try (Statement st = con.createStatement(); ResultSet rs = st.executeQuery(sql3)) {
                if (rs.next()) dto.setPendingLeaves(rs.getInt("cnt"));
            }
            // Giải trình chấm công chờ duyệt
            String sql4 = "SELECT COUNT(*) AS cnt FROM attendance_explanations WHERE status = 'PENDING'";
            try (Statement st = con.createStatement(); ResultSet rs = st.executeQuery(sql4)) {
                if (rs.next()) dto.setPendingExplanations(rs.getInt("cnt"));
            }
            // Vị trí tuyển dụng đang mở
            String sql5 = "SELECT COUNT(*) AS cnt FROM job_vacancies WHERE status = 'OPEN'";
            try (Statement st = con.createStatement(); ResultSet rs = st.executeQuery(sql5)) {
                if (rs.next()) dto.setOpenVacancies(rs.getInt("cnt"));
            }
        }
        return dto;
    }

    @Override
    public List<Map<String, Object>> fetchHeadcountByDept() throws Exception {
        String sql = "SELECT department_name, total_employees, active_count " +
                "FROM vw_headcount_by_dept ORDER BY total_employees DESC LIMIT 5";
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
            // Team size + pending leave approvals
            String sql1 = "SELECT " +
                    "  (SELECT COUNT(*) FROM employees " +
                    "   WHERE direct_manager_id = ? AND status IN ('ACTIVE','PROBATION')) AS team_size, " +
                    "  (SELECT COUNT(*) FROM leave_requests lr " +
                    "   JOIN employees e ON e.id = lr.employee_id " +
                    "   WHERE e.direct_manager_id = ? AND lr.status = 'PENDING') AS pending";
            try (PreparedStatement ps = con.prepareStatement(sql1)) {
                ps.setInt(1, managerId);
                ps.setInt(2, managerId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        dto.setTeamSize(rs.getInt("team_size"));
                        dto.setPendingApprovals(rs.getInt("pending"));
                    }
                }
            }
            // Giải trình chấm công chờ duyệt từ team
            String sql2 = "SELECT COUNT(*) AS cnt FROM attendance_explanations ae " +
                    "JOIN employees e ON e.id = ae.employee_id " +
                    "WHERE e.direct_manager_id = ? AND ae.status = 'PENDING'";
            try (PreparedStatement ps = con.prepareStatement(sql2)) {
                ps.setInt(1, managerId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) dto.setPendingExplanations(rs.getInt("cnt"));
                }
            }
            // Số ngày phép đã duyệt trong tháng này của team
            String sql3 = "SELECT COUNT(*) AS cnt FROM leave_requests lr " +
                    "JOIN employees e ON e.id = lr.employee_id " +
                    "WHERE e.direct_manager_id = ? AND lr.status = 'APPROVED' " +
                    "AND MONTH(lr.start_date) = MONTH(CURDATE()) " +
                    "AND YEAR(lr.start_date) = YEAR(CURDATE())";
            try (PreparedStatement ps = con.prepareStatement(sql3)) {
                ps.setInt(1, managerId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) dto.setApprovedLeavesMonth(rs.getInt("cnt"));
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
                "  COALESCE(a.status,'ABSENT')            AS status " +
                "FROM employees e " +
                "LEFT JOIN attendance_records a ON a.employee_id = e.id AND a.work_date = CURDATE() " +
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
                    "JOIN payrolls p ON p.id = pd.payroll_id " +
                    "WHERE pd.employee_id = ? AND p.year=YEAR(CURDATE()) AND p.month=MONTH(CURDATE()) LIMIT 1";
            try (PreparedStatement ps = con.prepareStatement(sql3)) {
                ps.setInt(1, employeeId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) dto.setEstimatedSalary(rs.getLong("sal"));
                }
            }
            // Tổng đơn chờ duyệt (nghỉ phép + giải trình chấm công)
            String sql4 = "SELECT " +
                    "  (SELECT COUNT(*) FROM leave_requests WHERE employee_id = ? AND status = 'PENDING') + " +
                    "  (SELECT COUNT(*) FROM attendance_explanations WHERE employee_id = ? AND status = 'PENDING') " +
                    "AS total_pending";
            try (PreparedStatement ps = con.prepareStatement(sql4)) {
                ps.setInt(1, employeeId);
                ps.setInt(2, employeeId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) dto.setPendingRequests(rs.getInt("total_pending"));
                }
            }
        }
        return dto;
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