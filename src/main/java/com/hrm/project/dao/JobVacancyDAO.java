package com.hrm.project.dao;

import com.hrm.project.model.JobVacancy;

import java.util.List;

public interface JobVacancyDAO {

    List<JobVacancy> getAll();

    List<JobVacancy> getOpen();

    JobVacancy getById(int id);

    boolean create(JobVacancy vacancy);

    boolean close(int id);

    int countHired(int vacancyId);
}
