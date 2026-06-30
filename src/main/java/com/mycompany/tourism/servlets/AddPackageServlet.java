package com.mycompany.tourism.servlets;

import com.mycompany.tourism.utils.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.*;

public class AddPackageServlet extends HttpServlet {

    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("isAdmin") == null
                || !(Boolean) s.getAttribute("isAdmin")) {
            resp.sendRedirect("login.html");
            return;
        }

        String title       = req.getParameter("title");
        String description = req.getParameter("description");
        String priceStr    = req.getParameter("price");
        String image       = req.getParameter("image");
        String duration    = req.getParameter("duration");
        String shortDesc   = req.getParameter("short_desc");

        if (shortDesc == null || shortDesc.trim().isEmpty()) {
            shortDesc = title; // fallback
        }
        if (image == null || image.trim().isEmpty()) {
            image = "goa.jpg"; // fallback placeholder
        }

        // duration stored as text e.g. "5 Days, 4 Nights"
        String sql = "INSERT INTO packages (title, description, price, image, short_desc, duration) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, title);
            ps.setString(2, description);
            ps.setBigDecimal(3, new BigDecimal(priceStr));
            ps.setString(4, image);
            ps.setString(5, shortDesc);
            ps.setString(6, duration != null && !duration.trim().isEmpty() ? duration : "N/A");
            ps.executeUpdate();
            resp.sendRedirect("admin-dashboard?added=1");
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
