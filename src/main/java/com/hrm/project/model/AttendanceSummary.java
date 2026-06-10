package com.hrm.project.model;

import java.util.Date;

public class AttendanceSummary {
    private int id;
    private int employeeId;
    private int month;
    private int year;
    private double standardDays;
    private double actualWorkedDays;
    private double paidLeaveDays;
    private double unpaidLeaveDays;
    private Date createdAt;
    private Date updatedAt;

    public AttendanceSummary() {
    }

    public AttendanceSummary(int id, int employeeId, int month, int year, double standardDays, double actualWorkedDays, double paidLeaveDays, double unpaidLeaveDays) {
        this.id = id;
        this.employeeId = employeeId;
        this.month = month;
        this.year = year;
        this.standardDays = standardDays;
        this.actualWorkedDays = actualWorkedDays;
        this.paidLeaveDays = paidLeaveDays;
        this.unpaidLeaveDays = unpaidLeaveDays;
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

    public int getMonth() {
        return month;
    }

    public void setMonth(int month) {
        this.month = month;
    }

    public int getYear() {
        return year;
    }

    public void setYear(int year) {
        this.year = year;
    }

    public double getStandardDays() {
        return standardDays;
    }

    public void setStandardDays(double standardDays) {
        this.standardDays = standardDays;
    }

    public double getActualWorkedDays() {
        return actualWorkedDays;
    }

    public void setActualWorkedDays(double actualWorkedDays) {
        this.actualWorkedDays = actualWorkedDays;
    }

    public double getPaidLeaveDays() {
        return paidLeaveDays;
    }

    public void setPaidLeaveDays(double paidLeaveDays) {
        this.paidLeaveDays = paidLeaveDays;
    }

    public double getUnpaidLeaveDays() {
        return unpaidLeaveDays;
    }

    public void setUnpaidLeaveDays(double unpaidLeaveDays) {
        this.unpaidLeaveDays = unpaidLeaveDays;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public Date getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Date updatedAt) {
        this.updatedAt = updatedAt;
    }
}
