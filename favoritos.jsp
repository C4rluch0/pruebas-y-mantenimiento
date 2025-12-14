<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"
         import="java.sql.*, java.util.*" %>
<%
    // Verificar usuario en sesión
    Integer clienteId = (Integer) session.getAttribute("clienteId");
    if (clienteId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Leer perfilKey
    String perfilKey = (String) session.getAttribute("perfilKey");
    if (perfilKey == null) {
        response.sendRedirect("usuarios.jsp");
        return;
    }
    
    // Manejar eliminar de favoritos
    String eliminarFav = request.getParameter("eliminarFav");
    if (eliminarFav != null) {
        int idContenido = Integer.parseInt(eliminarFav);
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection cn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/cinemaxplus?useSSL=false&serverTimezone=UTC","root","")) {
                
                try (PreparedStatement ps = cn.prepareStatement(
                        "DELETE FROM favs WHERE usuario = ? AND id_contenido = ?")) {
                    ps.setString(1, perfilKey);
                    ps.setInt(2, idContenido);
                    ps.executeUpdate();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        // Redirigir para evitar reenvío
        response.sendRedirect("favoritos.jsp");
        return;
    }

    // Cargar favoritos del usuario
    class Cont { 
        int id; 
        String titulo, img; 
    }
    List<Cont> favoritos = new ArrayList<>();
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection cn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/cinemaxplus?useSSL=false&serverTimezone=UTC","root","")) {

            // Obtener favoritos del usuario
            try (PreparedStatement ps = cn.prepareStatement(
                    "SELECT c.id_contenido, c.titulo, c.imagen_url " +
                    "FROM contenido c " +
                    "INNER JOIN favs f ON c.id_contenido = f.id_contenido " +
                    "WHERE f.usuario = ?")) {
                ps.setString(1, perfilKey);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Cont c = new Cont();
                        c.id = rs.getInt("id_contenido");
                        c.titulo = rs.getString("titulo");
                        c.img = rs.getString("imagen_url");
                        favoritos.add(c);
                    }
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Mis Favoritos - CinemaxPlus</title>
  <link rel="stylesheet" href="estilos_cinemax.css">
  <style>
    .favorites-body {
        background-color: var(--cinemax-dark);
        color: var(--cinemax-white);
        padding-top: 80px;
    }
    
    .profile-header {
        padding: 50px;
        text-align: center;
    }
    
    .profile-title {
        font-size: 2.5rem;
        margin-bottom: 20px;
        color: var(--cinemax-white);
    }
    
    .profile-description {
        color: var(--cinemax-gray-light);
        font-size: 1.2rem;
    }
    
    .favorites-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
        gap: 20px;
        padding: 0 50px 50px;
        max-width: 1200px;
        margin: 0 auto;
    }
    
    .favorite-item {
        position: relative;
        border-radius: 8px;
        overflow: hidden;
        transition: transform 0.3s;
        background: var(--cinemax-gray-dark);
    }
    
    .favorite-item:hover {
        transform: scale(1.05);
    }
    
    .favorite-item img {
        width: 100%;
        height: 300px;
        object-fit: cover;
        display: block;
    }
    
    .favorite-overlay {
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(0,0,0,0.8);
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        opacity: 0;
        transition: opacity 0.3s;
        padding: 20px;
    }
    
    .favorite-item:hover .favorite-overlay {
        opacity: 1;
    }
    
    .favorite-title {
        color: var(--cinemax-white);
        font-size: 1.1rem;
        margin-bottom: 15px;
        text-align: center;
        font-weight: bold;
    }
    
    .remove-btn {
        background-color: var(--cinemax-red);
        color: var(--cinemax-white);
        border: none;
        padding: 10px 20px;
        border-radius: 4px;
        cursor: pointer;
        font-size: 14px;
        transition: background-color 0.3s;
    }
    
    .remove-btn:hover {
        background-color: #b8070f;
    }
    
    .watch-btn {
        background-color: var(--cinemax-white);
        color: var(--cinemax-dark);
        border: none;
        padding: 10px 20px;
        border-radius: 4px;
        cursor: pointer;
        font-size: 14px;
        margin-bottom: 10px;
        transition: background-color 0.3s;
    }
    
    .watch-btn:hover {
        background-color: var(--cinemax-gray-lighter);
    }
    
    .empty-favorites {
        text-align: center;
        padding: 100px 50px;
        color: var(--cinemax-gray-light);
    }
    
    .empty-favorites h2 {
        font-size: 2rem;
        margin-bottom: 20px;
        color: var(--cinemax-white);
    }
  </style>
</head>
<body class="favorites-body">
  <nav class="navbar">
    <div class="cinemax-logo" role="img" aria-label="CinemaxPlus logo"></div>
    <div class="nav-links">
      <a href="repertorio.jsp">Inicio</a>
      <a href="favoritos.jsp" class="active">Mi lista</a>
    </div>
    <div class="user-menu">
      <a href="usuarios.jsp" class="user-icon">👤</a>
    </div>
  </nav>

  <div class="profile-header">
    <h1 class="profile-title">Mi lista de favoritos</h1>
    <p class="profile-description">Tus películas y series guardadas para ver más tarde</p>
  </div>

  <section class="content-section">
    <% if (favoritos.isEmpty()) { %>
      <div class="empty-favorites">
        <h2>No tienes favoritos aún</h2>
        <p>Explora nuestro catálogo y agrega contenido a tu lista</p>
        <a href="repertorio.jsp" class="btn btn-primary" style="margin-top: 20px;">Explorar catálogo</a>
      </div>
    <% } else { %>
      <div class="favorites-grid">
        <% for (Cont c : favoritos) { %>
          <div class="favorite-item">
            <img src="<%= c.img %>" alt="<%= c.titulo %>">
            <div class="favorite-overlay">
              <div class="favorite-title"><%= c.titulo %></div>
              <a href="https://www.youtube.com/watch?v=dQw4w9WgXcQ" class="watch-btn" target="_blank">▶ Ver ahora</a>
              <form action="favoritos.jsp" method="post">
                <input type="hidden" name="eliminarFav" value="<%= c.id %>">
                <button type="submit" class="remove-btn">❌ Eliminar de favoritos</button>
              </form>
            </div>
          </div>
        <% } %>
      </div>
    <% } %>
  </section>

  <footer style="text-align: center; padding: 30px; background: var(--cinemax-dark);">
    <p>© 2025 CinemaxPlus – Todos los derechos reservados.</p>
  </footer>
</body>
</html>