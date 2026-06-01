package com.hrm.project.dao;

import com.hrm.project.model.InsuranceConfig;
import com.hrm.project.model.InsuranceConfigDTO;

import java.sql.SQLException;
import java.util.List;

/**
 * InsuranceDAO Interface
 * Định nghĩa các phương thức CRUD cho Bảo hiểm (Bảo hiểm xã hội, y tế, thất nghiệp)
 */
public interface InsuranceDAO {

    /**
     * Lấy tất cả cấu hình bảo hiểm
     */
    List<InsuranceConfigDTO> getAll() throws SQLException;

    /**
     * Lấy cấu hình bảo hiểm theo ID
     */
    InsuranceConfig getById(int id) throws SQLException;

    /**
     * Lấy cấu hình bảo hiểm của một nhân viên cụ thể
     */
    InsuranceConfig getByEmployeeId(int employeeId) throws SQLException;

    /**
     * Tìm kiếm cấu hình bảo hiểm theo keyword (mã nhân viên, tên, số bảo hiểm)
     * và lọc theo trạng thái
     */
    List<InsuranceConfigDTO> search(String keyword, String status) throws SQLException;

    /**
     * Thêm mới cấu hình bảo hiểm
     */
    boolean create(InsuranceConfig insurance) throws SQLException;

    /**
     * Cập nhật cấu hình bảo hiểm
     */
    boolean update(InsuranceConfig insurance) throws SQLException;

    /**
     * Xóa cấu hình bảo hiểm
     */
    boolean delete(int id) throws SQLException;

    /**
     * Thay đổi trạng thái hoạt động của bảo hiểm
     */
    boolean toggleActive(int id, boolean isActive) throws SQLException;

    /**
     * Lấy thống kê bảo hiểm (tổng cộng, đang áp dụng, đã dừng)
     */
    InsuranceStatDTO getStats() throws SQLException;

    /**
     * Kiểm tra xem số bảo hiểm đã tồn tại chưa
     */
    boolean isInsuranceNumberExists(String insuranceNumber, int excludeId) throws SQLException;

    // ───────────────────────────────────────────────────────────────
    // Insurance Rate Config (insurance_rate table)
    // ───────────────────────────────────────────────────────────────

    /** Lấy tất cả loại bảo hiểm + tỷ lệ */
    List<InsuranceRateDTO> getAllRates() throws SQLException;

    /** Thêm mới loại bảo hiểm */
    boolean createRate(InsuranceRateDTO rate) throws SQLException;

    /** Cập nhật tỷ lệ % người lao động / doanh nghiệp */
    boolean updateRate(int id, double employeeRate, double employerRate) throws SQLException;

    /** Xóa loại bảo hiểm */
    boolean deleteRate(int id) throws SQLException;

    /** Thay đổi trạng thái hoạt động của loại bảo hiểm */
    boolean toggleRateActive(int id, boolean isActive) throws SQLException;

    /**
     * DTO cho một loại bảo hiểm (BHXH, BHYT, BHTN …)
     */
    class InsuranceRateDTO {
        public int id;
        public String name;           // Bảo hiểm xã hội
        public String code;           // BHXH
        public double employeeRate;   // NLĐ đóng (%)
        public double employerRate;   // DN đóng (%)
        public String note;
        public boolean active;

        public InsuranceRateDTO() {}

        public InsuranceRateDTO(int id, String name, String code,
                                double employeeRate, double employerRate,
                                String note, boolean active) {
            this.id = id;
            this.name = name;
            this.code = code;
            this.employeeRate = employeeRate;
            this.employerRate = employerRate;
            this.note = note;
            this.active = active;
        }

        public int getId()              { return id; }
        public String getName()         { return name; }
        public String getCode()         { return code; }
        public double getEmployeeRate() { return employeeRate; }
        public double getEmployerRate() { return employerRate; }
        public String getNote()         { return note; }
        public boolean isActive()       { return active; }
    }

    /**
     * DTO thống kê bảo hiểm
     */
    class InsuranceStatDTO {
        public int totalInsurances;
        public int activeInsurances;
        public int inactiveInsurances;

        public InsuranceStatDTO(int total, int active, int inactive) {
            this.totalInsurances = total;
            this.activeInsurances = active;
            this.inactiveInsurances = inactive;
        }

        public int getTotalInsurances() {
            return totalInsurances;
        }

        public int getActiveInsurances() {
            return activeInsurances;
        }

        public int getInactiveInsurances() {
            return inactiveInsurances;
        }
    }
}