#!/bin/bash

# Echo usage if something isn't right.
usage() { 
cat <<EOF
Usage: ./diable-local-user-sh [-dra] USER [USERN]
inhabilita usuaris local de linux
    -d Borra una conta
    -r Borra els directori associat amb la conta
    -a Crea un archive del home directori de les contes
EOF
exit 1
}
 
while getopts :dra o; do
    case "${o}" in
        d)
            delete=true
            ;;
        r)
            rd=true
            ;;
        a)  
            archive=true
            ;;
        :)  
            echo "ERROR: Option -$OPTARG requires an argument"
            #usage
            ;;
        \?)
            echo "ERROR: Invalid option -$OPTARG"
            #usage
            ;;
        *)
            echo "Unknown Error"
            ;;
    esac
done

shift $((OPTIND-1))

if [$(id -u) -eq 0];then
    if [$# -ne 0]; then
        for user in $@; do
            echo "Procesando usuario: $user"
            if id -u "$user" > /dev/null 2>&1 ; then
                if [$(id -u $user) -gt 999]; then
                    if [$archive]; then
                        if [! /archive/]; then
                            mkdir /archive/
                         echo "Creando directorio /archive"
                        fi
                        echo "Archivando /archive/$user a /archive/$user.tgz"
                        tar czvz /archive/$user.tgz /home/$user > dev/null 2>&1
                    fi
                    if [ $rd]; then
                        rm -rf /home/$user
                        if [ $? -eq 0];then
                            echo "El directorio /home/$user ha sido eliminado";
                        else
                            echo "El directori /home/$user no se ha podido eliminar";
                            fi
                        fi
                    if [$delete]; then
                            userdel -r $user
                        if [$? -eq 0];then
                            echo "El usuari: $user ha sido eliminado";
                        else
                            echo "El usuari: $user no ha sido eliminado";
                        fi
                    fi
                    if  [ ! $archive] && [! $rd] && [! $delete]; then
                        usermode -L $user
                        echo "La cuenta $user ha sido deshabilitada."
                    fi

                else
                    echo "No se puede eliminat el $user ."
            fi
        fi        
    done
        usage
    fi

else
    echo "Porfavor inicia con root o sudo";exit 1

fi
