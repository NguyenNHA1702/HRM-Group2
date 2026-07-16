package com.hrm.project.dao;

import com.hrm.project.model.Candidate;

import java.util.List;

public interface CandidateDAO {

    List<Candidate> getByVacancy(int vacancyId);

    List<Candidate> getAll();

    Candidate getById(long id);

    boolean create(Candidate candidate);

    boolean updateStatus(long id, String status, Integer updatedBy);

    int countByVacancyAndStatus(int vacancyId, String status);
}
