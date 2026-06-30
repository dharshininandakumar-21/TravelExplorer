<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.math.BigDecimal" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>My Bookings — TravelExplorer</title>
<script>
(function(){try{var t=localStorage.getItem('te-theme');if(t==='light')document.documentElement.setAttribute('data-theme','light');}catch(e){}})();
</script>
<link rel="stylesheet" href="css/style.css">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
<style>
@media(max-width:700px){
  .table-container table thead{display:none;}
  .table-container table tr{display:block;margin-bottom:14px;border:1px solid var(--border);border-radius:var(--radius-md);padding:14px;}
  .table-container table td{display:flex;justify-content:space-between;align-items:center;border:none;padding:7px 0;}
}
</style>
</head>
<body>
<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("userId") == null) { response.sendRedirect("login.html"); return; }
    String userName = (String) sess.getAttribute("userName");
    String success   = request.getParameter("success");
    String newBkId   = request.getParameter("booking_id");
    String cancelled = request.getParameter("cancelled");
    String reviewed  = request.getParameter("reviewed");
    List<HashMap<String,Object>> bookings = (List<HashMap<String,Object>>) request.getAttribute("bookings");
    if (bookings == null) bookings = new ArrayList<>();
%>

<div class="modal-overlay" id="reviewModal">
    <div class="modal-box">
        <h3><i class="fas fa-star" style="color:var(--accent);"></i> Rate Your Experience</h3>
        <form action="submit-review" method="post">
            <input type="hidden" name="package_id" id="reviewPkgId">
            <div class="star-row">
                <input type="radio" name="rating" id="s5" value="5"><label for="s5" title="Excellent">★</label>
                <input type="radio" name="rating" id="s4" value="4"><label for="s4" title="Good">★</label>
                <input type="radio" name="rating" id="s3" value="3"><label for="s3" title="Average">★</label>
                <input type="radio" name="rating" id="s2" value="2"><label for="s2" title="Poor">★</label>
                <input type="radio" name="rating" id="s1" value="1"><label for="s1" title="Very Poor">★</label>
            </div>
            <textarea name="comment" class="modal-textarea" rows="4" placeholder="Share your travel experience..."></textarea>
            <div class="modal-btns">
                <button type="submit" class="modal-submit">Submit Review</button>
                <button type="button" class="modal-cancel-btn" onclick="closeModal()">Cancel</button>
            </div>
        </form>
    </div>
</div>

<header>
  <div class="container header-content">
    <a href="index.html" class="logo"><i class="fas fa-globe-americas"></i> TravelExplorer</a>
    <nav id="mainNav">
      <a href="index.html"><i class="fas fa-home"></i> Home</a>
      <a href="destinations"><i class="fas fa-map-marked-alt"></i> Destinations</a>
      <a href="bookings" class="active"><i class="fas fa-suitcase"></i> My Bookings</a>
      <a href="contact.html"><i class="fas fa-envelope"></i> Contact</a>
      <a href="logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </nav>
    <div style="display:flex;align-items:center;gap:10px;">
      <span class="user-hello">Hi, <%= userName %></span>
      <div class="theme-toggle" id="themeToggle"><div class="theme-toggle-track"><div class="theme-toggle-thumb"><i class="theme-icon fas fa-moon"></i></div></div></div>
      <div class="hamburger" id="hamburger"><span></span><span></span><span></span></div>
    </div>
  </div>
</header>

