package com.hrm.project.dao;

import com.hrm.project.model.Holiday;
import java.util.List;

public interface HolidayDAO {
    List<Holiday> getAllHolidays();
    Holiday getHolidayById(int id);
    boolean addHoliday(Holiday holiday);
    boolean updateHoliday(Holiday holiday);
    boolean deleteHoliday(int id);
    List<Holiday> getHolidays(String keyword, String year, String sortBy, String sortOrder, int page, int pageSize);
    int getHolidaysCount(String keyword, String year);
    List<Integer> getHolidayYears();
}
