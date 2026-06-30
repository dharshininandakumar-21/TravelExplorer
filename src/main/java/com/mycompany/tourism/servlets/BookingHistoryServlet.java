package com.mycompany.tourism.servlets;

import com.mycompany.tourism.utils.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

public class BookingHistoryServlet extends HttpServlet {

    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("userId") == null) {
            resp.sendRedirect("login.html");
            return;
        }

        int userId = (int) s.getAttribute("userId");

        // Left join reviews so we know if user already reviewed this package
        String sql =
            "SELECT b.id, b.travelers, b.booking_date, b.total_amount, b.status, b.created_at, " +
            "p.id AS package_id, p.title, p.image, p.duration " +
            "FROM bookings b " +
            "JOIN packages p ON b.package_id = p.id " +
            "WHERE b.user_id = ? " +
            "ORDER BY b.created_at DESC";

        // Separately fetch which package_ids the user already reviewed
        Set<Integer> reviewed = new HashSet<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps2 = conn.prepareStatement(
                 "SELECT package_id FROM reviews WHERE user_id = ?")) {
            ps2.setInt(1, userId);
            ResultSet r2 = ps2.executeQuery();
            while (r2.next()) reviewed.add(r2.getInt("package_id"));
        } catch (SQLException ex) {
            // reviews table may not exist yet — ignore
        }

        List<HashMap<String, Object>> bookings = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    HashMap<String, Object> m = new HashMap<>();
                    int pkgId = rs.getInt("package_id");
                    m.put("id",           rs.getInt("id"));
                    m.put("package_id",   pkgId);
                    m.put("travelers",    rs.getInt("travelers"));
                    m.put("booking_date", rs.getDate("booking_date"));
                    m.put("total_amount", rs.getBigDecimal("total_amount"));
                    m.put("status",       rs.getString("status"));
                    m.put("created_at",   rs.getTimestamp("created_at"));
                    m.put("title",        rs.getString("title"));
                    m.put("image",        rs.getString("image"));
                    m.put("duration",     rs.getString("duration"));
                    m.put("already_reviewed", reviewed.contains(pkgId));
                    bookings.add(m);
                }
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }

        req.setAttribute("bookings", bookings);
        req.getRequestDispatcher("bookings.jsp").forward(req, resp);
    }
}
