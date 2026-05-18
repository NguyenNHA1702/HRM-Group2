package com.hrm.project.model.dtos.response;

/** Stats cho HR Dashboard */
public class HrStatsDto {
    private int    totalEmployees;
    private int    newThisMonth;
    private int    terminated;
    private long   payrollFund;      // VND

    public int    getTotalEmployees()        { return totalEmployees; }
    public void   setTotalEmployees(int v)   { this.totalEmployees = v; }
    public int    getNewThisMonth()          { return newThisMonth; }
    public void   setNewThisMonth(int v)     { this.newThisMonth = v; }
    public int    getTerminated()            { return terminated; }
    public void   setTerminated(int v)       { this.terminated = v; }
    public long   getPayrollFund()           { return payrollFund; }
    public void   setPayrollFund(long v)     { this.payrollFund = v; }

    /** Hiển thị quỹ lương dạng "2.5 tỷ" / "500 triệu" */
    public String getPayrollFundFormatted() {
        if (payrollFund >= 1_000_000_000L)
            return String.format("%.1f tỷ", payrollFund / 1_000_000_000.0);
        if (payrollFund >= 1_000_000L)
            return String.format("%.0f triệu", payrollFund / 1_000_000.0);
        return String.format("%,d đ", payrollFund);
    }
}