<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Noticias – CinemaxPlus</title>
  <link rel="stylesheet" href="estilos_cinemax.css">
  <style>
    /* Estilos para el contenedor de los botones de la cabecera */
    .header-buttons {
        display: flex;
        gap: 15px; /* Espacio entre los botones */
    }

    /* Estilos para las tarjetas de noticias */
    .news-container {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
        gap: 30px;
        padding: 40px 50px;
        max-width: 1400px;
        margin: 0 auto;
    }
    .news-card {
        background: var(--cinemax-gray-dark);
        border-radius: 8px;
        overflow: hidden;
        display: flex;
        flex-direction: column;
        border: 1px solid var(--cinemax-gray-medium);
        transition: transform 0.3s;
    }
    .news-card:hover {
        transform: translateY(-5px);
    }
    .news-card-media {
        width: 100%;
        height: 200px;
        background-color: #000;
    }
    .news-card-media img, .news-card-media iframe {
        width: 100%;
        height: 100%;
        object-fit: cover;
        border: none;
    }
    .news-card-content {
        padding: 20px;
        flex-grow: 1;
        display: flex;
        flex-direction: column;
    }
    .news-card-content h3 {
        color: var(--cinemax-white);
        margin-bottom: 15px;
        font-size: 1.2rem;
    }
    .news-card-content p {
        color: var(--cinemax-gray-light);
        flex-grow: 1;
        margin-bottom: 20px;
    }
    .news-card-content a {
        align-self: flex-start;
    }
  </style>
</head>
<body class="equipo-body">

  <header class="equipo-header" style="justify-content: space-between; padding: 15px 50px;">
    <div class="cinemax-logo" role="img" aria-label="CinemaxPlus logo" style="margin: 0;"></div>
    
    <div class="header-buttons">
        <a href="login.jsp" class="btn btn-primary">Iniciar Sesión</a>
        <a href="registro.jsp" class="btn btn-secondary">Registrarse</a>
    </div>
  </header>

  <div class="descripcion-equipo" style="background: var(--cinemax-dark); color: var(--cinemax-white);">
    <h1>Noticias del Mundo del Cine</h1>
    <p>Las últimas novedades y los tráilers más esperados, todo en un solo lugar.</p>
  </div>

  <div class="news-container">
    <div class="news-card">
      <div class="news-card-media">
        <img src="https://lacallerosa.com/download/multimedia.normal.a759892fe57bf5e9.bm9ybWFsLndlYnA%3D.webp" alt="Logo de The Fantastic Four">
      </div>
      <div class="news-card-content">
        <h3>Marvel Studios Lanza el Tráiler Final de 'The Fantastic Four'</h3>
        <p>El nuevo avance de la esperada película de Marvel muestra por primera vez a Galactus y ofrece un vistazo completo a los poderes del equipo. Los fans están analizando cada segundo del épico tráiler.</p>
        <a href="https://www.ign.com/movies" class="btn btn-secondary" target="_blank">Leer Artículo</a>
      </div>
    </div>

    <div class="news-card">
      <div class="news-card-media">
        <img src="https://s3.amazonaws.com/rtvc-assets-senalcolombia.gov.co/s3fs-public/styles/imagen_noticia/public/field/image/Sin%20ti%CC%81tulo-1_0.jpg?itok=aXjCkk4i" alt="Imagen de la película SUPERMAN">
      </div>
      <div class="news-card-content">
        <h3>DC Studios Presenta el Épico Tráiler de 'SUPERMAN'</h3>
        <p>El primer tráiler oficial de la película dirigida por James Gunn ya está aquí. David Corenswet se enfunda el traje en una visión completamente nueva y esperanzadora para el Hombre de Acero.</p>
        <a href="https://www.youtube.com/watch?v=tnqje4O31mg&t=11s&ab_channel=WarnerBros.PicturesLatinoam%C3%A9rica" class="btn btn-secondary" target="_blank">Ver en YouTube</a>
      </div>
    </div>

    <div class="news-card">
      <div class="news-card-media">
        <img src="https://i.ytimg.com/vi/zZRnIYNJQrs/hq720.jpg?sqp=-oaymwEhCK4FEIIDSFryq4qpAxMIARUAAAAAGAElAADIQj0AgKJD&rs=AOn4CLDVj_84qaoQKoQcdG8iJI2TPKMh5g" alt="Logo de TRON Ares">
      </div>
      <div class="news-card-content">
        <h3>Disney Lanza el Espectacular Tráiler Oficial de 'TRON: Ares'</h3>
        <p>El esperado tráiler ya está aquí, mostrando a Jared Leto como Ares en su misión desde el mundo digital al nuestro. El avance está cargado de acción, con impresionantes batallas de discos y la nueva generación de Light Cycles en una estética visualmente deslumbrante.</p>
        <a href="https://www.youtube.com/watch?v=9KVG_X_7Naw&ab_channel=Disney" class="btn btn-secondary" target="_blank">Ver en YouTube</a>
      </div>
    </div>
  </div>

  <footer>
    <p>© 2025 CinemaxPlus – Todos los derechos reservados.</p>
    <a href= "sobre_nosotros.jsp" style= "color:#FF5733"; text-decoration=none;>Sobre Nosotros</a>
  </footer>

</body>
</html>