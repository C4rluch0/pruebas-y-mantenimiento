<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%
    // Invalida la sesión actual
    session.invalidate();
    // Redirige de vuelta al login
    response.sendRedirect("login.jsp");
%>
