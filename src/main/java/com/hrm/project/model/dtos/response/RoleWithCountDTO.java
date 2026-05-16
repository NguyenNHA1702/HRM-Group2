package com.hrm.project.model.dtos.response;

public class RoleWithCountDTO {
    private int id;
    private String name;
    private String description;
    private int userCount;

    // Default Constructor
    public RoleWithCountDTO() {
    }

    // Full Constructor
    public RoleWithCountDTO(int id, String name, String description, int userCount) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.userCount = userCount;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public int getUserCount() {
        return userCount;
    }

    public void setUserCount(int userCount) {
        this.userCount = userCount;
    }
}