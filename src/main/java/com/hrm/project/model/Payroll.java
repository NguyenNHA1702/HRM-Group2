package com.hrm.project.model;

import java.sql.Timestamp;

/**
 * Bảng lương tháng (master record).
 * Flow duyệt: DRAFT → MANAGER_CONFIRMED → HR_FINALIZED
 */
public class Payroll {
    private int id;
    private int month;
    private int year;
    private String status; // DRAFT, MANAGER_CONFIRMED, HR_FINALIZED
    private int totalEmployees;
    private double totalAmount;

    // DRAFT creator
    private int createdBy;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Legacy fields (kept for backward compatibility)
    private int approvedBy;
    private Timestamp approvedAt;
    private int paidBy;
    private Timestamp paidAt;

    // New flow fields
    private int managerConfirmedBy;
    private Timestamp managerConfirmedAt;
    private int hrConfirmedBy;
    private Timestamp hrConfirmedAt;
    private int finalizedBy;
    private Timestamp finalizedAt;

    // Display names
    private String createdByName;
    private String approvedByName;
    private String paidByName;
    private String managerConfirmedByName;
    private String hrConfirmedByName;
    private String finalizedByName;

    public Payroll() {}

    // === Getters & Setters ===

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

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    // Legacy
    public int getApprovedBy() { return approvedBy; }
    public void setApprovedBy(int approvedBy) { this.approvedBy = approvedBy; }

    public Timestamp getApprovedAt() { return approvedAt; }
    public void setApprovedAt(Timestamp approvedAt) { this.approvedAt = approvedAt; }

    public int getPaidBy() { return paidBy; }
    public void setPaidBy(int paidBy) { this.paidBy = paidBy; }

    public Timestamp getPaidAt() { return paidAt; }
    public void setPaidAt(Timestamp paidAt) { this.paidAt = paidAt; }

    // New flow
    public int getManagerConfirmedBy() { return managerConfirmedBy; }
    public void setManagerConfirmedBy(int managerConfirmedBy) { this.managerConfirmedBy = managerConfirmedBy; }

    public Timestamp getManagerConfirmedAt() { return managerConfirmedAt; }
    public void setManagerConfirmedAt(Timestamp managerConfirmedAt) { this.managerConfirmedAt = managerConfirmedAt; }

    public int getHrConfirmedBy() { return hrConfirmedBy; }
    public void setHrConfirmedBy(int hrConfirmedBy) { this.hrConfirmedBy = hrConfirmedBy; }

    public Timestamp getHrConfirmedAt() { return hrConfirmedAt; }
    public void setHrConfirmedAt(Timestamp hrConfirmedAt) { this.hrConfirmedAt = hrConfirmedAt; }

    public int getFinalizedBy() { return finalizedBy; }
    public void setFinalizedBy(int finalizedBy) { this.finalizedBy = finalizedBy; }

    public Timestamp getFinalizedAt() { return finalizedAt; }
    public void setFinalizedAt(Timestamp finalizedAt) { this.finalizedAt = finalizedAt; }

    // Display names
    public String getCreatedByName() { return createdByName; }
    public void setCreatedByName(String createdByName) { this.createdByName = createdByName; }

    public String getApprovedByName() { return approvedByName; }
    public void setApprovedByName(String approvedByName) { this.approvedByName = approvedByName; }

    public String getPaidByName() { return paidByName; }
    public void setPaidByName(String paidByName) { this.paidByName = paidByName; }

    public String getManagerConfirmedByName() { return managerConfirmedByName; }
    public void setManagerConfirmedByName(String n) { this.managerConfirmedByName = n; }

    public String getHrConfirmedByName() { return hrConfirmedByName; }
    public void setHrConfirmedByName(String n) { this.hrConfirmedByName = n; }

    public String getFinalizedByName() { return finalizedByName; }
    public void setFinalizedByName(String n) { this.finalizedByName = n; }

    /**
     * Helper: trả về label hiển thị cho status
     */
    public String getStatusLabel() {
        if (status == null) return "Không xác định";
        switch (status) {
            case "DRAFT": return "Bản nháp";
            case "MANAGER_CONFIRMED": return "Manager đã xác nhận";
            case "HR_FINALIZED": return "Đã chốt lương";
            // Legacy
            case "APPROVED": return "Đã duyệt (cũ)";
            case "PAID": return "Đã thanh toán (cũ)";
            default: return status;
        }
    }

    /**
     * Helper: trả về CSS class cho badge status
     */
    public String getStatusBadgeClass() {
        if (status == null) return "badge-gray";
        switch (status) {
            case "DRAFT": return "badge-yellow";
            case "MANAGER_CONFIRMED": return "badge-blue";
            case "HR_FINALIZED": return "badge-green";
            case "APPROVED": return "badge-blue";
            case "PAID": return "badge-green";
            default: return "badge-gray";
        }
    }
}
