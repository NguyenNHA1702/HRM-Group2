package com.hrm.project.model;

public class SalaryScale {
    private int id;
    private String grade;
    private double basicSalary;
    private String description;
    private boolean active;

    public SalaryScale() {}

    public SalaryScale(int id, String grade, double basicSalary, String description, boolean active) {
        this.id = id;
        this.grade = grade;
        this.basicSalary = basicSalary;
        this.description = description;
        this.active = active;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getGrade() { return grade; }
    public void setGrade(String grade) { this.grade = grade; }

    public double getBasicSalary() { return basicSalary; }
    public void setBasicSalary(double basicSalary) { this.basicSalary = basicSalary; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    // Trả về CSS class badge dựa theo trạng thái active/inactive
    public String getStatusBadgeClass() {
        return active ? "badge-green" : "badge-red";
    }

    public String getStatusLabel() {
        return active ? "Đang dùng" : "Vô hiệu hóa";
    }
}
