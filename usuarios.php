<?php
session_start();
require 'db.php';

if (!isset($_SESSION['clienteId'])) {
    header("Location: login.php");
    exit();
}

$clienteId = $_SESSION['clienteId'];
$mensaje = null;

// Eliminar Perfil
if (isset($_GET['eliminar'])) {
    $perfilEliminar = $_GET['eliminar'];
    $stmt = $pdo->prepare("DELETE FROM usuarios WHERE perfil_key = ? AND cliente_id = ?");
    $stmt->execute([$perfilEliminar, $clienteId]);
    header("Location: usuarios.php");
    exit();
}

// Crear Perfil
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['nombre'])) {
    $nombre = trim($_POST['nombre']);
    $genero = $_POST['generoFavorito'];

    if (!empty($nombre)) {
        $nombreNorm = strtolower(str_replace(' ', '', $nombre));
        $perfilKey = $clienteId . '_' . $nombreNorm;

        $stmt = $pdo->prepare("SELECT COUNT(*) FROM usuarios WHERE perfil_key = ?");
        $stmt->execute([$perfilKey]);
        
        if ($stmt->fetchColumn() > 0) {
            $mensaje = "Ya existe un perfil con ese nombre.";
        } else {
            $stmt = $pdo->prepare("INSERT INTO usuarios (perfil_key, cliente_id, nombre, cat_fav) VALUES (?, ?, ?, ?)");
            $stmt->execute([$perfilKey, $clienteId, $nombre, $genero]);
            header("Location: usuarios.php");
            exit();
        }
    } else {
        $mensaje = "El nombre no puede estar vacío.";
    }
}

// Obtener perfiles
$stmt = $pdo->prepare("SELECT perfil_key, nombre FROM usuarios WHERE cliente_id = ?");
$stmt->execute([$clienteId]);
$perfiles = $stmt->fetchAll();

$emojis = ["😀","😎","😂","🤖","🦊","🐼","🐸","🦁"];
?>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Gestionar perfiles – CinemaxPlus</title>
  <link rel="stylesheet" href="estilos_cinemax.css">
  <style>
      .modal { display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.8); justify-content:center; align-items:center; }
      .modal-content { background:#181818; padding:40px; border-radius:8px; width:400px; }
  </style>
</head>
<body class="perfil-body">
  <div class="profile-management">
    <h1 class="profile-title">¿Quién está viendo ahora?</h1>
    <div class="profiles-container">
      <?php foreach ($perfiles as $p): 
          $avatar = $emojis[array_rand($emojis)]; ?>
        <div class="profile" onclick="location.href='repertorio.php?perfil=<?= $p['perfil_key'] ?>'">
          <button class="delete-btn btn btn-outline" 
                  onclick="event.stopPropagation(); location.href='usuarios.php?eliminar=<?= $p['perfil_key'] ?>'">❌</button>
          <div class="profile-avatar" style="display:flex; justify-content:center; align-items:center; font-size:50px;"><?= $avatar ?></div>
          <div class="profile-name"><?= htmlspecialchars($p['nombre']) ?></div>
        </div>
      <?php endforeach; ?>
      
      <div class="profile" id="addProfileBtn">
        <div class="add-profile">+</div>
        <div class="profile-name">Añadir perfil</div>
      </div>
    </div>
    
    <?php if ($mensaje): ?>
        <div class="error-message" style="display:block; text-align:center;"><strong><?= $mensaje ?></strong></div>
    <?php endif; ?>
    
    <div style="text-align:center; margin-top:40px;">
        <a href="logout.php" class="btn btn-outline">Cerrar sesión</a>
    </div>
  </div>

  <!-- Modal -->
  <div class="modal" id="profileModal">
    <div class="modal-content">
      <h2 style="color:white; margin-bottom:20px;">Añadir perfil</h2>
      <form action="usuarios.php" method="post">
        <div class="form-group">
          <label style="color:#aaa">Nombre</label>
          <input type="text" name="nombre" required style="width:100%; padding:10px;">
        </div>
        <div class="form-group">
          <label style="color:#aaa">Género</label>
          <select name="generoFavorito" style="width:100%; padding:10px;">
            <option value="Acción">Acción</option>
            <option value="Drama">Drama</option>
            <option value="Comedia">Comedia</option>
            <option value="Terror">Terror</option>
          </select>
        </div>
        <button type="button" class="btn btn-secondary" id="cancelBtn">Cancelar</button>
        <button type="submit" class="btn btn-primary">Crear</button>
      </form>
    </div>
  </div>
  
  <script>
    const modal = document.getElementById('profileModal');
    document.getElementById('addProfileBtn').onclick = () => modal.style.display = 'flex';
    document.getElementById('cancelBtn').onclick = () => modal.style.display = 'none';
  </script>
</body>
</html>