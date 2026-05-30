package com.hrm.project.model;

public class AllowanceType {
    private int id;
    private String code;
    private String name;
    private double amount;
    private String description;
    private boolean active;

    public AllowanceType() {}

    public AllowanceType(int id, String code, String name, double amount, String description, boolean active) {
        this.id = id;
        this.code = code;
        this.name = name;
        this.amount = amount;
        this.description = description;
        this.active = active;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public double getAmount() { return amount; }
    public void setAmount(double amount) { this.amount = amount; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public String getStatusBadgeClass() {
        return active ? "badge-green" : "badge-red";
    }

    public String getStatusLabel() {
        return active ? "Đang dùng" : "Vô hiệu hóa";
    }
}
