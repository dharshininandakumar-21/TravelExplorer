<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.mycompany.tourism.utils.DBConnection, java.math.BigDecimal" %>
<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("userId") == null) { response.sendRedirect("login.html"); return; }
    int userId = (int) sess.getAttribute("userId");

    String bookingId = request.getParameter("booking_id");
    if (bookingId == null) { response.sendRedirect("bookings"); return; }

    String pkgTitle = ""; BigDecimal totalAmount = BigDecimal.ZERO;
    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(
             "SELECT b.total_amount, p.title FROM bookings b " +
             "JOIN packages p ON b.package_id = p.id " +
             "WHERE b.id = ? AND b.user_id = ?")) {
        ps.setInt(1, Integer.parseInt(bookingId));
        ps.setInt(2, userId);
        ResultSet rs = ps.executeQuery();
        if (!rs.next()) { response.sendRedirect("bookings"); return; }
        totalAmount = rs.getBigDecimal("total_amount");
        pkgTitle    = rs.getString("title");
    } catch (Exception e) { throw new jakarta.servlet.ServletException(e); }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Payment — TravelExplorer</title>
<script>
(function(){try{var t=localStorage.getItem('te-theme');if(t==='light')document.documentElement.setAttribute('data-theme','light');}catch(e){}})();
</script>
<link rel="stylesheet" href="css/style.css">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
<style>
.pay-wrap{max-width:580px;margin:0 auto;padding:calc(var(--header-h) + 40px) 20px 60px;}
.pay-card{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-xl);padding:36px;box-shadow:var(--shadow-md);}
.pay-card h2{font-family:var(--font-display);color:var(--text-primary);margin-bottom:4px;}
.pay-card .sub{color:var(--text-secondary);margin-bottom:24px;font-size:0.92rem;}
.method-tabs{display:flex;gap:8px;margin-bottom:24px;}
.method-tab{flex:1;padding:14px 6px;border:1.5px solid var(--border);border-radius:var(--radius-md);text-align:center;cursor:pointer;background:var(--bg-input);transition:var(--transition);}
.method-tab:hover{border-color:var(--border-hover);}
.method-tab.active{border-color:var(--accent);background:var(--accent-soft);}
.method-tab i{display:block;font-size:1.4rem;color:var(--accent);margin-bottom:4px;}
.method-tab span{font-size:0.8rem;font-weight:700;color:var(--text-primary);}
.field-sec{display:none;} .field-sec.show{display:block;}
.two-col{display:grid;grid-template-columns:1fr 1fr;gap:12px;}
.summary-mini{background:var(--bg-input);border:1px solid var(--border);border-radius:var(--radius-md);padding:18px;margin-bottom:22px;}
.s-row{display:flex;justify-content:space-between;padding:4px 0;font-size:0.9rem;color:var(--text-secondary);}
.s-row.total{font-weight:800;font-size:1.1rem;color:var(--accent);border-top:1px solid var(--border);margin-top:8px;padding-top:10px;font-family:var(--font-display);}
.btn-pay-now{width:100%;padding:15px;background:var(--accent);color:#000;border:none;border-radius:var(--radius-md);font-size:1rem;font-weight:700;cursor:pointer;transition:var(--transition);font-family:var(--font-body);}
.btn-pay-now:hover{background:var(--accent-dark);box-shadow:var(--shadow-accent);transform:translateY(-2px);}
.secure{text-align:center;color:var(--text-muted);font-size:0.8rem;margin-top:14px;}
.err{color:var(--error);font-size:0.85rem;margin-bottom:14px;display:none;background:var(--error-soft);padding:10px 14px;border-radius:var(--radius-md);border:1px solid rgba(255,92,122,0.2);}
</style>
</head>
<body>
<header>
  <div class="container header-content">
    <a href="index.html" class="logo"><i class="fas fa-globe-americas"></i> TravelExplorer</a>
    <nav id="mainNav"><a href="bookings"><i class="fas fa-arrow-left"></i> Back to Bookings</a></nav>
    <div style="display:flex;align-items:center;gap:10px;">
      <div class="theme-toggle" id="themeToggle"><div class="theme-toggle-track"><div class="theme-toggle-thumb"><i class="theme-icon fas fa-moon"></i></div></div></div>
      <div class="hamburger" id="hamburger"><span></span><span></span><span></span></div>
    </div>
  </div>
</header>

<div class="pay-wrap">
    <div class="pay-card anim">
        <h2><i class="fas fa-lock" style="color:var(--success);margin-right:6px;"></i>Secure Payment</h2>
        <p class="sub">Complete payment for: <strong style="color:var(--text-primary);"><%= pkgTitle %></strong></p>

        <div class="summary-mini">
            <div class="s-row"><span>Booking ID</span><span>#<%= bookingId %></span></div>
            <div class="s-row"><span>Package</span><span><%= pkgTitle %></span></div>
            <div class="s-row total"><span>Amount Due</span><span>₹<%= String.format("%,.2f", totalAmount.doubleValue()) %></span></div>
        </div>

        <div class="method-tabs">
            <div class="method-tab active" onclick="switchMethod('card', this)"><i class="fas fa-credit-card"></i><span>Card</span></div>
            <div class="method-tab" onclick="switchMethod('upi', this)"><i class="fas fa-mobile-alt"></i><span>UPI</span></div>
            <div class="method-tab" onclick="switchMethod('netbanking', this)"><i class="fas fa-university"></i><span>Net Banking</span></div>
        </div>

        <form action="process-payment" method="post" onsubmit="return validatePay()">
            <input type="hidden" name="booking_id"     value="<%= bookingId %>">
            <input type="hidden" name="payment_method" id="payMethod" value="card">

            <p class="err" id="errMsg"></p>

            <div class="field-sec show" id="sec-card">
                <div class="fg" style="margin-bottom:15px;"><label>Card Number</label>
                    <input type="text" id="cardNum" placeholder="1234 5678 9012 3456" maxlength="19"></div>
                <div class="two-col">
                    <div class="fg" style="margin-bottom:15px;"><label>Expiry (MM/YY)</label>
                        <input type="text" id="expiry" placeholder="MM/YY" maxlength="5"></div>
                    <div class="fg" style="margin-bottom:15px;"><label>CVV</label>
                        <input type="text" id="cvv" placeholder="123" maxlength="3"></div>
                </div>
                <div class="fg" style="margin-bottom:15px;"><label>Name on Card</label>
                    <input type="text" id="cardName" placeholder="As printed on card"></div>
            </div>

            <div class="field-sec" id="sec-upi">
                <div class="fg" style="margin-bottom:15px;"><label>UPI ID</label>
                    <input type="text" id="upiId" placeholder="yourname@upi"></div>
            </div>

            <div class="field-sec" id="sec-netbanking">
                <div class="fg" style="margin-bottom:15px;"><label>Select Bank</label>
                    <select id="bankSel">
                        <option value="">-- Select Your Bank --</option>
                        <option>State Bank of India</option><option>HDFC Bank</option>
                        <option>ICICI Bank</option><option>Axis Bank</option>
                        <option>Kotak Mahindra Bank</option><option>Punjab National Bank</option>
                        <option>Bank of Baroda</option>
                    </select>
                </div>
            </div>

            <button type="submit" class="btn-pay-now"><i class="fas fa-lock"></i>&nbsp; Pay ₹<%= String.format("%,.2f", totalAmount.doubleValue()) %></button>
            <p class="secure"><i class="fas fa-shield-alt" style="color:var(--success);"></i> 256-bit SSL Encrypted. Safe &amp; Secure.</p>
        </form>
    </div>
</div>

<script src="js/theme.js"></script>
<script>
function switchMethod(m, el) {
    document.querySelectorAll('.method-tab').forEach(t => t.classList.remove('active'));
    el.classList.add('active');
    document.querySelectorAll('.field-sec').forEach(s => s.classList.remove('show'));
    document.getElementById('sec-' + m).classList.add('show');
    document.getElementById('payMethod').value = m;
}
document.getElementById('cardNum').addEventListener('input', function() {
    let v = this.value.replace(/\D/g,'').substring(0,16);
    this.value = v.replace(/(.{4})/g,'$1 ').trim();
});
document.getElementById('expiry').addEventListener('input', function() {
    let v = this.value.replace(/\D/g,'');
    if (v.length >= 2) v = v.substring(0,2) + '/' + v.substring(2,4);
    this.value = v;
});
function validatePay() {
    const m = document.getElementById('payMethod').value;
    let msg = '';
    if (m === 'card') {
        const n = document.getElementById('cardNum').value.replace(/\s/g,'');
        if (n.length < 16) msg = 'Enter a valid 16-digit card number.';
        else if (!document.getElementById('expiry').value.match(/^\d{2}\/\d{2}$/)) msg = 'Enter expiry as MM/YY.';
        else if (document.getElementById('cvv').value.length < 3) msg = 'Enter a valid 3-digit CVV.';
        else if (!document.getElementById('cardName').value.trim()) msg = 'Enter name on card.';
    } else if (m === 'upi') {
        if (!document.getElementById('upiId').value.includes('@')) msg = 'Enter a valid UPI ID (e.g. name@upi).';
    } else if (m === 'netbanking') {
        if (!document.getElementById('bankSel').value) msg = 'Please select a bank.';
    }
    const err = document.getElementById('errMsg');
    if (msg) { err.textContent = '⚠ ' + msg; err.style.display = 'block'; return false; }
    err.style.display = 'none'; return true;
}
</script>
</body>
</html>
