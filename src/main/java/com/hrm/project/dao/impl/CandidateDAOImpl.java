package com.hrm.project.dao.impl;

import com.hrm.project.dao.CandidateDAO;
import com.hrm.project.model.Candidate;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CandidateDAOImpl implements CandidateDAO {

    private static final String SELECT_BASE =
            "SELECT c.*, " +
                    "jv.title AS vacancy_title, " +
                    "d.name AS department_name, " +
                    "p.name AS position_name, " +
                    "e.full_name AS updated_by_name " +
                    "FROM candidates c " +
                    "JOIN job_vacancies jv ON c.vacancy_id = jv.id " +
                    "JOIN departments d ON jv.department_id = d.id " +
                    "LEFT JOIN positions p ON jv.position_id = p.id " +
                    "LEFT JOIN employees e ON c.updated_by = e.id ";

    @Override
    public List<Candidate> getByVacancy(int vacancyId) {
        List<Candidate> list = new ArrayList<>();
        String sql = SELECT_BASE + "WHERE c.vacancy_id = ? ORDER BY c.applied_at DESC";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, vacancyId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(map(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    @Override
    public List<Candidate> getAll() {
        List<Candidate> list = new ArrayList<>();
        String sql = SELECT_BASE + "ORDER BY c.applied_at DESC";

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
    public Candidate getById(long id) {
        String sql = SELECT_BASE + "WHERE c.id = ?";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setLong(1, id);
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
    public boolean create(Candidate candidate) {
        String sql =
                "INSERT INTO candidates " +
                        "(vacancy_id, full_name, email, phone, resume_url, notes, status) " +
                        "VALUES (?, ?, ?, ?, ?, ?, 'NEW')";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, candidate.getVacancyId());
            ps.setString(2, candidate.getFullName());
            ps.setString(3, candidate.getEmail());
            ps.setString(4, candidate.getPhone());
            ps.setString(5, candidate.getResumeUrl());
            ps.setString(6, candidate.getNotes());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean updateStatus(long id, String status, Integer updatedBy) {
        String sql =
                "UPDATE candidates " +
                        "SET status = ?, updated_by = ? " +
                        "WHERE id = ?";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, status);
            if (updatedBy != null) {
                ps.setInt(2, updatedBy);
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            ps.setLong(3, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public int countByVacancyAndStatus(int vacancyId, String status) {
        String sql =
                "SELECT COUNT(*) FROM candidates " +
                        "WHERE vacancy_id = ? AND status = ?";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, vacancyId);
            ps.setString(2, status);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    private Candidate map(ResultSet rs) throws SQLException {
        Candidate c = new Candidate();
        c.setId(rs.getLong("id"));
        c.setVacancyId(rs.getInt("vacancy_id"));
        c.setFullName(rs.getString("full_name"));
        c.setEmail(rs.getString("email"));
        c.setPhone(rs.getString("phone"));
        c.setResumeUrl(rs.getString("resume_url"));
        c.setNotes(rs.getString("notes"));
        c.setStatus(rs.getString("status"));
        c.setAppliedAt(rs.getTimestamp("applied_at"));
        int updatedBy = rs.getInt("updated_by");
        c.setUpdatedBy(rs.wasNull() ? null : updatedBy);
        int employeeId = rs.getInt("employee_id");
        c.setEmployeeId(rs.wasNull() ? null : employeeId);
        c.setCreatedAt(rs.getTimestamp("created_at"));
        c.setUpdatedAt(rs.getTimestamp("updated_at"));
        c.setVacancyTitle(rs.getString("vacancy_title"));
        c.setDepartmentName(rs.getString("department_name"));
        c.setPositionName(rs.getString("position_name"));
        c.setUpdatedByName(rs.getString("updated_by_name"));
        return c;
    }
}
