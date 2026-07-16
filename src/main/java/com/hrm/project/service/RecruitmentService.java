package com.hrm.project.service;

import com.hrm.project.model.Candidate;
import com.hrm.project.model.JobVacancy;

import java.util.List;

public interface RecruitmentService {

    List<JobVacancy> getAllVacancies();

    List<JobVacancy> getOpenVacancies();

    JobVacancy getVacancyById(int id);

    boolean createVacancy(JobVacancy vacancy);

    boolean closeVacancy(int vacancyId);

    List<Candidate> getCandidatesByVacancy(int vacancyId);

    List<Candidate> getAllCandidates();

    Candidate getCandidateById(long id);

    boolean addCandidate(Candidate candidate);

    boolean advanceToInterviewing(long candidateId, int reviewerId);

    boolean advanceToOffered(long candidateId, int reviewerId);

    boolean hireCandidate(long candidateId, int reviewerId);

    boolean rejectCandidate(long candidateId, int reviewerId);
}
