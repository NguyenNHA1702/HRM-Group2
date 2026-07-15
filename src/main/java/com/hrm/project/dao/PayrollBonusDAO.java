package com.hrm.project.dao;

import com.hrm.project.model.PayrollBonus;
import java.util.List;
import java.util.Map;

public interface PayrollBonusDAO {
    List<PayrollBonus> getByMonth(int year, int month);
    List<PayrollBonus> getByEmployeeMonth(int employeeId, int year, int month);
    PayrollBonus getById(int id);
    boolean add(PayrollBonus bonus);
    boolean update(PayrollBonus bonus);
    boolean delete(int id);

    /**
     * Lấy tổng hợp thưởng theo nhân viên cho tháng/năm.
     * Key = employeeId, Value = list các khoản thưởng.
     */
    Map<Integer, List<PayrollBonus>> getByMonthForPayroll(int year, int month);

    int countByMonth(int year, int month);
}
