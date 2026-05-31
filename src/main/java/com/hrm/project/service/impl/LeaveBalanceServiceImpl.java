package com.hrm.project.service.impl;

import com.hrm.project.dao.LeaveBalanceDAO;
import com.hrm.project.dao.impl.LeaveBalanceDAOImpl;
import com.hrm.project.model.LeaveBalance;
import com.hrm.project.service.LeaveBalanceService;

import java.util.List;

public class LeaveBalanceServiceImpl implements LeaveBalanceService {

    private final LeaveBalanceDAO leaveBalanceDAO =
            new LeaveBalanceDAOImpl();

    @Override
    public List<LeaveBalance> getByEmployee(int employeeId) {
        return leaveBalanceDAO.getByEmployee(employeeId);
    }

    @Override
    public List<LeaveBalance> getAll() {
        return leaveBalanceDAO.getAll();
    }

    @Override
    public boolean deductBalance(
            int employeeId,
            int leaveTypeId,
            double days) {

        return leaveBalanceDAO.deductBalance(
                employeeId,
                leaveTypeId,
                days);
    }
}