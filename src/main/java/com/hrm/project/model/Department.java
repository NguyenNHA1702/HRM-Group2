package com.hrm.project.model;

import java.sql.Timestamp;

public class Department {
    private int id;
    private String code;
    private String name;
    private Integer managerId; // Dùng Integer (Object) để chấp nhận giá trị NULL dưới DB
    private Integer parentId;   // Dùng Integer (Object) để chấp nhận giá trị NULL dưới DB
    private String description;
    private int isActive;      // Khớp với TINYINT(1) dưới DB
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Trường bổ trợ để hiển thị tên phòng ban cha ra Table cho đẹp
    private String parentName;
    private String managerName;
    private String managerCode;

    // Constructor không tham số (Bắt buộc phải có trong kiến trúc web)
    public Department() {}

    private int totalEmployees;

    public Department(int id, String code, String name, Integer managerId, Integer parentId, String description, int isActive) {
        this.id = id;
        this.code = code;
        this.name = name;
        this.managerId = managerId;
        this.parentId = parentId;
        this.description = description;
        this.isActive = isActive;
    }

    // --- BỘ GETTER VÀ SETTER TOÀN BỘ CÁC TRƯỜNG ---

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public Integer getManagerId() { return managerId; }
    public void setManagerId(Integer managerId) { this.managerId = managerId; }

    public Integer getParentId() { return parentId; }
    public void setParentId(Integer parentId) { this.parentId = parentId; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public int getIsActive() { return isActive; }
    public void setIsActive(int isActive) { this.isActive = isActive; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getParentName() { return parentName; }
    public void setParentName(String parentName) { this.parentName = parentName; }

    public int getTotalEmployees() { return totalEmployees; }
    public void setTotalEmployees(int totalEmployees) { this.totalEmployees = totalEmployees; }

    public String getManagerName() { return managerName; }
    public void setManagerName(String managerName) { this.managerName = managerName; }

    public String getManagerCode() { return managerCode; }
    public void setManagerCode(String managerCode) { this.managerCode = managerCode; }
}