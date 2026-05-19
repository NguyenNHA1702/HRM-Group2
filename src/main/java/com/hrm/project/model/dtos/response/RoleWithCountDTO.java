package com.hrm.project.model.dtos.response;

public class RoleWithCountDTO {
    private int id;
    private String name;
    private String description;
    private int userCount;
    private boolean isActive;

    // Default Constructor
    public RoleWithCountDTO() {
    }

    // Full Constructor
    public RoleWithCountDTO(int id, String name, String description, int userCount, boolean isActive) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.userCount = userCount;
        this.isActive = isActive;
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

    public boolean isActive() {
        return isActive;
    }

    /**
     * Alias getter cho JSP EL: ${role.isActive} tìm getIsActive() trước khi tìm isActive()
     * Không có getter này, tất cả role đều hiển thị sai thành false trong JavaScript.
     */
    public boolean getIsActive() {
        return isActive;
    }

    public void setActive(boolean isActive) {
        this.isActive = isActive;
    }
}