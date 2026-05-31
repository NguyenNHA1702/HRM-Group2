package com.hrm.project.dao;

import com.hrm.project.model.LeaveRequest;
import java.util.List;

public interface LeaveRequestDAO {

    List<LeaveRequest> getByEmployee(int employeeId);

    List<LeaveRequest> getAll();

    LeaveRequest getById(int id);

    boolean create(LeaveRequest request);

    boolean approve(int requestId, int approverId);

    boolean reject(int requestId, int approverId);

    boolean cancel(int requestId);
}