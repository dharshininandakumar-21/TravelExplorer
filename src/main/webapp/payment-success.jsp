<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Payment Successful — TravelExplorer</title>
<script>
(function(){try{var t=localStorage.getItem('te-theme');if(t==='light')document.documentElement.setAttribute('data-theme','light');}catch(e){}})();
</script>
<link rel="stylesheet" href="css/style.css">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
<style>
.success-wrap{min-height:100vh;display:flex;align-items:center;justify-content:center;padding:24px;}
.success-card{background:var(--bg-card);border:1px solid var(--border);border-radius:var(--radius-xl);padding:56px 44px;text-align:center;max-width:480px;box-shadow:var(--shadow-lg);position:relative;overflow:hidden;}
.success-card::before{content:'';position:absolute;top:0;left:15%;right:15%;height:2px;background:linear-gradient(90deg,transparent,var(--success),transparent);}
.success-icon{width:100px;height:100px;background:var(--success-soft);border:2px solid rgba(0,212,170,0.3);border-radius:50%;display:flex;align-items:center;justify-content:center;margin:0 auto 28px;animation:pop 0.5s cubic-bezier(0.34,1.56,0.64,1);}
@keyframes pop{0%{transform:scale(0);opacity:0;}100%{transform:scale(1);opacity:1;}}
.success-icon i{font-size:3rem;color:var(--success);}
.success-card h1{font-family:var(--font-display);color:var(--text-primary);margin-bottom:14px;font-size:1.8rem;}
.success-card p{color:var(--text-secondary);margin-bottom:32px;line-height:1.7;}
.btn-group{display:flex;gap:12px;justify-content:center;flex-wrap:wrap;}
</style>
</head>
<body>
<header>
  <div class="container header-content">
    <a href="index.html" class="logo"><i class="fas fa-globe-americas"></i> TravelExplorer</a>
    <div style="display:flex;align-items:center;gap:10px;">
      <div class="theme-toggle" id="themeToggle"><div class="theme-toggle-track"><div class="theme-toggle-thumb"><i class="theme-icon fas fa-moon"></i></div></div></div>
    </div>
  </div>
</header>

<div class="success-wrap">
    <div class="success-card anim">
        <div class="success-icon"><i class="fas fa-check"></i></div>
        <h1>Payment Successful!</h1>
        <p>Your payment has been processed and your booking is now <strong style="color:var(--success);">confirmed</strong>. A confirmation has been recorded against your account.</p>
        <div class="btn-group">
            <a href="bookings" class="btn"><i class="fas fa-suitcase"></i> My Bookings</a>
            <a href="destinations" class="btn-ghost btn"><i class="fas fa-map-marked-alt"></i> Book Another</a>
        </div>
    </div>
</div>
<script src="js/theme.js"></script>
</body>
</html>
