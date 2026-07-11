package com.hrm.project.dao;

import com.hrm.project.model.Payroll;
import com.hrm.project.model.PayrollDetail;

import java.util.List;

public interface PayrollDAO {
    List<Payroll> getAllPayrolls();
    Payroll getPayrollById(int id);
    Payroll getPayrollByMonthYear(int month, int year);
    List<PayrollDetail> getPayrollDetails(int payrollId);
    List<PayrollDetail> getPayrollDetailsByDepartment(int payrollId, int departmentId);
    List<PayrollDetail> getEmployeeSalaryHistory(int employeeId);
    PayrollDetail getPayrollDetailById(int detailId);
    
    /**
     * Generate payroll: lấy lương từ hợp đồng, phụ cấp từ position, tính thuế TNCN 7 bậc.
     */
    boolean generatePayroll(int month, int year, int createdBy) throws Exception;
    
    int countEmployeesMissingAttendanceSummary(int month, int year);
    
    /**
     * Update payroll status theo flow mới:
     * DRAFT → MANAGER_CONFIRMED (by Manager)
     * MANAGER_CONFIRMED → HR_FINALIZED (by HR)
     */
    boolean updatePayrollStatus(int id, String newStatus, int userId);
    
    List<Payroll> getPayrolls(Integer year, String searchKeyword, int offset, int limit);
    int getTotalPayrollsCount(Integer year, String searchKeyword);
    double getTotalAmountYTD(int year);
}
