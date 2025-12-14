<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"
         import="java.sql.*, java.util.*" %>
<%
    // 0) Guardar perfilKey si viene
    String perfilParam = request.getParameter("perfil");
    if (perfilParam != null) {
        session.setAttribute("perfilKey", perfilParam);
    }
    
    //guardar string youtube
    String youtubeLink = "https://www.youtube.com/watch?v=dQw4w9WgXcQ";

    // 1) Recuperar clienteId y perfilKey
    Integer clienteId = (Integer) session.getAttribute("clienteId");
    String perfilKey  = (String) session.getAttribute("perfilKey");
    if (clienteId == null || perfilKey == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // 2) Manejar agregar a favoritos
    String agregarFav = request.getParameter("agregarFav");
    if (agregarFav != null && perfilKey != null) {
        int idContenido = Integer.parseInt(agregarFav);
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection cn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/cinemaxplus?useSSL=false&serverTimezone=UTC",
                    "root","")) {
                
                // Verificar si ya existe en favoritos
                String checkSql = "SELECT COUNT(*) FROM favs WHERE usuario = ? AND id_contenido = ?";
                try (PreparedStatement checkPs = cn.prepareStatement(checkSql)) {
                    checkPs.setString(1, perfilKey);
                    checkPs.setInt(2, idContenido);
                    try (ResultSet rs = checkPs.executeQuery()) {
                        rs.next();
                        if (rs.getInt(1) == 0) {
                            // Insertar en favoritos
                            String insertSql = "INSERT INTO favs (usuario, id_contenido) VALUES (?, ?)";
                            try (PreparedStatement insertPs = cn.prepareStatement(insertSql)) {
                                insertPs.setString(1, perfilKey);
                                insertPs.setInt(2, idContenido);
                                insertPs.executeUpdate();
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        // Redirigir para evitar reenvío
        response.sendRedirect("repertorio.jsp");
        return;
    }

    // 3) Obtener género favorito
    String favGenre = "Acción";
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection cn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/cinemaxplus?useSSL=false&serverTimezone=UTC",
                "root","")) {
            try (PreparedStatement ps = cn.prepareStatement(
                    "SELECT cat_fav FROM usuarios WHERE perfil_key = ?")) {
                ps.setString(1, perfilKey);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) favGenre = rs.getString("cat_fav");
                }
            }
        }
    } catch (Exception ignored) {}

    // 4) Cargar hero, favoritos y populares
    class Cont { 
        int id; 
        String titulo, img; 
        boolean esFavorito; 
    }
    
    Map<String,String> hero = new HashMap<>();
    List<Cont> favs = new ArrayList<>(), pops = new ArrayList<>();
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try (Connection cn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/cinemaxplus?useSSL=false&serverTimezone=UTC",
                "root","")) {
            
            // Obtener favoritos del usuario actual
            Set<Integer> favoritosUsuario = new HashSet<>();
            try (PreparedStatement psFav = cn.prepareStatement(
                    "SELECT id_contenido FROM favs WHERE usuario = ?")) {
                psFav.setString(1, perfilKey);
                try (ResultSet rsFav = psFav.executeQuery()) {
                    while (rsFav.next()) {
                        favoritosUsuario.add(rsFav.getInt("id_contenido"));
                    }
                }
            }

            // Hero
            try (PreparedStatement ps = cn.prepareStatement(
                    "SELECT id_contenido, titulo, imagen_url FROM contenido WHERE genero = ? LIMIT 1")) {
                ps.setString(1, favGenre);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        hero.put("id", rs.getString("id_contenido"));
                        hero.put("titulo", rs.getString("titulo"));
                        hero.put("imagen", rs.getString("imagen_url"));
                    }
                }
            }
            
            // Favoritos (contenido del género favorito)
            try (PreparedStatement ps = cn.prepareStatement(
                    "SELECT id_contenido, titulo, imagen_url FROM contenido WHERE genero = ? LIMIT 5")) {
                ps.setString(1, favGenre);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Cont c = new Cont();
                        c.id = rs.getInt("id_contenido");
                        c.titulo = rs.getString("titulo");
                        c.img    = rs.getString("imagen_url");
                        c.esFavorito = favoritosUsuario.contains(c.id);
                        favs.add(c);
                    }
                }
            }
            
            // Populares
            try (PreparedStatement ps = cn.prepareStatement(
                    "SELECT id_contenido, titulo, imagen_url FROM contenido ORDER BY RAND() LIMIT 5")) {
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Cont c = new Cont();
                        c.id = rs.getInt("id_contenido");
                        c.titulo = rs.getString("titulo");
                        c.img    = rs.getString("imagen_url");
                        c.esFavorito = favoritosUsuario.contains(c.id);
                        pops.add(c);
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
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>CinemaxPlus – Películas y series</title>
  <link rel="stylesheet" href="estilos_cinemax.css">
  <style>
    .carousel-item {
        position: relative;
        min-width: 220px;
        height: 120px;
        background-size: cover;
        background-position: center;
        border-radius: 4px;
        transition: transform 0.3s;
        cursor: pointer;
        flex-shrink: 0;
        display: flex;
        align-items: flex-end;
    }
    
    .carousel-item:hover {
        transform: scale(1.1);
    }
    
    .title-label {
        background: rgba(0,0,0,0.7);
        color: white;
        padding: 5px 10px;
        width: 100%;
        font-size: 12px;
        border-bottom-left-radius: 4px;
        border-bottom-right-radius: 4px;
    }
    
    .favorite-btn {
        position: absolute;
        top: 5px;
        right: 5px;
        background: rgba(0,0,0,0.7);
        border: none;
        border-radius: 50%;
        width: 30px;
        height: 30px;
        color: white;
        cursor: pointer;
        font-size: 16px;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.3s;
    }
    
    .favorite-btn:hover {
        background: rgba(229, 9, 20, 0.9);
        transform: scale(1.1);
    }
    
    .favorite-btn.favorito {
        background: #e50914;
        color: white;
    }
    
    .favorite-btn.favorito:hover {
        background: #b8070f;
    }
  </style>
</head>
<body class="home-body">
  <nav class="navbar">
    <div class="cinemax-logo" role="img" aria-label="CinemaxPlus logo"></div>
    <div class="nav-links">
      <a href="repertorio.jsp" class="active">Inicio</a>
      <a href="favoritos.jsp">Mi lista</a>
    </div>
    <div class="user-menu">
      <a href="usuarios.jsp" class="user-icon">👤</a>
    </div>
  </nav>

  <main class="main-content">
    <!-- Hero dinámico con imagen -->
    <section class="hero" style="background: url('<%= hero.get("imagen") %>') center center / cover no-repeat;">
      <div class="hero-content">
        <h1 class="hero-title"><%= hero.getOrDefault("titulo","") %></h1>
        <div class="hero-buttons">
          <a href="<%= youtubeLink %>" class="btn btn-primary" target="_blank">▶ Ver ahora</a>
          <% if (hero.get("id") != null) { %>
            <form action="repertorio.jsp" method="post" style="display: inline;">
              <input type="hidden" name="agregarFav" value="<%= hero.get("id") %>">
              <button type="submit" class="btn btn-secondary">❤️ Agregar a favoritos</button>
            </form>
          <% } %>
        </div>
      </div>
    </section>

    <!-- Populares -->
    <section class="content-section">
      <h2 class="section-title">Populares en CinemaxPlus</h2>
      <div class="carousel">
        <% for (Cont c : pops) { %>
          <div class="carousel-item" style="background-image: url('<%= c.img %>');" 
               onclick="window.open('<%= youtubeLink %>','_blank')">
            <div class="title-label"><%= c.titulo %></div>
            <form action="repertorio.jsp" method="post">
              <input type="hidden" name="agregarFav" value="<%= c.id %>">
              <button type="submit" class="favorite-btn <%= c.esFavorito ? "favorito" : "" %>">
                <%= c.esFavorito ? "❤️" : "🤍" %>
              </button>
            </form>
          </div>
        <% } %>
      </div>
    </section>
    
    <!-- Género favorito -->
    <section class="content-section">
      <h2 class="section-title">Género: <%= favGenre %></h2>
      <div class="carousel">
        <% for (Cont c : favs) { %>
          <div class="carousel-item" style="background-image: url('<%= c.img %>');" 
               onclick="window.open('<%= youtubeLink %>','_blank')">
            <div class="title-label"><%= c.titulo %></div>
            <form action="repertorio.jsp" method="post">
              <input type="hidden" name="agregarFav" value="<%= c.id %>">
              <button type="submit" class="favorite-btn <%= c.esFavorito ? "favorito" : "" %>">
                <%= c.esFavorito ? "❤️" : "🤍" %>
              </button>
            </form>
          </div>
        <% } %>
      </div>
    </section>

  </main>

  <footer>
    <p>© 2025 CinemaxPlus – Todos los derechos reservados.</p>
  </footer>
</body>
</html>