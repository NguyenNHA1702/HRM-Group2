package com.hrm.project.model;

import java.util.Date;

public class SalaryHistory {
    private int id;
    private int employeeId;
    private int salaryScaleId;
    private Date effectiveDate;
    private Date createdAt;
    
    // Joined fields
    private String grade;
    private double basicSalary;

    public SalaryHistory() {}

    public SalaryHistory(int id, int employeeId, int salaryScaleId, Date effectiveDate, Date createdAt, String grade, double basicSalary) {
        this.id = id;
        this.employeeId = employeeId;
        this.salaryScaleId = salaryScaleId;
        this.effectiveDate = effectiveDate;
        this.createdAt = createdAt;
        this.grade = grade;
        this.basicSalary = basicSalary;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getEmployeeId() {
        return employeeId;
    }

    public void setEmployeeId(int employeeId) {
        this.employeeId = employeeId;
    }

    public int getSalaryScaleId() {
        return salaryScaleId;
    }

    public void setSalaryScaleId(int salaryScaleId) {
        this.salaryScaleId = salaryScaleId;
    }

    public Date getEffectiveDate() {
        return effectiveDate;
    }

    public void setEffectiveDate(Date effectiveDate) {
        this.effectiveDate = effectiveDate;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public String getGrade() {
        return grade;
    }

    public void setGrade(String grade) {
        this.grade = grade;
    }

    public double getBasicSalary() {
        return basicSalary;
    }

    public void setBasicSalary(double basicSalary) {
        this.basicSalary = basicSalary;
    }
}
