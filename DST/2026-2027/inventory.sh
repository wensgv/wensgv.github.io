#!/bin/bash

clear
campanya=$1
carpeta_dat="../$campanya/raw_data"
carpeta_res="../results"
mkdir -p $carpeta_res
fichero_res="${carpeta_res}/inventario_${campanya}.txt"
printf "Inventory report\n================\n\n" > $fichero_res

# !! si se quisiera el directorio absoluto
## OPCION A: (antes de la siguiente linea no comentada añadir, descomentando:)
# carpeta_dat=$(cd $carpeta_dat;pwd)
## OPCION B: (comandos nuevos, antes de la siguiente linea no comentada añadir, descomentando:))
# carpeta_dat=$(realpath $carpeta_dat)
printf "Directory: %s\n\n" $carpeta_dat >> $fichero_res

printf "Number of files: %s\n" $(echo ${carpeta_dat}/* | wc -w) >> $fichero_res
printf "\n" >> $fichero_res

## OPCION A
printf "TXT files: %s\n" $(echo ${carpeta_dat}/*.[tT][xX][tT] | wc -w) >> $fichero_res
printf "CSV files: %s\n" $(echo ${carpeta_dat}/*.[cC][sS][vV] | wc -w) >> $fichero_res
printf "LOG files: %s\n" $(echo ${carpeta_dat}/*.[lL][oO][gG] | wc -w) >> $fichero_res

## OPCION B (comentar la opcion A y descomentar las siguientes 7 lineas:)
# extensiones=$(ls -A $carpeta_dat | rev | cut -d. -f1 | rev | sort)
# TXT_files=$(echo "$extensiones" | grep -i "txt"| wc -l) 
# CSV_files=$(echo "$extensiones" | grep -i "csv"| wc -l) 
# LOG_files=$(echo "$extensiones" | grep -i "log"| wc -l) 
# printf "TXT files: %s\n" $TXT_files >> $fichero_res
# printf "CSV files: %s\n" $CSV_files >> $fichero_res
# printf "LOG files: %s\n" $LOG_files >> $fichero_res

## OPCION C (comandos nuevos, comentar la opcion A y descomentar las siguientes 5 lineas:)
# shopt -s nocaseglob
# printf "TXT files: %s\n" $(echo ${carpeta_dat}/*.txt | wc -w) >> $fichero_res
# printf "CSV files: %s\n" $(echo ${carpeta_dat}/*.csv | wc -w) >> $fichero_res
# printf "LOG files: %s\n" $(echo ${carpeta_dat}/*.log | wc -w) >> $fichero_res
# shopt -u nocaseglob
#

printf "Inventario generado de la campaña seleccionada\n"
