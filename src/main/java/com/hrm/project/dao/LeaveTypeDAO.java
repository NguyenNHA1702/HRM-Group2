package com.hrm.project.dao;

import com.hrm.project.model.LeaveType;
import java.util.List;

public interface LeaveTypeDAO {

    List<LeaveType> getAll();

    LeaveType getById(int id);

    boolean create(LeaveType leaveType);

    boolean update(LeaveType leaveType);

    boolean toggleStatus(int id);

}