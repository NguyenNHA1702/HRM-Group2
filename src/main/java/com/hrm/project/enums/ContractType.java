package com.hrm.project.enums;

public enum ContractType {
    PROBATION(1, "Thử việc"),
    OFFICIAL_1Y(2, "Chính thức 1 năm"),
    INDEFINITE(3, "Không thời hạn"),
    SEASONAL(4, "Thời vụ");

    private final int value;
    private final String label;

    ContractType(int value, String label) {
        this.value = value;
        this.label = label;
    }

    public int getValue() {
        return value;
    }

    public String getLabel() {
        return label;
    }

    public static ContractType fromValue(int value) {
        for (ContractType type : ContractType.values()) {
            if (type.getValue() == value) {
                return type;
            }
        }
        throw new IllegalArgumentException("Unknown contract type value: " + value);
    }
}
