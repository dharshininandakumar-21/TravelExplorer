package com.mycompany.tourism.servlets;

import com.mycompany.tourism.utils.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

public class ProcessPaymentServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String bookingId = req.getParameter("booking_id");
        if (bookingId == null) {
            resp.sendRedirect("bookings");
            return;
        }

        try (Connection con = DBConnection.getConnection()) {
            PreparedStatement ps = con.prepareStatement(
                "UPDATE bookings SET status='paid' WHERE id=?"
            );
            ps.setInt(1, Integer.parseInt(bookingId));
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new ServletException(e);
        }

        resp.sendRedirect("payment-success.jsp");
    }
}
