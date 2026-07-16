package com.hrm.project.controller.recruitment;

import com.hrm.project.service.RecruitmentService;
import com.hrm.project.service.impl.RecruitmentServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/hr/candidates")
public class HrCandidateController extends HttpServlet {

    private final RecruitmentService recruitmentService = new RecruitmentServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!HrVacancyController.isHrOrAdmin(request, response)) {
            return;
        }

        String vacancyIdParam = request.getParameter("vacancyId");
        if (vacancyIdParam != null && !vacancyIdParam.isEmpty()) {
            int vacancyId = Integer.parseInt(vacancyIdParam);
            request.setAttribute("vacancy", recruitmentService.getVacancyById(vacancyId));
            request.setAttribute("candidates", recruitmentService.getCandidatesByVacancy(vacancyId));
        } else {
            request.setAttribute("candidates", recruitmentService.getAllCandidates());
        }

        request.setAttribute("openVacancies", recruitmentService.getOpenVacancies());

        javax.servlet.http.HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("flashMessage") != null) {
            request.setAttribute("message", session.getAttribute("flashMessage"));
            session.removeAttribute("flashMessage");
        } else {
            String message = request.getParameter("message");
            if (message != null) {
                request.setAttribute("message", message);
            }
        }

        request.getRequestDispatcher("/WEB-INF/views/hr/candidates.jsp")
                .forward(request, response);
    }
}
