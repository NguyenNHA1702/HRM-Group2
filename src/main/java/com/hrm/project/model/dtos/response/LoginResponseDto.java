package com.hrm.project.model.dtos.response;

import java.io.Serializable;

public class LoginResponseDto implements Serializable{
    private static final long serialVersionUID = 1L;

    private int employeeId;
    private int accountId;

    private String fullName;
    private String workEmail;
    private String roleName;
    private String roleGroupCode;
    private String avatarUrl;

    private String sessionToken;

    public LoginResponseDto() {
    }

    public LoginResponseDto(String fullName, int employeeId, int accountId, String workEmail, String roleName, String roleGroupCode, String avatarUrl, String sessionToken) {
        this.fullName = fullName;
        this.employeeId = employeeId;
        this.accountId = accountId;
        this.workEmail = workEmail;
        this.roleName = roleName;
        this.roleGroupCode = roleGroupCode;
        this.avatarUrl = avatarUrl;
        this.sessionToken = sessionToken;
    }

    public int getEmployeeId() {
        return employeeId;
    }

    public void setEmployeeId(int employeeId) {
        this.employeeId = employeeId;
    }

    public int getAccountId() {
        return accountId;
    }

    public void setAccountId(int accountId) {
        this.accountId = accountId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getWorkEmail() {
        return workEmail;
    }

    public void setWorkEmail(String workEmail) {
        this.workEmail = workEmail;
    }

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    public String getRoleGroupCode() {
        return roleGroupCode;
    }

    public void setRoleGroupCode(String roleGroupCode) {
        this.roleGroupCode = roleGroupCode;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }

    public String getSessionToken() {
        return sessionToken;
    }

    public void setSessionToken(String sessionToken) {
        this.sessionToken = sessionToken;
    }

    @Override
    public String toString() {
        return "LoginResponseDto{" +
                "employeeId=" + employeeId +
                ", accountId=" + accountId +
                ", fullName='" + fullName + '\'' +
                ", workEmail='" + workEmail + '\'' +
                ", roleName='" + roleName + '\'' +
                ", roleGroupCode='" + roleGroupCode + '\'' +
                ", avatarUrl='" + avatarUrl + '\'' +
                ", sessionToken='" + sessionToken + '\'' +
                '}';
    }
}
