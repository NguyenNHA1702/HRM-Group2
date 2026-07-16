package com.hrm.project.service.impl;

import com.hrm.project.dao.CandidateDAO;
import com.hrm.project.dao.JobVacancyDAO;
import com.hrm.project.dao.impl.CandidateDAOImpl;
import com.hrm.project.dao.impl.JobVacancyDAOImpl;
import com.hrm.project.enums.CandidateStatus;
import com.hrm.project.enums.VacancyStatus;
import com.hrm.project.model.Candidate;
import com.hrm.project.model.JobVacancy;
import com.hrm.project.service.RecruitmentService;

import java.util.List;

public class RecruitmentServiceImpl implements RecruitmentService {

    private final JobVacancyDAO vacancyDAO = new JobVacancyDAOImpl();
    private final CandidateDAO candidateDAO = new CandidateDAOImpl();

    @Override
    public List<JobVacancy> getAllVacancies() {
        return vacancyDAO.getAll();
    }

    @Override
    public List<JobVacancy> getOpenVacancies() {
        return vacancyDAO.getOpen();
    }

    @Override
    public JobVacancy getVacancyById(int id) {
        return vacancyDAO.getById(id);
    }

    @Override
    public boolean createVacancy(JobVacancy vacancy) {
        if (vacancy.getHeadcount() < 1) {
            vacancy.setHeadcount(1);
        }
        vacancy.setStatus(VacancyStatus.OPEN.getCode());
        return vacancyDAO.create(vacancy);
    }

    @Override
    public boolean closeVacancy(int vacancyId) {
        JobVacancy vacancy = vacancyDAO.getById(vacancyId);
        if (vacancy == null || VacancyStatus.CLOSED.getCode().equals(vacancy.getStatus())) {
            return false;
        }
        return vacancyDAO.close(vacancyId);
    }

    @Override
    public List<Candidate> getCandidatesByVacancy(int vacancyId) {
        return candidateDAO.getByVacancy(vacancyId);
    }

    @Override
    public List<Candidate> getAllCandidates() {
        return candidateDAO.getAll();
    }

    @Override
    public Candidate getCandidateById(long id) {
        return candidateDAO.getById(id);
    }

    @Override
    public boolean addCandidate(Candidate candidate) {
        JobVacancy vacancy = vacancyDAO.getById(candidate.getVacancyId());
        if (vacancy == null || !VacancyStatus.OPEN.getCode().equals(vacancy.getStatus())) {
            return false;
        }
        return candidateDAO.create(candidate);
    }

    @Override
    public boolean advanceToInterviewing(long candidateId, int reviewerId) {
        return transition(candidateId, reviewerId,
                CandidateStatus.NEW,
                CandidateStatus.INTERVIEWING);
    }

    @Override
    public boolean advanceToOffered(long candidateId, int reviewerId) {
        return transition(candidateId, reviewerId,
                CandidateStatus.INTERVIEWING,
                CandidateStatus.OFFERED);
    }

    @Override
    public boolean hireCandidate(long candidateId, int reviewerId) {
        Candidate candidate = candidateDAO.getById(candidateId);
        if (candidate == null || !CandidateStatus.OFFERED.getCode().equals(candidate.getStatus())) {
            return false;
        }

        if (!candidateDAO.updateStatus(candidateId, CandidateStatus.HIRED.getCode(), reviewerId)) {
            return false;
        }

        checkAndCloseVacancy(candidate.getVacancyId());
        return true;
    }

    @Override
    public boolean rejectCandidate(long candidateId, int reviewerId) {
        Candidate candidate = candidateDAO.getById(candidateId);
        if (candidate == null) {
            return false;
        }

        String current = candidate.getStatus();
        if (CandidateStatus.HIRED.getCode().equals(current)
                || CandidateStatus.REJECTED.getCode().equals(current)) {
            return false;
        }

        return candidateDAO.updateStatus(candidateId, CandidateStatus.REJECTED.getCode(), reviewerId);
    }

    private boolean transition(long candidateId, int reviewerId,
                             CandidateStatus from, CandidateStatus to) {
        Candidate candidate = candidateDAO.getById(candidateId);
        if (candidate == null || !from.getCode().equals(candidate.getStatus())) {
            return false;
        }
        return candidateDAO.updateStatus(candidateId, to.getCode(), reviewerId);
    }

    private void checkAndCloseVacancy(int vacancyId) {
        JobVacancy vacancy = vacancyDAO.getById(vacancyId);
        if (vacancy == null || VacancyStatus.CLOSED.getCode().equals(vacancy.getStatus())) {
            return;
        }
        int hiredCount = vacancyDAO.countHired(vacancyId);
        if (hiredCount >= vacancy.getHeadcount()) {
            vacancyDAO.close(vacancyId);
        }
    }
}
