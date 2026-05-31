package com.hrm.project.model;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * Model - Cấu hình bảo hiểm của nhân viên
 */
public class InsuranceConfig implements Serializable {

    private int id;
    private int employeeId;           // ID nhân viên
    private String insuranceNumber;   // Số bảo hiểm

    // Các loại bảo hiểm - tỉ lệ (%)
    private double bhxhRate;          // BHXH - Bảo hiểm xã hội (%)
    private double bhytRate;          // BHYT - Bảo hiểm y tế (%)
    private double bhtnRate;          // BHTN - Bảo hiểm thất nghiệp (%)

    // Tiền đóng bảo hiểm
    private double baseSalary;        // Lương đóng bảo hiểm
    private double bhxhAmount;        // Tiền BHXH hàng tháng
    private double bhytAmount;        // Tiền BHYT hàng tháng
    private double bhtnAmount;        // Tiền BHTN hàng tháng
    private double totalAmount;       // Tổng tiền bảo hiểm hàng tháng

    // Trạng thái
    private boolean isActive;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // Constructors
    public InsuranceConfig() {}

    public InsuranceConfig(int employeeId, String insuranceNumber,
                           double bhxhRate, double bhytRate, double bhtnRate,
                           double baseSalary, boolean isActive) {
        this.employeeId = employeeId;
        this.insuranceNumber = insuranceNumber;
        this.bhxhRate = bhxhRate;
        this.bhytRate = bhytRate;
        this.bhtnRate = bhtnRate;
        this.baseSalary = baseSalary;
        this.isActive = isActive;
        calculateAmounts();
    }

    // Tính toán các khoản tiền bảo hiểm
    public void calculateAmounts() {
        this.bhxhAmount = baseSalary * (bhxhRate / 100.0);
        this.bhytAmount = baseSalary * (bhytRate / 100.0);
        this.bhtnAmount = baseSalary * (bhtnRate / 100.0);
        this.totalAmount = bhxhAmount + bhytAmount + bhtnAmount;
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
        calculateAmounts();
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

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    @Override
    public String toString() {
        return "InsuranceConfig{" +
                "id=" + id +
                ", employeeId=" + employeeId +
                ", insuranceNumber='" + insuranceNumber + '\'' +
                ", bhxhRate=" + bhxhRate +
                ", bhytRate=" + bhytRate +
                ", bhtnRate=" + bhtnRate +
                ", baseSalary=" + baseSalary +
                ", totalAmount=" + totalAmount +
                ", isActive=" + isActive +
                '}';
    }
}