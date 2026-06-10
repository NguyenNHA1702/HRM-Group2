package com.hrm.project.model;

import java.sql.Date;
import java.sql.Timestamp;

public class Contract {
    private int id;
    private String contractNumber;
    private int employeeId;
    private int contractType; // Maps to ContractType enum (1, 2, 3, 4)
    private Date startDate;
    private Date endDate; // Can be null if contractType = 3
    private double baseSalary; // Matches double usage for salary in SalaryScale and InsuranceConfig
    private int status; // Maps to ContractStatus enum (1, 2, 3)
    private String description;
    private String fileUrl; // Optional contract file URL or upload path
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Default Constructor
    public Contract() {
    }

    // Full Constructor
    public Contract(int id, String contractNumber, int employeeId, int contractType, Date startDate, Date endDate,
                    double baseSalary, int status, String description, Timestamp createdAt, Timestamp updatedAt) {
        this.id = id;
        this.contractNumber = contractNumber;
        this.employeeId = employeeId;
        this.contractType = contractType;
        this.startDate = startDate;
        this.endDate = endDate;
        this.baseSalary = baseSalary;
        this.status = status;
        this.description = description;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
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

    public int getContractType() {
        return contractType;
    }

    public void setContractType(int contractType) {
        this.contractType = contractType;
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

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
}
