package com.hrm.project.dao;

import com.hrm.project.model.dtos.response.AdminStatsDto;
import com.hrm.project.model.dtos.response.EmployeeStatsDto;
import com.hrm.project.model.dtos.response.HrStatsDto;
import com.hrm.project.model.dtos.response.ManagerStatsDto;

import java.util.List;
import java.util.Map;

/**
 * DashboardDao — truy vấn DB cho dashboard
 */
public interface DashboardDao {

    AdminStatsDto            fetchAdminStats()                              throws Exception;
    List<Map<String, Object>> fetchRecentActivity(int limit)               throws Exception;
    List<Map<String, Object>> fetchDailyLogins()                           throws Exception;
    List<Map<String, Object>> fetchUsersByRoleGroup()                      throws Exception;

    HrStatsDto               fetchHrStats()                                throws Exception;
    List<Map<String, Object>> fetchHeadcountByDept()                       throws Exception;
    List<Map<String, Object>> fetchRecruitmentTrend()                      throws Exception;

    ManagerStatsDto          fetchManagerStats(int managerId)              throws Exception;
    List<Map<String, Object>> fetchTeamStatusToday(int managerId)          throws Exception;
    List<Map<String, Object>> fetchPendingLeavesForManager(int managerId)  throws Exception;

    EmployeeStatsDto         fetchEmployeeStats(int employeeId)            throws Exception;
    List<Map<String, Object>> fetchMyRecentLeaves(int employeeId, int limit) throws Exception;
}