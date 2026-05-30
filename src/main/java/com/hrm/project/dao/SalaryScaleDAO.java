package com.hrm.project.dao;

import com.hrm.project.model.SalaryScale;
import java.util.List;

public interface SalaryScaleDAO {
    /** Lấy toàn bộ danh sách (kể cả đã vô hiệu hóa) */
    List<SalaryScale> getAllSalaryScales();

    /** Thêm mới một bậc lương */
    boolean addSalaryScale(SalaryScale scale);

    /** Cập nhật thông tin bậc lương */
    boolean updateSalaryScale(SalaryScale scale);

    /** Vô hiệu hóa / kích hoạt lại bậc lương */
    boolean toggleActive(int id, boolean isActive);

    /** Kiểm tra grade đã tồn tại chưa (trừ bản ghi hiện tại khi update) */
    boolean isGradeExists(String grade, int excludeId);
}
