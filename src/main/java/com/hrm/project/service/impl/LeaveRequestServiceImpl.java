package com.hrm.project.service.impl;

import com.hrm.project.dao.LeaveRequestDAO;
import com.hrm.project.dao.impl.LeaveRequestDAOImpl;
import com.hrm.project.model.LeaveRequest;
import com.hrm.project.model.dtos.response.LeaveSummaryDto;
import com.hrm.project.service.LeaveRequestService;

import java.sql.Date;
import java.util.List;

public class LeaveRequestServiceImpl implements LeaveRequestService {

    private final LeaveRequestDAO leaveRequestDAO =
            new LeaveRequestDAOImpl();

    @Override
    public List<LeaveRequest> getEmployeeRequests(int employeeId) {
        return leaveRequestDAO.getByEmployee(employeeId);
    }

    @Override
    public List<LeaveRequest> getAllRequests() {
        return leaveRequestDAO.getAll();
    }

    @Override
    public LeaveRequest getById(int id) {
        return leaveRequestDAO.getById(id);
    }

    @Override
    public boolean createRequest(LeaveRequest request) {
        return leaveRequestDAO.create(request);
    }

    @Override
    public boolean approveRequest(int requestId, int reviewerId) {
        return leaveRequestDAO.approve(requestId, reviewerId);
    }

    @Override
    public boolean rejectRequest(int requestId, int reviewerId) {
        return leaveRequestDAO.reject(requestId, reviewerId);
    }

    @Override
    public boolean cancelRequest(int requestId) {
        return leaveRequestDAO.cancel(requestId);
    }

    @Override
    public List<LeaveSummaryDto> getLeaveSummaryReport(Date fromDate, Date toDate, Integer departmentId) {
        return leaveRequestDAO.getLeaveSummaryReport(fromDate, toDate, departmentId);
    }
}