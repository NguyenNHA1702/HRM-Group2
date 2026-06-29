package com.hrm.project.controller.attendance;

import com.hrm.project.dao.HolidayDAO;
import com.hrm.project.dao.impl.HolidayDAOImpl;
import com.hrm.project.model.Holiday;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import java.util.List;

@WebServlet(name = "HolidayController", urlPatterns = {"/admin/holidays"})
public class HolidayController extends HttpServlet {

    private final HolidayDAO dao = new HolidayDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        
        String keyword = req.getParameter("keyword");
        if (keyword == null) keyword = "";
        
        String year = req.getParameter("year");
        if (year == null) year = "";
        
        String sortBy = req.getParameter("sortBy");
        if (sortBy == null || sortBy.trim().isEmpty()) sortBy = "start_date";
        
        String sortOrder = req.getParameter("sortOrder");
        if (sortOrder == null || sortOrder.trim().isEmpty()) sortOrder = "DESC";
        
        String pageStr = req.getParameter("page");
        int page = 1;
        if (pageStr != null && !pageStr.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageStr.trim());
                if (page < 1) page = 1;
            } catch (NumberFormatException e) {
                page = 1;
            }
        }
        
        String pageSizeStr = req.getParameter("pageSize");
        int pageSize = 5; // default pageSize
        if (pageSizeStr != null && !pageSizeStr.trim().isEmpty()) {
            try {
                pageSize = Integer.parseInt(pageSizeStr.trim());
                if (pageSize < 1) pageSize = 5;
            } catch (NumberFormatException e) {
                pageSize = 5;
            }
        }
        
        int totalRecords = dao.getHolidaysCount(keyword, year);
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;
        
        List<Holiday> list = dao.getHolidays(keyword, year, sortBy, sortOrder, page, pageSize);
        List<Integer> years = dao.getHolidayYears();
        
        req.setAttribute("holidays", list);
        req.setAttribute("years", years);
        req.setAttribute("page", page);
        req.setAttribute("pageSize", pageSize);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalRecords", totalRecords);
        req.setAttribute("keyword", keyword);
        req.setAttribute("year", year);
        req.setAttribute("sortBy", sortBy);
        req.setAttribute("sortOrder", sortOrder);
        
        req.getRequestDispatcher("/WEB-INF/views/admin/holiday-list.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        String ctx = req.getContextPath();
        HttpSession session = req.getSession();

        switch (action == null ? "" : action) {
            case "add": {
                String name = req.getParameter("name");
                String startDateStr = req.getParameter("startDate");
                String endDateStr = req.getParameter("endDate");
                String coefficientStr = req.getParameter("salaryCoefficient");
                String description = req.getParameter("description");

                if (isBlank(name) || isBlank(startDateStr) || isBlank(endDateStr) || isBlank(coefficientStr)) {
                    flash(session, "error", "Vui lòng điền đầy đủ các trường bắt buộc.");
                    break;
                }

                Date startDate = parseDate(startDateStr);
                Date endDate = parseDate(endDateStr);
                double coeff = parseDouble(coefficientStr);

                if (startDate == null || endDate == null) {
                    flash(session, "error", "Ngày bắt đầu hoặc ngày kết thúc không đúng định dạng.");
                    break;
                }

                if (startDate.after(endDate)) {
                    flash(session, "error", "Ngày bắt đầu không được sau ngày kết thúc.");
                    break;
                }

                if (coeff <= 0) {
                    flash(session, "error", "Hệ số lương phải lớn hơn 0.");
                    break;
                }

                Holiday holiday = new Holiday();
                holiday.setName(name);
                holiday.setStartDate(startDate);
                holiday.setEndDate(endDate);
                holiday.setSalaryCoefficient(coeff);
                holiday.setDescription(description);

                if (dao.addHoliday(holiday)) {
                    flash(session, "success", "Khai báo ngày nghỉ lễ \"" + name + "\" thành công!");
                } else {
                    flash(session, "error", "Lỗi hệ thống khi thêm ngày lễ. Vui lòng thử lại.");
                }
                break;
            }

            case "update": {
                String idStr = req.getParameter("id");
                String name = req.getParameter("name");
                String startDateStr = req.getParameter("startDate");
                String endDateStr = req.getParameter("endDate");
                String coefficientStr = req.getParameter("salaryCoefficient");
                String description = req.getParameter("description");

                if (isBlank(idStr) || isBlank(name) || isBlank(startDateStr) || isBlank(endDateStr) || isBlank(coefficientStr)) {
                    flash(session, "error", "Dữ liệu cập nhật không hợp lệ.");
                    break;
                }

                int id = Integer.parseInt(idStr);
                Date startDate = parseDate(startDateStr);
                Date endDate = parseDate(endDateStr);
                double coeff = parseDouble(coefficientStr);

                if (startDate == null || endDate == null) {
                    flash(session, "error", "Ngày bắt đầu hoặc ngày kết thúc không đúng định dạng.");
                    break;
                }

                if (startDate.after(endDate)) {
                    flash(session, "error", "Ngày bắt đầu không được sau ngày kết thúc.");
                    break;
                }

                if (coeff <= 0) {
                    flash(session, "error", "Hệ số lương phải lớn hơn 0.");
                    break;
                }

                Holiday holiday = new Holiday();
                holiday.setId(id);
                holiday.setName(name);
                holiday.setStartDate(startDate);
                holiday.setEndDate(endDate);
                holiday.setSalaryCoefficient(coeff);
                holiday.setDescription(description);

                if (dao.updateHoliday(holiday)) {
                    flash(session, "success", "Cập nhật thông tin ngày lễ \"" + name + "\" thành công!");
                } else {
                    flash(session, "error", "Lỗi hệ thống khi cập nhật ngày lễ. Vui lòng thử lại.");
                }
                break;
            }

            case "delete": {
                String idStr = req.getParameter("id");
                if (isBlank(idStr)) {
                    flash(session, "error", "ID không hợp lệ.");
                    break;
                }

                int id = Integer.parseInt(idStr);
                if (dao.deleteHoliday(id)) {
                    flash(session, "success", "Xóa ngày nghỉ lễ thành công!");
                } else {
                    flash(session, "error", "Lỗi hệ thống khi xóa ngày lễ. Vui lòng thử lại.");
                }
                break;
            }

            default:
                flash(session, "error", "Hành động không hợp lệ.");
        }

        resp.sendRedirect(ctx + "/admin/holidays");
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private Date parseDate(String s) {
        try {
            return Date.valueOf(s.trim());
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    private double parseDouble(String s) {
        try {
            return Double.parseDouble(s.trim());
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private void flash(HttpSession s, String type, String msg) {
        s.setAttribute("flash_" + type, msg);
    }
}
