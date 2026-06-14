package com.hrm.project.model;

public class LeaveType {

    private int id;
    private String code;
    private String name;
    private Double daysPerYear;   // Changed from double to Double to support NULL safely
    private boolean paid;
    private String description;   // Ensure your DAO does NOT try to map rs.getString("description")
    private boolean active;

    public LeaveType() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public Double getDaysPerYear() { return daysPerYear; }
    public void setDaysPerYear(Double daysPerYear) { this.daysPerYear = daysPerYear; }

    public boolean isPaid() { return paid; }
    public void setPaid(boolean paid) { this.paid = paid; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
}