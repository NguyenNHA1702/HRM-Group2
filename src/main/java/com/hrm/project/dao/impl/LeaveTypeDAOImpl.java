package com.hrm.project.dao.impl;

import com.hrm.project.dao.LeaveTypeDAO;
import com.hrm.project.model.LeaveType;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LeaveTypeDAOImpl implements LeaveTypeDAO {

    @Override
    public List<LeaveType> getAll() {

        List<LeaveType> list = new ArrayList<>();

        String sql =
                "SELECT * FROM leave_types " +
                        "ORDER BY name";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()
        ) {

            while (rs.next()) {
                list.add(map(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    @Override
    public LeaveType getById(int id) {

        String sql =
                "SELECT * FROM leave_types WHERE id=?";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setInt(1, id);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return map(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    @Override
    public boolean create(LeaveType leaveType) {

        String sql =
                "INSERT INTO leave_types " +
                        "(code, name, days_per_year, is_paid, is_active) " +
                        "VALUES(?,?,?,?,?)";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setString(1, leaveType.getCode());
            ps.setString(2, leaveType.getName());
            if (leaveType.getDaysPerYear() != null) {
                ps.setDouble(3, leaveType.getDaysPerYear());
            } else {
                ps.setNull(3, Types.DECIMAL);
            }
            ps.setBoolean(4, leaveType.isPaid());
            ps.setBoolean(5, leaveType.isActive());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public boolean update(LeaveType leaveType) {

        String sql =
                "UPDATE leave_types " +
                        "SET code=?, name=?, days_per_year=?, is_paid=? " +
                        "WHERE id=?";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setString(1, leaveType.getCode());
            ps.setString(2, leaveType.getName());
            if (leaveType.getDaysPerYear() != null) {
                ps.setDouble(3, leaveType.getDaysPerYear());
            } else {
                ps.setNull(3, Types.DECIMAL);
            }
            ps.setBoolean(4, leaveType.isPaid());
            ps.setInt(5, leaveType.getId());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    @Override
    public boolean toggleStatus(int id) {

        String sql =
                "UPDATE leave_types " +
                        "SET is_active = NOT is_active " +
                        "WHERE id=?";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setInt(1, id);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    private LeaveType map(ResultSet rs)
            throws SQLException {

        LeaveType t = new LeaveType();

        t.setId(rs.getInt("id"));
        t.setCode(rs.getString("code"));
        t.setName(rs.getString("name"));

        // Handles NULL safely for days_per_year using object wrappers
        Object daysObj = rs.getObject("days_per_year");
        if (daysObj != null) {
            t.setDaysPerYear(((Number) daysObj).doubleValue());
        } else {
            t.setDaysPerYear(null);
        }

        t.setPaid(rs.getBoolean("is_paid"));
        // t.setDescription(rs.getString("description")); // Ignored: column does not exist in DB
        t.setActive(rs.getBoolean("is_active"));

        return t;
    }
}