package com.hrm.project.enums;

public enum VacancyStatus {
    OPEN("OPEN", "Đang mở"),
    CLOSED("CLOSED", "Đã đóng");

    private final String code;
    private final String label;

    VacancyStatus(String code, String label) {
        this.code = code;
        this.label = label;
    }

    public String getCode() {
        return code;
    }

    public String getLabel() {
        return label;
    }

    public static VacancyStatus fromCode(String code) {
        for (VacancyStatus status : values()) {
            if (status.code.equals(code)) {
                return status;
            }
        }
        throw new IllegalArgumentException("Unknown vacancy status: " + code);
    }
}
