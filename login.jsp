<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"
         import="java.sql.*" %>
<%
    String mensaje = null;

    if ("POST".equalsIgnoreCase(request.getMethod())
        && request.getParameter("email") != null
        && request.getParameter("password") != null) {

        String email    = request.getParameter("email").trim();
        String password = request.getParameter("password").trim();

        if (email.contains("@") && password.length() >= 6) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                try (Connection cn = DriverManager.getConnection(
                        "jdbc:mysql://localhost:3306/cinemaxplus?useSSL=false&serverTimezone=UTC",
                        "root", "")) {

                    String sql =
                      "SELECT id, nombre FROM cliente WHERE correo = ? AND contrasena = ?";
                    try (PreparedStatement ps = cn.prepareStatement(sql)) {
                        ps.setString(1, email);
                        ps.setString(2, password);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) {
                                session.setAttribute("clienteId", rs.getInt("id"));
                                session.setAttribute("userEmail",   email);
                                session.setAttribute("userName",    rs.getString("nombre"));
                                response.sendRedirect("usuarios.jsp");
                                return;
                            } else {
                                mensaje = "Correo o contraseña incorrectos.";
                            }
                        }
                    }
                }
            } catch (Exception e) {
                mensaje = "Error al procesar el login: " + e.getMessage();
            }
        } else {
            mensaje = "Datos inválidos. Verifica e inténtalo de nuevo.";
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Iniciar sesión – CinemaxPlus</title>
  <link rel="stylesheet" href="estilos_cinemax.css">
</head>
<body class="login-body">
  <div class="login-container">

    <!-- Logo desde CSS -->
    <div class="cinemax-logo" role="img" aria-label="CinemaxPlus logo"></div>

    <h1 class="login-title">Iniciar sesión</h1>

    <% if (mensaje != null) { %>
      <div class="error-message" style="display:block; text-align:center; margin-bottom:20px;">
        <strong><%= mensaje %></strong>
      </div>
    <% } %>

    <form id="loginForm" action="login.jsp" method="post">
      <div class="form-group">
        <input type="email" id="email" name="email"
               placeholder="Correo electrónico" required>
        <div class="error-message" id="email-error">Por favor ingresa un correo válido</div>
      </div>

      <div class="form-group">
        <input type="password" id="password" name="password"
               placeholder="Contraseña" required minlength="6">
        <div class="error-message" id="password-error">La contraseña debe tener al menos 6 caracteres</div>
      </div>

      <button type="submit" class="btn btn-primary">Iniciar sesión</button> 
<!--  
      <div class="remember-help">
        <label><input type="checkbox"> Recuérdame</label>
        <a href="#">¿Necesitas ayuda?</a>
      </div>  -->
    </form>

    <div class="signup-link">
      ¿Primera vez en CinemaxPlus?
      <a href="registro.jsp">Regístrate ahora</a>.
    </div>
  </div>

  <script>
    document.getElementById('loginForm').addEventListener('submit', function(e) {
      let isValid = true;
      const email    = document.getElementById('email').value;
      const password = document.getElementById('password').value;

      // Validar email
      if (!email.includes('@') || !email.includes('.')) {
        document.getElementById('email-error').style.display = 'block';
        isValid = false;
      } else {
        document.getElementById('email-error').style.display = 'none';
      }

      // Validar contraseña
      if (password.length < 6) {
        document.getElementById('password-error').style.display = 'block';
        isValid = false;
      } else {
        document.getElementById('password-error').style.display = 'none';
      }

      if (!isValid) {
        e.preventDefault();
      }
    });
  </script>
</body>
</html>
