package com.hrm.project.filter;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/** Đảm bảo toàn bộ request/response dùng UTF-8. */
public class EncodingFilter implements Filter {

    private String encoding = "UTF-8";

    @Override
    public void init(FilterConfig config) {
        String enc = config.getInitParameter("encoding");
        if (enc != null && !enc.isBlank()) encoding = enc;
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        request.setCharacterEncoding(encoding);
        response.setCharacterEncoding(encoding);
        ((HttpServletResponse) response).setHeader("Content-Type", "text/html; charset=UTF-8");
        chain.doFilter(request, response);
    }
}
