package com.hrm.project.model.dtos.response;

/** Stats cho HR Dashboard */
public class HrStatsDto {
    private int    totalEmployees;
    private int    newThisMonth;
    private int    terminated;
    private long   payrollFund;      // VND
    private int    pendingLeaves;
    private int    pendingExplanations;
    private int    openVacancies;

    public int    getTotalEmployees()        { return totalEmployees; }
    public void   setTotalEmployees(int v)   { this.totalEmployees = v; }
    public int    getNewThisMonth()          { return newThisMonth; }
    public void   setNewThisMonth(int v)     { this.newThisMonth = v; }
    public int    getTerminated()            { return terminated; }
    public void   setTerminated(int v)       { this.terminated = v; }
    public long   getPayrollFund()           { return payrollFund; }
    public void   setPayrollFund(long v)     { this.payrollFund = v; }

    public int    getPendingLeaves()         { return pendingLeaves; }
    public void   setPendingLeaves(int v)    { this.pendingLeaves = v; }
    public int    getPendingExplanations()   { return pendingExplanations; }
    public void   setPendingExplanations(int v) { this.pendingExplanations = v; }
    public int    getOpenVacancies()         { return openVacancies; }
    public void   setOpenVacancies(int v)    { this.openVacancies = v; }

    /** Hiển thị quỹ lương dạng "2.5 tỷ" / "500 triệu" */
    public String getPayrollFundFormatted() {
        if (payrollFund >= 1_000_000_000L)
            return String.format("%.1f tỷ", payrollFund / 1_000_000_000.0);
        if (payrollFund >= 1_000_000L)
            return String.format("%.0f triệu", payrollFund / 1_000_000.0);
        return String.format("%,d đ", payrollFund);
    }
}