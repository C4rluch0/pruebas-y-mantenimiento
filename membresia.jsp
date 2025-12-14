<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Verificar si el usuario está en sesión (debería venir del registro)
    Integer clienteId = (Integer) session.getAttribute("clienteId");
    if (clienteId == null) {
        response.sendRedirect("registro.jsp");
        return;
    }
    
    String mensaje = null;
    String tipoMembresia = request.getParameter("tipoMembresia");
    
    // ESTA ES LA PARTE CLAVE - Redirección según la membresía seleccionada
    if (tipoMembresia != null) {
        session.setAttribute("tipoMembresia", tipoMembresia);
        
        if ("regular".equals(tipoMembresia)) {
            // Membresía regular es gratuita - ir directamente a usuarios
            response.sendRedirect("usuarios.jsp");
            return;
        } else if ("premium".equals(tipoMembresia)) {
            // Membresía premium requiere pago - ir a página de pago
            response.sendRedirect("pago.jsp");
            return;
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Seleccionar Membresía - CinemaxPlus</title>
    <link rel="stylesheet" href="estilos_cinemax.css">
</head>
<body class="membership-body">
    <div class="membership-container">
        <div class="cinemax-logo" role="img" aria-label="CinemaxPlus logo"></div>
        
        <h1 class="membership-title">Elige tu membresía</h1>
        
        <% if (mensaje != null) { %>
            <div class="error-message" style="display:block; text-align:center; margin-bottom:20px;">
                <strong><%= mensaje %></strong>
            </div>
        <% } %>
        
        <div class="membership-options">
            <!-- TARJETA REGULAR -->
            <div class="membership-card">
                <h3 class="membership-name">Regular</h3>
                <div class="membership-price">$0 <span>/mes</span></div>
                <ul class="membership-features">
                    <li>Acceso a todo el contenido</li>
                    <li>Calidad estándar (720p)</li>
                    <li>Anuncios incluidos</li>
                    <li>1 dispositivo a la vez</li>
                </ul>
                <form action="membresia.jsp" method="post">
                    <input type="hidden" name="tipoMembresia" value="regular">
                    <button type="submit" class="btn btn-primary">Seleccionar Regular</button>
                </form>
            </div>
            
            <!-- TARJETA PREMIUM -->
            <div class="membership-card">
                <h3 class="membership-name">Premium</h3>
                <div class="membership-price">$9.99 <span>/mes</span></div>
                <ul class="membership-features">
                    <li>Acceso a todo el contenido</li>
                    <li>Calidad Ultra HD (4K)</li>
                    <li>Sin anuncios</li>
                    <li>4 dispositivos simultáneos</li>
                    <li>Descargas para ver sin conexión</li>
                </ul>
                <form action="membresia.jsp" method="post">
                    <input type="hidden" name="tipoMembresia" value="premium">
                    <button type="submit" class="btn btn-primary">Seleccionar Premium</button>
                </form>
            </div>
        </div>
    </div>
</body>
</html>