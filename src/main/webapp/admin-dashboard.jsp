<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.math.BigDecimal" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Admin Dashboard — TravelExplorer</title>
<script>
(function(){try{var t=localStorage.getItem('te-theme');if(t==='light')document.documentElement.setAttribute('data-theme','light');}catch(e){}})();
</script>
<link rel="stylesheet" href="css/style.css">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body class="admin-body">
<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("isAdmin") == null || !(Boolean)sess.getAttribute("isAdmin")) {
        response.sendRedirect("login.html"); return;
    }
    String adminName = (String) sess.getAttribute("userName");

    List<HashMap<String,Object>> packages  = (List<HashMap<String,Object>>) request.getAttribute("packages");
    List<HashMap<String,Object>> bookings  = (List<HashMap<String,Object>>) request.getAttribute("bookings");
    List<HashMap<String,Object>> users     = (List<HashMap<String,Object>>) request.getAttribute("users");
    List<HashMap<String,Object>> reviews   = (List<HashMap<String,Object>>) request.getAttribute("reviews");
    List<HashMap<String,Object>> contacts  = (List<HashMap<String,Object>>) request.getAttribute("contacts");
    if (packages == null) packages = new ArrayList<>();
    if (bookings == null) bookings = new ArrayList<>();
    if (users    == null) users    = new ArrayList<>();
    if (reviews  == null) reviews  = new ArrayList<>();
    if (contacts == null) contacts = new ArrayList<>();

    Integer totalBookings = (Integer)    request.getAttribute("totalBookings"); if (totalBookings==null) totalBookings=0;
    Integer totalUsers    = (Integer)    request.getAttribute("totalUsers");    if (totalUsers==null)    totalUsers=0;
    Integer totalPackages = (Integer)    request.getAttribute("totalPackages"); if (totalPackages==null) totalPackages=0;
    BigDecimal totalRevenue = (BigDecimal) request.getAttribute("totalRevenue"); if (totalRevenue==null) totalRevenue=BigDecimal.ZERO;
    BigDecimal paidRevenue  = (BigDecimal) request.getAttribute("paidRevenue");  if (paidRevenue==null)  paidRevenue=BigDecimal.ZERO;

    List<String> chartMonths   = (List<String>) request.getAttribute("chartMonths");   if (chartMonths==null)   chartMonths=new ArrayList<>();
    List<Double> chartRevenues = (List<Double>) request.getAttribute("chartRevenues"); if (chartRevenues==null) chartRevenues=new ArrayList<>();

    StringBuilder mJ = new StringBuilder("["), rJ = new StringBuilder("[");
    for (int i = 0; i < chartMonths.size(); i++) {
        if (i>0){mJ.append(",");rJ.append(",");}
        mJ.append("\"").append(chartMonths.get(i)).append("\"");
        rJ.append(chartRevenues.get(i));
    }
    mJ.append("]"); rJ.append("]");
%>

<header>
  <div class="container header-content">
    <a href="index.html" class="logo"><i class="fas fa-globe-americas"></i> TravelExplorer</a>
    <nav>
      <span class="user-hello"><i class="fas fa-user-shield"></i> <%= adminName %> (Admin)</span>
      <a href="destinations"><i class="fas fa-eye"></i> View Site</a>
      <a href="logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </nav>
    <div class="theme-toggle" id="themeToggle"><div class="theme-toggle-track"><div class="theme-toggle-thumb"><i class="theme-icon fas fa-moon"></i></div></div></div>
  </div>
</header>

