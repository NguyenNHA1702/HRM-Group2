package com.hrm.project.model.dtos.response;

import java.sql.Date;

public class ContractDTO {
    private int id;
    private String contractNumber;
    private int employeeId;
    private String employeeCode;
    private String employeeFullName;
    private String departmentName;
    private int contractType;
    private String contractTypeLabel;
    private Date startDate;
    private Date endDate;
    private double baseSalary;
    private int status;
    private String statusLabel;
    private String description;
    private String fileUrl;
    private java.util.List<Integer> allowanceTypeIds;
    private java.util.List<com.hrm.project.model.AllowanceType> allowances;

    // Default Constructor
    public ContractDTO() {
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getContractNumber() {
        return contractNumber;
    }

    public void setContractNumber(String contractNumber) {
        this.contractNumber = contractNumber;
    }

    public int getEmployeeId() {
        return employeeId;
    }

    public void setEmployeeId(int employeeId) {
        this.employeeId = employeeId;
    }

    public String getEmployeeCode() {
        return employeeCode;
    }

    public void setEmployeeCode(String employeeCode) {
        this.employeeCode = employeeCode;
    }

    public String getEmployeeFullName() {
        return employeeFullName;
    }

    public void setEmployeeFullName(String employeeFullName) {
        this.employeeFullName = employeeFullName;
    }

    public String getDepartmentName() {
        return departmentName;
    }

    public void setDepartmentName(String departmentName) {
        this.departmentName = departmentName;
    }

    public int getContractType() {
        return contractType;
    }

    public void setContractType(int contractType) {
        this.contractType = contractType;
    }

    public String getContractTypeLabel() {
        return contractTypeLabel;
    }

    public void setContractTypeLabel(String contractTypeLabel) {
        this.contractTypeLabel = contractTypeLabel;
    }

    public Date getStartDate() {
        return startDate;
    }

    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }

    public double getBaseSalary() {
        return baseSalary;
    }

    public void setBaseSalary(double baseSalary) {
        this.baseSalary = baseSalary;
    }

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }

    public String getStatusLabel() {
        return statusLabel;
    }

    public void setStatusLabel(String statusLabel) {
        this.statusLabel = statusLabel;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getFileUrl() {
        return fileUrl;
    }

    public void setFileUrl(String fileUrl) {
        this.fileUrl = fileUrl;
    }

    public java.util.List<Integer> getAllowanceTypeIds() {
        return allowanceTypeIds;
    }

    public void setAllowanceTypeIds(java.util.List<Integer> allowanceTypeIds) {
        this.allowanceTypeIds = allowanceTypeIds;
    }

    public String getAllowanceTypeIdsString() {
        if (allowanceTypeIds == null || allowanceTypeIds.isEmpty()) {
            return "";
        }
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < allowanceTypeIds.size(); i++) {
            sb.append(allowanceTypeIds.get(i));
            if (i < allowanceTypeIds.size() - 1) {
                sb.append(",");
            }
        }
        return sb.toString();
    }

    public java.util.List<com.hrm.project.model.AllowanceType> getAllowances() {
        return allowances;
    }

    public void setAllowances(java.util.List<com.hrm.project.model.AllowanceType> allowances) {
        this.allowances = allowances;
    }
}
