package com.hrm.project.model;

/**
 * Model mapping chức vụ (Position) với loại phụ cấp (AllowanceType).
 * Phụ cấp được cấu hình theo position, không gán trực tiếp cho nhân viên.
 */
public class PositionAllowance {
    private int positionId;
    private int allowanceTypeId;

    // Display fields
    private String positionName;
    private String positionCode;
    private String allowanceName;
    private String allowanceCode;
    private double allowanceAmount;

    public PositionAllowance() {}

    public int getPositionId() { return positionId; }
    public void setPositionId(int positionId) { this.positionId = positionId; }

    public int getAllowanceTypeId() { return allowanceTypeId; }
    public void setAllowanceTypeId(int allowanceTypeId) { this.allowanceTypeId = allowanceTypeId; }

    public String getPositionName() { return positionName; }
    public void setPositionName(String positionName) { this.positionName = positionName; }

    public String getPositionCode() { return positionCode; }
    public void setPositionCode(String positionCode) { this.positionCode = positionCode; }

    public String getAllowanceName() { return allowanceName; }
    public void setAllowanceName(String allowanceName) { this.allowanceName = allowanceName; }

    public String getAllowanceCode() { return allowanceCode; }
    public void setAllowanceCode(String allowanceCode) { this.allowanceCode = allowanceCode; }

    public double getAllowanceAmount() { return allowanceAmount; }
    public void setAllowanceAmount(double allowanceAmount) { this.allowanceAmount = allowanceAmount; }
}
