package com.hrm.project.dao.impl;

import com.hrm.project.dao.HolidayDAO;
import com.hrm.project.model.Holiday;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class HolidayDAOImpl implements HolidayDAO {

    @Override
    public List<Holiday> getAllHolidays() {
        List<Holiday> list = new ArrayList<>();
        String sql = "SELECT * FROM holidays ORDER BY start_date DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Holiday holiday = new Holiday();
                holiday.setId(rs.getInt("id"));
                holiday.setName(rs.getString("name"));
                holiday.setStartDate(rs.getDate("start_date"));
                holiday.setEndDate(rs.getDate("end_date"));
                holiday.setSalaryCoefficient(rs.getDouble("salary_coefficient"));
                holiday.setDescription(rs.getString("description"));
                list.add(holiday);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public Holiday getHolidayById(int id) {
        String sql = "SELECT * FROM holidays WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Holiday holiday = new Holiday();
                    holiday.setId(rs.getInt("id"));
                    holiday.setName(rs.getString("name"));
                    holiday.setStartDate(rs.getDate("start_date"));
                    holiday.setEndDate(rs.getDate("end_date"));
                    holiday.setSalaryCoefficient(rs.getDouble("salary_coefficient"));
                    holiday.setDescription(rs.getString("description"));
                    return holiday;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public boolean addHoliday(Holiday holiday) {
        String sql = "INSERT INTO holidays (name, start_date, end_date, salary_coefficient, description) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, holiday.getName());
            ps.setDate(2, holiday.getStartDate());
            ps.setDate(3, holiday.getEndDate());
            ps.setDouble(4, holiday.getSalaryCoefficient());
            ps.setString(5, holiday.getDescription());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean updateHoliday(Holiday holiday) {
        String sql = "UPDATE holidays SET name = ?, start_date = ?, end_date = ?, salary_coefficient = ?, description = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, holiday.getName());
            ps.setDate(2, holiday.getStartDate());
            ps.setDate(3, holiday.getEndDate());
            ps.setDouble(4, holiday.getSalaryCoefficient());
            ps.setString(5, holiday.getDescription());
            ps.setInt(6, holiday.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean deleteHoliday(int id) {
        String sql = "DELETE FROM holidays WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public List<Holiday> getHolidays(String keyword, String year, String sortBy, String sortOrder, int page, int pageSize) {
        List<Holiday> list = new ArrayList<>();
        
        // Whitelist validation for security
        String cleanSortBy = "start_date";
        if ("name".equalsIgnoreCase(sortBy)) cleanSortBy = "name";
        else if ("start_date".equalsIgnoreCase(sortBy) || "startDate".equalsIgnoreCase(sortBy)) cleanSortBy = "start_date";
        else if ("end_date".equalsIgnoreCase(sortBy) || "endDate".equalsIgnoreCase(sortBy)) cleanSortBy = "end_date";
        else if ("salary_coefficient".equalsIgnoreCase(sortBy) || "salaryCoefficient".equalsIgnoreCase(sortBy)) cleanSortBy = "salary_coefficient";
        
        String cleanSortOrder = "DESC";
        if ("ASC".equalsIgnoreCase(sortOrder)) {
            cleanSortOrder = "ASC";
        }
        
        StringBuilder sql = new StringBuilder("SELECT * FROM holidays WHERE 1=1");
        List<Object> params = new ArrayList<>();
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (name LIKE ? OR description LIKE ?)");
            String k = "%" + keyword.trim() + "%";
            params.add(k);
            params.add(k);
        }
        
        if (year != null && !year.trim().isEmpty()) {
            sql.append(" AND (YEAR(start_date) = ? OR YEAR(end_date) = ?)");
            try {
                int y = Integer.parseInt(year.trim());
                params.add(y);
                params.add(y);
            } catch (NumberFormatException e) {
                // Ignore invalid year format
            }
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
                    Holiday holiday = new Holiday();
                    holiday.setId(rs.getInt("id"));
                    holiday.setName(rs.getString("name"));
                    holiday.setStartDate(rs.getDate("start_date"));
                    holiday.setEndDate(rs.getDate("end_date"));
                    holiday.setSalaryCoefficient(rs.getDouble("salary_coefficient"));
                    holiday.setDescription(rs.getString("description"));
                    list.add(holiday);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public int getHolidaysCount(String keyword, String year) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM holidays WHERE 1=1");
        List<Object> params = new ArrayList<>();
        
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (name LIKE ? OR description LIKE ?)");
            String k = "%" + keyword.trim() + "%";
            params.add(k);
            params.add(k);
        }
        
        if (year != null && !year.trim().isEmpty()) {
            sql.append(" AND (YEAR(start_date) = ? OR YEAR(end_date) = ?)");
            try {
                int y = Integer.parseInt(year.trim());
                params.add(y);
                params.add(y);
            } catch (NumberFormatException e) {
                // Ignore
            }
        }
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
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

    @Override
    public List<Integer> getHolidayYears() {
        List<Integer> years = new ArrayList<>();
        String sql = "SELECT DISTINCT YEAR(start_date) as y FROM holidays UNION SELECT DISTINCT YEAR(end_date) as y FROM holidays ORDER BY y DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                int y = rs.getInt("y");
                if (y > 0 && !years.contains(y)) {
                    years.add(y);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return years;
    }
}
