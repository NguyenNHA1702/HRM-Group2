package com.hrm.project.dao.impl;

import com.hrm.project.dao.ScheduleDAO;
import com.hrm.project.model.EmployeeSchedule;
import com.hrm.project.model.ScheduleHistory;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ScheduleDAOImpl implements ScheduleDAO {

    @Override
    public List<EmployeeSchedule> getSchedules(String keyword, Integer departmentId, Integer workShiftId, String startDate, String endDate, int page, int pageSize) {
        List<EmployeeSchedule> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT es.id, es.employee_id, es.work_shift_id, es.schedule_date, es.notes, " +
            "e.employee_code, e.full_name AS employee_name, d.name AS department_name, " +
            "ws.name AS work_shift_name, ws.start_time, ws.end_time " +
            "FROM employee_schedules es " +
            "JOIN employees e ON es.employee_id = e.id " +
            "JOIN work_shifts ws ON es.work_shift_id = ws.id " +
            "LEFT JOIN departments d ON e.department_id = d.id " +
            "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (e.full_name LIKE ? OR e.employee_code LIKE ? OR es.notes LIKE ?) ");
            String k = "%" + keyword.trim() + "%";
            params.add(k);
            params.add(k);
            params.add(k);
        }
        if (departmentId != null && departmentId > 0) {
            sql.append("AND e.department_id = ? ");
            params.add(departmentId);
        }
        if (workShiftId != null && workShiftId > 0) {
            sql.append("AND es.work_shift_id = ? ");
            params.add(workShiftId);
        }
        if (startDate != null && !startDate.trim().isEmpty()) {
            sql.append("AND es.schedule_date >= ? ");
            params.add(Date.valueOf(startDate.trim()));
        }
        if (endDate != null && !endDate.trim().isEmpty()) {
            sql.append("AND es.schedule_date <= ? ");
            params.add(Date.valueOf(endDate.trim()));
        }

        sql.append("ORDER BY es.schedule_date DESC, e.full_name ASC ");
        sql.append("LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapScheduleRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public int getSchedulesCount(String keyword, Integer departmentId, Integer workShiftId, String startDate, String endDate) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM employee_schedules es " +
            "JOIN employees e ON es.employee_id = e.id " +
            "WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (e.full_name LIKE ? OR e.employee_code LIKE ?) ");
            String k = "%" + keyword.trim() + "%";
            params.add(k);
            params.add(k);
        }
        if (departmentId != null && departmentId > 0) {
            sql.append("AND e.department_id = ? ");
            params.add(departmentId);
        }
        if (workShiftId != null && workShiftId > 0) {
            sql.append("AND es.work_shift_id = ? ");
            params.add(workShiftId);
        }
        if (startDate != null && !startDate.trim().isEmpty()) {
            sql.append("AND es.schedule_date >= ? ");
            params.add(Date.valueOf(startDate.trim()));
        }
        if (endDate != null && !endDate.trim().isEmpty()) {
            sql.append("AND es.schedule_date <= ? ");
            params.add(Date.valueOf(endDate.trim()));
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
    public EmployeeSchedule getScheduleById(int id) {
        String sql = "SELECT es.id, es.employee_id, es.work_shift_id, es.schedule_date, es.notes, " +
                     "e.employee_code, e.full_name AS employee_name, d.name AS department_name, " +
                     "ws.name AS work_shift_name, ws.start_time, ws.end_time " +
                     "FROM employee_schedules es " +
                     "JOIN employees e ON es.employee_id = e.id " +
                     "JOIN work_shifts ws ON es.work_shift_id = ws.id " +
                     "LEFT JOIN departments d ON e.department_id = d.id " +
                     "WHERE es.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapScheduleRow(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public EmployeeSchedule getScheduleByEmployeeAndDate(int employeeId, String date) {
        String sql = "SELECT es.id, es.employee_id, es.work_shift_id, es.schedule_date, es.notes, " +
                     "e.employee_code, e.full_name AS employee_name, d.name AS department_name, " +
                     "ws.name AS work_shift_name, ws.start_time, ws.end_time " +
                     "FROM employee_schedules es " +
                     "JOIN employees e ON es.employee_id = e.id " +
                     "JOIN work_shifts ws ON es.work_shift_id = ws.id " +
                     "LEFT JOIN departments d ON e.department_id = d.id " +
                     "WHERE es.employee_id = ? AND es.schedule_date = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            ps.setDate(2, Date.valueOf(date));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapScheduleRow(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public boolean assignSchedule(EmployeeSchedule schedule) {
        String sql = "INSERT INTO employee_schedules (employee_id, work_shift_id, schedule_date, notes) " +
                     "VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE work_shift_id = ?, notes = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, schedule.getEmployeeId());
            ps.setInt(2, schedule.getWorkShiftId());
            ps.setDate(3, schedule.getScheduleDate());
            ps.setString(4, schedule.getNotes());
            ps.setInt(5, schedule.getWorkShiftId());
            ps.setString(6, schedule.getNotes());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean updateSchedule(EmployeeSchedule schedule, String changedBy, String changeReason) {
        String getOldShiftSql = "SELECT ws.name FROM employee_schedules es JOIN work_shifts ws ON es.work_shift_id = ws.id WHERE es.id = ?";
        String getNewShiftSql = "SELECT name FROM work_shifts WHERE id = ?";
        String updateSql = "UPDATE employee_schedules SET work_shift_id = ?, notes = ?, schedule_date = ? WHERE id = ?";
        String insertHistorySql = "INSERT INTO schedule_history (employee_id, schedule_date, old_shift_name, new_shift_name, changed_by, change_reason) VALUES (?, ?, ?, ?, ?, ?)";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            String oldShiftName = "";
            try (PreparedStatement psOld = conn.prepareStatement(getOldShiftSql)) {
                psOld.setInt(1, schedule.getId());
                try (ResultSet rs = psOld.executeQuery()) {
                    if (rs.next()) oldShiftName = rs.getString(1);
                }
            }

            String newShiftName = "";
            try (PreparedStatement psNew = conn.prepareStatement(getNewShiftSql)) {
                psNew.setInt(1, schedule.getWorkShiftId());
                try (ResultSet rs = psNew.executeQuery()) {
                    if (rs.next()) newShiftName = rs.getString(1);
                }
            }

            try (PreparedStatement psUpdate = conn.prepareStatement(updateSql)) {
                psUpdate.setInt(1, schedule.getWorkShiftId());
                psUpdate.setString(2, schedule.getNotes());
                psUpdate.setDate(3, schedule.getScheduleDate());
                psUpdate.setInt(4, schedule.getId());
                psUpdate.executeUpdate();
            }

            try (PreparedStatement psHistory = conn.prepareStatement(insertHistorySql)) {
                psHistory.setInt(1, schedule.getEmployeeId());
                psHistory.setDate(2, schedule.getScheduleDate());
                psHistory.setString(3, oldShiftName);
                psHistory.setString(4, newShiftName);
                psHistory.setString(5, changedBy);
                psHistory.setString(6, changeReason);
                psHistory.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
        return false;
    }

    @Override
    public boolean deleteSchedule(int id) {
        String sql = "DELETE FROM employee_schedules WHERE id = ?";
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
    public List<ScheduleHistory> getHistoryByEmployee(int employeeId) {
        List<ScheduleHistory> list = new ArrayList<>();
        String sql = "SELECT * FROM schedule_history WHERE employee_id = ? ORDER BY changed_at DESC LIMIT 15";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ScheduleHistory h = new ScheduleHistory();
                    h.setId(rs.getInt("id"));
                    h.setEmployeeId(rs.getInt("employee_id"));
                    h.setScheduleDate(rs.getDate("schedule_date"));
                    h.setOldShiftName(rs.getString("old_shift_name"));
                    h.setNewShiftName(rs.getString("new_shift_name"));
                    h.setChangedBy(rs.getString("changed_by"));
                    h.setChangeReason(rs.getString("change_reason"));
                    h.setChangedAt(rs.getTimestamp("changed_at"));
                    list.add(h);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<EmployeeSchedule> getEmployeeSchedulesForMonth(int employeeId, String yearMonth) {
        List<EmployeeSchedule> list = new ArrayList<>();
        String sql = "SELECT es.id, es.employee_id, es.work_shift_id, es.schedule_date, es.notes, " +
                     "ws.name AS work_shift_name, ws.start_time, ws.end_time " +
                     "FROM employee_schedules es " +
                     "JOIN work_shifts ws ON es.work_shift_id = ws.id " +
                     "WHERE es.employee_id = ? AND DATE_FORMAT(es.schedule_date, '%Y-%m') = ? " +
                     "ORDER BY es.schedule_date ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, employeeId);
            ps.setString(2, yearMonth);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    EmployeeSchedule s = new EmployeeSchedule();
                    s.setId(rs.getInt("id"));
                    s.setEmployeeId(rs.getInt("employee_id"));
                    s.setWorkShiftId(rs.getInt("work_shift_id"));
                    s.setScheduleDate(rs.getDate("schedule_date"));
                    s.setNotes(rs.getString("notes"));
                    s.setWorkShiftName(rs.getString("work_shift_name"));
                    s.setStartTime(rs.getTime("start_time"));
                    s.setEndTime(rs.getTime("end_time"));
                    list.add(s);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private EmployeeSchedule mapScheduleRow(ResultSet rs) throws SQLException {
        EmployeeSchedule s = new EmployeeSchedule();
        s.setId(rs.getInt("id"));
        s.setEmployeeId(rs.getInt("employee_id"));
        s.setWorkShiftId(rs.getInt("work_shift_id"));
        s.setScheduleDate(rs.getDate("schedule_date"));
        s.setNotes(rs.getString("notes"));
        s.setEmployeeCode(rs.getString("employee_code"));
        s.setEmployeeName(rs.getString("employee_name"));
        s.setDepartmentName(rs.getString("department_name"));
        s.setWorkShiftName(rs.getString("work_shift_name"));
        s.setStartTime(rs.getTime("start_time"));
        s.setEndTime(rs.getTime("end_time"));
        return s;
    }
}
