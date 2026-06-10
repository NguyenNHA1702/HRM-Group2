package com.hrm.project.model;

public class UserAccount {
    private int employeeId;
    private String employeeCode;
    private String fullName;
    private String avatarUrl;
    private String phone;
    private String workEmail;
    private String personalEmail;
    private String departmentName;
    private String positionName;
    private String roleName;
    private String managerName;
    private String status;
    
    // Additional fields for Admin Update
    private String dateOfBirth;
    private String gender;
    private int departmentId;
    private int positionId;
    private int roleId;
    private boolean isActive;
    private int salaryScaleId;
    private java.util.List<Integer> allowanceTypeIds = new java.util.ArrayList<>();

    public UserAccount() {}

    // Getters and Setters
    public int getEmployeeId() { return employeeId; }
    public void setEmployeeId(int employeeId) { this.employeeId = employeeId; }

    public String getEmployeeCode() { return employeeCode; }
    public void setEmployeeCode(String employeeCode) { this.employeeCode = employeeCode; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getAvatarUrl() { return avatarUrl; }
    public void setAvatarUrl(String avatarUrl) { this.avatarUrl = avatarUrl; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getWorkEmail() { return workEmail; }
    public void setWorkEmail(String workEmail) { this.workEmail = workEmail; }

    public String getPersonalEmail() { return personalEmail; }
    public void setPersonalEmail(String personalEmail) { this.personalEmail = personalEmail; }

    public String getDepartmentName() { return departmentName; }
    public void setDepartmentName(String departmentName) { this.departmentName = departmentName; }

    public String getPositionName() { return positionName; }
    public void setPositionName(String positionName) { this.positionName = positionName; }

    public String getRoleName() { return roleName; }
    public void setRoleName(String roleName) { this.roleName = roleName; }

    public String getManagerName() { return managerName; }
    public void setManagerName(String managerName) { this.managerName = managerName; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getDateOfBirth() { return dateOfBirth; }
    public void setDateOfBirth(String dateOfBirth) { this.dateOfBirth = dateOfBirth; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public int getDepartmentId() { return departmentId; }
    public void setDepartmentId(int departmentId) { this.departmentId = departmentId; }

    public int getPositionId() { return positionId; }
    public void setPositionId(int positionId) { this.positionId = positionId; }

    public int getRoleId() { return roleId; }
    public void setRoleId(int roleId) { this.roleId = roleId; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean isActive) { this.isActive = isActive; }

    public int getSalaryScaleId() { return salaryScaleId; }
    public void setSalaryScaleId(int salaryScaleId) { this.salaryScaleId = salaryScaleId; }

    public java.util.List<Integer> getAllowanceTypeIds() { return allowanceTypeIds; }
    public void setAllowanceTypeIds(java.util.List<Integer> allowanceTypeIds) { this.allowanceTypeIds = allowanceTypeIds; }
}
