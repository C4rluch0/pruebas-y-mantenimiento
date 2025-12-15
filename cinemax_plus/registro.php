<?php
session_start();
require 'db.php';
$mensaje = null;

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['email'])) {
    $email = trim($_POST['email']);
    $password = trim($_POST['password']);
    $nombre = trim($_POST['name']);

    if (strpos($email, '@') !== false && strlen($password) >= 6 && !empty($nombre)) {
        try {
            // 1. Comprobar si existe
            $stmt = $pdo->prepare("SELECT COUNT(*) FROM cliente WHERE correo = ?");
            $stmt->execute([$email]);
            if ($stmt->fetchColumn() > 0) {
                $mensaje = "El correo ingresado ya está registrado. Inicia sesión.";
            } else {
                // 2. Insertar
                $stmt = $pdo->prepare("INSERT INTO cliente (correo, contrasena, nombre) VALUES (?, ?, ?)");
                if ($stmt->execute([$email, $password, $nombre])) {
                    $_SESSION['clienteId'] = $pdo->lastInsertId();
                    $_SESSION['userEmail'] = $email;
                    $_SESSION['userName'] = $nombre;
                    header("Location: membresia.php");
                    exit();
                } else {
                    $mensaje = "No se pudo registrar. Intenta de nuevo.";
                }
            }
        } catch (Exception $e) {
            $mensaje = "Error en registro: " . $e->getMessage();
        }
    } else {
        $mensaje = "Datos inválidos.";
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Registro – CinemaxPlus</title>
  <link rel="stylesheet" href="estilos_cinemax.css">
</head>
<body class="register-body">
  <div class="register-container">
    <div class="cinemax-logo"></div>
    <h1 class="register-title">Crear una cuenta</h1>
    <?php if ($mensaje): ?>
      <div class="error-message" style="display:block; text-align:center; margin-bottom:20px;">
        <strong><?= htmlspecialchars($mensaje) ?></strong>
      </div>
    <?php endif; ?>
    <form id="registerForm" action="registro.php" method="post">
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
    <div class="login-link">¿Ya tienes una cuenta? <a href="login.php">Inicia sesión</a></div>
  </div>
  <!-- Script JS de validación igual al original -->
  <script>
    document.getElementById('registerForm').addEventListener('submit', function(e) {
      let valid = true;
      const email = document.getElementById('email').value;
      const pass = document.getElementById('password').value;
      const name = document.getElementById('name').value;
      if (!email.includes('@')) { document.getElementById('email-error').style.display = 'block'; valid = false; }
      if (pass.length < 6) { document.getElementById('password-error').style.display = 'block'; valid = false; }
      if (name.trim() === '') { document.getElementById('name-error').style.display = 'block'; valid = false; }
      if (!valid) e.preventDefault();
    });
  </script>
</body>
</html>