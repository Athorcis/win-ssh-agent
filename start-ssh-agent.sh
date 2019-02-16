#!/bin/bash

function pid {
    echo $(ps -u $USERNAME | grep $1 | head -n 1 | awk '{print $1}')
}

# Le chemin du socket ssh-agent
socket=~/.ssh/socket

# On récupèrle pid de ssh-agent
pid=$(pid ssh-agent)

# Le chemin de la clé à ajouter
identity=~/.ssh/id_rsa

# Vaut 1 si il faut ajouté la clé
sshAddRequired=1

# Si on a trouvé ssh-agent
if [ -n "$pid" ]
then
    # On exporte le chemin du socket ainsi que son pid 
    export SSH_AUTH_SOCK=$socket
    export SSH_AGENT_PID=$pid
    
    # On récupère la liste des clés ajoutées à ssh-agent
    loadedIdentities=$(ssh-add -l | awk '{print $3}')
    
    # On parcours la liste des clés
    for loadedIdentity in "$loadedIdentities"
    do
        # Si on trouve la clé que l'on voulait ajouter
        if [ $identity = "$loadedIdentity" ]
        then
            # Alors pas besoin de l'ajouter
            sshAddRequired=0
            break
        fi
    done

# Sinon
else
    # Si on trouve un socket encore présent
    if [ -f $socket ] || [ -S $socket ]
    then
    
        # On le supprime
        rm $socket
    fi

    # Puis on lance ssh-agent
    eval $(ssh-agent -a $socket) > /dev/null
fi

# Si notre clé n'est pas encore ajoutée
if [ $sshAddRequired -eq 1 ]
then
    
    # On l'ajoute
    ssh-add $identity
    
    # Puis on vide la sortie du shell
    printf "\ec"
fi

# Si le script a été appelé en mode "cmd"
if [ "$1" = "cmd-mode" ]
then
    
    # Alors on dump les variables exportés dans un fichier cmd
    tee ~/.ssh/env.tmp.cmd > /dev/null <<EOF
SET SSH_AUTH_SOCK=$(cygpath -w $SSH_AUTH_SOCK)
SET SSH_AGENT_PID=$SSH_AGENT_PID
EOF
fi
