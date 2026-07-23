package com.hrm.project.model.dtos.response;

/** Stats cho Manager Dashboard */
public class ManagerStatsDto {
    private int teamSize;
    private int pendingExplanations;
    private int approvedLeavesMonth;
    private int pendingApprovals;

    public int  getTeamSize()              { return teamSize; }
    public void setTeamSize(int v)         { this.teamSize = v; }
    public int  getPendingExplanations()   { return pendingExplanations; }
    public void setPendingExplanations(int v) { this.pendingExplanations = v; }
    public int  getApprovedLeavesMonth()   { return approvedLeavesMonth; }
    public void setApprovedLeavesMonth(int v) { this.approvedLeavesMonth = v; }
    public int  getPendingApprovals()      { return pendingApprovals; }
    public void setPendingApprovals(int v) { this.pendingApprovals = v; }
}