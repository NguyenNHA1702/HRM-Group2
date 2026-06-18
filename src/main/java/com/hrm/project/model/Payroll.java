package com.hrm.project.model;

import java.sql.Timestamp;

public class Payroll {
    private int id;
    private int month;
    private int year;
    private String status;
    private int totalEmployees;
    private double totalAmount;
    private int createdBy;
    private int approvedBy;
    private Timestamp approvedAt;
    private int paidBy;
    private Timestamp paidAt;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Additional fields for displaying
    private String createdByName;
    private String approvedByName;
    private String paidByName;

    public Payroll() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getMonth() { return month; }
    public void setMonth(int month) { this.month = month; }

    public int getYear() { return year; }
    public void setYear(int year) { this.year = year; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getTotalEmployees() { return totalEmployees; }
    public void setTotalEmployees(int totalEmployees) { this.totalEmployees = totalEmployees; }

    public double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }

    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }

    public int getApprovedBy() { return approvedBy; }
    public void setApprovedBy(int approvedBy) { this.approvedBy = approvedBy; }

    public Timestamp getApprovedAt() { return approvedAt; }
    public void setApprovedAt(Timestamp approvedAt) { this.approvedAt = approvedAt; }

    public int getPaidBy() { return paidBy; }
    public void setPaidBy(int paidBy) { this.paidBy = paidBy; }

    public Timestamp getPaidAt() { return paidAt; }
    public void setPaidAt(Timestamp paidAt) { this.paidAt = paidAt; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getCreatedByName() { return createdByName; }
    public void setCreatedByName(String createdByName) { this.createdByName = createdByName; }

    public String getApprovedByName() { return approvedByName; }
    public void setApprovedByName(String approvedByName) { this.approvedByName = approvedByName; }

    public String getPaidByName() { return paidByName; }
    public void setPaidByName(String paidByName) { this.paidByName = paidByName; }
}
