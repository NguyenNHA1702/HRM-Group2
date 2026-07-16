package com.hrm.project.controller.recruitment;

import com.hrm.project.model.JobVacancy;
import com.hrm.project.service.RecruitmentService;
import com.hrm.project.service.impl.RecruitmentServiceImpl;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/hr/vacancies/action")
public class HrVacancyActionController extends HttpServlet {

    private final RecruitmentService recruitmentService = new RecruitmentServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/hr/vacancies");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        if (!HrVacancyController.isHrOrAdmin(request, response)) {
            return;
        }

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        String ctx = request.getContextPath();
        HttpSession session = request.getSession(false);

        try {
            if ("create".equals(action)) {
                String title = request.getParameter("title");
                String departmentIdStr = request.getParameter("departmentId");
                String headcountStr = request.getParameter("headcount");

                if (title == null || title.trim().isEmpty()
                        || departmentIdStr == null || departmentIdStr.isEmpty()) {
                    flashAndRedirect(session, response, ctx, "Vui lòng nhập đầy đủ thông tin");
                    return;
                }

                JobVacancy vacancy = new JobVacancy();
                vacancy.setTitle(title.trim());
                vacancy.setDepartmentId(Integer.parseInt(departmentIdStr));
                String positionId = request.getParameter("positionId");
                if (positionId != null && !positionId.isEmpty()) {
                    vacancy.setPositionId(Integer.parseInt(positionId));
                }
                vacancy.setDescription(request.getParameter("description"));
                vacancy.setHeadcount(headcountStr != null && !headcountStr.isEmpty()
                        ? Integer.parseInt(headcountStr) : 1);
                vacancy.setCreatedBy((Integer) session.getAttribute("employeeId"));

                boolean ok = recruitmentService.createVacancy(vacancy);
                flashAndRedirect(session, response, ctx,
                        ok ? "Đã tạo vị trí tuyển dụng mới" : "Không thể tạo vị trí tuyển dụng");
                return;
            }

            if ("close".equals(action)) {
                String idStr = request.getParameter("id");
                if (idStr == null || idStr.isEmpty()) {
                    flashAndRedirect(session, response, ctx, "Thiếu mã vị trí");
                    return;
                }
                boolean ok = recruitmentService.closeVacancy(Integer.parseInt(idStr));
                flashAndRedirect(session, response, ctx,
                        ok ? "Đã đóng vị trí tuyển dụng" : "Không thể đóng vị trí");
                return;
            }

            response.sendRedirect(ctx + "/hr/vacancies");
        } catch (Exception e) {
            e.printStackTrace();
            flashAndRedirect(session, response, ctx, "Lỗi: " + e.getMessage());
        }
    }

    private void flashAndRedirect(HttpSession session, HttpServletResponse response,
                                  String ctx, String message) throws IOException {
        if (session != null) {
            session.setAttribute("flashMessage", message);
        }
        response.sendRedirect(ctx + "/hr/vacancies");
    }
}
