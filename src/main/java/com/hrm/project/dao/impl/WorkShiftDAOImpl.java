package com.hrm.project.dao.impl;

import com.hrm.project.dao.WorkShiftDAO;
import com.hrm.project.model.WorkShift;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class WorkShiftDAOImpl implements WorkShiftDAO {

    @Override
    public List<WorkShift> getAllWorkShifts() {
        List<WorkShift> list = new ArrayList<>();
        String sql = "SELECT * FROM work_shifts ORDER BY id ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                WorkShift shift = new WorkShift();
                shift.setId(rs.getInt("id"));
                shift.setName(rs.getString("name"));
                shift.setStartTime(rs.getTime("start_time"));
                shift.setEndTime(rs.getTime("end_time"));
                shift.setDescription(rs.getString("description"));
                list.add(shift);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public WorkShift getWorkShiftById(int id) {
        String sql = "SELECT * FROM work_shifts WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    WorkShift shift = new WorkShift();
                    shift.setId(rs.getInt("id"));
                    shift.setName(rs.getString("name"));
                    shift.setStartTime(rs.getTime("start_time"));
                    shift.setEndTime(rs.getTime("end_time"));
                    shift.setDescription(rs.getString("description"));
                    return shift;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public boolean addWorkShift(WorkShift shift) {
        String sql = "INSERT INTO work_shifts (name, start_time, end_time, description) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, shift.getName());
            ps.setTime(2, shift.getStartTime());
            ps.setTime(3, shift.getEndTime());
            ps.setString(4, shift.getDescription());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean updateWorkShift(WorkShift shift) {
        String sql = "UPDATE work_shifts SET name = ?, start_time = ?, end_time = ?, description = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, shift.getName());
            ps.setTime(2, shift.getStartTime());
            ps.setTime(3, shift.getEndTime());
            ps.setString(4, shift.getDescription());
            ps.setInt(5, shift.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public List<WorkShift> getWorkShifts(String keyword, String sortBy, String sortOrder, int page, int pageSize) {
        List<WorkShift> list = new ArrayList<>();
        
        // Whitelist validation for security
        String cleanSortBy = "id";
        if ("name".equalsIgnoreCase(sortBy)) cleanSortBy = "name";
        else if ("start_time".equalsIgnoreCase(sortBy) || "startTime".equalsIgnoreCase(sortBy)) cleanSortBy = "start_time";
        else if ("end_time".equalsIgnoreCase(sortBy) || "endTime".equalsIgnoreCase(sortBy)) cleanSortBy = "end_time";
        
        String cleanSortOrder = "ASC";
        if ("DESC".equalsIgnoreCase(sortOrder)) {
            cleanSortOrder = "DESC";
        }
        
        StringBuilder sql = new StringBuilder("SELECT * FROM work_shifts WHERE 1=1");
        List<Object> params = new ArrayList<>();
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (name LIKE ? OR description LIKE ?)");
            String k = "%" + keyword.trim() + "%";
            params.add(k);
            params.add(k);
        }
        
        sql.append(" ORDER BY ").append(cleanSortBy).append(" ").append(cleanSortOrder);
        sql.append(" LIMIT ? OFFSET ?");
        
        int offset = (page - 1) * pageSize;
        params.add(pageSize);
        params.add(offset);
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    WorkShift shift = new WorkShift();
                    shift.setId(rs.getInt("id"));
                    shift.setName(rs.getString("name"));
                    shift.setStartTime(rs.getTime("start_time"));
                    shift.setEndTime(rs.getTime("end_time"));
                    shift.setDescription(rs.getString("description"));
                    list.add(shift);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public int getWorkShiftsCount(String keyword) {
        String sql = "SELECT COUNT(*) FROM work_shifts WHERE 1=1";
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql += " AND (name LIKE ? OR description LIKE ?)";
        }
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            if (keyword != null && !keyword.trim().isEmpty()) {
                String k = "%" + keyword.trim() + "%";
                ps.setString(1, k);
                ps.setString(2, k);
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}
