package com.hrm.project.model;

import java.time.LocalDateTime;

/**
 * DTO hien thi thong tin User cho trang Admin Quan ly Users.
 * Map voi ket qua JOIN user_accounts + employees + roles + role_groups.
 */
public class UserAccountDTO {

    private int     id;
    private int     employeeId;        // linked employee ID
    private String  username;          // email dang nhap (work_email)
    private String  fullName;
    private String  roleGroupCode;     // ADMIN | HR | MANAGER | EMPLOYEE
    private String  roleName;          // ten role chi tiet
    private String  employeeCode;      // ma NV (null neu admin thuan)
    private boolean isActive;
    private LocalDateTime lastLoginAt;
    private boolean forceResetPwd;

    // --- Constructors -------------------------------------------
    public UserAccountDTO() {}

    // --- Getters / Setters --------------------------------------
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getEmployeeId() { return employeeId; }
    public void setEmployeeId(int employeeId) { this.employeeId = employeeId; }


    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getRoleGroupCode() { return roleGroupCode; }
    public void setRoleGroupCode(String roleGroupCode) { this.roleGroupCode = roleGroupCode; }

    public String getRoleName() { return roleName; }
    public void setRoleName(String roleName) { this.roleName = roleName; }

    public String getEmployeeCode() { return employeeCode; }
    public void setEmployeeCode(String employeeCode) { this.employeeCode = employeeCode; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public LocalDateTime getLastLoginAt() { return lastLoginAt; }
    public void setLastLoginAt(LocalDateTime lastLoginAt) { this.lastLoginAt = lastLoginAt; }

    public boolean isForceResetPwd() { return forceResetPwd; }
    public void setForceResetPwd(boolean forceResetPwd) { this.forceResetPwd = forceResetPwd; }

    // --- Helpers (dung trong JSP) -------------------------------
    /** Ten hien thi cho badge Role. */
    public String getRoleDisplayName() {
        if (roleGroupCode == null) return roleName;
        switch (roleGroupCode) {
            case "ADMIN":
                return "Admin";
            case "HR":
                return "Hr";
            case "MANAGER":
                return "Manager";
            case "EMPLOYEE":
                return "Employee";
            default:
                return roleName;
        }
    }

    /** CSS class cho badge Role. */
    public String getRoleBadgeClass() {
        if (roleGroupCode == null) return "badge-employee";
        switch (roleGroupCode) {
            case "ADMIN":
                return "badge-admin";
            case "HR":
                return "badge-hr";
            case "MANAGER":
                return "badge-manager";
            default:
                return "badge-employee";
        }
    }

    /** Label Trang thai. */
    public String getStatusLabel() { return isActive ? "Active" : "Inactive"; }

    /** CSS class cho trang thai. */
    public String getStatusClass() { return isActive ? "status-active" : "status-inactive"; }
}