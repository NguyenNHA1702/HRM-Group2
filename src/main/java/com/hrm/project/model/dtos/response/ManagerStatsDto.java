package com.hrm.project.model.dtos.response;

/** Stats cho Manager Dashboard */
public class ManagerStatsDto {
    private int teamSize;
    private int presentToday;
    private int onLeave;
    private int pendingApprovals;

    public int  getTeamSize()              { return teamSize; }
    public void setTeamSize(int v)         { this.teamSize = v; }
    public int  getPresentToday()          { return presentToday; }
    public void setPresentToday(int v)     { this.presentToday = v; }
    public int  getOnLeave()               { return onLeave; }
    public void setOnLeave(int v)          { this.onLeave = v; }
    public int  getPendingApprovals()      { return pendingApprovals; }
    public void setPendingApprovals(int v) { this.pendingApprovals = v; }
}