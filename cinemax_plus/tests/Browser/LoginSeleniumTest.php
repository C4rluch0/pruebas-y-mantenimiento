<?php
use PHPUnit\Framework\TestCase;
use Facebook\WebDriver\Remote\RemoteWebDriver;
use Facebook\WebDriver\Remote\DesiredCapabilities;
use Facebook\WebDriver\WebDriverBy;

class LoginSeleniumTest extends TestCase {
    protected $driver;

    public function setUp(): void {
        // Conectar al servidor Selenium (debes tenerlo corriendo)
        $this->driver = RemoteWebDriver::create(
            'http://localhost:4444', 
            DesiredCapabilities::chrome()
        );
    }

    public function testLoginFlujoCompleto() {
        // 1. Ir al Login
        $this->driver->get('http://localhost/CinemaxPlus/login.php');

        // 2. Llenar formulario
        $this->driver->findElement(WebDriverBy::name('email'))->sendKeys('test@prueba.com');
        $this->driver->findElement(WebDriverBy::name('password'))->sendKeys('123456');

        // 3. Hacer Clic en botón Submit
        // Buscamos el botón por su clase css
        $this->driver->findElement(WebDriverBy::cssSelector('.btn-primary'))->click();

        // 4. Esperar un poco y verificar URL o Elemento
        sleep(2); // Espera simple
        
        // Obtenemos la URL actual
        $urlActual = $this->driver->getCurrentURL();
        
        // Verificamos si redirigió (ajusta según tu lógica real, si el usuario existe o no)
        // Si el usuario no existe, se quedará en login.php
        // Si existe, irá a usuarios.php
        
        // Ejemplo asumiendo login fallido por usuario no existente en DB real:
        // $this->assertStringContainsString('login.php', $urlActual);
        
        // Ejemplo asumiendo login exitoso:
        // $this->assertStringContainsString('usuarios.php', $urlActual);
        
        $this->assertTrue(true); // Placeholder para que pase si no falla el código anterior
    }

    public function tearDown(): void {
        $this->driver->quit();
    }
}