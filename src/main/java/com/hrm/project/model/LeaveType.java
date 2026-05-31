package com.hrm.project.model;

public class LeaveType {

    private int id;
    private String code;
    private String name;
    private double daysPerYear;   // decimal(5,1) trong DB
    private boolean paid;         // is_paid trong DB
    private String description;
    private boolean active;       // is_active trong DB

    public LeaveType() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public double getDaysPerYear() { return daysPerYear; }
    public void setDaysPerYear(double daysPerYear) { this.daysPerYear = daysPerYear; }

    public boolean isPaid() { return paid; }
    public void setPaid(boolean paid) { this.paid = paid; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
}