package com.hrm.project.service.impl;

import com.hrm.project.dao.LeaveTypeDAO;
import com.hrm.project.dao.impl.LeaveTypeDAOImpl;
import com.hrm.project.model.LeaveType;
import com.hrm.project.service.LeaveTypeService;

import java.util.List;

public class LeaveTypeServiceImpl implements LeaveTypeService {

    private final LeaveTypeDAO leaveTypeDAO =
            new LeaveTypeDAOImpl();

    @Override
    public List<LeaveType> getAll() {
        return leaveTypeDAO.getAll();
    }

    @Override
    public LeaveType getById(int id) {
        return leaveTypeDAO.getById(id);
    }

    @Override
    public boolean create(LeaveType leaveType) {
        return leaveTypeDAO.create(leaveType);
    }

    @Override
    public boolean update(LeaveType leaveType) {
        return leaveTypeDAO.update(leaveType);
    }

    @Override
    public boolean toggleStatus(int id) {
        return leaveTypeDAO.toggleStatus(id);
    }
}