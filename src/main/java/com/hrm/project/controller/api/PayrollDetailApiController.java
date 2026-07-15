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
                out.print("{\"error\": \"Không tìm thấy chi tiết lương\"}");
                return;
            }

            List<AllowanceType> allowances = positionAllowanceDAO.getAllowancesByPositionId(detail.getPositionId());

            com.google.gson.JsonArray holidayDetails = getHolidayDetails(detail.getEmployeeId(), detail.getMonth(), detail.getYear());

            Gson gson = new Gson();
            JsonObject jsonResponse = new JsonObject();
            jsonResponse.add("detail", gson.toJsonTree(detail));
            jsonResponse.add("allowances", gson.toJsonTree(allowances));
            jsonResponse.add("holidayDetails", holidayDetails);

            out.print(gson.toJson(jsonResponse));

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\": \"Tham số không hợp lệ\"}");
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"error\": \"Lỗi server\"}");
            e.printStackTrace();
        } finally {
            out.flush();
        }
    }

    private com.google.gson.JsonArray getHolidayDetails(int empId, int month, int year) {
        com.google.gson.JsonArray arr = new com.google.gson.JsonArray();
        String sql = "SELECT DATE_FORMAT(a.date, '%d/%m/%Y') as wdate, h.name, h.salary_coefficient " +
                     "FROM attendance a " +
                     "JOIN holidays h ON a.date BETWEEN h.start_date AND h.end_date " +
                     "WHERE a.employee_id = ? AND MONTH(a.date) = ? AND YEAR(a.date) = ? " +
                     "AND a.status IN ('PRESENT', 'LATE', 'EARLY_LEAVE') " +
                     "AND DAYOFWEEK(a.date) NOT IN (1, 7) " +
                     "ORDER BY a.date ASC";
        try (java.sql.Connection conn = com.hrm.project.util.DBUtil.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
             ps.setInt(1, empId);
             ps.setInt(2, month);
             ps.setInt(3, year);
             try (java.sql.ResultSet rs = ps.executeQuery()) {
                 while(rs.next()) {
                     JsonObject obj = new JsonObject();
                     obj.addProperty("date", rs.getString("wdate"));
                     obj.addProperty("name", rs.getString("name"));
                     obj.addProperty("coefficient", rs.getDouble("salary_coefficient"));
                     arr.add(obj);
                 }
             }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return arr;
    }
}
