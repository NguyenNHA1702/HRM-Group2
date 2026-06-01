package com.hrm.project.model;

import java.sql.Time;

public class WorkShift {
    private int id;
    private String name;
    private Time startTime;
    private Time endTime;
    private String description;

    public WorkShift() {}

    public WorkShift(int id, String name, Time startTime, Time endTime, String description) {
        this.id = id;
        this.name = name;
        this.startTime = startTime;
        this.endTime = endTime;
        this.description = description;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public Time getStartTime() { return startTime; }
    public void setStartTime(Time startTime) { this.startTime = startTime; }

    public Time getEndTime() { return endTime; }
    public void setEndTime(Time endTime) { this.endTime = endTime; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    // Helper to get formatted start and end time (HH:mm)
    public String getFormattedStartTime() {
        if (startTime == null) return "";
        String s = startTime.toString();
        return s.substring(0, 5); // hh:mm
    }
    
    public String getFormattedEndTime() {
        if (endTime == null) return "";
        String s = endTime.toString();
        return s.substring(0, 5); // hh:mm
    }
}