<div class="admin-layout">
    <div class="sidebar">
        <div class="nav-label">Dashboard</div>
        <a href="#" class="active" onclick="showPanel('overview',this)"><i class="fas fa-gauge-high"></i> Overview</a>
        <div class="nav-label">Management</div>
        <a href="#" onclick="showPanel('packages',this)"><i class="fas fa-box-open"></i> Packages</a>
        <a href="#" onclick="showPanel('bookings',this)"><i class="fas fa-calendar-check"></i> Bookings</a>
        <a href="#" onclick="showPanel('users',this)"><i class="fas fa-users"></i> Users</a>
        <a href="#" onclick="showPanel('reviews',this)"><i class="fas fa-star"></i> Reviews</a>
        <a href="#" onclick="showPanel('messages',this)"><i class="fas fa-envelope"></i> Messages</a>
        <hr>
        <div class="nav-label">Actions</div>
        <a href="#" onclick="showPanel('add-package',this)"><i class="fas fa-plus-circle"></i> Add Package</a>
        <hr>
        <a href="logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>

    <div class="admin-main">
        <% if ("1".equals(request.getParameter("added"))) { %>
        <div class="alert-ok"><i class="fas fa-check-circle"></i> Package added successfully!</div>
        <% } %>

        <!-- OVERVIEW -->
        <div class="panel active" id="panel-overview">
            <div class="panel-title"><i class="fas fa-gauge-high"></i> Dashboard Overview</div>
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon" style="background:rgba(108,99,255,0.15);color:#6C63FF;"><i class="fas fa-calendar-check"></i></div>
                    <div class="stat-info"><h3><%= totalBookings %></h3><p>Total Bookings</p></div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon" style="background:rgba(0,212,170,0.15);color:#00D4AA;"><i class="fas fa-rupee-sign"></i></div>
                    <div class="stat-info"><h3>₹<%= String.format("%,.0f", totalRevenue.doubleValue()) %></h3><p>Total Revenue</p></div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon" style="background:var(--accent-soft);color:var(--accent);"><i class="fas fa-check-double"></i></div>
                    <div class="stat-info"><h3>₹<%= String.format("%,.0f", paidRevenue.doubleValue()) %></h3><p>Paid Revenue</p></div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon" style="background:rgba(255,92,122,0.15);color:#FF5C7A;"><i class="fas fa-users"></i></div>
                    <div class="stat-info"><h3><%= totalUsers %></h3><p>Registered Users</p></div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon" style="background:rgba(108,99,255,0.15);color:#6C63FF;"><i class="fas fa-box-open"></i></div>
                    <div class="stat-info"><h3><%= totalPackages %></h3><p>Packages</p></div>
                </div>
            </div>
            <div class="chart-wrap"><canvas id="revenueChart" height="200"></canvas></div>
        </div>

        <!-- PACKAGES -->
        <div class="panel" id="panel-packages">
            <div class="panel-title"><i class="fas fa-box-open"></i> Manage Packages</div>
            <div style="overflow-x:auto;">
            <table class="data-table">
                <thead><tr><th>#</th><th>Title</th><th>Duration</th><th>Price</th><th>Added On</th><th>Action</th></tr></thead>
                <tbody>
                <% if (packages.isEmpty()) { %><tr><td colspan="6" class="empty-msg">No packages yet.</td></tr>
                <% } else { for (HashMap<String,Object> p : packages) {
                    String dur = (String) p.get("duration"); if (dur==null) dur="N/A";
                %>
                <tr>
                    <td><%= p.get("id") %></td>
                    <td><strong><%= p.get("title") %></strong></td>
                    <td><%= dur %></td>
                    <td>₹<%= p.get("price") %></td>
                    <td><%= p.get("created_at").toString().substring(0,10) %></td>
                    <td>
                        <form action="admin-dashboard" method="post" style="display:inline;"
                              onsubmit="return confirm('Delete this package? All its bookings will also be removed.')">
                            <input type="hidden" name="action"     value="delete_package">
                            <input type="hidden" name="package_id" value="<%= p.get("id") %>">
                            <button class="btn-sm btn-del"><i class="fas fa-trash"></i> Delete</button>
                        </form>
                    </td>
                </tr>
                <% } } %>
                </tbody>
            </table>
            </div>
        </div>

        <!-- BOOKINGS -->
        <div class="panel" id="panel-bookings">
            <div class="panel-title"><i class="fas fa-calendar-check"></i> All Bookings</div>
            <div style="overflow-x:auto;">
            <table class="data-table">
                <thead><tr><th>ID</th><th>User</th><th>Package</th><th>Travelers</th><th>Travel Date</th><th>Amount</th><th>Status</th><th>Update</th></tr></thead>
                <tbody>
                <% if (bookings.isEmpty()) { %><tr><td colspan="8" class="empty-msg">No bookings yet.</td></tr>
                <% } else { for (HashMap<String,Object> b : bookings) {
                    String st = (String) b.get("status"); if (st==null) st="confirmed";
                %>
                <tr>
                    <td><strong>#<%= b.get("id") %></strong></td>
                    <td><div><%= b.get("user_name") %></div><small style="color:var(--text-muted);"><%= b.get("email") %></small></td>
                    <td><%= b.get("pkg_title") %></td>
                    <td><%= b.get("travelers") %></td>
                    <td><%= b.get("booking_date") != null ? b.get("booking_date") : "—" %></td>
                    <td>₹<%= b.get("total_amount") %></td>
                    <td><span class="badge b-<%= st.toLowerCase() %>"><%= st %></span></td>
                    <td>
                        <form action="admin-dashboard" method="post" style="display:flex;gap:5px;align-items:center;">
                            <input type="hidden" name="action"     value="update_booking_status">
                            <input type="hidden" name="booking_id" value="<%= b.get("id") %>">
                            <select name="status" class="status-sel">
                                <option value="confirmed"  <%= "confirmed".equals(st)?"selected":"" %>>Confirmed</option>
                                <option value="paid"       <%= "paid".equals(st)?"selected":"" %>>Paid</option>
                                <option value="completed"  <%= "completed".equals(st)?"selected":"" %>>Completed</option>
                                <option value="cancelled"  <%= "cancelled".equals(st)?"selected":"" %>>Cancelled</option>
                            </select>
                            <button class="btn-sm btn-save"><i class="fas fa-save"></i></button>
                        </form>
                    </td>
                </tr>
                <% } } %>
                </tbody>
            </table>
            </div>
        </div>

        <!-- USERS -->
        <div class="panel" id="panel-users">
            <div class="panel-title"><i class="fas fa-users"></i> Registered Users</div>
            <div style="overflow-x:auto;">
            <table class="data-table">
                <thead><tr><th>ID</th><th>Name</th><th>Email</th><th>Phone</th><th>Role</th><th>Joined</th></tr></thead>
                <tbody>
                <% if (users.isEmpty()) { %><tr><td colspan="6" class="empty-msg">No users found.</td></tr>
                <% } else { for (HashMap<String,Object> u : users) {
                    boolean adm = (Boolean) u.get("is_admin");
                %>
                <tr>
                    <td><%= u.get("id") %></td>
                    <td><strong><%= u.get("name") %></strong></td>
                    <td><%= u.get("email") %></td>
                    <td><%= u.get("phone") != null ? u.get("phone") : "—" %></td>
                    <td><span class="badge <%= adm?"b-admin":"b-user" %>"><%= adm?"Admin":"User" %></span></td>
                    <td><%= u.get("created_at").toString().substring(0,10) %></td>
                </tr>
                <% } } %>
                </tbody>
            </table>
            </div>
        </div>

        <!-- REVIEWS -->
        <div class="panel" id="panel-reviews">
            <div class="panel-title"><i class="fas fa-star"></i> Customer Reviews</div>
            <div style="overflow-x:auto;">
            <table class="data-table">
                <thead><tr><th>User</th><th>Package</th><th>Rating</th><th>Comment</th><th>Date</th></tr></thead>
                <tbody>
                <% if (reviews.isEmpty()) { %><tr><td colspan="5" class="empty-msg">No reviews yet. Reviews appear after users complete payment and submit feedback.</td></tr>
                <% } else { for (HashMap<String,Object> rv : reviews) {
                    int rt = (Integer) rv.get("rating");
                %>
                <tr>
                    <td><%= rv.get("user_name") %></td>
                    <td><%= rv.get("pkg_title") %></td>
                    <td class="stars">
                        <% for (int i=0;i<rt;i++) out.print("★"); for (int i=rt;i<5;i++) out.print("<span style='color:var(--border);'>★</span>"); %>
                        (<%= rt %>/5)
                    </td>
                    <td><%= rv.get("comment") != null ? rv.get("comment") : "—" %></td>
                    <td><%= rv.get("created_at").toString().substring(0,10) %></td>
                </tr>
                <% } } %>
                </tbody>
            </table>
            </div>
        </div>

        <!-- MESSAGES -->
        <div class="panel" id="panel-messages">
            <div class="panel-title"><i class="fas fa-envelope"></i> Contact Messages</div>
            <div style="overflow-x:auto;">
            <table class="data-table">
                <thead><tr><th>Name</th><th>Email</th><th>Subject</th><th>Message</th><th>Date</th></tr></thead>
                <tbody>
                <% if (contacts.isEmpty()) { %><tr><td colspan="5" class="empty-msg">No messages yet.</td></tr>
                <% } else { for (HashMap<String,Object> c : contacts) { %>
                <tr>
                    <td><%= c.get("name") %></td>
                    <td><%= c.get("email") %></td>
                    <td><%= c.get("subject") %></td>
                    <td style="max-width:260px;word-wrap:break-word;"><%= c.get("message") %></td>
                    <td><%= c.get("created_at").toString().substring(0,10) %></td>
                </tr>
                <% } } %>
                </tbody>
            </table>
            </div>
        </div>

        <!-- ADD PACKAGE -->
        <div class="panel" id="panel-add-package">
            <div class="panel-title"><i class="fas fa-plus-circle"></i> Add New Package</div>
            <form action="add-package" method="post">
                <div class="form-grid">
                    <div class="fg"><label>Package Title *</label>
                        <input type="text" name="title" placeholder="e.g. Goa Beach Vacation" required></div>
                    <div class="fg"><label>Price (₹) *</label>
                        <input type="number" step="0.01" min="0" name="price" placeholder="e.g. 15000" required></div>
                    <div class="fg"><label>Duration</label>
                        <input type="text" name="duration" placeholder="e.g. 5 Days, 4 Nights"></div>
                    <div class="fg"><label>Short Description</label>
                        <input type="text" name="short_desc" placeholder="One-line summary"></div>
                    <div class="fg"><label>Image Filename</label>
                        <input type="text" name="image" placeholder="e.g. goa.jpg (place in /images/)"></div>
                    <div class="fg full-row"><label>Full Description *</label>
                        <textarea name="description" rows="3" placeholder="Detailed package description..." required></textarea></div>
                </div>
                <button type="submit" class="btn" style="margin-top:18px;"><i class="fas fa-plus"></i> Add Package</button>
            </form>
        </div>

    </div>
