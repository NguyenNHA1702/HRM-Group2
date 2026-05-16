package com.hrm.project.model;

import java.sql.Timestamp;

public class Module {
    private int id;
    private String code;
    private String name;
    private boolean isAdminOnly;
    private String description;
    private Timestamp createdAt;

    // Default Constructor
    public Module() {
    }

    // Full Constructor
    public Module(int id, String code, String name, boolean isAdminOnly, String description, Timestamp createdAt) {
        this.id = id;
        this.code = code;
        this.name = name;
        this.isAdminOnly = isAdminOnly;
        this.description = description;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public boolean isAdminOnly() {
        return isAdminOnly;
    }

    public void setAdminOnly(boolean isAdminOnly) {
        this.isAdminOnly = isAdminOnly;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}