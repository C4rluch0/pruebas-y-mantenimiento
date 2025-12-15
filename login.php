<?php
session_start();
require 'db.php';

$mensaje = null;

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['email'], $_POST['password'])) {
    $email = trim($_POST['email']);
    $password = trim($_POST['password']);

    if (strpos($email, '@') !== false && strlen($password) >= 6) {
        try {
            $stmt = $pdo->prepare("SELECT id, nombre FROM cliente WHERE correo = ? AND contrasena = ?");
            $stmt->execute([$email, $password]);
            $user = $stmt->fetch();

            if ($user) {
                $_SESSION['clienteId'] = $user['id'];
                $_SESSION['userEmail'] = $email;
                $_SESSION['userName'] = $user['nombre'];
                header("Location: usuarios.php");
                exit();
            } else {
                $mensaje = "Correo o contraseña incorrectos.";
            }
        } catch (Exception $e) {
            $mensaje = "Error: " . $e->getMessage();
        }
    } else {
        $mensaje = "Datos inválidos. Verifica e inténtalo de nuevo.";
    }
}
?>
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
    <div class="cinemax-logo" role="img" aria-label="CinemaxPlus logo"></div>
    <h1 class="login-title">Iniciar sesión</h1>

    <?php if ($mensaje): ?>
      <div class="error-message" style="display:block; text-align:center; margin-bottom:20px;">
        <strong><?= htmlspecialchars($mensaje) ?></strong>
      </div>
    <?php endif; ?>

    <form id="loginForm" action="login.php" method="post">
      <div class="form-group">
        <input type="email" id="email" name="email" placeholder="Correo electrónico" required>
        <div class="error-message" id="email-error">Por favor ingresa un correo válido</div>
      </div>
      <div class="form-group">
        <input type="password" id="password" name="password" placeholder="Contraseña" required minlength="6">
        <div class="error-message" id="password-error">La contraseña debe tener al menos 6 caracteres</div>
      </div>
      <button type="submit" class="btn btn-primary">Iniciar sesión</button> 
    </form>

    <div class="signup-link">
      ¿Primera vez en CinemaxPlus?
      <a href="registro.php">Regístrate ahora</a>.
    </div>
  </div>
  <!-- El script de validación JS se mantiene igual -->
  <script>
    document.getElementById('loginForm').addEventListener('submit', function(e) {
      // (Mismo script JS que tenías en JSP)
      let isValid = true;
      const email = document.getElementById('email').value;
      const password = document.getElementById('password').value;
      if (!email.includes('@') || !email.includes('.')) {
        document.getElementById('email-error').style.display = 'block'; isValid = false;
      } else { document.getElementById('email-error').style.display = 'none'; }
      if (password.length < 6) {
        document.getElementById('password-error').style.display = 'block'; isValid = false;
      } else { document.getElementById('password-error').style.display = 'none'; }
      if (!isValid) e.preventDefault();
    });
  </script>
</body>
</html>