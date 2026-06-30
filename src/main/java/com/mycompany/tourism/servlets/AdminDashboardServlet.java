package com.mycompany.tourism.servlets;

import com.mycompany.tourism.utils.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

public class AdminDashboardServlet extends HttpServlet {

    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("isAdmin") == null
                || !(Boolean) s.getAttribute("isAdmin")) {
            resp.sendRedirect("login.html");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {

            // ---- Packages (columns that actually exist) ----
            List<HashMap<String, Object>> packages = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT id, title, price, duration, created_at FROM packages ORDER BY created_at DESC");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    HashMap<String, Object> p = new HashMap<>();
                    p.put("id",         rs.getInt("id"));
                    p.put("title",      rs.getString("title"));
                    p.put("price",      rs.getBigDecimal("price"));
                    p.put("duration",   rs.getString("duration"));
                    p.put("created_at", rs.getTimestamp("created_at"));
                    packages.add(p);
                }
            }
            req.setAttribute("packages", packages);

            // ---- Bookings ----
            List<HashMap<String, Object>> bookings = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT b.id, b.travelers, b.booking_date, b.total_amount, b.status, " +
                    "b.created_at, u.name AS user_name, u.email, p.title AS pkg_title " +
                    "FROM bookings b " +
                    "JOIN users u ON b.user_id = u.id " +
                    "JOIN packages p ON b.package_id = p.id " +
                    "ORDER BY b.created_at DESC LIMIT 50");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    HashMap<String, Object> b = new HashMap<>();
                    b.put("id",           rs.getInt("id"));
                    b.put("user_name",    rs.getString("user_name"));
                    b.put("email",        rs.getString("email"));
                    b.put("pkg_title",    rs.getString("pkg_title"));
                    b.put("travelers",    rs.getInt("travelers"));
                    b.put("booking_date", rs.getDate("booking_date"));
                    b.put("total_amount", rs.getBigDecimal("total_amount"));
                    b.put("status",       rs.getString("status"));
                    b.put("created_at",   rs.getTimestamp("created_at"));
                    bookings.add(b);
                }
            }
            req.setAttribute("bookings", bookings);

            // ---- Users ----
            List<HashMap<String, Object>> users = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT id, name, email, phone, is_admin, created_at FROM users ORDER BY created_at DESC");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    HashMap<String, Object> u = new HashMap<>();
                    u.put("id",         rs.getInt("id"));
                    u.put("name",       rs.getString("name"));
                    u.put("email",      rs.getString("email"));
                    u.put("phone",      rs.getString("phone"));
                    u.put("is_admin",   rs.getBoolean("is_admin"));
                    u.put("created_at", rs.getTimestamp("created_at"));
                    users.add(u);
                }
            }
            req.setAttribute("users", users);

            // ---- Reviews ----
            List<HashMap<String, Object>> reviews = new ArrayList<>();
            // reviews table may not exist yet — catch gracefully
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT r.id, r.rating, r.comment, r.created_at, " +
                    "u.name AS user_name, p.title AS pkg_title " +
                    "FROM reviews r " +
                    "JOIN users u ON r.user_id = u.id " +
                    "JOIN packages p ON r.package_id = p.id " +
                    "ORDER BY r.created_at DESC LIMIT 30");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    HashMap<String, Object> rv = new HashMap<>();
                    rv.put("id",         rs.getInt("id"));
                    rv.put("user_name",  rs.getString("user_name"));
                    rv.put("pkg_title",  rs.getString("pkg_title"));
                    rv.put("rating",     rs.getInt("rating"));
                    rv.put("comment",    rs.getString("comment"));
                    rv.put("created_at", rs.getTimestamp("created_at"));
                    reviews.add(rv);
                }
            } catch (SQLException ex) {
                // reviews table may not exist — ignore, show empty list
            }
            req.setAttribute("reviews", reviews);

            // ---- Contact messages — table name is 'contacts' ----
            List<HashMap<String, Object>> contacts = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT id, name, email, subject, message, created_at " +
                    "FROM contacts ORDER BY created_at DESC LIMIT 20");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    HashMap<String, Object> c = new HashMap<>();
                    c.put("id",         rs.getInt("id"));
                    c.put("name",       rs.getString("name"));
                    c.put("email",      rs.getString("email"));
                    c.put("subject",    rs.getString("subject"));
                    c.put("message",    rs.getString("message"));
                    c.put("created_at", rs.getTimestamp("created_at"));
                    contacts.add(c);
                }
            }
            req.setAttribute("contacts", contacts);

            // ---- Summary stats ----
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) AS total_bookings, " +
                    "COALESCE(SUM(total_amount), 0) AS total_revenue, " +
                    "COALESCE(SUM(CASE WHEN status='paid' THEN total_amount ELSE 0 END), 0) AS paid_revenue " +
                    "FROM bookings WHERE status != 'cancelled'");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    req.setAttribute("totalBookings", rs.getInt("total_bookings"));
                    req.setAttribute("totalRevenue",  rs.getBigDecimal("total_revenue"));
                    req.setAttribute("paidRevenue",   rs.getBigDecimal("paid_revenue"));
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) AS cnt FROM users WHERE is_admin = FALSE");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) req.setAttribute("totalUsers", rs.getInt("cnt"));
            }

            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) AS cnt FROM packages");
                 ResultSet rs = ps.executeQuery()) {
                if (rs.next()) req.setAttribute("totalPackages", rs.getInt("cnt"));
            }

            // ---- Monthly revenue for Chart.js ----
            List<String> chartMonths   = new ArrayList<>();
            List<Double> chartRevenues = new ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT DATE_FORMAT(created_at,'%b %Y') AS month, " +
                    "COALESCE(SUM(total_amount), 0) AS revenue " +
                    "FROM bookings " +
                    "WHERE status != 'cancelled' " +
                    "AND created_at >= DATE_SUB(NOW(), INTERVAL 6 MONTH) " +
                    "GROUP BY DATE_FORMAT(created_at,'%Y-%m') " +
                    "ORDER BY MIN(created_at)");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    chartMonths.add(rs.getString("month"));
                    chartRevenues.add(rs.getDouble("revenue"));
                }
            }
            req.setAttribute("chartMonths",   chartMonths);
            req.setAttribute("chartRevenues", chartRevenues);

        } catch (SQLException e) {
            throw new ServletException(e);
        }

        req.getRequestDispatcher("admin-dashboard.jsp").forward(req, resp);
    }

    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession s = req.getSession(false);
        if (s == null || !(Boolean) s.getAttribute("isAdmin")) {
            resp.sendRedirect("login.html");
            return;
        }

        String action = req.getParameter("action");

        if ("delete_package".equals(action)) {
            int pid = Integer.parseInt(req.getParameter("package_id"));
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(
                         "DELETE FROM packages WHERE id = ?")) {
                ps.setInt(1, pid);
                ps.executeUpdate();
            } catch (SQLException e) {
                throw new ServletException(e);
            }

        } else if ("update_booking_status".equals(action)) {
            int bid   = Integer.parseInt(req.getParameter("booking_id"));
            String st = req.getParameter("status");
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(
                         "UPDATE bookings SET status = ? WHERE id = ?")) {
                ps.setString(1, st);
                ps.setInt(2, bid);
                ps.executeUpdate();
            } catch (SQLException e) {
                throw new ServletException(e);
            }
        }

        resp.sendRedirect("admin-dashboard");
    }
}
