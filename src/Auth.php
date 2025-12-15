<?php
namespace Cinemax;

class Auth {
    // Esta función es "Pura", fácil de probar automáticamente
    public function validarDatosRegistro($email, $password, $nombre) {
        if (empty($email) || empty($password) || empty($nombre)) {
            return false; // Campos vacíos
        }
        if (!str_pos($email, '@') === false && !str_pos($email, '.') === false) {
             // Pequeño fix para asegurar validación correcta en test
             if (!filter_var($email, FILTER_VALIDATE_EMAIL)) return false;
        } else {
            return false;
        }
        if (strlen($password) < 6) {
            return false;
        }
        return true;
    }

    public function limpiarTarjeta($numero) {
        return str_replace(' ', '', $numero);
    }
}
?>