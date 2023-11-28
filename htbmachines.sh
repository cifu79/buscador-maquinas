#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function ctr_c(){
    echo -e "\n\n\t${redColour}Saliendo...${endColour}\n"
    tput cnorm;exit 1
}

#ctrl_c
trap ctr_c INT

#variables globales
main_url="https://htbmachines.github.io/bundle.js"

function helpPanel(){
    echo -e "\n${yellowColour}[+]${endColour}${grayColour}Uso: ${endColour}"
    echo -e "\t${purpleColour}u)${endColour}${grayColour} Descargar archivos necesarios${endColour}"
    echo -e "\t${purpleColour}m)${endColour}${grayColour} Buscar por un nombre de maquina${endColour}"
    echo -e "\t${purpleColour}i)${endColour}${grayColour} Buscar por direccion IP${endColour}"
    echo -e "\t${purpleColour}d)${endColour}${grayColour} Buscar por la dificultad de una maquina${endColour}"
    echo -e "\t${purpleColour}o)${endColour}${grayColour} Buscar por el sistema operativo${endColour}"
    echo -e "\t${purpleColour}y)${endColour}${grayColour} Obtener enlace de la resolucion de la maquina en youtube${endColour}"
    echo -e "\t${purpleColour}h)${endColour}${grayColour} Mostrar este panel de ayuda${endColour}"

}

function searchMachine(){
    machineName="$1"

    machineNameChecker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//')"

    if [ "$machineNameChecker" ];then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando las propiedades de la maquina${endColour} ${blueColour}$machineName${endColour}${grayColour}:${endColour}\n"
        cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//'
    else
        echo -e "\n${redColour}[!] La maquina proporcionada no existe${endColour}\n"
    fi
}

function updateFiles(){
    if [ ! -f bundle.js ];then
        tput civis
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Descargando archivos necesarios${endColour}"
        curl -s $main_url > bundle.js
        js-beautify bundle.js | sponge bundle.js
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Todos los archivos han sido descargados${endColour}"
        tput cnorm
    else
        tput civis
        echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Comprobando si hay actualizaciones pendientes...${endColour}"
        curl -s $main_url > bundle_temp.js
        js-beautify bundle_temp.js | sponge bundle_temp.js
        md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}') 
        md5_original_value=$(md5sum bundle.js | awk '{print $1}') 

        if [ "$md5_temp_value" == "$md5_original_value" ];then
            echo -e "\n${yellowColour}[+]${endColour}${grayColour} No se han detectado actualizaciones, lo tienes todo al dia${endColour}"
            rm bundle_temp.js
        else
            echo "\n${yellowColour}[+]${endColour}${grayColour} Se han encontrado actualizaciones disponibles${endColour}"
            sleep 1
            rm bundle.js && mv bundle_temp.js bundle.js
            echo -e "\n${yellowColour}[+]${endColour}${grayColour} Los archivos han sido actualizados${endColour}"
        fi
        tput cnorm
    fi
}

function searchIP(){
    ipAddress="$1"
    
    machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ",")"

    if [ "$machineName" ];then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} La maquina correspondiente para la IP${endColour}${blueColour} $ipAddress${endColour}${grayColour} es${endColour}${purpleColour} $machineName${endColour}\n"
    else
        echo -e "\n${redColour}[!] La direccion ip proporcionada no existe ${endColour}"
    fi
}

function getYoutubeLInk(){
    # cat bundle.js | awk "/name: \"Forge\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep youtube | awk 'NF{print $NF}'
    machineName="$1"
    youtubeLink="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep youtube | awk 'NF{print $NF}')"

    if [ "$youtubeLink" ];then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} El tutorial para esta maquina esta en el siguiente enlace:${endColour} ${blueColour}$youtubeLink${endColour}"
    else
        echo -e "\n${redColour}[!] La maquina proporcionada no existe${endColour}"
    fi
}

function getMachineDifficulty(){
    difficulty="$1"
    results_check="$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

    if [ "${results_check}" ];then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Representando las maquinas que poseen un nivel de dificultad${endColour} ${blueColour}$difficulty${endColour}${grayColour}:${endColour}\n"
        cat bundle.js | grep "dificultad: \"Insane\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
    else
        echo -e "\n${redColour}[!] La dificultad indicada no existe${endColour}"
    fi
}

function getOSMachines(){
    os="$1"
    os_results="$(cat bundle.js | grep "so: \"$os\"" -B 4 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

    if [ "$os_results" ];then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Mostrando las maquinas cuyo sistema operativo es${endColour}${blueColour} $os${endColour}${grayColour}:${endColour}\n"
        cat bundle.js | grep "so: \"$os\"" -B 4 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
    else
        echo -e "\n${redColour}[!] El sistema operativo indicado no existe${endColour}\n"
    fi
}

function getOSDifficultyMachines(){
    difficulty="$1"
    os="$2"

    check_results="$(cat bundle.js | grep "so: \"$os\"" -C 5 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
    
    if [ "$check_results" ];then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando maquinas de dificultad${endColour} ${blueColour}$difficulty${endColour}${grayColour} que tengan sistema operativo${endColour}${purpleColour} $os${endColour}${grayColour}:${endColour}\n"
        cat bundle.js | grep "so: \"$os\"" -C 5 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
    else
        echo -e "\n${redColour}[!] Se ha indicado una dificultad o sistema operativo incorrectos${endColour}"
    fi
}

#indicadores
declare -i parameter_counter=0

#chivatos
declare -i chivato_difficulty=0
declare -i chivato_os=0

while getopts "m:ui:y:d:o:h" args; do
    case $args in
        m) machineName="$OPTARG"; let parameter_counter+=1;;
        u) let parameter_counter+=2;;
        i) ipAddress="$OPTARG"; let parameter_counter+=3;;
        y) machineName="$OPTARG"; let parameter_counter+=4;;
        d) difficulty="$OPTARG";chivato_difficulty=1; let parameter_counter+=5;;
        o) os="$OPTARG";chivato_os=1; let parameter_counter+=6;;
        h) ;;
    esac
done

if [ $parameter_counter -eq 1 ];then
    searchMachine $machineName
elif [ $parameter_counter -eq 2 ];then
    updateFiles
elif [ $parameter_counter -eq 3 ];then
    searchIP $ipAddress
elif [ $parameter_counter -eq 4 ];then
    getYoutubeLInk $machineName
elif [ $parameter_counter -eq 5 ];then
    getMachineDifficulty $difficulty
elif [ $parameter_counter -eq 6 ];then
    getOSMachines $os
elif [ $chivato_difficulty -eq 1 ] && [ $chivato_os -eq 1 ];then
    getOSDifficultyMachines $difficulty $os
else
    helpPanel
fi