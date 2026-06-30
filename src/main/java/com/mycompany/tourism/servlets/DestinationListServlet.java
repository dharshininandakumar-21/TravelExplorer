package com.mycompany.tourism.servlets;

import com.mycompany.tourism.utils.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

public class DestinationListServlet extends HttpServlet {

    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String search   = req.getParameter("search");
        String minPrice = req.getParameter("minPrice");
        String maxPrice = req.getParameter("maxPrice");

        StringBuilder sql = new StringBuilder(
            "SELECT id, title, description, short_desc, price, image, duration " +
            "FROM packages WHERE 1=1");

        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (title LIKE ? OR description LIKE ? OR short_desc LIKE ?)");
            String like = "%" + search.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }
        if (minPrice != null && !minPrice.trim().isEmpty()) {
            sql.append(" AND price >= ?");
            params.add(Double.parseDouble(minPrice.trim()));
        }
        if (maxPrice != null && !maxPrice.trim().isEmpty()) {
            sql.append(" AND price <= ?");
            params.add(Double.parseDouble(maxPrice.trim()));
        }
        sql.append(" ORDER BY created_at DESC");

        List<HashMap<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    HashMap<String, Object> p = new HashMap<>();
                    p.put("id",          rs.getInt("id"));
                    p.put("title",       rs.getString("title"));
                    p.put("description", rs.getString("description"));
                    p.put("short_desc",  rs.getString("short_desc"));
                    p.put("price",       rs.getBigDecimal("price"));
                    p.put("image",       rs.getString("image"));
                    p.put("duration",    rs.getString("duration"));
                    list.add(p);
                }
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }

        req.setAttribute("packages", list);
        req.setAttribute("search",   search);
        req.setAttribute("minPrice", minPrice);
        req.setAttribute("maxPrice", maxPrice);
        req.getRequestDispatcher("destinations.jsp").forward(req, resp);
    }
}
