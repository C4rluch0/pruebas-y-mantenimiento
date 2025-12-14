<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Verificar si el usuario está en sesión y ha seleccionado premium
    Integer clienteId = (Integer) session.getAttribute("clienteId");
    String tipoMembresia = (String) session.getAttribute("tipoMembresia");
    
    // Depuración - ver qué hay en sesión
    System.out.println("DEBUG - ClienteID: " + clienteId);
    System.out.println("DEBUG - Tipo Membresia: " + tipoMembresia);
    
    if (clienteId == null) {
        response.sendRedirect("registro.jsp");
        return;
    }
    
    if (!"premium".equals(tipoMembresia)) {
        response.sendRedirect("membresia.jsp");
        return;
    }
    
    String mensaje = null;
    boolean pagoExitoso = false;
    
    // Procesar pago cuando se envía el formulario
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String numeroTarjeta = request.getParameter("numeroTarjeta");
        String nombreTitular = request.getParameter("nombreTitular");
        String fechaExpiracion = request.getParameter("fechaExpiracion");
        String cvv = request.getParameter("cvv");
        
        // Validaciones básicas
        if (numeroTarjeta != null && nombreTitular != null && 
            fechaExpiracion != null && cvv != null) {
            
            numeroTarjeta = numeroTarjeta.replaceAll("\\s+", "");
            
            if (numeroTarjeta.length() == 16 && cvv.length() == 3) {
                // Simular procesamiento de pago exitoso
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    try (java.sql.Connection cn = java.sql.DriverManager.getConnection(
                            "jdbc:mysql://localhost:3306/cinemaxplus?useSSL=false&serverTimezone=UTC",
                            "root", "")) {
                        
                        // Insertar información de membresía
                        String sql = "INSERT INTO membresias (cliente_id, tipo, fecha_inicio, fecha_vencimiento) " +
                                     "VALUES (?, 'premium', NOW(), DATE_ADD(NOW(), INTERVAL 1 MONTH))";
                        try (java.sql.PreparedStatement ps = cn.prepareStatement(sql)) {
                            ps.setInt(1, clienteId);
                            ps.executeUpdate();
                        }
                    }
                    
                    pagoExitoso = true;
                    mensaje = "¡Pago exitoso! Bienvenido a CinemaxPlus Premium.";
                    
                } catch (Exception e) {
                    mensaje = "Error al procesar el pago: " + e.getMessage();
                    e.printStackTrace();
                }
            } else {
                mensaje = "Datos de tarjeta inválidos. Verifica e inténtalo de nuevo.";
            }
        } else {
            mensaje = "Por favor completa todos los campos.";
        }
    }
    
    // Si el pago fue exitoso, redirigir después de 3 segundos
    if (pagoExitoso) {
        response.setHeader("Refresh", "3;url=usuarios.jsp");
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Procesar Pago - CinemaxPlus</title>
    <link rel="stylesheet" href="estilos_cinemax.css">
    <style>
        .payment-container {
            max-width: 500px;
            margin: 50px auto;
            padding: 30px;
            background: var(--cinemax-gray-dark);
            border-radius: 8px;
        }
        
        .payment-title {
            text-align: center;
            margin-bottom: 30px;
            color: var(--cinemax-white);
        }
        
        .payment-summary {
            background: rgba(0,0,0,0.3);
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 30px;
            border-left: 4px solid var(--cinemax-red);
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: var(--cinemax-gray-light);
            font-weight: bold;
        }
        
        .form-group input {
            width: 100%;
            padding: 12px 15px;
            background: rgba(255,255,255,0.1);
            border: 1px solid var(--cinemax-gray-medium);
            border-radius: 4px;
            color: var(--cinemax-white);
            font-size: 16px;
        }
        
        .form-group input:focus {
            outline: none;
            border-color: var(--cinemax-red);
        }
        
        .form-row {
            display: flex;
            gap: 15px;
        }
        
        .form-row .form-group {
            flex: 1;
        }
        
        .success-message {
            text-align: center;
            padding: 40px;
            background: var(--cinemax-gray-dark);
            border-radius: 8px;
            border: 2px solid #00ff00;
        }
        
        .success-message h1 {
            color: #00ff00;
            margin-bottom: 20px;
        }
    </style>
</head>
<body class="membership-body">
    <div class="payment-container">
        <div class="cinemax-logo" role="img" aria-label="CinemaxPlus logo"></div>
        
        <% if (pagoExitoso) { %>
            <div class="success-message">
                <h1>¡Pago Exitoso! ✅</h1>
                <p style="color: var(--cinemax-white); font-size: 18px; margin-bottom: 20px;">
                    <%= mensaje %>
                </p>
                <p style="color: var(--cinemax-gray-light); margin-bottom: 30px;">
                    Serás redirigido automáticamente en 3 segundos...
                </p>
                <a href="usuarios.jsp" class="btn btn-primary">Continuar ahora</a>
            </div>
        <% } else { %>
            <h1 class="payment-title">Completa tu información de pago</h1>
            
            <% if (mensaje != null) { %>
                <div class="error-message" style="display:block; text-align:center; margin-bottom:20px; color: var(--cinemax-red);">
                    <strong><%= mensaje %></strong>
                </div>
            <% } %>
            
            <div class="payment-summary">
                <h3 style="color: var(--cinemax-white); margin-bottom: 15px;">Resumen de compra</h3>
                <p style="color: var(--cinemax-gray-light); margin: 5px 0;">
                    <strong style="color: var(--cinemax-white);">Membresía:</strong> Premium
                </p>
                <p style="color: var(--cinemax-gray-light); margin: 5px 0;">
                    <strong style="color: var(--cinemax-white);">Precio:</strong> $9.99 / mes
                </p>
                <p style="color: var(--cinemax-gray-light); margin: 5px 0;">
                    <strong style="color: var(--cinemax-white);">Prueba gratuita:</strong> 30 días
                </p>
            </div>
            
            <form action="pago.jsp" method="post" id="paymentForm">
                <div class="form-group">
                    <label for="numeroTarjeta">Número de tarjeta</label>
                    <input type="text" id="numeroTarjeta" name="numeroTarjeta" 
                           placeholder="1234 5678 9012 3456" required>
                </div>
                
                <div class="form-group">
                    <label for="nombreTitular">Nombre del titular</label>
                    <input type="text" id="nombreTitular" name="nombreTitular" 
                           placeholder="Como aparece en la tarjeta" required>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="fechaExpiracion">Fecha de expiración</label>
                        <input type="text" id="fechaExpiracion" name="fechaExpiracion" 
                               placeholder="MM/AA" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="cvv">CVV</label>
                        <input type="text" id="cvv" name="cvv" placeholder="123" 
                               required maxlength="3">
                    </div>
                </div>
                
                <button type="submit" class="btn btn-primary" style="width: 100%; padding: 15px; font-size: 16px;">
                    💳 Completar Pago - $9.99
                </button>
            </form>
            
            <div style="text-align: center; margin-top: 20px;">
                <a href="membresia.jsp" style="color: var(--cinemax-gray-light); text-decoration: none;">
                    ← Volver a selección de membresía
                </a>
            </div>
            
            <div style="text-align: center; margin-top: 20px; padding: 15px; background: rgba(0,0,0,0.3); border-radius: 5px;">
                <p style="color: var(--cinemax-gray-light); font-size: 12px; margin: 0;">
                    🔒 Tu información está protegida con encriptación SSL
                </p>
            </div>
        <% } %>
    </div>
    
    <script>
        // Formatear número de tarjeta (agrupar cada 4 dígitos)
        document.getElementById('numeroTarjeta')?.addEventListener('input', function(e) {
            let value = e.target.value.replace(/\s+/g, '').replace(/[^0-9]/gi, '');
            let formattedValue = value.match(/.{1,4}/g)?.join(' ') || value;
            e.target.value = formattedValue;
        });
        
        // Formatear fecha de expiración (MM/AA)
        document.getElementById('fechaExpiracion')?.addEventListener('input', function(e) {
            let value = e.target.value.replace(/\D/g, '');
            if (value.length >= 2) {
                value = value.substring(0, 2) + '/' + value.substring(2, 4);
            }
            e.target.value = value;
        });
        
        // Solo números para CVV
        document.getElementById('cvv')?.addEventListener('input', function(e) {
            e.target.value = e.target.value.replace(/\D/g, '');
        });
    </script>
</body>
</html>