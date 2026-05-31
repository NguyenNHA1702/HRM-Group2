package com.hrm.project.controller;

import com.hrm.project.dao.WorkShiftDAO;
import com.hrm.project.dao.impl.WorkShiftDAOImpl;
import com.hrm.project.model.WorkShift;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Time;
import java.util.List;

@WebServlet(name = "WorkShiftController", urlPatterns = {"/admin/work-shifts"})
public class WorkShiftController extends HttpServlet {

    private final WorkShiftDAO dao = new WorkShiftDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        
        String keyword = req.getParameter("keyword");
        if (keyword == null) keyword = "";
        
        String sortBy = req.getParameter("sortBy");
        if (sortBy == null || sortBy.trim().isEmpty()) sortBy = "id";
        
        String sortOrder = req.getParameter("sortOrder");
        if (sortOrder == null || sortOrder.trim().isEmpty()) sortOrder = "ASC";
        
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
        
        int totalRecords = dao.getWorkShiftsCount(keyword);
        int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;
        
        List<WorkShift> list = dao.getWorkShifts(keyword, sortBy, sortOrder, page, pageSize);
        
        req.setAttribute("workShifts", list);
        req.setAttribute("page", page);
        req.setAttribute("pageSize", pageSize);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalRecords", totalRecords);
        req.setAttribute("keyword", keyword);
        req.setAttribute("sortBy", sortBy);
        req.setAttribute("sortOrder", sortOrder);
        
        req.getRequestDispatcher("/WEB-INF/views/admin/work-shift-list.jsp").forward(req, resp);
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
                String startTimeStr = req.getParameter("startTime");
                String endTimeStr = req.getParameter("endTime");
                String description = req.getParameter("description");

                if (isBlank(name) || isBlank(startTimeStr) || isBlank(endTimeStr)) {
                    flash(session, "error", "Vui lòng điền đầy đủ các trường bắt buộc.");
                    break;
                }

                Time startTime = parseTime(startTimeStr);
                Time endTime = parseTime(endTimeStr);

                if (startTime == null || endTime == null) {
                    flash(session, "error", "Khung giờ Check-in hoặc Check-out không hợp lệ.");
                    break;
                }

                WorkShift shift = new WorkShift();
                shift.setName(name);
                shift.setStartTime(startTime);
                shift.setEndTime(endTime);
                shift.setDescription(description);

                if (dao.addWorkShift(shift)) {
                    flash(session, "success", "Tạo ca làm việc mới \"" + name + "\" thành công!");
                } else {
                    flash(session, "error", "Lỗi hệ thống khi thêm ca làm việc. Vui lòng thử lại.");
                }
                break;
            }

            case "update": {
                String idStr = req.getParameter("id");
                String name = req.getParameter("name");
                String startTimeStr = req.getParameter("startTime");
                String endTimeStr = req.getParameter("endTime");
                String description = req.getParameter("description");

                if (isBlank(idStr) || isBlank(name) || isBlank(startTimeStr) || isBlank(endTimeStr)) {
                    flash(session, "error", "Dữ liệu cập nhật không hợp lệ.");
                    break;
                }

                int id = Integer.parseInt(idStr);
                Time startTime = parseTime(startTimeStr);
                Time endTime = parseTime(endTimeStr);

                if (startTime == null || endTime == null) {
                    flash(session, "error", "Khung giờ Check-in hoặc Check-out không hợp lệ.");
                    break;
                }

                WorkShift shift = new WorkShift();
                shift.setId(id);
                shift.setName(name);
                shift.setStartTime(startTime);
                shift.setEndTime(endTime);
                shift.setDescription(description);

                if (dao.updateWorkShift(shift)) {
                    flash(session, "success", "Cập nhật ca làm việc \"" + name + "\" thành công!");
                } else {
                    flash(session, "error", "Lỗi hệ thống khi cập nhật ca làm việc. Vui lòng thử lại.");
                }
                break;
            }

            default:
                flash(session, "error", "Hành động không hợp lệ.");
        }

        resp.sendRedirect(ctx + "/admin/work-shifts");
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private Time parseTime(String s) {
        try {
            s = s.trim();
            if (s.length() == 5) { // hh:mm -> hh:mm:00
                s = s + ":00";
            }
            return Time.valueOf(s);
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    private void flash(HttpSession s, String type, String msg) {
        s.setAttribute("flash_" + type, msg);
    }
}
