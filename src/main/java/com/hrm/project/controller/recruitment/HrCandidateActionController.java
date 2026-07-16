package com.hrm.project.controller.recruitment;

import com.hrm.project.model.Candidate;
import com.hrm.project.service.RecruitmentService;
import com.hrm.project.service.impl.RecruitmentServiceImpl;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/hr/candidates/action")
public class HrCandidateActionController extends HttpServlet {

    private final RecruitmentService recruitmentService = new RecruitmentServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/hr/candidates");
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
        int reviewerId = (Integer) session.getAttribute("employeeId");

        try {
            if ("create".equals(action)) {
                Candidate candidate = new Candidate();
                candidate.setVacancyId(Integer.parseInt(request.getParameter("vacancyId")));
                candidate.setFullName(request.getParameter("fullName"));
                candidate.setEmail(request.getParameter("email"));
                candidate.setPhone(request.getParameter("phone"));
                candidate.setResumeUrl(request.getParameter("resumeUrl"));
                candidate.setNotes(request.getParameter("notes"));

                boolean ok = recruitmentService.addCandidate(candidate);
                int vacancyId = candidate.getVacancyId();
                String msg = ok ? "Đã thêm ứng viên mới" : "Không thể thêm ứng viên (vị trí đã đóng?)";
                flashAndRedirect(session, response, ctx, vacancyId, msg);
                return;
            }

            long candidateId = Long.parseLong(request.getParameter("id"));
            Candidate candidate = recruitmentService.getCandidateById(candidateId);
            int vacancyId = candidate != null ? candidate.getVacancyId() : 0;

            switch (action) {
                case "interview":
                    recruitmentService.advanceToInterviewing(candidateId, reviewerId);
                    break;
                case "offer":
                    recruitmentService.advanceToOffered(candidateId, reviewerId);
                    break;
                case "hire":
                    recruitmentService.hireCandidate(candidateId, reviewerId);
                    break;
                case "reject":
                    recruitmentService.rejectCandidate(candidateId, reviewerId);
                    break;
                default:
                    break;
            }

            flashAndRedirect(session, response, ctx, vacancyId, null);
        } catch (Exception e) {
            e.printStackTrace();
            flashAndRedirect(session, response, ctx, 0, "Lỗi: " + e.getMessage());
        }
    }

    private void flashAndRedirect(HttpSession session, HttpServletResponse response,
                                  String ctx, int vacancyId, String message) throws IOException {
        if (session != null && message != null) {
            session.setAttribute("flashMessage", message);
        }
        if (vacancyId > 0) {
            response.sendRedirect(ctx + "/hr/candidates?vacancyId=" + vacancyId);
        } else {
            response.sendRedirect(ctx + "/hr/candidates");
        }
    }
}
