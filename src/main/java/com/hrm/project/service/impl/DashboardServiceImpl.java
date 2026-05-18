package com.hrm.project.service.impl;

import com.hrm.project.dao.DashboardDao;
import com.hrm.project.dao.impl.DashboardDaoImpl;
import com.hrm.project.model.dtos.response.AdminStatsDto;
import com.hrm.project.model.dtos.response.EmployeeStatsDto;
import com.hrm.project.model.dtos.response.HrStatsDto;
import com.hrm.project.model.dtos.response.ManagerStatsDto;
import com.hrm.project.service.DashboardService;

import java.util.List;
import java.util.Map;

public class DashboardServiceImpl implements DashboardService {

    // Khởi tạo đối tượng DAO để tương tác với Database
    private final DashboardDao dashboardDao = new DashboardDaoImpl();

    // ============================================================
    // ── ADMIN ROLE
    // ============================================================

    @Override
    public AdminStatsDto getAdminStats() throws Exception {
        return dashboardDao.fetchAdminStats();
    }

    @Override
    public List<Map<String, Object>> getRecentActivity(int limit) throws Exception {
        return dashboardDao.fetchRecentActivity(limit);
    }

    @Override
    public List<Map<String, Object>> getDailyLogins() throws Exception {
        return dashboardDao.fetchDailyLogins();
    }

    @Override
    public List<Map<String, Object>> getUsersByRoleGroup() throws Exception {
        return dashboardDao.fetchUsersByRoleGroup();
    }

    // ============================================================
    // ── HR ROLE
    // ============================================================

    @Override
    public HrStatsDto getHrStats() throws Exception {
        return dashboardDao.fetchHrStats();
    }

    @Override
    public List<Map<String, Object>> getHeadcountByDept() throws Exception {
        return dashboardDao.fetchHeadcountByDept();
    }

    @Override
    public List<Map<String, Object>> getRecruitmentTrend() throws Exception {
        return dashboardDao.fetchRecruitmentTrend();
    }

    // ============================================================
    // ── MANAGER ROLE
    // ============================================================

    @Override
    public ManagerStatsDto getManagerStats(int managerId) throws Exception {
        return dashboardDao.fetchManagerStats(managerId);
    }

    @Override
    public List<Map<String, Object>> getTeamStatusToday(int managerId) throws Exception {
        return dashboardDao.fetchTeamStatusToday(managerId);
    }

    @Override
    public List<Map<String, Object>> getPendingLeavesForManager(int managerId) throws Exception {
        return dashboardDao.fetchPendingLeavesForManager(managerId);
    }

    @Override
    public List<Map<String, Object>> getTeamKpi(int managerId) throws Exception {
        return dashboardDao.fetchTeamKpi(managerId);
    }

    // ============================================================
    // ── EMPLOYEE ROLE
    // ============================================================

    @Override
    public EmployeeStatsDto getEmployeeStats(int employeeId) throws Exception {
        return dashboardDao.fetchEmployeeStats(employeeId);
    }

    @Override
    public Map<String, Object> getTodayAttendance(int employeeId) throws Exception {
        return dashboardDao.fetchTodayAttendance(employeeId);
    }

    @Override
    public List<Map<String, Object>> getMyRecentLeaves(int employeeId, int limit) throws Exception {
        return dashboardDao.fetchMyRecentLeaves(employeeId, limit);
    }
}