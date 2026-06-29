package com.hrm.project.controller.payroll;

import com.hrm.project.dao.PayrollDAO;
import com.hrm.project.dao.impl.PayrollDAOImpl;
import com.hrm.project.model.Payroll;
import com.hrm.project.model.PayrollDetail;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.OutputStream;
import java.util.List;

@WebServlet(name = "ExportPayrollExcelController", urlPatterns = {"/admin/payroll/export-excel"})
public class ExportPayrollExcelController extends HttpServlet {
    private PayrollDAO payrollDAO;

    @Override
    public void init() throws ServletException {
        payrollDAO = new PayrollDAOImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("employeeId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String roleGroup = (String) session.getAttribute("roleGroup");
        if (!"ADMIN".equals(roleGroup) && !"HR".equals(roleGroup)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền export bảng lương.");
            return;
        }

        String idParam = request.getParameter("payrollId");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu payrollId.");
            return;
        }

        int payrollId;
        try {
            payrollId = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "payrollId không hợp lệ.");
            return;
        }

        Payroll payroll = payrollDAO.getPayrollById(payrollId);
        if (payroll == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy bảng lương.");
            return;
        }

        List<PayrollDetail> details = payrollDAO.getPayrollDetails(payrollId);

        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        String filename = "payroll_" + payroll.getMonth() + "_" + payroll.getYear() + ".xlsx";
        response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

        try (Workbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Payroll");

            // Header row
            Row headerRow = sheet.createRow(0);
            String[] columns = {
                    "Employee Code", "Full Name", "Department", "Basic Salary",
                    "Total Allowance", "Overtime Amount", "Insurance Deduction",
                    "Unpaid Leave Deduction", "Tax Amount", "Net Salary", "Status"
            };

            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);

            for (int i = 0; i < columns.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(columns[i]);
                cell.setCellStyle(headerStyle);
            }

            // Data rows
            int rowNum = 1;
            for (PayrollDetail d : details) {
                Row row = sheet.createRow(rowNum++);
                row.createCell(0).setCellValue(d.getEmployeeCode() != null ? d.getEmployeeCode() : "");
                row.createCell(1).setCellValue(d.getEmployeeName() != null ? d.getEmployeeName() : "");
                row.createCell(2).setCellValue(d.getDepartmentName() != null ? d.getDepartmentName() : "");
                row.createCell(3).setCellValue(d.getBasicSalary());
                row.createCell(4).setCellValue(d.getAllowanceAmount());
                row.createCell(5).setCellValue("N/A"); // Overtime not supported yet
                row.createCell(6).setCellValue(d.getInsuranceDeduction());
                row.createCell(7).setCellValue(d.getUnpaidLeaveDeduction());
                row.createCell(8).setCellValue(d.getTaxDeduction());
                row.createCell(9).setCellValue(d.getNetSalary());
                row.createCell(10).setCellValue(payroll.getStatus());
            }

            // Auto-size columns
            for (int i = 0; i < columns.length; i++) {
                sheet.autoSizeColumn(i);
            }

            try (OutputStream out = response.getOutputStream()) {
                workbook.write(out);
            }
        } catch (Exception e) {
            e.printStackTrace();
            if (!response.isCommitted()) {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi khi tạo file Excel.");
            }
        }
    }
}
