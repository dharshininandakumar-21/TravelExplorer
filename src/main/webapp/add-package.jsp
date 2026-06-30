<%@ page contentType="text/html; charset=UTF-8" %>
<%
    HttpSession sess = request.getSession(false);
    if(sess==null||sess.getAttribute("isAdmin")==null||!(Boolean)sess.getAttribute("isAdmin")){
        response.sendRedirect("login.html"); return;
    }
    response.sendRedirect("admin-dashboard");
%>
