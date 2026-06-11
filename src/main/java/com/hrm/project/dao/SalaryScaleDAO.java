package com.hrm.project.dao;

import com.hrm.project.model.SalaryScale;
import java.util.List;

public interface SalaryScaleDAO {
    List<SalaryScale> getAllSalaryScales();

    /**
     * Returns only active salary scales (for contract creation dropdown).
     */
    List<SalaryScale> getActiveSalaryScales();

    /**
     * Returns the basic_salary for a given salary scale ID, or -1 if not found/inactive.
     */
    double getBasicSalaryById(int salaryScaleId);

    boolean addSalaryScale(SalaryScale scale);

    boolean updateSalaryScale(SalaryScale scale);

    boolean toggleActive(int id, boolean isActive);

    boolean isGradeExists(String grade, int excludeId);
}
