package com.hrm.project.dao;

import com.hrm.project.model.AllowanceType;
import com.hrm.project.model.Position;

import java.util.List;
import java.util.Map;

/**
 * DAO cho quản lý phụ cấp theo chức vụ (position_allowances).
 */
public interface PositionAllowanceDAO {

    /**
     * Lấy danh sách AllowanceType đang gán cho một position.
     */
    List<AllowanceType> getAllowancesByPositionId(int positionId);

    /**
     * Tính tổng tiền phụ cấp cho một position.
     */
    double getTotalAllowanceByPositionId(int positionId);

    /**
     * Lưu mapping position ↔ allowance types (xóa cũ, insert mới).
     */
    boolean save(int positionId, List<Integer> allowanceTypeIds);

    /**
     * Lấy tất cả positions kèm danh sách phụ cấp.
     * Key = Position, Value = List<AllowanceType>
     */
    Map<Position, List<AllowanceType>> getAllPositionsWithAllowances();

    /**
     * Lấy danh sách tất cả positions.
     */
    List<Position> getAllPositions();
}
