package com.hrm.project.controller.common;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.net.URLDecoder;
import java.nio.file.Files;

@WebServlet(name = "FileServlet", urlPatterns = {"/uploads/*"})
public class FileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get requested file path after /uploads/
        String requestURI = request.getRequestURI();
        String contextPath = request.getContextPath();
        String relativePath = requestURI.substring(contextPath.length()); // e.g., /uploads/contracts/file.jpg
        relativePath = URLDecoder.decode(relativePath, "UTF-8");

        // Locate the file in the deployed webapp folder
        String appPath = getServletContext().getRealPath("");
        File file = new File(appPath + relativePath);

        // Fallback: If not found in deployed folder, check in the source workspace webapp folder (crucial for IDE runs)
        if (!file.exists()) {
            // Source fallback path
            String srcFallbackPath = "d:\\FU_Document\\SWP\\TestSWP\\src\\main\\webapp" + relativePath.replace("/", File.separator);
            file = new File(srcFallbackPath);
        }

        if (!file.exists() || file.isDirectory()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "File not found: " + relativePath);
            return;
        }

        // Get content type based on file extension
        String contentType = getServletContext().getMimeType(file.getName());
        if (contentType == null) {
            contentType = "application/octet-stream";
        }

        response.reset();
        response.setContentType(contentType);
        response.setHeader("Content-Length", String.valueOf(file.length()));
        // For PDFs/Images, show inline in the browser instead of forcing download
        response.setHeader("Content-Disposition", "inline; filename=\"" + file.getName() + "\"");

        // Stream the file back to client
        try (FileInputStream in = new FileInputStream(file);
             OutputStream out = response.getOutputStream()) {
            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = in.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }
        }
    }
}
