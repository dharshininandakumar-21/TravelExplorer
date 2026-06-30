package com.mycompany.tourism.servlets;
import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.sql.*;
import com.mycompany.tourism.utils.DBConnection;
import com.mycompany.tourism.utils.PasswordUtil;

public class RegisterServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        if (firstName == null || firstName.trim().isEmpty() ||
            lastName == null || lastName.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            showMessagePage(response, "Missing Information", "Please fill in all required fields.", false);
            return;
        }
        if (!password.equals(confirmPassword)) {
            showMessagePage(response, "Password Mismatch", "Your passwords do not match. Please try again.", false);
            return;
        }
        if (password.length() < 6) {
            showMessagePage(response, "Weak Password", "Password must be at least 6 characters long.", false);
            return;
        }

        String fullName = firstName.trim() + " " + lastName.trim();
        String hashedPassword = PasswordUtil.hashPassword(password);

        Connection con = null;
        try {
            con = DBConnection.getConnection();
            String checkSql = "SELECT id FROM users WHERE email = ?";
            PreparedStatement checkStmt = con.prepareStatement(checkSql);
            checkStmt.setString(1, email);
            ResultSet rs = checkStmt.executeQuery();
            if (rs.next()) {
                showMessagePage(response, "Account Exists", "A user with this email already exists. Please sign in instead.", false);
                return;
            }

            String insertSql = "INSERT INTO users(name, email, phone, password) VALUES(?, ?, ?, ?)";
            PreparedStatement ps = con.prepareStatement(insertSql);
            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, phone != null ? phone.trim() : null);
            ps.setString(4, hashedPassword);

            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                showMessagePage(response, "Welcome Aboard!", "Your account has been created successfully. You can now sign in and start exploring.", true);
            } else {
                showMessagePage(response, "Registration Failed", "Something went wrong. Please try again.", false);
            }

        } catch (SQLException e) {
            e.printStackTrace();
            String msg = e.getMessage();
            if (msg != null && msg.contains("Duplicate entry")) {
                showMessagePage(response, "Account Exists", "A user with this email already exists. Please sign in instead.", false);
            } else if (msg != null && msg.contains("Unknown column 'phone'")) {
                showMessagePage(response, "Setup Incomplete", "Database setup incomplete. Run: ALTER TABLE users ADD COLUMN phone VARCHAR(20) AFTER email;", false);
            } else if (msg != null && (msg.contains("Access denied") || msg.contains("Unknown database"))) {
                showMessagePage(response, "Connection Error", "Cannot connect to the database. Check that MySQL is running and credentials in context.xml are correct.", false);
            } else {
                showMessagePage(response, "Registration Failed", "A database error occurred. Please try again later.", false);
            }
        } finally {
            if (con != null) {
                try { con.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
    }

    private void showMessagePage(HttpServletResponse response, String title, String message, boolean success)
            throws IOException {
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        String icon  = success ? "fa-circle-check" : "fa-circle-exclamation";
        String color = success ? "var(--success)" : "var(--error)";
        String bg     = success ? "var(--success-soft)" : "var(--error-soft)";
        out.println("<!DOCTYPE html>");
        out.println("<html lang=\"en\"><head><meta charset=\"UTF-8\">");
        out.println("<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">");
        out.println("<title>" + title + " — TravelExplorer</title>");
        out.println("<script>(function(){try{var t=localStorage.getItem('te-theme');if(t==='light')document.documentElement.setAttribute('data-theme','light');}catch(e){}})();</script>");
        out.println("<link rel=\"stylesheet\" href=\"css/style.css\">");
        out.println("<link href=\"https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css\" rel=\"stylesheet\">");
        out.println("</head><body>");
        out.println("<div class=\"auth-container\">");
        out.println("<div class=\"auth-card anim\" style=\"text-align:center;\">");
        out.println("<div style=\"width:84px;height:84px;background:" + bg + ";border-radius:50%;display:flex;align-items:center;justify-content:center;margin:0 auto 24px;\">");
        out.println("<i class=\"fas " + icon + "\" style=\"font-size:2.4rem;color:" + color + ";\"></i>");
        out.println("</div>");
        out.println("<h2 style=\"font-family:var(--font-display);color:var(--text-primary);margin-bottom:12px;\">" + title + "</h2>");
        out.println("<p style=\"color:var(--text-secondary);margin-bottom:28px;line-height:1.6;\">" + message + "</p>");
        if (success) {
            out.println("<a href=\"login.html\" class=\"btn-auth\" style=\"text-decoration:none;\"><i class=\"fas fa-sign-in-alt\"></i> Go to Login</a>");
        } else {
            out.println("<div style=\"display:flex;gap:12px;\">");
            out.println("<a href=\"register.html\" class=\"btn-auth\" style=\"text-decoration:none;flex:1;\"><i class=\"fas fa-rotate-left\"></i> Try Again</a>");
            out.println("<a href=\"login.html\" class=\"btn-ghost btn\" style=\"text-decoration:none;flex:1;justify-content:center;\">Sign In</a>");
            out.println("</div>");
        }
        out.println("</div></div>");
        out.println("</body></html>");
    }
}
