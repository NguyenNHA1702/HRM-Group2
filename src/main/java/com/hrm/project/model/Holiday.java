package com.hrm.project.model;

import java.sql.Date;

public class Holiday {
    private int id;
    private String name;
    private Date startDate;
    private Date endDate;
    private double salaryCoefficient;
    private String description;

    public Holiday() {}

    public Holiday(int id, String name, Date startDate, Date endDate, double salaryCoefficient, String description) {
        this.id = id;
        this.name = name;
        this.startDate = startDate;
        this.endDate = endDate;
        this.salaryCoefficient = salaryCoefficient;
        this.description = description;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public Date getStartDate() { return startDate; }
    public void setStartDate(Date startDate) { this.startDate = startDate; }

    public Date getEndDate() { return endDate; }
    public void setEndDate(Date endDate) { this.endDate = endDate; }

    public double getSalaryCoefficient() { return salaryCoefficient; }
    public void setSalaryCoefficient(double salaryCoefficient) { this.salaryCoefficient = salaryCoefficient; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}
