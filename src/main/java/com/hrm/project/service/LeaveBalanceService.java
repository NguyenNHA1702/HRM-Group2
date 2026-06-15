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

    boolean updateBalance(int id, double usedDays, double remainingDays);

    int resetAll();

    boolean create(int employeeId, int leaveTypeId, double totalDays);

    boolean exists(int employeeId, int leaveTypeId);
}