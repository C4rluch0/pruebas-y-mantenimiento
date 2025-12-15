<?php
use PHPUnit\Framework\TestCase;
use Cinemax\Auth;

class AuthTest extends TestCase {
    
    // CASO DE PRUEBA 1: Datos Válidos
    public function testRegistroDatosValidos() {
        $auth = new Auth();
        $resultado = $auth->validarDatosRegistro("juan@test.com", "123456", "Juan");
        $this->assertTrue($resultado, "Debería aceptar datos correctos");
    }

    // CASO DE PRUEBA 2: Contraseña Corta (Fallido intencional si pasas '123')
    public function testPasswordCorta() {
        $auth = new Auth();
        $resultado = $auth->validarDatosRegistro("juan@test.com", "123", "Juan");
        $this->assertFalse($resultado, "Debería rechazar contraseñas cortas");
    }

    // CASO DE PRUEBA 3: Limpieza de Tarjeta
    public function testLimpiarTarjeta() {
        $auth = new Auth();
        $limpio = $auth->limpiarTarjeta("1234 5678");
        $this->assertEquals("12345678", $limpio);
    }
}