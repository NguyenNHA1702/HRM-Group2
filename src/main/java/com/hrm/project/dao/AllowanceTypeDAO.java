package com.hrm.project.dao;

import com.hrm.project.model.AllowanceType;
import java.util.List;

public interface AllowanceTypeDAO {
    /** Lấy toàn bộ danh sách phụ cấp (kể cả đã vô hiệu hóa) */
    List<AllowanceType> getAllAllowanceTypes();

    /** Thêm mới loại phụ cấp */
    boolean addAllowanceType(AllowanceType type);

    /** Cập nhật loại phụ cấp */
    boolean updateAllowanceType(AllowanceType type);

    /** Vô hiệu hóa / kích hoạt lại loại phụ cấp */
    boolean toggleActive(int id, boolean isActive);

    /** Kiểm tra code đã tồn tại chưa (trừ bản ghi hiện tại khi update) */
    boolean isCodeExists(String code, int excludeId);
}
