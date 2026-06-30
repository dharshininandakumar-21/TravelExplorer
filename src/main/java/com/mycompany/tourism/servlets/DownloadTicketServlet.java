package com.mycompany.tourism.servlets;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import com.mycompany.tourism.utils.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.*;

public class DownloadTicketServlet extends HttpServlet {

    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession s = req.getSession(false);
        if (s == null || s.getAttribute("userId") == null) {
            resp.sendRedirect("login.html");
            return;
        }

        int userId = (int) s.getAttribute("userId");
        String bookingIdStr = req.getParameter("booking_id");
        if (bookingIdStr == null) {
            resp.sendRedirect("bookings");
            return;
        }
        int bookingId = Integer.parseInt(bookingIdStr);

        // Use only columns that exist in the real schema
        String sql =
            "SELECT b.id, b.travelers, b.booking_date, b.total_amount, b.status, b.created_at, " +
            "p.title, p.description, p.duration, " +
            "u.name, u.email, u.phone " +
            "FROM bookings b " +
            "JOIN packages p ON b.package_id = p.id " +
            "JOIN users u ON b.user_id = u.id " +
            "WHERE b.id = ? AND b.user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, bookingId);
            ps.setInt(2, userId);
            ResultSet rs = ps.executeQuery();

            if (!rs.next()) {
                resp.sendRedirect("bookings");
                return;
            }

            resp.setContentType("application/pdf");
            resp.setHeader("Content-Disposition",
                    "attachment; filename=TravelTicket_" + bookingId + ".pdf");

            Document doc = new Document(PageSize.A4);
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            PdfWriter.getInstance(doc, baos);
            doc.open();

            // Fonts
            Font titleFont  = new Font(Font.FontFamily.HELVETICA, 22, Font.BOLD,   new BaseColor(75,  0, 130));
            Font headFont   = new Font(Font.FontFamily.HELVETICA, 13, Font.BOLD,   BaseColor.WHITE);
            Font labelFont  = new Font(Font.FontFamily.HELVETICA, 11, Font.BOLD,   new BaseColor(50,  50, 50));
            Font valueFont  = new Font(Font.FontFamily.HELVETICA, 11, Font.NORMAL, new BaseColor(30,  30, 30));
            Font footFont   = new Font(Font.FontFamily.HELVETICA,  9, Font.ITALIC, BaseColor.GRAY);

            // Banner
            PdfPTable banner = new PdfPTable(1);
            banner.setWidthPercentage(100);
            PdfPCell bc = new PdfPCell(new Phrase("✈  TravelExplorer — Booking Confirmation", titleFont));
            bc.setBackgroundColor(new BaseColor(238, 228, 255));
            bc.setPadding(18); bc.setBorder(Rectangle.NO_BORDER);
            bc.setHorizontalAlignment(Element.ALIGN_CENTER);
            banner.addCell(bc);
            doc.add(banner);
            doc.add(Chunk.NEWLINE);

            // ID Badge
            PdfPTable badge = new PdfPTable(1);
            badge.setWidthPercentage(35);
            badge.setHorizontalAlignment(Element.ALIGN_CENTER);
            PdfPCell idCell = new PdfPCell(new Phrase("Booking ID: #" + rs.getInt("id"), headFont));
            idCell.setBackgroundColor(new BaseColor(75, 0, 130));
            idCell.setPadding(9); idCell.setBorder(Rectangle.NO_BORDER);
            idCell.setHorizontalAlignment(Element.ALIGN_CENTER);
            badge.addCell(idCell);
            doc.add(badge);
            doc.add(Chunk.NEWLINE);

            // Details table
            PdfPTable details = new PdfPTable(2);
            details.setWidthPercentage(100);
            details.setWidths(new float[]{35f, 65f});
            details.setSpacingBefore(10);

            addRow(details, "Package",         rs.getString("title"),          labelFont, valueFont);
            addRow(details, "Description",     rs.getString("description"),    labelFont, valueFont);
            addRow(details, "Duration",        rs.getString("duration") != null ? rs.getString("duration") : "N/A", labelFont, valueFont);
            addRow(details, "Traveler Name",   rs.getString("name"),           labelFont, valueFont);
            addRow(details, "Email",           rs.getString("email"),          labelFont, valueFont);
            addRow(details, "Phone",           rs.getString("phone") != null ? rs.getString("phone") : "N/A", labelFont, valueFont);
            addRow(details, "No. of Travelers",String.valueOf(rs.getInt("travelers")), labelFont, valueFont);
            Date bd = rs.getDate("booking_date");
            addRow(details, "Travel Date",     bd != null ? bd.toString() : "N/A", labelFont, valueFont);
            addRow(details, "Booking Date",    rs.getTimestamp("created_at").toString().substring(0, 19), labelFont, valueFont);
            addRow(details, "Total Amount",    "Rs. " + rs.getBigDecimal("total_amount"), labelFont, valueFont);
            String status = rs.getString("status");
            addRow(details, "Status",          status != null ? status.toUpperCase() : "CONFIRMED", labelFont, valueFont);
            doc.add(details);
            doc.add(Chunk.NEWLINE);

            // Footer
            PdfPTable footer = new PdfPTable(1);
            footer.setWidthPercentage(100);
            PdfPCell fc = new PdfPCell(new Phrase(
                "Thank you for choosing TravelExplorer! " +
                "Support: support@travelexplorer.com | +91 98765 43210", footFont));
            fc.setBorder(Rectangle.TOP);
            fc.setPadding(10);
            fc.setHorizontalAlignment(Element.ALIGN_CENTER);
            footer.addCell(fc);
            doc.add(footer);

            doc.close();
            resp.getOutputStream().write(baos.toByteArray());

        } catch (DocumentException | SQLException e) {
            throw new ServletException(e);
        }
    }

    private void addRow(PdfPTable t, String label, String value, Font lf, Font vf) {
        BaseColor bg   = new BaseColor(245, 240, 255);
        BaseColor bdr  = new BaseColor(200, 190, 220);
        PdfPCell lc = new PdfPCell(new Phrase(label, lf));
        lc.setBackgroundColor(bg); lc.setPadding(8); lc.setBorderColor(bdr);
        PdfPCell vc = new PdfPCell(new Phrase(value != null ? value : "", vf));
        vc.setPadding(8); vc.setBorderColor(bdr);
        t.addCell(lc); t.addCell(vc);
    }
}
