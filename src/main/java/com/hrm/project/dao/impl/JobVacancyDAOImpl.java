package com.hrm.project.dao.impl;

import com.hrm.project.dao.JobVacancyDAO;
import com.hrm.project.model.JobVacancy;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class JobVacancyDAOImpl implements JobVacancyDAO {

    private static final String SELECT_BASE =
            "SELECT jv.*, " +
                    "d.name AS department_name, " +
                    "p.name AS position_name, " +
                    "e.full_name AS created_by_name, " +
                    "(SELECT COUNT(*) FROM candidates c WHERE c.vacancy_id = jv.id) AS candidate_count, " +
                    "(SELECT COUNT(*) FROM candidates c WHERE c.vacancy_id = jv.id AND c.status = 'HIRED') AS hired_count " +
                    "FROM job_vacancies jv " +
                    "JOIN departments d ON jv.department_id = d.id " +
                    "LEFT JOIN positions p ON jv.position_id = p.id " +
                    "LEFT JOIN employees e ON jv.created_by = e.id ";

    @Override
    public List<JobVacancy> getAll() {
        List<JobVacancy> list = new ArrayList<>();
        String sql = SELECT_BASE + "ORDER BY jv.created_at DESC";

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
    public List<JobVacancy> getOpen() {
        List<JobVacancy> list = new ArrayList<>();
        String sql = SELECT_BASE + "WHERE jv.status = 'OPEN' ORDER BY jv.created_at DESC";

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
    public JobVacancy getById(int id) {
        String sql = SELECT_BASE + "WHERE jv.id = ?";

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
    public boolean create(JobVacancy vacancy) {
        String sql =
                "INSERT INTO job_vacancies " +
                        "(title, department_id, position_id, description, headcount, status, created_by) " +
                        "VALUES (?, ?, ?, ?, ?, 'OPEN', ?)";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setString(1, vacancy.getTitle());
            ps.setInt(2, vacancy.getDepartmentId());
            if (vacancy.getPositionId() != null) {
                ps.setInt(3, vacancy.getPositionId());
            } else {
                ps.setNull(3, Types.INTEGER);
            }
            ps.setString(4, vacancy.getDescription());
            ps.setInt(5, vacancy.getHeadcount());
            if (vacancy.getCreatedBy() != null) {
                ps.setInt(6, vacancy.getCreatedBy());
            } else {
                ps.setNull(6, Types.INTEGER);
            }
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean close(int id) {
        String sql =
                "UPDATE job_vacancies " +
                        "SET status = 'CLOSED', closed_at = NOW() " +
                        "WHERE id = ? AND status = 'OPEN'";

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

    @Override
    public int countHired(int vacancyId) {
        String sql =
                "SELECT COUNT(*) FROM candidates " +
                        "WHERE vacancy_id = ? AND status = 'HIRED'";

        try (
                Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)
        ) {
            ps.setInt(1, vacancyId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    private JobVacancy map(ResultSet rs) throws SQLException {
        JobVacancy v = new JobVacancy();
        v.setId(rs.getInt("id"));
        v.setTitle(rs.getString("title"));
        v.setDepartmentId(rs.getInt("department_id"));
        int posId = rs.getInt("position_id");
        v.setPositionId(rs.wasNull() ? null : posId);
        v.setDescription(rs.getString("description"));
        v.setHeadcount(rs.getInt("headcount"));
        v.setStatus(rs.getString("status"));
        int createdBy = rs.getInt("created_by");
        v.setCreatedBy(rs.wasNull() ? null : createdBy);
        v.setOpenedAt(rs.getTimestamp("opened_at"));
        v.setClosedAt(rs.getTimestamp("closed_at"));
        v.setCreatedAt(rs.getTimestamp("created_at"));
        v.setUpdatedAt(rs.getTimestamp("updated_at"));
        v.setDepartmentName(rs.getString("department_name"));
        v.setPositionName(rs.getString("position_name"));
        v.setCreatedByName(rs.getString("created_by_name"));
        v.setCandidateCount(rs.getInt("candidate_count"));
        v.setHiredCount(rs.getInt("hired_count"));
        return v;
    }
}
