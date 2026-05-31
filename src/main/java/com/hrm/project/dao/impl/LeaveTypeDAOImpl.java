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
                        "(code, name, days_per_year, is_paid, description, is_active) " +
                        "VALUES(?,?,?,?,?,?)";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setString(1, leaveType.getCode());
            ps.setString(2, leaveType.getName());
            ps.setDouble(3, leaveType.getDaysPerYear());
            ps.setBoolean(4, leaveType.isPaid());
            ps.setString(5, leaveType.getDescription());
            ps.setBoolean(6, leaveType.isActive());

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
                        "SET code=?, name=?, days_per_year=?, is_paid=?, description=? " +
                        "WHERE id=?";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {

            ps.setString(1, leaveType.getCode());
            ps.setString(2, leaveType.getName());
            ps.setDouble(3, leaveType.getDaysPerYear());
            ps.setBoolean(4, leaveType.isPaid());
            ps.setString(5, leaveType.getDescription());
            ps.setInt(6, leaveType.getId());

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
        t.setDaysPerYear(rs.getDouble("days_per_year"));
        t.setPaid(rs.getBoolean("is_paid"));
        t.setDescription(rs.getString("description"));
        t.setActive(rs.getBoolean("is_active"));

        return t;
    }
}