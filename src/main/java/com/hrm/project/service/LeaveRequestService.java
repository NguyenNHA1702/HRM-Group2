package com.hrm.project.service;

import com.hrm.project.model.LeaveRequest;
import com.hrm.project.model.dtos.response.LeaveSummaryDto;
import java.sql.Date;
import java.util.List;

public interface LeaveRequestService {

    List<LeaveRequest> getEmployeeRequests(int employeeId);

    List<LeaveRequest> getRequestsForManager(int managerId);

    List<LeaveRequest> getAllRequests();

    LeaveRequest getById(int id);

    boolean createRequest(LeaveRequest request);

    boolean approveRequest(int requestId, int reviewerId);

    boolean rejectRequest(int requestId, int reviewerId);

    boolean cancelRequest(int requestId);

    List<LeaveSummaryDto> getLeaveSummaryReport(Date fromDate, Date toDate, Integer departmentId, String roleGroup, Integer userId);
}