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
    
    // Core function to calculate and save payroll for a given month and year
    boolean generatePayroll(int month, int year, int createdBy);
    boolean updatePayrollStatus(int id, String status, int userId);
}
