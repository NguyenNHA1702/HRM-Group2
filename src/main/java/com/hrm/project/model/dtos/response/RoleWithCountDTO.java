package com.hrm.project.model.dtos.response;

public class RoleWithCountDTO {
    private int id;
    private String name;
    private String description;
    private int userCount;
    private boolean isActive;
    private int groupId;
    private String groupName;

    // Default Constructor
    public RoleWithCountDTO() {
    }

    // Full Constructor
    public RoleWithCountDTO(int id, String name, String description, int userCount, boolean isActive, int groupId, String groupName) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.userCount = userCount;
        this.isActive = isActive;
        this.groupId = groupId;
        this.groupName = groupName;
    }

    // Getters and Setters
    public boolean isActive() {
        return isActive;
    }

    public boolean getIsActive() {
        return isActive;
    }

    public void setActive(boolean active) {
        isActive = active;
    }

    public int getGroupId() {
        return groupId;
    }

    public void setGroupId(int groupId) {
        this.groupId = groupId;
    }

    public String getGroupName() {
        return groupName;
    }

    public void setGroupName(String groupName) {
        this.groupName = groupName;
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