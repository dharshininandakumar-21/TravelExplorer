<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.math.BigDecimal" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Destinations — TravelExplorer</title>
<script>
(function(){try{var t=localStorage.getItem('te-theme');if(t==='light')document.documentElement.setAttribute('data-theme','light');}catch(e){}})();
</script>
<link rel="stylesheet" href="css/style.css">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body>
<%
    HttpSession sess = request.getSession(false);
    String userName = (sess != null) ? (String) sess.getAttribute("userName") : null;
    Boolean isAdmin = (sess != null && sess.getAttribute("isAdmin") != null) ? (Boolean) sess.getAttribute("isAdmin") : false;
    String searchVal   = request.getAttribute("search")   != null ? (String)request.getAttribute("search")   : "";
    String minPriceVal = request.getAttribute("minPrice") != null ? (String)request.getAttribute("minPrice") : "";
    String maxPriceVal = request.getAttribute("maxPrice") != null ? (String)request.getAttribute("maxPrice") : "";
    List<HashMap<String,Object>> packages = (List<HashMap<String,Object>>) request.getAttribute("packages");
    if (packages == null) packages = new ArrayList<>();
%>
<header>
  <div class="container header-content">
    <a href="index.html" class="logo"><i class="fas fa-globe-americas"></i> TravelExplorer</a>
    <nav id="mainNav">
      <a href="index.html"><i class="fas fa-home"></i> Home</a>
      <a href="destinations" class="active"><i class="fas fa-map-marked-alt"></i> Destinations</a>
      <% if (userName != null) { %>
        <a href="bookings"><i class="fas fa-suitcase"></i> My Bookings</a>
        <% if (isAdmin) { %><a href="admin-dashboard"><i class="fas fa-cog"></i> Admin</a><% } %>
        <a href="logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
      <% } else { %>
        <a href="login.html"><i class="fas fa-sign-in-alt"></i> Login</a>
        <a href="register.html"><i class="fas fa-user-plus"></i> Register</a>
      <% } %>
      <a href="contact.html"><i class="fas fa-envelope"></i> Contact</a>
    </nav>
    <div style="display:flex;align-items:center;gap:10px;">
      <% if (userName != null) { %><span class="user-hello">Hi, <%= userName %></span><% } %>
      <div class="theme-toggle" id="themeToggle" title="Toggle dark / light theme">
        <div class="theme-toggle-track"><div class="theme-toggle-thumb"><i class="theme-icon fas fa-moon"></i></div></div>
      </div>
      <div class="hamburger" id="hamburger"><span></span><span></span><span></span></div>
    </div>
  </div>
</header>

<section class="contact-hero" style="padding-top:calc(var(--header-h) + 50px);padding-bottom:40px;">
  <div class="container">
    <div class="anim">
      <span class="section-tag">Explore The World</span>
      <h1>Discover Amazing Destinations</h1>
      <p>Search and find your perfect travel package from our curated collection</p>
    </div>
  </div>
</section>

<section style="padding-top:0;">
  <div class="container">
    <div class="filter-bar">
      <form action="destinations" method="get">
        <div class="fg">
          <label><i class="fas fa-search"></i> Search</label>
          <input type="text" name="search" placeholder="Destination, keyword..." value="<%= searchVal %>">
        </div>
        <div class="fg">
          <label><i class="fas fa-rupee-sign"></i> Min Price</label>
          <input type="number" name="minPrice" placeholder="0" value="<%= minPriceVal %>">
        </div>
        <div class="fg">
          <label><i class="fas fa-rupee-sign"></i> Max Price</label>
          <input type="number" name="maxPrice" placeholder="100000" value="<%= maxPriceVal %>">
        </div>
        <button type="submit" class="btn"><i class="fas fa-filter"></i> Filter</button>
        <a href="destinations" class="clear-btn"><i class="fas fa-times"></i> Clear</a>
      </form>
    </div>

    <p class="results-info">
      Showing <strong><%= packages.size() %></strong> package<%= packages.size() != 1 ? "s" : "" %>
      <% if (!searchVal.isEmpty()) { %> for "<em><%= searchVal %></em>"<% } %>
    </p>

    <div class="packages">
    <% if (!packages.isEmpty()) {
           for (HashMap<String,Object> pkg : packages) {
               int id         = (Integer) pkg.get("id");
               String title   = (String) pkg.get("title");
               String shortD  = (String) pkg.get("short_desc");
               String desc    = (String) pkg.get("description");
               String display = (shortD != null && !shortD.isEmpty()) ? shortD : (desc != null ? desc : "");
               if (display.length() > 100) display = display.substring(0, 100) + "…";
               BigDecimal price = (BigDecimal) pkg.get("price");
               String image   = (String) pkg.get("image");
               String dur     = (String) pkg.get("duration");
    %>
        <div class="package-card anim">
            <img src="images/<%= image %>" alt="<%= title %>"
                 onerror="this.src='https://placehold.co/400x250/141B3C/F5A623?text=<%= java.net.URLEncoder.encode(title, "UTF-8") %>'">
            <div class="package-content">
                <h3><%= title %></h3>
                <div class="pkg-meta">
                    <% if (dur != null && !dur.isEmpty()) { %><span><i class="fas fa-clock"></i> <%= dur %></span><% } %>
                </div>
                <p><%= display %></p>
                <p class="package-price">₹<%= String.format("%,.0f", price.doubleValue()) %></p>
                <% if (userName != null) { %>
                    <a href="booking.jsp?id=<%= id %>" class="btn"><i class="fas fa-calendar-check"></i> Book Now</a>
                <% } else { %>
                    <a href="login.html" class="btn"><i class="fas fa-sign-in-alt"></i> Login to Book</a>
                <% } %>
            </div>
        </div>
    <% } } else { %>
        <div class="no-results">
            <i class="fas fa-compass"></i>
            <h3>No packages found</h3>
            <p>Try different keywords or <a href="destinations">clear filters</a>.</p>
        </div>
    <% } %>
    </div>
  </div>
</section>

<footer>
  <div class="container">
    <div class="footer-content">
      <div class="footer-section">
        <h3><i class="fas fa-globe-americas"></i> TravelExplorer</h3>
        <p>Making travel memorable for everyone.</p>
        <div class="social-links">
          <a href="#"><i class="fab fa-facebook"></i></a>
          <a href="#"><i class="fab fa-twitter"></i></a>
          <a href="#"><i class="fab fa-instagram"></i></a>
          <a href="#"><i class="fab fa-linkedin"></i></a>
        </div>
      </div>
      <div class="footer-section">
        <h4>Quick Links</h4>
        <ul>
          <li><a href="index.html">Home</a></li>
          <li><a href="destinations">Destinations</a></li>
          <li><a href="login.html">Login</a></li>
          <li><a href="register.html">Register</a></li>
        </ul>
      </div>
      <div class="footer-section">
        <h4>Contact</h4>
        <div class="footer-contact">
          <p><i class="fas fa-envelope"></i> info@travelexplorer.com</p>
          <p><i class="fas fa-phone"></i> +91 98765 43210</p>
        </div>
      </div>
    </div>
    <div class="footer-bottom">
      <p>&copy; 2025 Travel &amp; Tourism Management System. All rights reserved.</p>
    </div>
  </div>
</footer>
<script src="js/theme.js"></script>
</body>
</html>
