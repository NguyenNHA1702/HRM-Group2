package com.hrm.project.dao;

import com.hrm.project.model.Payroll;
import com.hrm.project.model.PayrollDetail;

import java.util.List;

public interface PayrollDAO {
    List<Payroll> getAllPayrolls();
    Payroll getPayrollById(int id);
    Payroll getPayrollByMonthYear(int month, int year);
    List<PayrollDetail> getPayrollDetails(int payrollId);
    List<PayrollDetail> getEmployeeSalaryHistory(int employeeId);
    PayrollDetail getPayrollDetailById(int detailId);
    
    // Core function to calculate and save payroll for a given month and year
    boolean generatePayroll(int month, int year, int createdBy) throws Exception;
    
    /**
     * Kiểm tra số lượng nhân viên đang active chưa có dữ liệu chấm công trong tháng/năm.
     */
    int countEmployeesMissingAttendanceSummary(int month, int year);
    boolean updatePayrollStatus(int id, String status, int userId);
    
    List<Payroll> getPayrolls(Integer year, String searchKeyword, int offset, int limit);
    int getTotalPayrollsCount(Integer year, String searchKeyword);
    double getTotalAmountYTD(int year);
}
