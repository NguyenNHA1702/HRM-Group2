package com.hrm.project.model;

import java.sql.Date;
import java.sql.Timestamp;

public class ScheduleHistory {
    private int id;
    private int employeeId;
    private Date scheduleDate;
    private String oldShiftName;
    private String newShiftName;
    private String changedBy;
    private String changeReason;
    private Timestamp changedAt;

    public ScheduleHistory() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getEmployeeId() { return employeeId; }
    public void setEmployeeId(int employeeId) { this.employeeId = employeeId; }

    public Date getScheduleDate() { return scheduleDate; }
    public void setScheduleDate(Date scheduleDate) { this.scheduleDate = scheduleDate; }

    public String getOldShiftName() { return oldShiftName; }
    public void setOldShiftName(String oldShiftName) { this.oldShiftName = oldShiftName; }

    public String getNewShiftName() { return newShiftName; }
    public void setNewShiftName(String newShiftName) { this.newShiftName = newShiftName; }

    public String getChangedBy() { return changedBy; }
    public void setChangedBy(String changedBy) { this.changedBy = changedBy; }

    public String getChangeReason() { return changeReason; }
    public void setChangeReason(String changeReason) { this.changeReason = changeReason; }

    public Timestamp getChangedAt() { return changedAt; }
    public void setChangedAt(Timestamp changedAt) { this.changedAt = changedAt; }
}
