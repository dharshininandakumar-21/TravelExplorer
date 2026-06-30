package com.mycompany.tourism.servlets;

import com.mycompany.tourism.utils.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.*;

public class BookingServlet extends HttpServlet {

    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("userId") == null) {
            resp.sendRedirect("login.html");
            return;
        }

        int userId    = (int) s.getAttribute("userId");
        int packageId = Integer.parseInt(req.getParameter("package_id"));
        int travelers = Integer.parseInt(req.getParameter("travelers"));
        String dateStr = req.getParameter("booking_date");
        BigDecimal price = new BigDecimal(req.getParameter("price"));
        BigDecimal total  = price.multiply(new BigDecimal(travelers));

        Date bookingDate = null;
        if (dateStr != null && !dateStr.isEmpty()) {
            bookingDate = Date.valueOf(dateStr);
        }

        String sql = "INSERT INTO bookings (user_id, package_id, travelers, booking_date, " +
                     "total_amount, status, created_at) VALUES (?, ?, ?, ?, ?, 'confirmed', NOW())";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, userId);
            ps.setInt(2, packageId);
            ps.setInt(3, travelers);
            ps.setDate(4, bookingDate);
            ps.setBigDecimal(5, total);
            ps.executeUpdate();

            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) {
                resp.sendRedirect("bookings?success=true&booking_id=" + keys.getInt(1));
            } else {
                resp.sendRedirect("bookings?success=true");
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
