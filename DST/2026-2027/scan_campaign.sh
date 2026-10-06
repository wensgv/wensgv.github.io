#!/bin/bash

# ==============================================================================
# PREÁMBULO / CABECERA DE DOCUMENTACIÓN
# ==============================================================================
# NOMBRE DEL SCRIPT: scan_campaign.sh
# AUTOR: Wenceslao González wens@unav.es
# FECHA CREACIÓN: 20261027
# FECHA MODIFICACIÓN: -
# VERSIÓN: v1.0
# DESCRIPCIÓN:       Comprueba (con check_data.sh) todos los ficheros de datos de una campaña, indicando (en pantalla) si tienen algún error o no, y contando cuantos ficheros hay y cuantos tienen errores.
# USO:               ./scan_campaign.sh <nombre_de_la_campaña>
# REQUISITOS:        Requiere Bash y el uso del script check_data.sh funcional.
# VALORES DE SALIDA (EXIT CODES):
#   0 : El script se ha ejecutado correctamente.
#   1 : Error en número de argumentos, existencia de la carpeta de datos, o existencia de ficheros de datos dentro.
# ==============================================================================

# ==========================================
# 1. Validación de los argumentos de entrada
# ==========================================
# Comprueba si el número de argumentos ($#) NO es igual (-ne) a 1.
if [[ "$#" -ne 1 ]]; then
    printf "\nError: El script necesita exactamente un argumento (el nombre de la campaña).\n\n"
    exit 1  # Finaliza la ejecución con código de error 1
fi  

# ==========================================
# 2. Comprobación de la existencia del directorio
# ==========================================
# Define la ruta de la carpeta basándose en el argumento recibido ($1)
CARPETA="../${1}/raw_data"

# Comprueba si la ruta NO es un directorio existente (! [[ -d ... ]])
if ! [[ -d "$CARPETA" ]]; then 
	printf "\nError: La carpeta donde se espera que estén los ficheros de la campaña indicada ($CARPETA) no existe.\n\n"
	exit 1 # Finaliza la ejecución con código de error 1
fi

# ==========================================
# 3. Comprobación de carpeta vacía
# ==========================================
# Cuenta los elementos dentro del directorio listándolos y contando las líneas
# Si todo estuviera como esperamos NUM contendría el número de ficheros procesados
NUM=$(ls "$CARPETA" | wc -l)

# Si el número de archivos/elementos es igual a 0, lanza un error
if [[ "$NUM" -eq 0 ]] ; then
	printf "\nError: La carpeta raw_data de la campaña $1 está vacía.\n\n"
	exit 1 # Finaliza la ejecución con código de error 1
fi

# ==========================================
# 4. Impresión de la cabecera del informe
# ==========================================
printf "\n===================\n"
printf "Campaign inspection\n"
printf "===================\n"
printf "Campaign: ${1}\n"
printf "Folder: ${CARPETA}\n\n"

# ==========================================
# 5. Inspección y análisis de los ficheros
# ==========================================
N="0"       # Contador total de archivos analizados
NPROBLEM="0"       # Contador de archivos con errores

# Bucle que recorre cada elemento dentro de la carpeta
for FILE in $CARPETA/*; do
	# Si el elemento no es un fichero regular (por ejemplo, es una subcarpeta), se omite
    if ! [[ -f $FILE ]]; then
		continue
	fi
	# Imprime el nombre del archivo alineado a la izquierda en un campo de 23 caracteres
    printf "%-27s" $(basename $FILE)
	# Ejecuta el script externo 'check_data.sh' pasando el archivo como parámetro.
    # Redirige la salida estándar y de errores a /dev/null para que no se muestren en pantalla.
    bash check_data.sh $FILE > /dev/null 2>&1
	
	# Comprueba el estado de salida ($?) del último script ejecutado (check_data.sh)
    if [[ "$?" -eq "0" ]]; then
		printf "OK\n"  # Si devuelve 0, el archivo está correcto
	else
		printf "PROBLEM FOUND\n"  # Si devuelve un código distinto de 0, hay un problema
		((NPROBLEM++))  # Incrementa el contador de problemas
	fi
	
	((N++))  # Incrementa el contador de archivos procesados
done

# ==========================================
# 6. Resumen de resultados
# ==========================================
printf "\n--------------------------------\n"
printf "Files checked: ${N}\n"
printf "Problems found: ${NPROBLEM}\n\n"
exit 0  # Finaliza el script con éxito (código 0)
