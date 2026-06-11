package com.hrm.project.enums;

public enum ContractStatus {
    ACTIVE(1, "Active"),
    EXPIRED(2, "Expired"),
    TERMINATED(3, "Terminated");

    private final int value;
    private final String label;

    ContractStatus(int value, String label) {
        this.value = value;
        this.label = label;
    }

    public int getValue() {
        return value;
    }

    public String getLabel() {
        return label;
    }

    public static ContractStatus fromValue(int value) {
        for (ContractStatus status : ContractStatus.values()) {
            if (status.getValue() == value) {
                return status;
            }
        }
        throw new IllegalArgumentException("Unknown contract status value: " + value);
    }
}
