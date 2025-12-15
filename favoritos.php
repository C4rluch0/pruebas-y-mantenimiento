<?php
session_start();
require 'db.php';

if (!isset($_SESSION['clienteId'])) { header("Location: login.php"); exit(); }
if (!isset($_SESSION['perfilKey'])) { header("Location: usuarios.php"); exit(); }

$perfilKey = $_SESSION['perfilKey'];

// Eliminar
if (isset($_POST['eliminarFav'])) {
    $id = $_POST['eliminarFav'];
    $stmt = $pdo->prepare("DELETE FROM favs WHERE usuario = ? AND id_contenido = ?");
    $stmt->execute([$perfilKey, $id]);
    header("Location: favoritos.php");
    exit();
}

// Cargar lista
$stmt = $pdo->prepare("SELECT c.id_contenido, c.titulo, c.imagen_url FROM contenido c INNER JOIN favs f ON c.id_contenido = f.id_contenido WHERE f.usuario = ?");
$stmt->execute([$perfilKey]);
$favoritos = $stmt->fetchAll();
?>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Mis Favoritos</title>
  <link rel="stylesheet" href="estilos_cinemax.css">
  <style>
      .favorites-body { background: var(--cinemax-dark); color:white; padding-top:80px; }
      .favorites-grid { display:grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap:20px; padding:50px; }
      .favorite-item { position:relative; transition: transform 0.3s; }
      .favorite-item:hover { transform: scale(1.05); }
      .favorite-item img { width:100%; display:block; }
      .favorite-overlay { position:absolute; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.8); display:flex; flex-direction:column; justify-content:center; align-items:center; opacity:0; transition:opacity 0.3s; }
      .favorite-item:hover .favorite-overlay { opacity:1; }
  </style>
</head>
<body class="favorites-body">
  <nav class="navbar">
    <div class="cinemax-logo"></div>
    <div class="nav-links">
      <a href="repertorio.php">Inicio</a>
      <a href="favoritos.php" class="active">Mi lista</a>
    </div>
    <div class="user-menu"><a href="usuarios.php" class="user-icon">👤</a></div>
  </nav>

  <div class="profile-header">
    <h1 class="profile-title" style="text-align:center">Mi lista de favoritos</h1>
  </div>

  <?php if (empty($favoritos)): ?>
      <div style="text-align:center; padding:100px;">
        <h2>No tienes favoritos aún</h2>
        <a href="repertorio.php" class="btn btn-primary">Explorar catálogo</a>
      </div>
  <?php else: ?>
      <div class="favorites-grid">
        <?php foreach ($favoritos as $c): ?>
          <div class="favorite-item">
            <img src="<?= $c['imagen_url'] ?>" alt="<?= htmlspecialchars($c['titulo']) ?>">
            <div class="favorite-overlay">
              <div style="margin-bottom:10px; font-weight:bold;"><?= htmlspecialchars($c['titulo']) ?></div>
              <a href="https://www.youtube.com/watch?v=dQw4w9WgXcQ" class="btn btn-primary" target="_blank" style="margin-bottom:10px; font-size:12px;">▶ Ver</a>
              <form action="favoritos.php" method="post">
                <input type="hidden" name="eliminarFav" value="<?= $c['id_contenido'] ?>">
                <button type="submit" class="btn btn-secondary" style="background:#e50914;">❌ Eliminar</button>
              </form>
            </div>
          </div>
        <?php endforeach; ?>
      </div>
  <?php endif; ?>
</body>
</html>