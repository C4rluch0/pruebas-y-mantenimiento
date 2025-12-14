<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"
         import="java.sql.*, java.util.*" %>
<%
    Integer clienteId = (Integer) session.getAttribute("clienteId");
    if (clienteId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Eliminar perfil
    String perfilEliminar = request.getParameter("eliminar");
    if (perfilEliminar != null) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection cn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/cinemaxplus?useSSL=false&serverTimezone=UTC",
                    "root","")) {
                try (PreparedStatement del = cn.prepareStatement(
                        "DELETE FROM usuarios WHERE perfil_key = ? AND cliente_id = ?")) {
                    del.setString(1, perfilEliminar);
                    del.setInt(2, clienteId);
                    del.executeUpdate();
                }
            }
        } catch (Exception ignored) {}
        response.sendRedirect("usuarios.jsp");
        return;
    }

    String mensaje     = null;
    String nuevoNombre = request.getParameter("nombre");
    String generoFav   = request.getParameter("generoFavorito");

    if (nuevoNombre != null && generoFav != null) {
        nuevoNombre = nuevoNombre.trim();
        if (!nuevoNombre.isEmpty()) {
            String nombreNorm = nuevoNombre.replaceAll("\\s+","").toLowerCase();
            String perfilKey  = clienteId + "_" + nombreNorm;
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                try (Connection cn = DriverManager.getConnection(
                        "jdbc:mysql://localhost:3306/cinemaxplus?useSSL=false&serverTimezone=UTC",
                        "root","")) {
                    try (PreparedStatement chk = cn.prepareStatement(
                            "SELECT COUNT(*) FROM usuarios WHERE perfil_key = ?")) {
                        chk.setString(1, perfilKey);
                        try (ResultSet rs = chk.executeQuery()) {
                            rs.next();
                            if (rs.getInt(1) > 0) {
                                mensaje = "Ya existe un perfil con ese nombre.";
                            }
                        }
                    }
                    if (mensaje == null) {
                        try (PreparedStatement ins = cn.prepareStatement(
                                "INSERT INTO usuarios (perfil_key, cliente_id, nombre, cat_fav) VALUES (?,?,?,?)")) {
                            ins.setString(1, perfilKey);
                            ins.setInt(2, clienteId);
                            ins.setString(3, nuevoNombre);
                            ins.setString(4, generoFav);
                            ins.executeUpdate();
                        }
                        response.sendRedirect("usuarios.jsp");
                        return;
                    }
                }
            } catch (Exception e) {
                mensaje = "Error al crear perfil: " + e.getMessage();
            }
        } else {
            mensaje = "El nombre del perfil no puede estar vacío.";
        }
    }

    class Perfil { String key, nombre; }
    List<Perfil> perfiles = new ArrayList<>();
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection cn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/cinemaxplus?useSSL=false&serverTimezone=UTC",
                "root","")) {
            try (PreparedStatement ps = cn.prepareStatement(
                    "SELECT perfil_key, nombre FROM usuarios WHERE cliente_id = ?")) {
                ps.setInt(1, clienteId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Perfil p = new Perfil();
                        p.key    = rs.getString("perfil_key");
                        p.nombre = rs.getString("nombre");
                        perfiles.add(p);
                    }
                }
            }
        }
    } catch (Exception ignored) {}
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Gestionar perfiles – CinemaxPlus</title>
  <link rel="stylesheet" href="estilos_cinemax.css">
  <style>
    .logout-container {
      text-align: center;
      margin-top: 40px;
      padding-bottom: 30px;
    }
  </style>
</head>
<body class="perfil-body">
  <div class="profile-management">
    <header class="equipo-header">
      <!-- <img src="https://i.imgur.com/mEVz9SH.png"
           alt="CinemaxPlus logo"
           class="logo cinemax-logo"> -->
    </header>

    <h1 class="profile-title">¿Quién está viendo ahora?</h1>
    <p class="profile-subtitle">Selecciona un perfil para continuar</p>

    <div class="profiles-container">
      <% String[] emojis = {"😀","😎","😂","🤖","🦊","🐼","🐸","🦁"};
         java.util.Random rnd = new java.util.Random();
         for (Perfil p : perfiles) {
           String avatar = emojis[rnd.nextInt(emojis.length)]; %>
        <div class="profile" onclick="location.href='repertorio.jsp?perfil=<%=p.key%>'">
          <button class="delete-btn btn btn-outline"
                  onclick="event.stopPropagation();
                           location.href='usuarios.jsp?eliminar=<%=p.key%>'">
            ❌
          </button>
          <div class="profile-avatar"><%= avatar %></div>
          <div class="profile-name"><%= p.nombre %></div>
        </div>
      <% } %>
      <div class="profile" id="addProfileBtn">
        <div class="add-profile">+</div>
        <div class="profile-name">Añadir perfil</div>
      </div>
    </div>

    <% if (mensaje != null) { %>
      <div class="error-message" style="display:block; text-align:center; margin-top:20px;">
        <strong><%= mensaje %></strong>
      </div>
    <% } %>

    <div class="logout-container">
      <a href="logout.jsp" class="btn btn-outline">Cerrar sesión</a>
    </div>
  </div>
  
  <div class="modal" id="profileModal">
    <div class="modal-content">
      <h2 class="register-title">Añadir perfil</h2>
      <form action="usuarios.jsp" method="post">
        <div class="form-group">
          <label>Nombre del perfil</label>
          <input type="text" name="nombre" placeholder="Ej. Juan" required>
        </div>
        <div class="form-group">
          <label>Género favorito</label>
          <select name="generoFavorito" required>
            <option value="Acción">Acción</option>
            <option value="Drama">Drama</option>
            <option value="Comedia">Comedia</option>
            <option value="Terror">Terror</option>
          </select>
        </div>
        <div class="modal-buttons">
          <button type="button" class="btn btn-secondary" id="cancelBtn">Cancelar</button>
          <button type="submit" class="btn btn-primary">Crear</button>
        </div>
      </form>
    </div>
  </div>
  
  <script>
    document.getElementById('addProfileBtn').onclick = () =>
      document.getElementById('profileModal').style.display = 'flex';
    document.getElementById('cancelBtn').onclick = () =>
      document.getElementById('profileModal').style.display = 'none';
    window.onclick = e => {
      if (e.target.id === 'profileModal') e.target.style.display = 'none';
    };
  </script>
</body>
</html>