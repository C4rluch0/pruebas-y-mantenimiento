<?php
session_start();
if (!isset($_SESSION['clienteId'])) {
    header("Location: registro.php");
    exit();
}

if (isset($_POST['tipoMembresia'])) {
    $tipo = $_POST['tipoMembresia'];
    $_SESSION['tipoMembresia'] = $tipo;

    if ($tipo === "regular") {
        header("Location: usuarios.php");
        exit();
    } elseif ($tipo === "premium") {
        header("Location: pago.php");
        exit();
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Seleccionar Membresía - CinemaxPlus</title>
    <link rel="stylesheet" href="estilos_cinemax.css">
</head>
<body class="membership-body">
    <div class="membership-container">
        <div class="cinemax-logo"></div>
        <h1 class="membership-title">Elige tu membresía</h1>
        
        <div class="membership-options">
            <!-- REGULAR -->
            <div class="membership-card">
                <h3 class="membership-name">Regular</h3>
                <div class="membership-price">$0 <span>/mes</span></div>
                <ul class="membership-features">
                    <li>Acceso a todo el contenido</li>
                    <li>Calidad estándar (720p)</li>
                    <li>Anuncios incluidos</li>
                    <li>1 dispositivo a la vez</li>
                </ul>
                <form action="membresia.php" method="post">
                    <input type="hidden" name="tipoMembresia" value="regular">
                    <button type="submit" class="btn btn-primary">Seleccionar Regular</button>
                </form>
            </div>
            <!-- PREMIUM -->
            <div class="membership-card">
                <h3 class="membership-name">Premium</h3>
                <div class="membership-price">$9.99 <span>/mes</span></div>
                <ul class="membership-features">
                    <li>Calidad Ultra HD (4K)</li>
                    <li>Sin anuncios</li>
                    <li>4 dispositivos simultáneos</li>
                    <li>Descargas offline</li>
                </ul>
                <form action="membresia.php" method="post">
                    <input type="hidden" name="tipoMembresia" value="premium">
                    <button type="submit" class="btn btn-primary">Seleccionar Premium</button>
                </form>
            </div>
        </div>
    </div>
</body>
</html>