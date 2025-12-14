<%@ page language="java" contentType="text/html; charset=UTF-8" import="java.sql.*" %>
<%
    String mensaje = null;

    if (request.getParameter("email") != null) {
        String email    = request.getParameter("email").trim();
        String password = request.getParameter("password").trim();
        String nombre   = request.getParameter("name").trim();

        if (email.contains("@") && email.contains(".") && password.length() >= 6 && !nombre.isEmpty()) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                try (Connection cn = DriverManager.getConnection(
                        "jdbc:mysql://localhost:3306/cinemaxplus?useSSL=false&serverTimezone=UTC",
                        "root", "")) {

                    // 1) Comprobar si el email ya existe
                    String checkSql = "SELECT COUNT(*) FROM cliente WHERE correo = ?";
                    try (PreparedStatement checkPs = cn.prepareStatement(checkSql)) {
                        checkPs.setString(1, email);
                        try (ResultSet rs = checkPs.executeQuery()) {
                            rs.next();
                            if (rs.getInt(1) > 0) {
                                mensaje = "El correo ingresado ya está registrado. Inicia sesión.";
                            }
                        }
                    }

                    // 2) Insertar si no existe
                    if (mensaje == null) {
                        String insertSql = "INSERT INTO cliente (correo, contrasena, nombre) VALUES (?, ?, ?)";
                        try (PreparedStatement insertPs = cn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
                            insertPs.setString(1, email);
                            insertPs.setString(2, password);
                            insertPs.setString(3, nombre);
                            
                            if (insertPs.executeUpdate() > 0) {
                                // Obtener el ID del cliente recién insertado
                                try (ResultSet generatedKeys = insertPs.getGeneratedKeys()) {
                                    if (generatedKeys.next()) {
                                        int nuevoClienteId = generatedKeys.getInt(1);
                                        // Guardar en sesión
                                        session.setAttribute("clienteId", nuevoClienteId);
                                        session.setAttribute("userEmail", email);
                                        session.setAttribute("userName", nombre);
                                        
                                        // REDIRIGIR A MEMBRESÍA después del registro
                                        response.sendRedirect("membresia.jsp");
                                        return;
                                    }
                                }
                            } else {
                                mensaje = "No se pudo registrar. Intenta de nuevo.";
                            }
                        }
                    }
                }
            } catch (Exception e) {
                mensaje = "Error en registro: " + e.getMessage();
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
  <title>Registro – CinemaxPlus</title>
  <link rel="stylesheet" href="estilos_cinemax.css">
</head>
<body class="register-body">
  <div class="register-container">
    <div class="cinemax-logo" role="img" aria-label="CinemaxPlus logo"></div>

    <h1 class="register-title">Crear una cuenta</h1>

    <% if (mensaje != null) { %>
      <div class="error-message" style="display:block; text-align:center; margin-bottom:20px;">
        <strong><%= mensaje %></strong>
      </div>
    <% } %>

    <form id="registerForm" action="registro.jsp" method="post">
      <div class="form-group">
        <label for="email">Correo electrónico</label>
        <input type="email" id="email" name="email" placeholder="correo@ejemplo.com" required>
        <div class="error-message" id="email-error">Por favor ingresa un correo válido</div>
      </div>

      <div class="form-group">
        <label for="password">Contraseña</label>
        <input type="password" id="password" name="password" placeholder="Mínimo 6 caracteres" required minlength="6">
        <div class="error-message" id="password-error">La contraseña debe tener al menos 6 caracteres</div>
      </div>

      <div class="form-group">
        <label for="name">Nombre</label>
        <input type="text" id="name" name="name" placeholder="Tu nombre completo" required>
        <div class="error-message" id="name-error">Por favor ingresa tu nombre</div>
      </div>

      <button type="submit" class="btn btn-primary">Registrarse</button>
    </form>

    <div class="login-link">
      ¿Ya tienes una cuenta? <a href="login.jsp">Inicia sesión</a>
    </div>
    <div class="terms">
      Al registrarte, aceptas nuestros Términos de servicio y Política de privacidad.
    </div>
  </div>

  <script>
    document.getElementById('registerForm').addEventListener('submit', function(e) {
      let valid = true;
      const email    = document.getElementById('email').value;
      const password = document.getElementById('password').value;
      const name     = document.getElementById('name').value;

      // Email
      if (!email.includes('@') || !email.includes('.')) {
        document.getElementById('email-error').style.display = 'block';
        valid = false;
      } else {
        document.getElementById('email-error').style.display = 'none';
      }

      // Password
      if (password.length < 6) {
        document.getElementById('password-error').style.display = 'block';
        valid = false;
      } else {
        document.getElementById('password-error').style.display = 'none';
      }

      // Name
      if (name.trim() === '') {
        document.getElementById('name-error').style.display = 'block';
        valid = false;
      } else {
        document.getElementById('name-error').style.display = 'none';
      }

      if (!valid) e.preventDefault();
    });
  </script>
</body>
</html>