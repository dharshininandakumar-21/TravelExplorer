package com.mycompany.tourism.servlets;
import com.mycompany.tourism.utils.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
public class CancelBookingServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("userId") == null) {
            resp.sendRedirect("login.html");
            return;
        }
        int bookingId = Integer.parseInt(req.getParameter("booking_id"));
        int userId = (int) s.getAttribute("userId");
        String sql = "UPDATE bookings SET status = 'cancelled' WHERE id = ? AND user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookingId);
            ps.setInt(2, userId);
            int rowsAffected = ps.executeUpdate();       
            if (rowsAffected > 0) {
                resp.sendRedirect("bookings?cancelled=true");
            } else {
                resp.sendRedirect("bookings?error=cancel_failed");
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}