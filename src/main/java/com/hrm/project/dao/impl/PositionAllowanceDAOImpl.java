package com.hrm.project.dao.impl;

import com.hrm.project.dao.PositionAllowanceDAO;
import com.hrm.project.model.AllowanceType;
import com.hrm.project.model.Position;

import java.sql.*;
import java.util.*;

public class PositionAllowanceDAOImpl implements PositionAllowanceDAO {

    @Override
    public List<AllowanceType> getAllowancesByPositionId(int positionId) {
        List<AllowanceType> list = new ArrayList<>();
        String sql = "SELECT t.id, t.code, t.name, t.amount, t.description, t.is_active " +
                     "FROM position_allowances pa " +
                     "JOIN allowance_types t ON pa.allowance_type_id = t.id " +
                     "WHERE pa.position_id = ? AND t.is_active = 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, positionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AllowanceType at = new AllowanceType();
                    at.setId(rs.getInt("id"));
                    at.setCode(rs.getString("code"));
                    at.setName(rs.getString("name"));
                    at.setAmount(rs.getDouble("amount"));
                    at.setDescription(rs.getString("description"));
                    at.setActive(rs.getBoolean("is_active"));
                    list.add(at);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public double getTotalAllowanceByPositionId(int positionId) {
        String sql = "SELECT COALESCE(SUM(t.amount), 0) " +
                     "FROM position_allowances pa " +
                     "JOIN allowance_types t ON pa.allowance_type_id = t.id " +
                     "WHERE pa.position_id = ? AND t.is_active = 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, positionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getDouble(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    @Override
    public boolean save(int positionId, List<Integer> allowanceTypeIds) {
        String deleteSql = "DELETE FROM position_allowances WHERE position_id = ?";
        String insertSql = "INSERT INTO position_allowances (position_id, allowance_type_id) VALUES (?, ?)";
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement psDel = conn.prepareStatement(deleteSql)) {
                    psDel.setInt(1, positionId);
                    psDel.executeUpdate();
                }
                if (allowanceTypeIds != null && !allowanceTypeIds.isEmpty()) {
                    try (PreparedStatement psIns = conn.prepareStatement(insertSql)) {
                        for (int atId : allowanceTypeIds) {
                            psIns.setInt(1, positionId);
                            psIns.setInt(2, atId);
                            psIns.addBatch();
                        }
                        psIns.executeBatch();
                    }
                }
                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                e.printStackTrace();
                return false;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public Map<Position, List<AllowanceType>> getAllPositionsWithAllowances() {
        Map<Position, List<AllowanceType>> result = new LinkedHashMap<>();
        String sql = "SELECT p.id as pos_id, p.code as pos_code, p.name as pos_name, p.department_id, " +
                     "       t.id as at_id, t.code as at_code, t.name as at_name, t.amount as at_amount " +
                     "FROM positions p " +
                     "LEFT JOIN position_allowances pa ON p.id = pa.position_id " +
                     "LEFT JOIN allowance_types t ON pa.allowance_type_id = t.id AND t.is_active = 1 " +
                     "ORDER BY p.name, t.name";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            Map<Integer, Position> posMap = new LinkedHashMap<>();
            Map<Integer, List<AllowanceType>> allowMap = new LinkedHashMap<>();

            while (rs.next()) {
                int posId = rs.getInt("pos_id");
                if (!posMap.containsKey(posId)) {
                    Position pos = new Position();
                    pos.setId(posId);
                    pos.setCode(rs.getString("pos_code"));
                    pos.setName(rs.getString("pos_name"));
                    pos.setDepartmentId(rs.getInt("department_id"));
                    posMap.put(posId, pos);
                    allowMap.put(posId, new ArrayList<>());
                }
                int atId = rs.getInt("at_id");
                if (atId > 0) {
                    AllowanceType at = new AllowanceType();
                    at.setId(atId);
                    at.setCode(rs.getString("at_code"));
                    at.setName(rs.getString("at_name"));
                    at.setAmount(rs.getDouble("at_amount"));
                    allowMap.get(posId).add(at);
                }
            }
            for (Map.Entry<Integer, Position> entry : posMap.entrySet()) {
                result.put(entry.getValue(), allowMap.get(entry.getKey()));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    @Override
    public List<Position> getAllPositions() {
        List<Position> list = new ArrayList<>();
        String sql = "SELECT id, code, name, department_id FROM positions ORDER BY name";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Position p = new Position();
                p.setId(rs.getInt("id"));
                p.setCode(rs.getString("code"));
                p.setName(rs.getString("name"));
                p.setDepartmentId(rs.getInt("department_id"));
                list.add(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
