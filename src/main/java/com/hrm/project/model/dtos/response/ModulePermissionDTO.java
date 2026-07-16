package com.hrm.project.model.dtos.response;

public class ModulePermissionDTO {
    private int moduleId;
    private String moduleCode; // Mã định danh ngắn: DASHBOARD, EMPLOYEE_MGMT, PAYROLL...
    private String moduleName;
    private boolean view;
    private boolean create;
    private boolean edit;
    private boolean delete;

    // Default Constructor
    public ModulePermissionDTO() {
    }

    // Full Constructor
    public ModulePermissionDTO(int moduleId, String moduleCode, String moduleName, boolean view, boolean create, boolean edit, boolean delete) {
        this.moduleId = moduleId;
        this.moduleCode = moduleCode;
        this.moduleName = moduleName;
        this.view = view;
        this.create = create;
        this.edit = edit;
        this.delete = delete;
    }

    // Getters and Setters
    public int getModuleId() {
        return moduleId;
    }

    public void setModuleId(int moduleId) {
        this.moduleId = moduleId;
    }

    public String getModuleCode() {
        return moduleCode;
    }

    public void setModuleCode(String moduleCode) {
        this.moduleCode = moduleCode;
    }

    public String getModuleName() {
        return moduleName;
    }

    public void setModuleName(String moduleName) {
        this.moduleName = moduleName;
    }

    public boolean isView() {
        return view;
    }

    public void setView(boolean view) {
        this.view = view;
    }

    public boolean isCreate() {
        return create;
    }

    public void setCreate(boolean create) {
        this.create = create;
    }

    public boolean isEdit() {
        return edit;
    }

    public void setEdit(boolean edit) {
        this.edit = edit;
    }

    public boolean isDelete() {
        return delete;
    }

    public void setDelete(boolean delete) {
        this.delete = delete;
    }
}