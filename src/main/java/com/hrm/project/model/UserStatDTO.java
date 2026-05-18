package com.hrm.project.model;

/** DTO thống kê nhanh cho 4 thẻ đầu trang Quản lý Users. */
public class UserStatDTO {
    private int totalUsers;
    private int activeUsers;
    private int inactiveUsers;
    private int adminUsers;

    public UserStatDTO() {}

    public int getTotalUsers()    { return totalUsers; }
    public void setTotalUsers(int v)    { this.totalUsers = v; }

    public int getActiveUsers()   { return activeUsers; }
    public void setActiveUsers(int v)   { this.activeUsers = v; }

    public int getInactiveUsers() { return inactiveUsers; }
    public void setInactiveUsers(int v) { this.inactiveUsers = v; }

    public int getAdminUsers()    { return adminUsers; }
    public void setAdminUsers(int v)    { this.adminUsers = v; }
}
