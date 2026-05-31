package com.hrm.project.dao;

import com.hrm.project.model.LeaveBalance;
import java.util.List;

public interface LeaveBalanceDAO {

    List<LeaveBalance> getByEmployee(int employeeId);

    List<LeaveBalance> getAll();

    boolean deductBalance(
            int employeeId,
            int leaveTypeId,
            double days);

}