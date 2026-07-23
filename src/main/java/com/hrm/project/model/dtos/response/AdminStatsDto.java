package com.hrm.project.model.dtos.response;

/** Stats cho Admin Dashboard */
public class AdminStatsDto {
    private int totalActiveUsers;
    private int activeToday;
    private int totalRoles;
    private int totalEmployees;

    // Getters & Setters
    public int getTotalActiveUsers()          { return totalActiveUsers; }
    public void setTotalActiveUsers(int v)     { this.totalActiveUsers = v; }
    public int getActiveToday()               { return activeToday; }
    public void setActiveToday(int v)          { this.activeToday = v; }
    public int getTotalRoles()                { return totalRoles; }
    public void setTotalRoles(int v)           { this.totalRoles = v; }
    public int getTotalEmployees()            { return totalEmployees; }
    public void setTotalEmployees(int v)       { this.totalEmployees = v; }
}