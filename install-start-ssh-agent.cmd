@ECHO OFF

REM On active l'UTF-8
CHCP 65001 > NUL

REM On récupère le répertoire qui contient les scripts
SET scriptDir=%~dp0

REM On construit le chemin du script batch
SET cmdScript=%scriptDir%start-ssh-agent.cmd

REM On construit le chemin du script bash
SET bashScript=%scriptDir:\=/%start-ssh-agent.sh

REM On déclare la clé et le nom de la valeur du registre
SET regKey=HKCU\Software\Microsoft\Command Processor
SET regName=AutoRun

REM On récupère la valeur stockée dans le registre
FOR /F "tokens=2*" %%G IN ('REG QUERY "%regKey%" /v "%regName%" 2^> NUL') DO SET regValue=%%H

REM Si le registre ne contient pas la valeur
IF "%regValue%"=="" (

	REM On ajoute la valeur au registre
	REG ADD "%regKey%" /v "%regName%" /d "%cmdScript%" > NUL

	REM On ajoute également le script bash au .bashrc
	ECHO %bashScript%>> "%HOMEDRIVE%%HOMEPATH%\.bashrc"
	
	ECHO installation terminée
REM Si le registre contient déjà la valeur
) ELSE ( IF "%regValue%"=="%cmdScript%" (
	ECHO start-ssh-agent est déjà installé

REM Si le registre contient une autre valeur
) ELSE (
	ECHO erreur: %regKey% %regName% est déjà défini: %regValue%
))
