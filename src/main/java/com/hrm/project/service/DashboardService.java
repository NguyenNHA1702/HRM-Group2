package com.hrm.project.service;

import com.hrm.project.model.dtos.response.AdminStatsDto;
import com.hrm.project.model.dtos.response.EmployeeStatsDto;
import com.hrm.project.model.dtos.response.HrStatsDto;
import com.hrm.project.model.dtos.response.ManagerStatsDto;

import java.util.List;
import java.util.Map;

/**
 * DashboardService — cung cấp dữ liệu cho 4 loại dashboard theo role
 */
public interface DashboardService {

    // ── ADMIN ──────────────────────────────────────────────────────

    /** Thống kê tổng quan: tổng users, hoạt động hôm nay, roles, tăng trưởng */
    AdminStatsDto getAdminStats() throws Exception;

    /** Danh sách hoạt động gần đây (từ vw_recent_activity) */
    List<Map<String, Object>> getRecentActivity(int limit) throws Exception;

    /** Dữ liệu đăng nhập theo ngày cho line chart (7 ngày gần nhất) */
    List<Map<String, Object>> getDailyLogins() throws Exception;

    /** Phân bố users theo role group cho bar chart */
    List<Map<String, Object>> getUsersByRoleGroup() throws Exception;

    // ── HR ─────────────────────────────────────────────────────────

    /** Thống kê HR: tổng NV, mới tháng này, nghỉ việc, quỹ lương */
    HrStatsDto getHrStats() throws Exception;

    /** Headcount theo phòng ban (từ vw_headcount_by_dept) */
    List<Map<String, Object>> getHeadcountByDept() throws Exception;

    /** Số lượng tuyển dụng theo tháng (5 tháng gần nhất) */
    List<Map<String, Object>> getRecruitmentTrend() throws Exception;

    // ── MANAGER ────────────────────────────────────────────────────

    /** Thống kê team: size, đơn chờ duyệt, giải trình chờ duyệt, phép tháng */
    ManagerStatsDto getManagerStats(int managerId) throws Exception;

    /** Tình trạng team: checkin, status */
    List<Map<String, Object>> getTeamStatusToday(int managerId) throws Exception;

    /** Đơn nghỉ phép PENDING cần duyệt */
    List<Map<String, Object>> getPendingLeavesForManager(int managerId) throws Exception;

    // ── EMPLOYEE ───────────────────────────────────────────────────

    /** Thống kê cá nhân: ngày công, phép còn lại, lương dự kiến, đơn chờ duyệt */
    EmployeeStatsDto getEmployeeStats(int employeeId) throws Exception;

    /** Danh sách đơn nghỉ phép gần đây của nhân viên */
    List<Map<String, Object>> getMyRecentLeaves(int employeeId, int limit) throws Exception;
}