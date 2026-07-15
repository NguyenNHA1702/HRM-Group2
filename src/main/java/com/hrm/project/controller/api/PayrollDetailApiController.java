package com.hrm.project.controller.api;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.hrm.project.dao.PayrollDAO;
import com.hrm.project.dao.PositionAllowanceDAO;
import com.hrm.project.dao.impl.PayrollDAOImpl;
import com.hrm.project.dao.impl.PositionAllowanceDAOImpl;
import com.hrm.project.model.AllowanceType;
import com.hrm.project.model.PayrollDetail;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet(name = "PayrollDetailApiController", urlPatterns = {"/api/payroll-detail"})
public class PayrollDetailApiController extends HttpServlet {
    private PayrollDAO payrollDAO;
    private PositionAllowanceDAO positionAllowanceDAO;

    @Override
    public void init() throws ServletException {
        payrollDAO = new PayrollDAOImpl();
        positionAllowanceDAO = new PositionAllowanceDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            int detailId = Integer.parseInt(request.getParameter("detailId"));
            PayrollDetail detail = payrollDAO.getPayrollDetailById(detailId);
            
            if (detail == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"error\": \"Không tìm th?y chi ti?t luong\"}");
                return;
            }

            List<AllowanceType> allowances = positionAllowanceDAO.getAllowancesByPositionId(detail.getPositionId());

            Gson gson = new Gson();
            JsonObject jsonResponse = new JsonObject();
            jsonResponse.add("detail", gson.toJsonTree(detail));
            jsonResponse.add("allowances", gson.toJsonTree(allowances));

            out.print(gson.toJson(jsonResponse));

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"Tham s? không h?p l?\"}");
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"L?i server\"}");
            e.printStackTrace();
        } finally {
            out.flush();
        }
    }
}
