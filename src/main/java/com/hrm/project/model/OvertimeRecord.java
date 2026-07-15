package com.hrm.project.model;

import java.sql.Date;
import java.sql.Timestamp;

/**
 * Bản ghi tăng ca của nhân viên theo ngày.
 * HR nhập dữ liệu trước khi generate payroll.
 * 
 * overtime_type: WEEKDAY (150%), WEEKEND (200%), HOLIDAY (300%+100%)
 * status: PENDING, APPROVED, REJECTED
 */
public class OvertimeRecord {
    private int id;
    private int employeeId;
    private Date overtimeDate;
    private double hours;
    private String overtimeType;  // WEEKDAY, WEEKEND, HOLIDAY
    private String status;        // PENDING, APPROVED, REJECTED
    private int createdBy;
    private String note;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Display fields
    private String employeeName;
    private String employeeCode;
    private String departmentName;

    public OvertimeRecord() {}

    // === Getters & Setters ===

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getEmployeeId() { return employeeId; }
    public void setEmployeeId(int employeeId) { this.employeeId = employeeId; }

    public Date getOvertimeDate() { return overtimeDate; }
    public void setOvertimeDate(Date overtimeDate) { this.overtimeDate = overtimeDate; }

    public double getHours() { return hours; }
    public void setHours(double hours) { this.hours = hours; }

    public String getOvertimeType() { return overtimeType; }
    public void setOvertimeType(String overtimeType) { this.overtimeType = overtimeType; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getCreatedBy() { return createdBy; }
    public void setCreatedBy(int createdBy) { this.createdBy = createdBy; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    // Display
    public String getEmployeeName() { return employeeName; }
    public void setEmployeeName(String employeeName) { this.employeeName = employeeName; }

    public String getEmployeeCode() { return employeeCode; }
    public void setEmployeeCode(String employeeCode) { this.employeeCode = employeeCode; }

    public String getDepartmentName() { return departmentName; }
    public void setDepartmentName(String departmentName) { this.departmentName = departmentName; }

    /**
     * Helper: trả về label hiển thị cho loại tăng ca
     */
    public String getOvertimeTypeLabel() {
        if (overtimeType == null) return "Không xác định";
        switch (overtimeType) {
            case "WEEKDAY": return "Ngày thường (150%)";
            case "WEEKEND": return "Chủ nhật (200%)";
            case "HOLIDAY": return "Ngày lễ (300%)";
            default: return overtimeType;
        }
    }

    /**
     * Helper: trả về label hiển thị cho trạng thái
     */
    public String getStatusLabel() {
        if (status == null) return "Không xác định";
        switch (status) {
            case "PENDING": return "Chờ duyệt";
            case "APPROVED": return "Đã duyệt";
            case "REJECTED": return "Từ chối";
            default: return status;
        }
    }
}
