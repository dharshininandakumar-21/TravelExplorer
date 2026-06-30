package com.mycompany.tourism.servlets;

import com.mycompany.tourism.utils.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;

public class ReviewServlet extends HttpServlet {

    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("userId") == null) {
            resp.sendRedirect("login.html");
            return;
        }

        int userId    = (int) s.getAttribute("userId");
        int packageId = Integer.parseInt(req.getParameter("package_id"));
        int rating    = Integer.parseInt(req.getParameter("rating"));
        String comment = req.getParameter("comment");

        String sql = "INSERT INTO reviews (user_id, package_id, rating, comment) " +
                     "VALUES (?, ?, ?, ?) " +
                     "ON DUPLICATE KEY UPDATE rating=VALUES(rating), comment=VALUES(comment)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, packageId);
            ps.setInt(3, rating);
            ps.setString(4, comment);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new ServletException(e);
        }
        resp.sendRedirect("bookings?reviewed=true");
    }
}
