package com.hrm.project.service;

import com.hrm.project.model.LeaveBalance;
import java.util.List;

public interface LeaveBalanceService {

    List<LeaveBalance> getByEmployee(int employeeId);

    List<LeaveBalance> getAll();

    boolean deductBalance(
            int employeeId,
            int leaveTypeId,
            double days);
}