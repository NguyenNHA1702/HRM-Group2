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

    /** HR: chỉnh sửa thủ công quỹ phép theo id bản ghi */
    boolean updateBalance(int id, double usedDays, double remainingDays);

    /** HR: reset toàn bộ quỹ phép về 0 dùng / days_per_year còn lại */
    int resetAll();

    /** HR: tạo mới bản ghi quỹ phép cho nhân viên + loại phép */
    boolean create(int employeeId, int leaveTypeId, double totalDays);

    /** Kiểm tra bản ghi đã tồn tại chưa */
    boolean exists(int employeeId, int leaveTypeId);

}