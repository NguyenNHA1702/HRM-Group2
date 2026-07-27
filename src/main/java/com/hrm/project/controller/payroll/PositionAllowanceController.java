package com.hrm.project.controller.payroll;

import com.hrm.project.dao.PositionAllowanceDAO;
import com.hrm.project.dao.impl.PositionAllowanceDAOImpl;
import com.hrm.project.model.AllowanceType;
import com.hrm.project.model.Position;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Cấu hình phụ cấp theo chức vụ (position).
 * Chỉ HR/ADMIN mới được truy cập.
 */
@WebServlet(name = "PositionAllowanceController", urlPatterns = {"/admin/position-allowances", "/hr/position-allowances"})
public class PositionAllowanceController extends HttpServlet {
    private PositionAllowanceDAO positionAllowanceDAO;
    private com.hrm.project.dao.AllowanceTypeDAO allowanceTypeDAO;

    @Override
    public void init() throws ServletException {
        positionAllowanceDAO = new PositionAllowanceDAOImpl();
        allowanceTypeDAO = new com.hrm.project.dao.impl.AllowanceTypeDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String roleGroup = (String) session.getAttribute("roleGroup");
        if (!"HR".equals(roleGroup) && !"ADMIN".equals(roleGroup)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        Map<Position, List<AllowanceType>> positionsWithAllowances = positionAllowanceDAO.getAllPositionsWithAllowances();
        List<AllowanceType> allAllowanceTypes = allowanceTypeDAO.getAllAllowanceTypes();

        request.setAttribute("positionsWithAllowances", positionsWithAllowances);
        request.setAttribute("allAllowanceTypes", allAllowanceTypes);
        request.setAttribute("roleGroup", roleGroup);

        request.getRequestDispatcher("/WEB-INF/views/admin/position-allowance-config.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String roleGroup = (String) session.getAttribute("roleGroup");
        if (!"HR".equals(roleGroup) && !"ADMIN".equals(roleGroup)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try {
            int positionId = Integer.parseInt(request.getParameter("positionId"));
            String[] atIds = request.getParameterValues("allowanceTypeIds");
            List<Integer> allowanceTypeIds = new ArrayList<>();
            if (atIds != null) {
                for (String id : atIds) {
                    allowanceTypeIds.add(Integer.parseInt(id));
                }
            }

            boolean success = positionAllowanceDAO.save(positionId, allowanceTypeIds);
            String status = success ? "success=saved" : "error=save_failed";
            response.sendRedirect(request.getContextPath() + "/admin/position-allowances?" + status);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/position-allowances?error=invalid_data");
        }
    }
}