</div>

<script src="js/theme.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.0/chart.umd.min.js"></script>
<script>
function showPanel(name, el) {
    document.querySelectorAll('.panel').forEach(p => p.classList.remove('active'));
    document.querySelectorAll('.sidebar a').forEach(a => a.classList.remove('active'));
    const panel = document.getElementById('panel-' + name);
    if (panel) panel.classList.add('active');
    if (el) el.classList.add('active');
    event.preventDefault();
}

const months   = <%= mJ %>;
const revenues = <%= rJ %>;
const isLight = document.documentElement.getAttribute('data-theme') === 'light';
const gridColor = isLight ? 'rgba(0,0,0,0.06)' : 'rgba(255,255,255,0.06)';
const textColor = isLight ? '#3A4260' : '#9AA5C4';

const ctx = document.getElementById('revenueChart').getContext('2d');
new Chart(ctx, {
    type: 'bar',
    data: {
        labels: months.length ? months : ['No Data'],
        datasets: [{
            label: 'Revenue (₹)',
            data: revenues.length ? revenues : [0],
            backgroundColor: 'rgba(245,166,35,0.75)',
            borderColor: '#F5A623',
            borderWidth: 1.5,
            borderRadius: 8,
            maxBarThickness: 56
        }]
    },
    options: {
        responsive: true,
        plugins: {
            legend: { display: false },
            title: { display: true, text: 'Monthly Revenue — Last 6 Months', color:'#F5A623', font:{size:14,weight:'bold',family:'Inter'} }
        },
        scales: {
            x: { ticks:{color:textColor}, grid:{color:gridColor} },
            y: { beginAtZero: true, ticks: { color:textColor, callback: v => '₹' + v.toLocaleString('en-IN') }, grid:{color:gridColor} }
        }
    }
});
</script>
</body>
</html>
