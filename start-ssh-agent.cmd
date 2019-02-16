@ECHO OFF

REM On active l'UTF-8
CHCP 65001 > NUL

REM Si on se trouve dans un shell appelé par start-ssh-agent.cmd
IF "%START_SSH_AGENT%"=="1" (

	REM On s'arrête là (surtout pas de EXIT ça terminerait le shell courant)
	GOTO EOF
)

REM On créé la variable indiquant que start-ssh-agent.cmd a été appelé
SET START_SSH_AGENT=1

REM On récupère le chemin de la commande git
FOR /F "tokens=*" %%G IN ('WHERE git') DO (SET GIT=%%G)

REM On en déduit le répertoire d'installation de git
SET GIT_HOME=%GIT:\cmd\git.exe=%

REM On construit le chemin de la commande bash
SET BASH=%GIT_HOME%\bin\bash.exe

REM On lance ssh-agent si il n'est pas déjà lancé
REM et on créé le script qui défini les variables
REM d'environnement utilisées par SSH
"%BASH%" "%~dp0\start-ssh-agent.sh" cmd-mode

REM On construit le chemin vers ce script
SET SSH_ENV=%HOMEDRIVE%%HOMEPATH%\.ssh\env.tmp.cmd

REM On exécute ce script, puis on le supprime
REM On le fait en une ligne car l'appel de scripts sans CALL
REM quitte le script parent quand le script enfant a terminé
"%SSH_ENV%" && DEL "%SSH_ENV%"

:EOF
