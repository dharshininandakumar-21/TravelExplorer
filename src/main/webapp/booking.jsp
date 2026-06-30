<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.mycompany.tourism.utils.DBConnection, java.math.BigDecimal" %>
<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("userId") == null) {
        response.sendRedirect("login.html"); return;
    }
    String userName = (String) sess.getAttribute("userName");

    String idParam = request.getParameter("id");
    if (idParam == null) { response.sendRedirect("destinations"); return; }
    int packageId = Integer.parseInt(idParam);

    String    pkgTitle = "", pkgDesc = "", pkgImage = "", pkgDuration = "";
    BigDecimal pkgPrice = BigDecimal.ZERO;

    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(
             "SELECT id, title, description, price, image, duration FROM packages WHERE id=?")) {
        ps.setInt(1, packageId);
        ResultSet rs = ps.executeQuery();
        if (!rs.next()) { response.sendRedirect("destinations"); return; }
        pkgTitle    = rs.getString("title");
        pkgDesc     = rs.getString("description");
        pkgImage    = rs.getString("image");
        pkgPrice    = rs.getBigDecimal("price");
        pkgDuration = rs.getString("duration"); if (pkgDuration == null) pkgDuration = "";
    } catch (Exception e) { throw new jakarta.servlet.ServletException(e); }

    String minDate = java.time.LocalDate.now().plusDays(1).toString();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Book <%= pkgTitle %> — TravelExplorer</title>
<script>
(function(){try{var t=localStorage.getItem('te-theme');if(t==='light')document.documentElement.setAttribute('data-theme','light');}catch(e){}})();
</script>
<link rel="stylesheet" href="css/style.css">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
<style>
.bk-grid{display:grid;grid-template-columns:1fr 1.5fr;gap:28px;align-items:start;max-width:920px;margin:0 auto;}
.pkg-summary{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-lg);overflow:hidden;box-shadow:var(--shadow-sm);}
.pkg-summary img{width:100%;height:220px;object-fit:cover;}
.pkg-summary-body{padding:24px;}
.pkg-summary-body h2{font-family:var(--font-display);color:var(--text-primary);margin-bottom:8px;font-size:1.3rem;}
.price-tag{font-family:var(--font-display);font-size:1.9rem;font-weight:800;color:var(--accent);margin-top:14px;}
.price-tag small{font-size:0.9rem;font-weight:400;color:var(--text-muted);}
.bk-form-card{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-lg);padding:30px;box-shadow:var(--shadow-sm);}
.bk-form-card h3{font-family:var(--font-display);color:var(--text-primary);margin-bottom:22px;padding-bottom:12px;border-bottom:1px solid var(--border);}
.summary-box{background:var(--bg-input);border-radius:var(--radius-md);padding:18px;margin-bottom:22px;border:1px solid var(--border);}
.sum-row{display:flex;justify-content:space-between;padding:5px 0;font-size:0.9rem;color:var(--text-secondary);}
.sum-row.total{font-weight:800;font-size:1.1rem;color:var(--accent);border-top:1px solid var(--border);margin-top:8px;padding-top:12px;font-family:var(--font-display);}
@media(max-width:768px){.bk-grid{grid-template-columns:1fr;}}
</style>
</head>
<body>
<header>
  <div class="container header-content">
    <a href="index.html" class="logo"><i class="fas fa-globe-americas"></i> TravelExplorer</a>
    <nav id="mainNav">
      <a href="index.html"><i class="fas fa-home"></i> Home</a>
      <a href="destinations"><i class="fas fa-map-marked-alt"></i> Destinations</a>
      <a href="bookings"><i class="fas fa-suitcase"></i> My Bookings</a>
      <a href="logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </nav>
    <div style="display:flex;align-items:center;gap:10px;">
      <span class="user-hello">Hi, <%= userName %></span>
      <div class="theme-toggle" id="themeToggle"><div class="theme-toggle-track"><div class="theme-toggle-thumb"><i class="theme-icon fas fa-moon"></i></div></div></div>
      <div class="hamburger" id="hamburger"><span></span><span></span><span></span></div>
    </div>
  </div>
</header>

<div class="container" style="padding:calc(var(--header-h) + 32px) 24px 60px;">
  <a href="destinations" class="back-btn"><i class="fas fa-arrow-left"></i> Back to Destinations</a>

  <div class="bk-grid">
    <div class="pkg-summary anim">
      <img src="images/<%= pkgImage %>" alt="<%= pkgTitle %>"
           onerror="this.src='https://placehold.co/500x220/141B3C/F5A623?text=<%= java.net.URLEncoder.encode(pkgTitle,"UTF-8") %>'">
      <div class="pkg-summary-body">
        <h2><%= pkgTitle %></h2>
        <% if (!pkgDuration.isEmpty()) { %>
        <div class="pkg-meta"><span><i class="fas fa-clock"></i> <%= pkgDuration %></span></div>
        <% } %>
        <p style="color:var(--text-secondary);font-size:0.9rem;margin:12px 0;line-height:1.7;"><%= pkgDesc %></p>
        <div class="price-tag">₹<%= String.format("%,.0f", pkgPrice.doubleValue()) %> <small>/ person</small></div>
      </div>
    </div>

    <div class="bk-form-card anim anim-d1">
      <h3><i class="fas fa-calendar-check" style="color:var(--accent);margin-right:8px;"></i>Complete Your Booking</h3>
      <form action="book" method="post">
        <input type="hidden" name="package_id" value="<%= packageId %>">
        <input type="hidden" name="price"      value="<%= pkgPrice %>">

        <div class="fg" style="margin-bottom:18px;">
          <label><i class="fas fa-users"></i> Number of Travelers</label>
          <input type="number" name="travelers" id="travelers" value="1" min="1" max="20" required>
        </div>
        <div class="fg" style="margin-bottom:22px;">
          <label><i class="fas fa-calendar-alt"></i> Travel Date</label>
          <input type="date" name="booking_date" id="booking_date" min="<%= minDate %>" required>
        </div>

        <div class="summary-box">
          <div class="sum-row"><span>Package</span><span><%= pkgTitle %></span></div>
          <div class="sum-row"><span>Price/person</span><span>₹<%= String.format("%,.0f", pkgPrice.doubleValue()) %></span></div>
          <div class="sum-row"><span>Travelers</span><span id="sumTravelers">1</span></div>
          <div class="sum-row total"><span>Total</span><span id="sumTotal">₹<%= String.format("%,.0f", pkgPrice.doubleValue()) %></span></div>
        </div>

        <button type="submit" class="btn" style="width:100%;justify-content:center;padding:14px;font-size:1rem;">
          <i class="fas fa-check-circle"></i> Confirm Booking
        </button>
      </form>
    </div>
  </div>
</div>

<script src="js/theme.js"></script>
<script>
const pricePerPerson = <%= pkgPrice.doubleValue() %>;
document.getElementById('travelers').addEventListener('input', function() {
    const n = Math.max(1, parseInt(this.value) || 1);
    document.getElementById('sumTravelers').textContent = n;
    document.getElementById('sumTotal').textContent = '₹' + (n * pricePerPerson).toLocaleString('en-IN', {maximumFractionDigits:0});
});
</script>
</body>
</html>
