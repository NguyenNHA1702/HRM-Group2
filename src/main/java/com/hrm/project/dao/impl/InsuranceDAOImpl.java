package com.hrm.project.dao.impl;

import com.hrm.project.dao.InsuranceDAO;
import com.hrm.project.model.InsuranceConfig;
import com.hrm.project.model.InsuranceConfigDTO;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

/**
 * InsuranceDAOImpl - Implementation của InsuranceDAO
 * Xử lý tất cả các thao tác database liên quan đến bảo hiểm
 */
public class InsuranceDAOImpl implements InsuranceDAO {

    private static final Logger logger = Logger.getLogger(InsuranceDAOImpl.class.getName());

    /**
     * Lấy tất cả cấu hình bảo hiểm (JOIN với employees, departments, positions)
     */
    @Override
    public List<InsuranceConfigDTO> getAll() throws SQLException {
        String sql = "SELECT " +
                "    ic.id, ic.employee_id, e.employee_code, e.full_name, " +
                "    d.name as department_name, p.name as position_name, " +
                "    ic.insurance_number, ic.bhxh_rate, ic.bhyt_rate, ic.bhtn_rate, " +
                "    ic.base_salary, ic.total_amount, ic.is_active " +
                "FROM insurance_config ic " +
                "LEFT JOIN employees e ON ic.employee_id = e.id " +
                "LEFT JOIN departments d ON e.department_id = d.id " +
                "LEFT JOIN positions p ON e.position_id = p.id " +
                "ORDER BY e.full_name ASC";

        List<InsuranceConfigDTO> list = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                InsuranceConfigDTO dto = new InsuranceConfigDTO(
                        rs.getInt("id"),
                        rs.getInt("employee_id"),
                        rs.getString("employee_code"),
                        rs.getString("full_name"),
                        rs.getString("department_name"),
                        rs.getString("position_name"),
                        rs.getString("insurance_number"),
                        rs.getDouble("bhxh_rate"),
                        rs.getDouble("bhyt_rate"),
                        rs.getDouble("bhtn_rate"),
                        rs.getDouble("base_salary"),
                        rs.getDouble("total_amount"),
                        rs.getBoolean("is_active")
                );
                list.add(dto);
            }
        } catch (SQLException e) {
            logger.severe("Error fetching all insurance configs: " + e.getMessage());
            throw e;
        }

        return list;
    }

    /**
     * Lấy cấu hình bảo hiểm theo ID
     */
    @Override
    public InsuranceConfig getById(int id) throws SQLException {
        String sql = "SELECT * FROM insurance_config WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToInsuranceConfig(rs);
                }
            }
        } catch (SQLException e) {
            logger.severe("Error fetching insurance config by id: " + e.getMessage());
            throw e;
        }

        return null;
    }

    /**
     * Lấy cấu hình bảo hiểm theo Employee ID
     */
    @Override
    public InsuranceConfig getByEmployeeId(int employeeId) throws SQLException {
        String sql = "SELECT * FROM insurance_config WHERE employee_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, employeeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToInsuranceConfig(rs);
                }
            }
        } catch (SQLException e) {
            logger.severe("Error fetching insurance config by employee_id: " + e.getMessage());
            throw e;
        }

        return null;
    }

    /**
     * Tìm kiếm cấu hình bảo hiểm
     */
    @Override
    public List<InsuranceConfigDTO> search(String keyword, String status) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT " +
                        "    ic.id, ic.employee_id, e.employee_code, e.full_name, " +
                        "    d.name as department_name, p.name as position_name, " +
                        "    ic.insurance_number, ic.bhxh_rate, ic.bhyt_rate, ic.bhtn_rate, " +
                        "    ic.base_salary, ic.total_amount, ic.is_active " +
                        "FROM insurance_config ic " +
                        "LEFT JOIN employees e ON ic.employee_id = e.id " +
                        "LEFT JOIN departments d ON e.department_id = d.id " +
                        "LEFT JOIN positions p ON e.position_id = p.id " +
                        "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (e.employee_code LIKE ? OR e.full_name LIKE ? OR ic.insurance_number LIKE ?) ");
            String searchPattern = "%" + keyword.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }

        if (status != null && !status.isEmpty()) {
            if ("active".equalsIgnoreCase(status)) {
                sql.append("AND ic.is_active = true ");
            } else if ("inactive".equalsIgnoreCase(status)) {
                sql.append("AND ic.is_active = false ");
            }
        }

        sql.append("ORDER BY e.full_name ASC");

        List<InsuranceConfigDTO> list = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    InsuranceConfigDTO dto = new InsuranceConfigDTO(
                            rs.getInt("id"),
                            rs.getInt("employee_id"),
                            rs.getString("employee_code"),
                            rs.getString("full_name"),
                            rs.getString("department_name"),
                            rs.getString("position_name"),
                            rs.getString("insurance_number"),
                            rs.getDouble("bhxh_rate"),
                            rs.getDouble("bhyt_rate"),
                            rs.getDouble("bhtn_rate"),
                            rs.getDouble("base_salary"),
                            rs.getDouble("total_amount"),
                            rs.getBoolean("is_active")
                    );
                    list.add(dto);
                }
            }
        } catch (SQLException e) {
            logger.severe("Error searching insurance configs: " + e.getMessage());
            throw e;
        }

        return list;
    }

    /**
     * Thêm mới cấu hình bảo hiểm
     */
    @Override
    public boolean create(InsuranceConfig insurance) throws SQLException {
        String sql = "INSERT INTO insurance_config " +
                "(employee_id, insurance_number, bhxh_rate, bhyt_rate, bhtn_rate, " +
                "base_salary, bhxh_amount, bhyt_amount, bhtn_amount, total_amount, is_active) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, insurance.getEmployeeId());
            ps.setString(2, insurance.getInsuranceNumber());
            ps.setDouble(3, insurance.getBhxhRate());
            ps.setDouble(4, insurance.getBhytRate());
            ps.setDouble(5, insurance.getBhtnRate());
            ps.setDouble(6, insurance.getBaseSalary());
            ps.setDouble(7, insurance.getBhxhAmount());
            ps.setDouble(8, insurance.getBhytAmount());
            ps.setDouble(9, insurance.getBhtnAmount());
            ps.setDouble(10, insurance.getTotalAmount());
            ps.setBoolean(11, insurance.isActive());

            int result = ps.executeUpdate();
            logger.info("Created insurance config for employee: " + insurance.getEmployeeId());
            return result > 0;

        } catch (SQLException e) {
            logger.severe("Error creating insurance config: " + e.getMessage());
            throw e;
        }
    }

    /**
     * Cập nhật cấu hình bảo hiểm
     */
    @Override
    public boolean update(InsuranceConfig insurance) throws SQLException {
        String sql = "UPDATE insurance_config SET " +
                "insurance_number = ?, bhxh_rate = ?, bhyt_rate = ?, bhtn_rate = ?, " +
                "base_salary = ?, bhxh_amount = ?, bhyt_amount = ?, bhtn_amount = ?, " +
                "total_amount = ?, is_active = ? " +
                "WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, insurance.getInsuranceNumber());
            ps.setDouble(2, insurance.getBhxhRate());
            ps.setDouble(3, insurance.getBhytRate());
            ps.setDouble(4, insurance.getBhtnRate());
            ps.setDouble(5, insurance.getBaseSalary());
            ps.setDouble(6, insurance.getBhxhAmount());
            ps.setDouble(7, insurance.getBhytAmount());
            ps.setDouble(8, insurance.getBhtnAmount());
            ps.setDouble(9, insurance.getTotalAmount());
            ps.setBoolean(10, insurance.isActive());
            ps.setInt(11, insurance.getId());

            int result = ps.executeUpdate();
            logger.info("Updated insurance config: " + insurance.getId());
            return result > 0;

        } catch (SQLException e) {
            logger.severe("Error updating insurance config: " + e.getMessage());
            throw e;
        }
    }

    /**
     * Xóa cấu hình bảo hiểm
     */
    @Override
    public boolean delete(int id) throws SQLException {
        String sql = "DELETE FROM insurance_config WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            int result = ps.executeUpdate();
            logger.info("Deleted insurance config: " + id);
            return result > 0;

        } catch (SQLException e) {
            logger.severe("Error deleting insurance config: " + e.getMessage());
            throw e;
        }
    }

    /**
     * Thay đổi trạng thái hoạt động của bảo hiểm
     */
    @Override
    public boolean toggleActive(int id, boolean isActive) throws SQLException {
        String sql = "UPDATE insurance_config SET is_active = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setBoolean(1, isActive);
            ps.setInt(2, id);
            int result = ps.executeUpdate();
            logger.info("Toggled insurance config status: " + id + " to " + isActive);
            return result > 0;

        } catch (SQLException e) {
            logger.severe("Error toggling insurance config status: " + e.getMessage());
            throw e;
        }
    }

    /**
     * Lấy thống kê loại bảo hiểm (từ bảng insurance_rate)
     */
    @Override
    public InsuranceStatDTO getStats() throws SQLException {
        String sql = "SELECT " +
                "COUNT(*) as total, " +
                "SUM(CASE WHEN is_active = true THEN 1 ELSE 0 END) as active, " +
                "SUM(CASE WHEN is_active = false THEN 1 ELSE 0 END) as inactive " +
                "FROM insurance_rate";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            if (rs.next()) {
                return new InsuranceStatDTO(
                        rs.getInt("total"),
                        rs.getInt("active"),
                        rs.getInt("inactive")
                );
            }
        } catch (SQLException e) {
            logger.warning("Error fetching insurance stats: " + e.getMessage());
        }

        return new InsuranceStatDTO(0, 0, 0);
    }

    /**
     * Kiểm tra xem số bảo hiểm đã tồn tại chưa
     */
    @Override
    public boolean isInsuranceNumberExists(String insuranceNumber, int excludeId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM insurance_config WHERE insurance_number = ? AND id != ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, insuranceNumber);
            ps.setInt(2, excludeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            logger.severe("Error checking insurance number existence: " + e.getMessage());
            throw e;
        }

        return false;
    }

    // ═══════════════════════════════════════════════════════════════
    // Insurance Rate Config implementations
    // ═══════════════════════════════════════════════════════════════

    @Override
    public List<InsuranceRateDTO> getAllRates() throws SQLException {
        String sql = "SELECT id, name, code, employee_rate, employer_rate, note, is_active " +
                "FROM insurance_rate ORDER BY id ASC";
        List<InsuranceRateDTO> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                list.add(new InsuranceRateDTO(
                        rs.getInt("id"),
                        rs.getString("name"),
                        rs.getString("code"),
                        rs.getDouble("employee_rate"),
                        rs.getDouble("employer_rate"),
                        rs.getString("note"),
                        rs.getBoolean("is_active")
                ));
            }
        }
        return list;
    }

    @Override
    public List<InsuranceRateDTO> getRates(int page, int pageSize) throws SQLException {
        String sql = "SELECT id, name, code, employee_rate, employer_rate, note, is_active " +
                "FROM insurance_rate ORDER BY id ASC LIMIT ? OFFSET ?";
        List<InsuranceRateDTO> list = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, pageSize);
            ps.setInt(2, (page - 1) * pageSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new InsuranceRateDTO(
                            rs.getInt("id"),
                            rs.getString("name"),
                            rs.getString("code"),
                            rs.getDouble("employee_rate"),
                            rs.getDouble("employer_rate"),
                            rs.getString("note"),
                            rs.getBoolean("is_active")
                    ));
                }
            }
        }
        return list;
    }

    @Override
    public int getRatesCount() throws SQLException {
        String sql = "SELECT COUNT(*) FROM insurance_rate";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    @Override
    public boolean createRate(InsuranceRateDTO rate) throws SQLException {
        String sql = "INSERT INTO insurance_rate (name, code, employee_rate, employer_rate, note, is_active) " +
                "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, rate.name);
            ps.setString(2, rate.code);
            ps.setDouble(3, rate.employeeRate);
            ps.setDouble(4, rate.employerRate);
            ps.setString(5, rate.note);
            ps.setBoolean(6, rate.active);
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public boolean updateRate(int id, double employeeRate, double employerRate) throws SQLException {
        String sql = "UPDATE insurance_rate SET employee_rate = ?, employer_rate = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDouble(1, employeeRate);
            ps.setDouble(2, employerRate);
            ps.setInt(3, id);
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public boolean deleteRate(int id) throws SQLException {
        String sql = "DELETE FROM insurance_rate WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        }
    }

    @Override
    public boolean toggleRateActive(int id, boolean isActive) throws SQLException {
        String sql = "UPDATE insurance_rate SET is_active = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, isActive);
            ps.setInt(2, id);
            int result = ps.executeUpdate();
            logger.info("Toggled insurance rate status: id=" + id + " -> " + isActive);
            return result > 0;
        } catch (SQLException e) {
            logger.severe("Error toggling insurance rate status: " + e.getMessage());
            throw e;
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // Insurance Applicable Group implementations
    // ═══════════════════════════════════════════════════════════════

    @Override
    public List<InsuranceApplicableGroupDTO> getAllApplicableGroups() throws SQLException {
        String sql = "SELECT id, name, description, condition_detail, sort_order, is_active " +
                "FROM insurance_applicable_group ORDER BY sort_order ASC, id ASC";
        List<InsuranceApplicableGroupDTO> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                list.add(new InsuranceApplicableGroupDTO(
                        rs.getInt("id"),
                        rs.getString("name"),
                        rs.getString("description"),
                        rs.getString("condition_detail"),
                        rs.getInt("sort_order"),
                        rs.getBoolean("is_active")
                ));
            }
        } catch (SQLException e) {
            logger.severe("Error fetching applicable groups: " + e.getMessage());
            throw e;
        }
        return list;
    }

    @Override
    public List<InsuranceApplicableGroupDTO> getApplicableGroups(int page, int pageSize)
            throws SQLException {
        String sql = "SELECT id, name, description, condition_detail, sort_order, is_active " +
                "FROM insurance_applicable_group ORDER BY sort_order ASC, id ASC LIMIT ? OFFSET ?";
        List<InsuranceApplicableGroupDTO> list = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, pageSize);
            ps.setInt(2, (page - 1) * pageSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new InsuranceApplicableGroupDTO(
                            rs.getInt("id"),
                            rs.getString("name"),
                            rs.getString("description"),
                            rs.getString("condition_detail"),
                            rs.getInt("sort_order"),
                            rs.getBoolean("is_active")
                    ));
                }
            }
        } catch (SQLException e) {
            logger.severe("Error fetching applicable groups by page: " + e.getMessage());
            throw e;
        }
        return list;
    }

    @Override
    public int getApplicableGroupsCount() throws SQLException {
        String sql = "SELECT COUNT(*) FROM insurance_applicable_group";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    @Override
    public boolean createApplicableGroup(InsuranceApplicableGroupDTO group) throws SQLException {
        String sql = "INSERT INTO insurance_applicable_group " +
                "(name, description, condition_detail, sort_order, is_active) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, group.name);
            ps.setString(2, group.description);
            ps.setString(3, group.conditionDetail);
            ps.setInt(4, group.sortOrder);
            ps.setBoolean(5, group.active);
            int result = ps.executeUpdate();
            logger.info("Created applicable group: " + group.name);
            return result > 0;
        } catch (SQLException e) {
            logger.severe("Error creating applicable group: " + e.getMessage());
            throw e;
        }
    }

    @Override
    public boolean updateApplicableGroup(InsuranceApplicableGroupDTO group) throws SQLException {
        String sql = "UPDATE insurance_applicable_group SET " +
                "name = ?, description = ?, condition_detail = ?, sort_order = ?, is_active = ? " +
                "WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, group.name);
            ps.setString(2, group.description);
            ps.setString(3, group.conditionDetail);
            ps.setInt(4, group.sortOrder);
            ps.setBoolean(5, group.active);
            ps.setInt(6, group.id);
            int result = ps.executeUpdate();
            logger.info("Updated applicable group: id=" + group.id);
            return result > 0;
        } catch (SQLException e) {
            logger.severe("Error updating applicable group: " + e.getMessage());
            throw e;
        }
    }

    @Override
    public boolean deleteApplicableGroup(int id) throws SQLException {
        String sql = "DELETE FROM insurance_applicable_group WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            int result = ps.executeUpdate();
            logger.info("Deleted applicable group: id=" + id);
            return result > 0;
        } catch (SQLException e) {
            logger.severe("Error deleting applicable group: " + e.getMessage());
            throw e;
        }
    }

    @Override
    public boolean toggleApplicableGroupActive(int id, boolean isActive) throws SQLException {
        String sql = "UPDATE insurance_applicable_group SET is_active = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, isActive);
            ps.setInt(2, id);
            int result = ps.executeUpdate();
            logger.info("Toggled applicable group status: id=" + id + " -> " + isActive);
            return result > 0;
        } catch (SQLException e) {
            logger.severe("Error toggling applicable group status: " + e.getMessage());
            throw e;
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // Helper Methods
    // ═══════════════════════════════════════════════════════════════

    /**
     * Map ResultSet sang InsuranceConfig object
     */
    private InsuranceConfig mapResultSetToInsuranceConfig(ResultSet rs) throws SQLException {
        InsuranceConfig config = new InsuranceConfig();
        config.setId(rs.getInt("id"));
        config.setEmployeeId(rs.getInt("employee_id"));
        config.setInsuranceNumber(rs.getString("insurance_number"));
        config.setBhxhRate(rs.getDouble("bhxh_rate"));
        config.setBhytRate(rs.getDouble("bhyt_rate"));
        config.setBhtnRate(rs.getDouble("bhtn_rate"));
        config.setBaseSalary(rs.getDouble("base_salary"));
        config.setBhxhAmount(rs.getDouble("bhxh_amount"));
        config.setBhytAmount(rs.getDouble("bhyt_amount"));
        config.setBhtnAmount(rs.getDouble("bhtn_amount"));
        config.setTotalAmount(rs.getDouble("total_amount"));
        config.setActive(rs.getBoolean("is_active"));
        return config;
    }
}
