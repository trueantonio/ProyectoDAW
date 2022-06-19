<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Discográficas Antonio</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <div class="navbar">
        <a href="./index.html"><img src="imagenes/logo.png" class="logo"></a>
            <ul>
                <li><a href="./index.html">HOME</a></li>
                <li><a href="./about.html">ABOUT</a></li>
                <li><a href="./artista.php">ARTISTS</a></li>
                <li><a href="./album.php">ALBUMS</a></li>
                <li><a href="./cancion.php">SONGS</a></li>
            </ul>
        </div>

        <div class="tabla">
            <h2>Listado de Álbumes de la base de datos</h2>
            <br>
            <?php 
                $conexionOracle = oci_connect("antonio", "5172", "localhost/orcl");

                    if (!$conexionOracle) {
                        $e = oci_error();
                        trigger_error(htmlentities($e['message'], ENT_QUOTES), E_USER_ERROR);
                        }

                    // Preparar la sentencia
                    $stid = oci_parse($conexionOracle, 'SELECT * FROM album');
                    if (!$stid) {
                        $e = oci_error($conexionOracle);
                        trigger_error(htmlentities($e['message'], ENT_QUOTES), E_USER_ERROR);
                    }

                    // Realizar la lógica de la consulta
                    $r = oci_execute($stid);
                    if (!$r) {
                        $e = oci_error($stid);
                        trigger_error(htmlentities($e['message'], ENT_QUOTES), E_USER_ERROR);
                    }

                    // Obtener los resultados de la consulta
                    print "<table border='1'>\n";
                    print "<th>Nombre del álbum</th><th>Nombre del artista</th><th>Pistas</th><th>Fecha de lanzamiento</th>\n";
                    while ($fila = oci_fetch_array($stid, OCI_ASSOC+OCI_RETURN_NULLS)) {
                        print "<tr>\n";
                        foreach ($fila as $elemento) {
                            print "    <td>" . ($elemento !== null ? htmlentities($elemento, ENT_QUOTES) : "") . "</td>\n";
                        }
                        print "</tr>\n";
                    }
                    print "</table>\n";

                    oci_free_statement($stid);
                    oci_close($conexionOracle);

                    ?>
        </div>
    </div>
    
</body>
</html>