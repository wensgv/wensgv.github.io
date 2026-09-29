#!/bin/bash

# ==============================================================================
# PREÁMBULO / CABECERA DE DOCUMENTACIÓN
# ==============================================================================
# NOMBRE DEL SCRIPT: check_data.sh
# AUTOR: Wenceslao González wens@unav.es
# FECHA CREACIÓN: 20260928
# FECHA MODIFICACIÓN: -
# VERSIÓN: v1.0
# DESCRIPCIÓN:       Valida la existencia, integridad y formato de un archivo de datos, comprobando variables críticas (sample_id, temperature) y la ausencia de errores (ERROR, NA).
# USO:               ./check_data.sh <ruta_del_archivo>
# REQUISITOS:        Requiere Bash y el comando estándar 'grep'.
# VALORES DE SALIDA (EXIT CODES):
#   0 : El archivo es válido y cumple todos los requisitos.
#   1 : Error de sintaxis, archivo no encontrado, vacío o corrupto.
# ==============================================================================

# ==============================================================================
# 1. VALIDACIÓN DE ARGUMENTOS
# ==============================================================================
# Comprobamos que el usuario haya pasado exactamente 1 argumento al script.
# -ne significa "Not Equal". $# almacena el número total de argumentos.
if [[ "$#" -ne 1 ]]; then
    printf "\nError: El script necesita exactamente un argumento (la ruta del archivo).\n\n"
    exit 1
fi  

# Guardamos el primer y único argumento ($1) en una variable descriptiva con comillas para evitar problemas si la ruta contiene espacios.
RUTA_COMPLETA="$1"

# ==============================================================================
# 2. EXTRACCIÓN DE METADATOS
# ==============================================================================
# Usamos nuevos comandos [estándar] para desglosar la ruta:
# - 'basename' obtiene solo el nombre del archivo (ej. "exp007_day2.txt").
# - 'dirname' obtiene la ruta de la carpeta que lo contiene (ej. "../campaign_A/raw_data").
# También podrían usarse sustituciones de bash "${RUTA_COMPLETA##*/}" y "${RUTA_COMPLETA%/*}", o con el rev: $(echo "$RUTA_COMPLETA" | rev | cut -d/ -f1 | rev) y $(echo "$RUTA_COMPLETA" | rev | cut -d/ -f2- | rev)
NOMBRE="$(basename "$RUTA_COMPLETA")"
CARPETA="$(dirname "$RUTA_COMPLETA")"

printf "\nChecking: %s\n" "$NOMBRE"
printf "=========================================\n\n"

# ==============================================================================
# 3. CONTROL DE EXISTENCIA DEL ARCHIVO
# ==============================================================================
# El operador '-f' evalúa si la ruta completa corresponde a un archivo regular ("normal") existente.
if [[ -f "$RUTA_COMPLETA" ]]; then
    printf "File exists:\tOK\n"
    printf "Folder:\t\t%s\n" "$CARPETA"
else
    # Si el archivo no existe, no podemos continuar. Imprimimos el estado de advertencia (WARNING/NA) y paramos la ejecución con código de error 1.
    printf "File exists:\tWARNING\n"
    printf "Folder:\t\t%s\n" "$CARPETA"
    printf "File not empty:\tNA\n"
    printf "sample_id:\tNA\n"
    printf "temperature:\tNA\n"
    printf "ERROR values:\tNA\n"
    printf "NA values:\tNA\n\n"
    printf "RESULT:\tPROBLEM FOUND\n\n"
    exit 1
fi

# Inicializamos una bandera (flag) booleana en 'true'.
# Si alguna comprobación posterior falla, cambiará a 'false'.
RESULTADO_OK=true

# ==============================================================================
# 4. CONTROL DE ARCHIVO VACÍO
# ==============================================================================
# El operador '-s' comprueba si el archivo existe y tiene un tamaño mayor a 0 bytes.
if [[ -s "$RUTA_COMPLETA" ]]; then
    printf "File not empty:\tOK\n"
else
    # Si está vacío, se detiene la ejecución inmediatamente.
    printf "File not empty:\tWARNING\n"
    printf "sample_id:\tNA\n"
    printf "temperature:\tNA\n"
    printf "ERROR values:\tNA\n"
    printf "NA values:\tNA\n\n"
    printf "RESULT:\tPROBLEM FOUND\n\n"
    exit 1
fi

# ==============================================================================
# 5. VALIDACIÓN DE CONTENIDO: "sample_id"
# ==============================================================================
# Buscamos la línea que contiene la etiqueta "sample_id".
FRASE="sample_id"
# la expresión se corresponde con "cualquier cosa", seguida por "sample" (cada caracter puede estar en minúscula o mayúscula), seguida por "-" o "_", seguida por "id" (cada caracter puede estar en minúscula o mayúscula), seguida por ":" o "="
MATCH="*[sS][aA][mM][pP][lL][eE][_-][iI][dD][:=]"

