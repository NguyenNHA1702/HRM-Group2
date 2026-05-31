package com.hrm.project.dao;

import com.hrm.project.model.WorkShift;
import java.util.List;

public interface WorkShiftDAO {
    List<WorkShift> getAllWorkShifts();
    WorkShift getWorkShiftById(int id);
    boolean addWorkShift(WorkShift shift);
    boolean updateWorkShift(WorkShift shift);
    List<WorkShift> getWorkShifts(String keyword, String sortBy, String sortOrder, int page, int pageSize);
    int getWorkShiftsCount(String keyword);
}
