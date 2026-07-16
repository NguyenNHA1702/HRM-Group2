package com.hrm.project.dao;

import com.hrm.project.model.OvertimeRecord;
import java.util.List;
import java.util.Map;

public interface OvertimeRecordDAO {
    List<OvertimeRecord> getByMonth(int year, int month);
    List<OvertimeRecord> getByEmployeeMonth(int employeeId, int year, int month);
    OvertimeRecord getById(int id);
    boolean add(OvertimeRecord record);
    boolean update(OvertimeRecord record);
    boolean delete(int id);

    /**
     * Lấy tổng hợp tăng ca theo nhân viên cho tháng/năm (chỉ APPROVED).
     * Key = employeeId, Value = list các bản ghi tăng ca đã duyệt.
     */
    Map<Integer, List<OvertimeRecord>> getApprovedByMonthForPayroll(int year, int month);

    /**
     * Cập nhật trạng thái duyệt tăng ca.
     */
    boolean updateStatus(int id, String newStatus, int reviewedBy);

    int countByMonth(int year, int month);
}
