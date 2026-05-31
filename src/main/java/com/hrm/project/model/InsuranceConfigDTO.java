package com.hrm.project.model;

import java.io.Serializable;

/**
 * DTO - Data Transfer Object cho Insurance Config
 * Dùng để truyền dữ liệu giữa Controller và View (JSP)
 * Kết hợp thông tin từ insurance_config + employees
 */
public class InsuranceConfigDTO implements Serializable {

    private int id;
    private int employeeId;
    private String employeeCode;     // Mã nhân viên (từ employees)
    private String fullName;         // Tên nhân viên (từ employees)
    private String departmentName;   // Tên phòng ban (từ departments)
    private String positionName;     // Tên chức vụ (từ positions)
    private String insuranceNumber;  // Số bảo hiểm

    // Tỉ lệ bảo hiểm (%)
    private double bhxhRate;         // BHXH %
    private double bhytRate;         // BHYT %
    private double bhtnRate;         // BHTN %

    // Tiền bảo hiểm
    private double baseSalary;       // Lương đóng bảo hiểm
    private double bhxhAmount;       // Tiền BHXH
    private double bhytAmount;       // Tiền BHYT
    private double bhtnAmount;       // Tiền BHTN
    private double totalAmount;      // Tổng tiền bảo hiểm

    // Trạng thái
    private boolean isActive;
    private String status;           // "Đang áp dụng" hoặc "Đã dừng"

    // Constructors
    public InsuranceConfigDTO() {}

    public InsuranceConfigDTO(int id, int employeeId, String employeeCode, String fullName,
                              String departmentName, String positionName, String insuranceNumber,
                              double bhxhRate, double bhytRate, double bhtnRate,
                              double baseSalary, double totalAmount, boolean isActive) {
        this.id = id;
        this.employeeId = employeeId;
        this.employeeCode = employeeCode;
        this.fullName = fullName;
        this.departmentName = departmentName;
        this.positionName = positionName;
        this.insuranceNumber = insuranceNumber;
        this.bhxhRate = bhxhRate;
        this.bhytRate = bhytRate;
        this.bhtnRate = bhtnRate;
        this.baseSalary = baseSalary;
        this.totalAmount = totalAmount;
        this.isActive = isActive;
        this.status = isActive ? "Đang áp dụng" : "Đã dừng";
    }

    // Getters and Setters
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

    public String getEmployeeCode() {
        return employeeCode;
    }

    public void setEmployeeCode(String employeeCode) {
        this.employeeCode = employeeCode;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getDepartmentName() {
        return departmentName;
    }

    public void setDepartmentName(String departmentName) {
        this.departmentName = departmentName;
    }

    public String getPositionName() {
        return positionName;
    }

    public void setPositionName(String positionName) {
        this.positionName = positionName;
    }

    public String getInsuranceNumber() {
        return insuranceNumber;
    }

    public void setInsuranceNumber(String insuranceNumber) {
        this.insuranceNumber = insuranceNumber;
    }

    public double getBhxhRate() {
        return bhxhRate;
    }

    public void setBhxhRate(double bhxhRate) {
        this.bhxhRate = bhxhRate;
    }

    public double getBhytRate() {
        return bhytRate;
    }

    public void setBhytRate(double bhytRate) {
        this.bhytRate = bhytRate;
    }

    public double getBhtnRate() {
        return bhtnRate;
    }

    public void setBhtnRate(double bhtnRate) {
        this.bhtnRate = bhtnRate;
    }

    public double getBaseSalary() {
        return baseSalary;
    }

    public void setBaseSalary(double baseSalary) {
        this.baseSalary = baseSalary;
    }

    public double getBhxhAmount() {
        return bhxhAmount;
    }

    public void setBhxhAmount(double bhxhAmount) {
        this.bhxhAmount = bhxhAmount;
    }

    public double getBhytAmount() {
        return bhytAmount;
    }

    public void setBhytAmount(double bhytAmount) {
        this.bhytAmount = bhytAmount;
    }

    public double getBhtnAmount() {
        return bhtnAmount;
    }

    public void setBhtnAmount(double bhtnAmount) {
        this.bhtnAmount = bhtnAmount;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}