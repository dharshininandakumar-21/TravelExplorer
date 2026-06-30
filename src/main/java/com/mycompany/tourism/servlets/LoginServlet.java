package com.mycompany.tourism.servlets;

import com.mycompany.tourism.utils.DBConnection;
import com.mycompany.tourism.utils.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String usernameOrEmail = req.getParameter("email");
        String password        = req.getParameter("password");
        String hash            = PasswordUtil.hashPassword(password);

        String sql = "SELECT id, name, email, is_admin " +
                     "FROM users WHERE (name=? OR email=?) AND password=?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, usernameOrEmail);
            ps.setString(2, usernameOrEmail);
            ps.setString(3, hash);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                HttpSession session = req.getSession(true);
                session.setAttribute("userId",   rs.getInt("id"));
                session.setAttribute("userName", rs.getString("name"));
                session.setAttribute("email",    rs.getString("email"));
                session.setAttribute("isAdmin",  rs.getBoolean("is_admin"));

                if (rs.getBoolean("is_admin")) {
                    resp.sendRedirect("admin-dashboard");
                } else {
                    resp.sendRedirect("destinations");
                }
            } else {
                // Redirect back to login with error flag
                resp.sendRedirect("login.html?error=1");
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
}
