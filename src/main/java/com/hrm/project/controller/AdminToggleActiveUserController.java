package com.hrm.project.controller;

import com.hrm.project.dao.UserDAO;
import com.hrm.project.dao.impl.UserDAOImpl;
import com.hrm.project.model.UserAccount;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "AdminToggleActiveUserController", urlPatterns = {"/admin/user/toggle-active"})
public class AdminToggleActiveUserController extends HttpServlet {

    private UserDAO userDAO = new UserDAOImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?error=InvalidUserId");
            return;
        }

        try {
            int userId = Integer.parseInt(idParam);
            UserAccount user = userDAO.getUserForAdminUpdate(userId);
            
            if (user != null) {
                boolean newActiveStatus = !user.isActive();
                boolean success = userDAO.updateUserActiveStatus(userId, newActiveStatus);
                
                if (success) {
                    // Redirect back to the page that requested the toggle (e.g., User List)
                    String referer = request.getHeader("Referer");
                    if (referer != null && !referer.isEmpty()) {
                        response.sendRedirect(referer);
                    } else {
                        response.sendRedirect(request.getContextPath() + "/index.jsp?success=1");
                    }
                } else {
                    response.sendRedirect(request.getContextPath() + "/index.jsp?error=ToggleFailed");
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/index.jsp?error=UserNotFound");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/index.jsp?error=InvalidUserId");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}