<div class="booking-container">
    <div class="booking-header">
        <a href="destinations" class="back-btn"><i class="fas fa-arrow-left"></i> Back to Destinations</a>
        <h1>My Bookings</h1>
        <p>Manage your travel reservations</p>
    </div>

    <% if ("true".equals(success)) { %>
    <div class="alert-box alert-green">
        <i class="fas fa-check-circle" style="font-size:1.3rem;"></i>
        <div>
            <strong>Booking confirmed!</strong>
            <% if (newBkId != null) { %>
            &nbsp;&mdash;
            <a href="download-ticket?booking_id=<%= newBkId %>" class="btn-dl"><i class="fas fa-download"></i> Download Ticket</a>
            <% } %>
        </div>
    </div>
    <% } %>
    <% if ("true".equals(cancelled)) { %>
    <div class="alert-box alert-yellow"><i class="fas fa-info-circle"></i> Booking cancelled successfully.</div>
    <% } %>
    <% if ("true".equals(reviewed)) { %>
    <div class="alert-box alert-blue"><i class="fas fa-star"></i> Thank you for your review!</div>
    <% } %>

    <div class="table-container">
        <table>
            <thead>
                <tr><th>Package</th><th>Travelers</th><th>Travel Date</th><th>Amount</th><th>Status</th><th>Actions</th></tr>
            </thead>
            <tbody>
            <% if (bookings.isEmpty()) { %>
                <tr><td colspan="6">
                    <div class="no-bk-msg">
                        <i class="fas fa-suitcase-rolling"></i>
                        <h3>No bookings yet</h3>
                        <p>Start your journey by exploring our packages!</p>
                        <a href="destinations" class="btn">Explore Destinations</a>
                    </div>
                </td></tr>
            <% } else {
                for (HashMap<String,Object> b : bookings) {
                    String status = (String) b.get("status");
                    if (status == null) status = "confirmed";
                    if ("cancelled".equalsIgnoreCase(status)) continue;

                    int bid   = (Integer) b.get("id");
                    int pkgId = (Integer) b.get("package_id");
                    boolean isPaid      = "paid".equalsIgnoreCase(status);
                    boolean isConfirmed = "confirmed".equalsIgnoreCase(status);
                    boolean alreadyReviewed = Boolean.TRUE.equals(b.get("already_reviewed"));
                    String dur = (String) b.get("duration"); if (dur == null) dur = "";
                    Object img = b.get("image"); if (img == null) img = "goa.jpg";
            %>
            <tr>
                <td>
                    <div class="pkg-cell">
                        <img src="images/<%= img %>" alt="<%= b.get("title") %>" class="pkg-img"
                             onerror="this.src='https://placehold.co/76x52/141B3C/F5A623?text=Trip'">
                        <div class="pkg-cell-info">
                            <strong><%= b.get("title") %></strong>
                            <small><i class="fas fa-clock"></i> <%= dur %> &nbsp;|&nbsp; Booked: <%= b.get("created_at").toString().substring(0,10) %></small>
                        </div>
                    </div>
                </td>
                <td><%= b.get("travelers") %></td>
                <td><%= b.get("booking_date") != null ? b.get("booking_date") : "—" %></td>
                <td><strong>₹<%= b.get("total_amount") %></strong></td>
                <td><span class="status-badge status-<%= status.toLowerCase() %>"><%= status %></span></td>
                <td>
                    <div class="action-row">
                        <a href="download-ticket?booking_id=<%= bid %>" class="btn-dl"><i class="fas fa-download"></i> Ticket</a>
                        <% if (isConfirmed) { %>
                        <a href="payment.jsp?booking_id=<%= bid %>" class="btn-pay"><i class="fas fa-credit-card"></i> Pay</a>
                        <% } %>
                        <% if (isPaid && !alreadyReviewed) { %>
                        <button class="btn-review" onclick="openReview(<%= pkgId %>)"><i class="fas fa-star"></i> Review</button>
                        <% } %>
                        <% if (isConfirmed) { %>
                        <form action="cancel-booking" method="post" style="display:inline;">
                            <input type="hidden" name="booking_id" value="<%= bid %>">
                            <button type="submit" class="btn-cancel-bk" onclick="return confirm('Cancel this booking?')">
                                <i class="fas fa-times"></i> Cancel
                            </button>
                        </form>
                        <% } %>
                    </div>
                </td>
            </tr>
            <% } } %>
            </tbody>
        </table>
    </div>
</div>

<footer>
  <div class="container">
    <div class="footer-bottom">
      <p>&copy; 2025 Travel &amp; Tourism Management System. All rights reserved.</p>
    </div>
  </div>
</footer>

<script src="js/theme.js"></script>
<script>
function openReview(pkgId) {
    document.getElementById('reviewPkgId').value = pkgId;
    document.getElementById('reviewModal').classList.add('open');
}
function closeModal() { document.getElementById('reviewModal').classList.remove('open'); }
document.getElementById('reviewModal').addEventListener('click', function(e) { if (e.target === this) closeModal(); });
</script>
</body>
</html>
