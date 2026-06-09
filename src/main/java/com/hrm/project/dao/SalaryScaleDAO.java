package com.hrm.project.dao;

import com.hrm.project.model.SalaryScale;
import java.util.List;

public interface SalaryScaleDAO {
    List<SalaryScale> getAllSalaryScales();

    boolean addSalaryScale(SalaryScale scale);

    boolean updateSalaryScale(SalaryScale scale);

    boolean toggleActive(int id, boolean isActive);

    boolean isGradeExists(String grade, int excludeId);
}