# Filtramos con 'grep -i' (insensible a mayúsculas) y tomamos solo la primera línea (por si acaso hubiera varias).
LINEA=$(grep -i "$FRASE" "$RUTA_COMPLETA" | head -n 1)

if [[ -z "$LINEA" ]]; then
    # El operador '-z' comprueba si una cadena de texto está vacía.
    printf "${FRASE}:\tWARNING\n"
    RESULTADO_OK=false
else
    # Eliminamos el patrón coincidente con la etiqueta usando la expansión de Bash. (p.ej. en ${var//d/s} sustituye todas las "d" por "s" en el contenido de la variable var. Si después de / no hay nada, simplemente lo elimina)
    DATO="${LINEA//$MATCH/}"
    # Quitamos los espacios en blanco para comprobar si realmente hay un valor escrito.
    DATO_sin_espacios="${DATO// /}"
    
    if [[ -z "$DATO_sin_espacios" ]]; then
        printf "${FRASE}:\tWARNING\n"
        RESULTADO_OK=false
    else
        printf "${FRASE}:\tOK\n"
    fi
fi

# ==============================================================================
# 6. VALIDACIÓN DE CONTENIDO: "temperature"
# ==============================================================================
# Buscamos la línea que contiene la etiqueta "temperature", reutilizamos la variable FRASE
FRASE="temperature"
# la expresión se corresponde con "cualquier cosa", seguida por "temperature" (cada caracter puede estar en minúscula o mayúscula),  seguida por ":" o "=", reutilizamos la variable MATCH
MATCH="*[tT][eE][mM][pP][eE][rR][aA][tT][uU][rR][eE][:=]"

# Filtramos con 'grep -i' (insensible a mayúsculas) y tomamos solo la primera línea (por si acaso hubiera varias). La parte de código siguiente es igual al del apartado anterior. Reutilizamos los nombres de las variables utilizadas
LINEA=$(grep -i "$FRASE" "$RUTA_COMPLETA" | head -n 1)

if [[ -z "$LINEA" ]]; then
    # El operador '-z' comprueba si una cadena de texto está vacía.
    printf "${FRASE}:\tWARNING\n"
    RESULTADO_OK=false
else
    # Eliminamos el patrón coincidente con la etiqueta usando la expansión de Bash. (p.ej. en ${var//d/s} sustituye todas las "d" por "s" en el contenido de la variable var. Si después de / no hay nada, simplemente lo elimina)
    DATO="${LINEA//$MATCH/}"
    # Quitamos los espacios en blanco para comprobar si realmente hay un valor escrito.
    DATO_sin_espacios="${DATO// /}"
    
    if [[ -z "$DATO_sin_espacios" ]]; then
        printf "${FRASE}:\tWARNING\n"
        RESULTADO_OK=false
    else
        printf "${FRASE}:\tOK\n"
    fi
fi

# ==============================================================================
# 7. COMPROBACIÓN DE VALORES DE ERROR ("ERROR")
# ==============================================================================
# El símbolo '!' invierte el resultado del condicional.
# 'grep -qi' busca la palabra sin imprimir nada en pantalla (-q de quiet, -i de case-insensitive).
# Traducido: "Si NO se encuentra la palabra ERROR en el archivo..."
if ! grep -qi "ERROR" "$RUTA_COMPLETA"; then
    printf "ERROR values:\tOK\n"
else
    printf "ERROR values:\tWARNING\n"
    RESULTADO_OK=false
fi

# ==============================================================================
# 8. COMPROBACIÓN DE VALORES NO DISPONIBLES ("NA")
# ==============================================================================
# El símbolo '!' invierte el resultado del condicional.
# 'grep -qi' busca la palabra sin imprimir nada en pantalla (-q de quiet, -i de case-insensitive).
# Traducido: "Si NO se encuentra la palabra NA en el archivo..."
if ! grep -qi "NA" "$RUTA_COMPLETA"; then
    printf "NA values:\tOK\n\n"
else
    printf "NA values:\tWARNING\n\n"
    RESULTADO_OK=false
fi

# ==============================================================================
# 9. EVALUACIÓN final Y TERMINACIÓN del programa
# ==============================================================================
# Evaluamos directamente el contenido de la variable $RESULTADO_OK.
# Dado que almacena 'true' o 'false' (que son comandos nativos en Bash), no requerimos usar corchetes '[[ ... ]]'. El condicional 'if' ejecutará el comando y reaccionará a su salida.
if "$RESULTADO_OK"; then
    printf "RESULT:\tOK\n\n"
else
    printf "RESULT:\tPROBLEM FOUND\n\n"
    exit 1
fi

exit 0
