package com.hrm.project.dao;

import com.hrm.project.model.EmployeeSchedule;
import com.hrm.project.model.ScheduleHistory;
import java.util.List;

public interface ScheduleDAO {
    List<EmployeeSchedule> getSchedules(String keyword, Integer departmentId, Integer workShiftId, String startDate, String endDate, int page, int pageSize);
    int getSchedulesCount(String keyword, Integer departmentId, Integer workShiftId, String startDate, String endDate);
    EmployeeSchedule getScheduleById(int id);
    EmployeeSchedule getScheduleByEmployeeAndDate(int employeeId, String date);
    boolean assignSchedule(EmployeeSchedule schedule);
    boolean updateSchedule(EmployeeSchedule schedule, String changedBy, String changeReason);
    boolean deleteSchedule(int id);
    List<ScheduleHistory> getHistoryByEmployee(int employeeId);
    List<EmployeeSchedule> getEmployeeSchedulesForMonth(int employeeId, String yearMonth);
}
