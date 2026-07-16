package com.hrm.project.enums;

public enum CandidateStatus {
    NEW("NEW", "Mới nhận"),
    INTERVIEWING("INTERVIEWING", "Đang phỏng vấn"),
    OFFERED("OFFERED", "Đề nghị làm việc"),
    HIRED("HIRED", "Đã nhận việc"),
    REJECTED("REJECTED", "Từ chối");

    private final String code;
    private final String label;

    CandidateStatus(String code, String label) {
        this.code = code;
        this.label = label;
    }

    public String getCode() {
        return code;
    }

    public String getLabel() {
        return label;
    }

    public static CandidateStatus fromCode(String code) {
        for (CandidateStatus status : values()) {
            if (status.code.equals(code)) {
                return status;
            }
        }
        throw new IllegalArgumentException("Unknown candidate status: " + code);
    }
}
