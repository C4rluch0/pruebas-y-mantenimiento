<?php
session_start();
require 'db.php';

// Guardar perfil si viene por GET
if (isset($_GET['perfil'])) {
    $_SESSION['perfilKey'] = $_GET['perfil'];
}

if (!isset($_SESSION['clienteId']) || !isset($_SESSION['perfilKey'])) {
    header("Location: login.php");
    exit();
}

$perfilKey = $_SESSION['perfilKey'];
$youtubeLink = "https://www.youtube.com/watch?v=dQw4w9WgXcQ";

// Agregar a favoritos
if (isset($_POST['agregarFav'])) {
    $idContenido = $_POST['agregarFav'];
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM favs WHERE usuario = ? AND id_contenido = ?");
    $stmt->execute([$perfilKey, $idContenido]);
    
    if ($stmt->fetchColumn() == 0) {
        $stmt = $pdo->prepare("INSERT INTO favs (usuario, id_contenido) VALUES (?, ?)");
        $stmt->execute([$perfilKey, $idContenido]);
    }
    header("Location: repertorio.php");
    exit();
}

// Obtener Género Favorito
$favGenre = "Acción";
$stmt = $pdo->prepare("SELECT cat_fav FROM usuarios WHERE perfil_key = ?");
$stmt->execute([$perfilKey]);
if ($row = $stmt->fetch()) {
    $favGenre = $row['cat_fav'];
}

// Obtener Favoritos actuales (IDs)
$favoritosIds = [];
$stmt = $pdo->prepare("SELECT id_contenido FROM favs WHERE usuario = ?");
$stmt->execute([$perfilKey]);
while ($row = $stmt->fetch()) {
    $favoritosIds[] = $row['id_contenido'];
}

// Hero
$stmt = $pdo->prepare("SELECT id_contenido, titulo, imagen_url FROM contenido WHERE genero = ? LIMIT 1");
$stmt->execute([$favGenre]);
$hero = $stmt->fetch();

// Lista Género Favorito
$stmt = $pdo->prepare("SELECT id_contenido, titulo, imagen_url FROM contenido WHERE genero = ? LIMIT 5");
$stmt->execute([$favGenre]);
$favs = $stmt->fetchAll();

// Lista Populares
$stmt = $pdo->prepare("SELECT id_contenido, titulo, imagen_url FROM contenido ORDER BY RAND() LIMIT 5");
$stmt->execute();
$pops = $stmt->fetchAll();
?>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>CinemaxPlus – Películas y series</title>
  <link rel="stylesheet" href="estilos_cinemax.css">
  <style>
    .carousel-item { position:relative; min-width:220px; height:120px; background-size:cover; border-radius:4px; margin-right:10px; cursor:pointer; }
    .favorite-btn { position:absolute; top:5px; right:5px; background:rgba(0,0,0,0.5); border:none; cursor:pointer; font-size:16px; border-radius:50%; width:30px; height:30px; }
    .favorite-btn.favorito { background:#e50914; }
  </style>
</head>
<body class="home-body">
  <nav class="navbar">
    <div class="cinemax-logo"></div>
    <div class="nav-links">
      <a href="repertorio.php" class="active">Inicio</a>
      <a href="favoritos.php">Mi lista</a>
      <a href="home.php">Home</a>
    </div>
    <div class="user-menu"><a href="usuarios.php" class="user-icon">👤</a></div>
  </nav>

  <main class="main-content">
    <!-- Hero -->
    <?php if ($hero): ?>
    <section class="hero" style="background: url('<?= $hero['imagen_url'] ?>') center center / cover no-repeat;">
      <div class="hero-content">
        <h1 class="hero-title"><?= htmlspecialchars($hero['titulo']) ?></h1>
        <div class="hero-buttons">
          <a href="<?= $youtubeLink ?>" class="btn btn-primary" target="_blank">▶ Ver ahora</a>
          <form action="repertorio.php" method="post" style="display:inline;">
             <input type="hidden" name="agregarFav" value="<?= $hero['id_contenido'] ?>">
             <button type="submit" class="btn btn-secondary">❤️ Agregar a favoritos</button>
          </form>
        </div>
      </div>
    </section>
    <?php endif; ?>

    <!-- Populares -->
    <section class="content-section">
      <h2 class="section-title">Populares</h2>
      <div class="carousel">
        <?php foreach ($pops as $c): 
            $esFav = in_array($c['id_contenido'], $favoritosIds); ?>
            
          <!-- Tarjeta principal con enlace a YouTube -->
          <div class="carousel-item" 
               style="background-image: url('<?= $c['imagen_url'] ?>');" 
               onclick="window.open('<?= $youtubeLink ?>','_blank')">
            
            <!-- Botón de favoritos con stopPropagation -->
            <form action="repertorio.php" method="post" onclick="event.stopPropagation();">
              <input type="hidden" name="agregarFav" value="<?= $c['id_contenido'] ?>">
              <button type="submit" class="favorite-btn <?= $esFav ? 'favorito' : '' ?>" title="Agregar a favoritos">
                <?= $esFav ? "❤️" : "🤍" ?>
              </button>
            </form>
            
            <!-- Opcional: Título al pasar el mouse (Overlay) -->
            <div style="position:absolute; bottom:0; left:0; width:100%; padding:10px; background:linear-gradient(transparent, black); border-radius:0 0 8px 8px; opacity:0; transition:0.3s;" onmouseover="this.style.opacity=1" onmouseout="this.style.opacity=0">
                <span style="font-size:14px; font-weight:bold;"><?= htmlspecialchars($c['titulo']) ?></span>
            </div>
            
          </div>
        <?php endforeach; ?>
      </div>
    </section>

    <!-- Género Fav -->
    <section class="content-section">
      <h2 class="section-title">Tu género: <?= htmlspecialchars($favGenre) ?></h2>
      <div class="carousel">
        <?php foreach ($favs as $c): 
            $esFav = in_array($c['id_contenido'], $favoritosIds); ?>
            
          <div class="carousel-item" 
               style="background-image: url('<?= $c['imagen_url'] ?>');" 
               onclick="window.open('<?= $youtubeLink ?>','_blank')">
            
            <!-- Botón de favoritos con stopPropagation -->
            <form action="repertorio.php" method="post" onclick="event.stopPropagation();">
              <input type="hidden" name="agregarFav" value="<?= $c['id_contenido'] ?>">
              <button type="submit" class="favorite-btn <?= $esFav ? 'favorito' : '' ?>" title="Agregar a favoritos">
                <?= $esFav ? "❤️" : "🤍" ?>
              </button>
            </form>
            
          </div>
        <?php endforeach; ?>
      </div>
    </section>
  </main>
</body>
</html>