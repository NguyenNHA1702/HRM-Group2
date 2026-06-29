package com.hrm.project.controller.payroll;

import com.hrm.project.dao.PayrollDAO;
import com.hrm.project.dao.impl.PayrollDAOImpl;
import com.hrm.project.model.PayrollDetail;
import com.lowagie.text.Document;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.FontFactory;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.pdf.BaseFont;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.OutputStream;
import java.text.DecimalFormat;

@WebServlet(name = "ExportPayslipPdfController", urlPatterns = {"/luong/export-pdf"})
public class ExportPayslipPdfController extends HttpServlet {
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

        Integer sessionEmployeeId = (Integer) session.getAttribute("employeeId");

        String idParam = request.getParameter("detailId");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu detailId.");
            return;
        }

        int detailId;
        try {
            detailId = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "detailId không hợp lệ.");
            return;
        }

        PayrollDetail detail = payrollDAO.getPayrollDetailById(detailId);
        if (detail == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Không tìm thấy chi tiết bảng lương.");
            return;
        }

        // Ownership check
        if (detail.getEmployeeId() != sessionEmployeeId) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền tải phiếu lương của người khác.");
            return;
        }

        // Status check
        if (!"APPROVED".equals(detail.getStatus()) && !"PAID".equals(detail.getStatus())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chỉ được phép tải phiếu lương đã được duyệt (APPROVED) hoặc đã thanh toán (PAID).");
            return;
        }

        response.setContentType("application/pdf");
        String filename = "payslip_" + detail.getEmployeeCode() + "_" + detail.getMonth() + "_" + detail.getYear() + ".pdf";
        response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

        try (OutputStream out = response.getOutputStream()) {
            Document document = new Document();
            PdfWriter.getInstance(document, out);
            document.open();

            // Font setup for Vietnamese Unicode
            FontFactory.registerDirectories();
            Font titleFont = FontFactory.getFont("Arial", BaseFont.IDENTITY_H, BaseFont.EMBEDDED, 18, Font.BOLD);
            if (titleFont == null || titleFont.getBaseFont() == null) {
                // Fallback if Arial not found on OS
                titleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18);
            }
            Font normalFont = FontFactory.getFont("Arial", BaseFont.IDENTITY_H, BaseFont.EMBEDDED, 12, Font.NORMAL);
            if (normalFont == null || normalFont.getBaseFont() == null) {
                normalFont = FontFactory.getFont(FontFactory.HELVETICA, 12);
            }
            Font boldFont = FontFactory.getFont("Arial", BaseFont.IDENTITY_H, BaseFont.EMBEDDED, 12, Font.BOLD);
            if (boldFont == null || boldFont.getBaseFont() == null) {
                boldFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12);
            }

            Paragraph title = new Paragraph("PHIẾU LƯƠNG NHÂN VIÊN", titleFont);
            title.setAlignment(Element.ALIGN_CENTER);
            title.setSpacingAfter(20);
            document.add(title);

            PdfPTable table = new PdfPTable(2);
            table.setWidthPercentage(100);
            table.setSpacingBefore(10f);
            table.setSpacingAfter(10f);

            DecimalFormat df = new DecimalFormat("#,##0");

            addTableRow(table, "Mã nhân viên (Employee Code):", detail.getEmployeeCode() != null ? detail.getEmployeeCode() : "N/A", normalFont, boldFont);
            addTableRow(table, "Họ tên (Full Name):", detail.getEmployeeName() != null ? detail.getEmployeeName() : "N/A", normalFont, boldFont);
            addTableRow(table, "Tháng lương (Payroll Month):", detail.getMonth() + "/" + detail.getYear(), normalFont, boldFont);
            addTableRow(table, "Tổng giờ/ngày công (Working Hours/Days):", "N/A", normalFont, boldFont);
            addTableRow(table, "Lương cơ bản (Basic Salary):", df.format(detail.getBasicSalary()) + " VNĐ", normalFont, normalFont);
            addTableRow(table, "Tổng phụ cấp (Allowance):", df.format(detail.getAllowanceAmount()) + " VNĐ", normalFont, normalFont);
            addTableRow(table, "Tổng tăng ca (Overtime):", "N/A", normalFont, normalFont);
            
            double deductions = detail.getInsuranceDeduction() + detail.getUnpaidLeaveDeduction() + detail.getTaxDeduction();
            addTableRow(table, "Tổng khấu trừ (Deductions):", df.format(deductions) + " VNĐ", normalFont, normalFont);
            addTableRow(table, "Thực lĩnh (Net Salary):", df.format(detail.getNetSalary()) + " VNĐ", normalFont, boldFont);
            addTableRow(table, "Trạng thái (Status):", detail.getStatus(), normalFont, boldFont);

            document.add(table);
            document.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void addTableRow(PdfPTable table, String label, String value, Font labelFont, Font valueFont) {
        PdfPCell cell1 = new PdfPCell(new Phrase(label, labelFont));
        cell1.setBorder(PdfPCell.NO_BORDER);
        cell1.setPadding(5);
        table.addCell(cell1);

        PdfPCell cell2 = new PdfPCell(new Phrase(value, valueFont));
        cell2.setBorder(PdfPCell.NO_BORDER);
        cell2.setPadding(5);
        cell2.setHorizontalAlignment(Element.ALIGN_RIGHT);
        table.addCell(cell2);
    }
}
