package com.hrm.project.dao;

import com.hrm.project.model.LeaveRequest;
import com.hrm.project.model.dtos.response.LeaveSummaryDto;
import java.sql.Date;
import java.util.List;

public interface LeaveRequestDAO {

    List<LeaveRequest> getByEmployee(int employeeId);

    List<LeaveRequest> getRequestsForManager(int managerId);

    List<LeaveRequest> getAll();

    LeaveRequest getById(int id);

    boolean create(LeaveRequest request);

    boolean approve(int requestId, int approverId);

    boolean reject(int requestId, int approverId);

    boolean cancel(int requestId);

    List<LeaveSummaryDto> getLeaveSummaryReport(Date fromDate, Date toDate, Integer departmentId);
}