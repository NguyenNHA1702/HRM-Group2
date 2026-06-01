package com.hrm.project.service;

import com.hrm.project.model.LeaveType;
import java.util.List;

public interface LeaveTypeService {

    List<LeaveType> getAll();

    LeaveType getById(int id);

    boolean create(LeaveType leaveType);

    boolean update(LeaveType leaveType);

    boolean toggleStatus(int id);
}