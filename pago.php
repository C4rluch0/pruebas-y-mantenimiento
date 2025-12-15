<?php
session_start();
require 'db.php';

if (!isset($_SESSION['clienteId'])) {
    header("Location: registro.php");
    exit();
}
if (isset($_SESSION['tipoMembresia']) && $_SESSION['tipoMembresia'] !== 'premium') {
    header("Location: membresia.php");
    exit();
}

$mensaje = null;
$pagoExitoso = false;

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $numeroTarjeta = str_replace(' ', '', $_POST['numeroTarjeta'] ?? '');
    $nombreTitular = $_POST['nombreTitular'] ?? '';
    $fechaExpiracion = $_POST['fechaExpiracion'] ?? '';
    $cvv = $_POST['cvv'] ?? '';

    if ($numeroTarjeta && $nombreTitular && $fechaExpiracion && $cvv) {
        if (strlen($numeroTarjeta) === 16 && strlen($cvv) === 3) {
            try {
                $stmt = $pdo->prepare("INSERT INTO membresias (cliente_id, tipo, fecha_inicio, fecha_vencimiento) VALUES (?, 'premium', NOW(), DATE_ADD(NOW(), INTERVAL 1 MONTH))");
                $stmt->execute([$_SESSION['clienteId']]);
                
                $pagoExitoso = true;
                $mensaje = "¡Pago exitoso! Bienvenido a CinemaxPlus Premium.";
            } catch (Exception $e) {
                $mensaje = "Error: " . $e->getMessage();
            }
        } else {
            $mensaje = "Datos de tarjeta inválidos.";
        }
    } else {
        $mensaje = "Completa todos los campos.";
    }
}

if ($pagoExitoso) {
    header("Refresh: 3; url=usuarios.php");
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Procesar Pago - CinemaxPlus</title>
    <link rel="stylesheet" href="estilos_cinemax.css">
    <style>
        .payment-container { max-width: 500px; margin: 50px auto; padding: 30px; background: var(--cinemax-gray-dark); border-radius: 8px; }
        .success-message { text-align: center; padding: 40px; border: 2px solid #00ff00; }
        /* (Resto de estilos CSS incrustados iguales al JSP) */
        .form-group input { width: 100%; padding: 12px; margin-bottom: 10px; background: rgba(255,255,255,0.1); border: 1px solid #888; color: white; }
    </style>
</head>
<body class="membership-body">
    <div class="payment-container">
        <div class="cinemax-logo"></div>
        
        <?php if ($pagoExitoso): ?>
            <div class="success-message">
                <h1 style="color:#00ff00">¡Pago Exitoso! ✅</h1>
                <p style="color:white"><?= $mensaje ?></p>
                <p style="color:#ccc">Redirigiendo en 3 segundos...</p>
                <a href="usuarios.php" class="btn btn-primary">Continuar ahora</a>
            </div>
        <?php else: ?>
            <h1 class="payment-title" style="text-align:center; color:white">Información de pago</h1>
            <?php if ($mensaje): ?>
                <div style="color:red; text-align:center; margin-bottom:15px;"><?= $mensaje ?></div>
            <?php endif; ?>
            
            <form action="pago.php" method="post">
                <div class="form-group">
                    <label style="color:#ccc">Número de tarjeta</label>
                    <input type="text" name="numeroTarjeta" placeholder="1234 5678 9012 3456" required>
                </div>
                <div class="form-group">
                    <label style="color:#ccc">Nombre del titular</label>
                    <input type="text" name="nombreTitular" required>
                </div>
                <div style="display:flex; gap:10px;">
                    <div class="form-group" style="flex:1">
                        <label style="color:#ccc">Expiración</label>
                        <input type="text" name="fechaExpiracion" placeholder="MM/AA" required>
                    </div>
                    <div class="form-group" style="flex:1">
                        <label style="color:#ccc">CVV</label>
                        <input type="text" name="cvv" placeholder="123" maxlength="3" required>
                    </div>
                </div>
                <button type="submit" class="btn btn-primary" style="width:100%; margin-top:20px;">💳 Pagar $9.99</button>
            </form>
        <?php endif; ?>
    </div>
</body>
</html>