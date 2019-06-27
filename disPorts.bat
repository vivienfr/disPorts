@echo off
REM Arcep disPorts: Preuve de concept d'un test de blocage de ports pour Windows.
REM Le script proposé pour inciter le dévellopement d'une véritable application pour réaliser ces tests.
REM Version 0.1 - Script perfectible, crée par Vivien GUEANT
REM Vous êtes invités à contribuer sur https://github.com/ARCEP-dev/disPorts - License MIT
REM Les problèmes détectés ne correspondent pas nécessairement à des problématiques de neutralité du net.
REM Ils peuvent être remontés via https://jalerte.arcep.fr/

REM ====== IMPORTANT : Prérequis pour l'éxécution ======
REM Nécessite curl.exe dans le même dossier que le fichier disPorts.bat
REM Téléchargement de CURL sur https://curl.haxx.se/windows/

if exist "curl.exe" goto menu
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo !! ERREUR :                   !!
echo !! curl.exe absent du dossier !!
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo.
echo Merci de placer le fichier "curl.exe" dans le mˆme dossier
echo que test-neutralite.bat
echo.
echo curl.exe est disponible … cette adresse :
echo https://lafibre.info/testdebit/curl/test-neutralite.zip
echo.
echo Rendez-vous sur https://LaFibre.info en cas de problŠme.
echo.
echo Appuyez sur une touche pour quitter.
pause >NUL
goto Fin

REM MENU POUR SELECTIONNER LA TAILLE DU FICHIER A TELECHARGER
:menu
echo "################################################################"
echo "##  Arcep           _ _     _____           _                 ##"
echo "##                 | (_)   |  __ \         | |                ##"
echo "##               __| |_ ___| |__) |__  _ __| |_ ___           ##"
echo "##              / _` | / __|  ___/ _ \| '__| __/ __|          ##"
echo "##             | (_| | \__ \ |  | (_) | |  | |_\__ \          ##"
echo "##              \__,_|_|___/_|   \___/|_|   \__|___/          ##"
echo "##                                                            ##"
echo "## TEST DE DEBIT ET DE NEUTRALITE, en http et en https        ##"
echo "## Test chaque port, du port TCP 1 au port TCP 32767          ##"
echo "## Test r‚alis‚ en IPv4, puis en IPv6 si IPv6 est disponible  ##"
echo "## Rien n'est ‚crit sur le disque dur. D‚bit mesur‚ sur 1sec  ##"
echo "################################################################"
echo.
echo Choisir une mire de test :
echo ----------------------------------------------------------------
echo 1. 10 Gb/s bouygues.testdebit.info (Bouygues Telecom AS5410)
echo 2. 1 Gb/s  k-net.testdebit.info (K-Net AS24904)
echo 3. 1 Gb/s  ikoula.testdebit.info (Ikoula AS21409)
echo 4. 10 Gb/s scaleway.testdebit.info (Scaleway AS12876)
echo q. Quitter imm‚diatement sans r‚aliser de test de d‚bit
echo. 
echo Exemple: Taper "1" pour le serveur de Bouygues Telecom.
set choice=
set /p choice=Votre choix ? 
if not '%choice%'=='' set choice=%choice:~0,1%
if /i %choice%==q goto Fin
set ul=0
set mire=bouygues.testdebit.info
if %choice%==1 set mire=bouygues.testdebit.info
if %choice%==2 set mire=k-net.testdebit.info
if %choice%==3 set mire=ikoula.testdebit.info
if %choice%==4 set mire=scaleway.testdebit.info
cls
for /f "delims=/ tokens=1,2,3" %%a in ('date /t') do set jour=%%a
for /f "delims=/ tokens=1,2,3" %%a in ('date /t') do set mois=%%b
for /f "delims=/ tokens=1,2,3" %%a in ('date /t') do set annee=%%c
echo %jour%/%mois%/%annee%%time:~0,8% T‚l‚chargement depuis %mire% :


REM IPv4: Download port 80 (http)
for /f "tokens=1-6" %%i in ('curl --max-time 1 -4 -s --write-out "%%{time_namelookup} %%{time_connect} %%{time_starttransfer} %%{time_total} %%{size_download}" -o NUL http://%mire%/1G.iso') do (
	set namelookup=%%i
	set connect=%%j
	set starttransfer=%%k
	set total=%%l
	set size=%%m
)
set namelookup=%namelookup:,=%
set /a namelookup = 1%namelookup%-(11%namelookup%-1%namelookup%)/10
set /a namelookupMS = %namelookup%/1000
set connect=%connect:,=%
set /a connect = 1%connect%-(11%connect%-1%connect%)/10
set /a connectMS = %connect%/1000
set /a PingMS=connectMS-namelookupMS
set starttransfer=%starttransfer:,=%
set /a starttransfer = 1%starttransfer%-(11%starttransfer%-1%starttransfer%)/10
set /a starttransferMS = %starttransfer%/1000
set /a GetMS=starttransferMS-connectMS
set total=%total:,=%
set /a total = 1%total%-(11%total%-1%total%)/10
set /a totalMS = %total%/1000
set /a temps_transfert=total-starttransfer
set /a temps_transfertMS=totalMS-starttransferMS
set /a sizeKO = %size%/1000
set /a temps_calcul = temps_transfert/8000
set /a Debit_utileMB = size/(temps_calcul*1000)
set /a Debit_utileKB = size/temps_calcul
set /a Debit_utileDE=Debit_utileKB-(Debit_utileMB*1000)
echo IPv4 Port80     http : %Debit_utileMB%,%Debit_utileDE% Mb/s - %sizeKO% Ko (DNS:%namelookupMS%ms+SYN:%PingMS%ms+GET:%GetMS%ms+Down:%temps_transfertMS%ms)

REM IPv4: Download port 81 (http)
for /f "tokens=1-6" %%i in ('curl --max-time 1 -4 -s --write-out "%%{time_namelookup} %%{time_connect} %%{time_starttransfer} %%{time_total} %%{size_download}" -o NUL http://%mire%:81/1G.iso') do (
	set namelookup=%%i
	set connect=%%j
	set starttransfer=%%k
	set total=%%l
	set size=%%m
)
set namelookup=%namelookup:,=%
set /a namelookup = 1%namelookup%-(11%namelookup%-1%namelookup%)/10
set /a namelookupMS = %namelookup%/1000
set connect=%connect:,=%
set /a connect = 1%connect%-(11%connect%-1%connect%)/10
set /a connectMS = %connect%/1000
set /a PingMS=connectMS-namelookupMS
set starttransfer=%starttransfer:,=%
set /a starttransfer = 1%starttransfer%-(11%starttransfer%-1%starttransfer%)/10
set /a starttransferMS = %starttransfer%/1000
set /a GetMS=starttransferMS-connectMS
set total=%total:,=%
set /a total = 1%total%-(11%total%-1%total%)/10
set /a totalMS = %total%/1000
set /a temps_transfert=total-starttransfer
set /a temps_transfertMS=totalMS-starttransferMS
set /a sizeKO = %size%/1000
set /a temps_calcul = temps_transfert/8000
set /a Debit_utileMB = size/(temps_calcul*1000)
set /a Debit_utileKB = size/temps_calcul
set /a Debit_utileDE=Debit_utileKB-(Debit_utileMB*1000)
echo IPv4 Port81     http : %Debit_utileMB%,%Debit_utileDE% Mb/s - %sizeKO% Ko (DNS:%namelookupMS%ms+SYN:%PingMS%ms+GET:%GetMS%ms+Down:%temps_transfertMS%ms)

REM IPv4: Download port 443 (https)
for /f "tokens=1-6" %%i in ('curl --max-time 1 -4 -s --write-out "%%{time_namelookup} %%{time_connect} %%{time_starttransfer} %%{time_total} %%{size_download}" -o NUL https://%mire%/1G.iso') do (
	set namelookup=%%i
	set connect=%%j
	set starttransfer=%%k
	set total=%%l
	set size=%%m
)
set namelookup=%namelookup:,=%
set /a namelookup = 1%namelookup%-(11%namelookup%-1%namelookup%)/10
set /a namelookupMS = %namelookup%/1000
set connect=%connect:,=%
set /a connect = 1%connect%-(11%connect%-1%connect%)/10
set /a connectMS = %connect%/1000
set /a PingMS=connectMS-namelookupMS
set starttransfer=%starttransfer:,=%
set /a starttransfer = 1%starttransfer%-(11%starttransfer%-1%starttransfer%)/10
set /a starttransferMS = %starttransfer%/1000
set /a GetMS=starttransferMS-connectMS
set total=%total:,=%
set /a total = 1%total%-(11%total%-1%total%)/10
set /a totalMS = %total%/1000
set /a temps_transfert=total-starttransfer
set /a temps_transfertMS=totalMS-starttransferMS
set /a sizeKO = %size%/1000
set /a temps_calcul = temps_transfert/8000
set /a Debit_utileMB = size/(temps_calcul*1000)
set /a Debit_utileKB = size/temps_calcul
set /a Debit_utileDE=Debit_utileKB-(Debit_utileMB*1000)
echo IPv4 Port443    https: %Debit_utileMB%,%Debit_utileDE% Mb/s - %sizeKO% Ko (DNS:%namelookupMS%ms+SYN:%PingMS%ms+GET:%GetMS%ms+Down:%temps_transfertMS%ms)

set port=0
:bv4down
set /a port = port + 1
if %port%==32768 goto finbv4down
REM IPv4: Download port %port% (https)
for /f "tokens=1-6" %%i in ('curl --max-time 1 -4 -s --write-out "%%{time_namelookup} %%{time_connect} %%{time_starttransfer} %%{time_total} %%{size_download}" -o NUL https://%mire%:%port%/1G.iso') do (
	set namelookup=%%i
	set connect=%%j
	set starttransfer=%%k
	set total=%%l
	set size=%%m
)
set namelookup=%namelookup:,=%
set /a namelookup = 1%namelookup%-(11%namelookup%-1%namelookup%)/10
set /a namelookupMS = %namelookup%/1000
set connect=%connect:,=%
set /a connect = 1%connect%-(11%connect%-1%connect%)/10
set /a connectMS = %connect%/1000
set /a PingMS=connectMS-namelookupMS
set starttransfer=%starttransfer:,=%
set /a starttransfer = 1%starttransfer%-(11%starttransfer%-1%starttransfer%)/10
set /a starttransferMS = %starttransfer%/1000
set /a GetMS=starttransferMS-connectMS
set total=%total:,=%
set /a total = 1%total%-(11%total%-1%total%)/10
set /a totalMS = %total%/1000
set /a temps_transfert=total-starttransfer
set /a temps_transfertMS=totalMS-starttransferMS
set /a sizeKO = %size%/1000
set /a temps_calcul = temps_transfert/8000
set /a Debit_utileMB = size/(temps_calcul*1000)
set /a Debit_utileKB = size/temps_calcul
set /a Debit_utileDE=Debit_utileKB-(Debit_utileMB*1000)
echo IPv4 Port%port% https: %Debit_utileMB%,%Debit_utileDE% Mb/s - %sizeKO% Ko (DNS:%namelookupMS%ms+SYN:%PingMS%ms+GET:%GetMS%ms+Down:%temps_transfertMS%ms)
goto bv4down
:finbv4down

REM Test de la connectivit‚ IPv6
ping -n 1 -w 1500 -6 %mire% >nul: 2>nul:
IF ERRORLEVEL 1 goto TestUpload


REM IPv6: Download port 80 (http)
for /f "tokens=1-6" %%i in ('curl --max-time 1 -6 -s --write-out "%%{time_namelookup} %%{time_connect} %%{time_starttransfer} %%{time_total} %%{size_download}" -o NUL http://%mire%/1G.iso') do (
	set namelookup=%%i
	set connect=%%j
	set starttransfer=%%k
	set total=%%l
	set size=%%m
)
set namelookup=%namelookup:,=%
set /a namelookup = 1%namelookup%-(11%namelookup%-1%namelookup%)/10
set /a namelookupMS = %namelookup%/1000
set connect=%connect:,=%
set /a connect = 1%connect%-(11%connect%-1%connect%)/10
set /a connectMS = %connect%/1000
set /a PingMS=connectMS-namelookupMS
set starttransfer=%starttransfer:,=%
set /a starttransfer = 1%starttransfer%-(11%starttransfer%-1%starttransfer%)/10
set /a starttransferMS = %starttransfer%/1000
set /a GetMS=starttransferMS-connectMS
set total=%total:,=%
set /a total = 1%total%-(11%total%-1%total%)/10
set /a totalMS = %total%/1000
set /a temps_transfert=total-starttransfer
set /a temps_transfertMS=totalMS-starttransferMS
set /a sizeKO = %size%/1000
set /a temps_calcul = temps_transfert/8000
set /a Debit_utileMB = size/(temps_calcul*1000)
set /a Debit_utileKB = size/temps_calcul
set /a Debit_utileDE=Debit_utileKB-(Debit_utileMB*1000)
echo IPv6 Port80     http : %Debit_utileMB%,%Debit_utileDE% Mb/s - %sizeKO% Ko (DNS:%namelookupMS%ms+SYN:%PingMS%ms+GET:%GetMS%ms+Down:%temps_transfertMS%ms)

REM IPv6: Download port 81 (http)
for /f "tokens=1-6" %%i in ('curl --max-time 1 -6 -s --write-out "%%{time_namelookup} %%{time_connect} %%{time_starttransfer} %%{time_total} %%{size_download}" -o NUL http://%mire%:81/1G.iso') do (
	set namelookup=%%i
	set connect=%%j
	set starttransfer=%%k
	set total=%%l
	set size=%%m
)
set namelookup=%namelookup:,=%
set /a namelookup = 1%namelookup%-(11%namelookup%-1%namelookup%)/10
set /a namelookupMS = %namelookup%/1000
set connect=%connect:,=%
set /a connect = 1%connect%-(11%connect%-1%connect%)/10
set /a connectMS = %connect%/1000
set /a PingMS=connectMS-namelookupMS
set starttransfer=%starttransfer:,=%
set /a starttransfer = 1%starttransfer%-(11%starttransfer%-1%starttransfer%)/10
set /a starttransferMS = %starttransfer%/1000
set /a GetMS=starttransferMS-connectMS
set total=%total:,=%
set /a total = 1%total%-(11%total%-1%total%)/10
set /a totalMS = %total%/1000
set /a temps_transfert=total-starttransfer
set /a temps_transfertMS=totalMS-starttransferMS
set /a sizeKO = %size%/1000
set /a temps_calcul = temps_transfert/8000
set /a Debit_utileMB = size/(temps_calcul*1000)
set /a Debit_utileKB = size/temps_calcul
set /a Debit_utileDE=Debit_utileKB-(Debit_utileMB*1000)
echo IPv6 Port81     http : %Debit_utileMB%,%Debit_utileDE% Mb/s - %sizeKO% Ko (DNS:%namelookupMS%ms+SYN:%PingMS%ms+GET:%GetMS%ms+Down:%temps_transfertMS%ms)

REM IPv6: Download port 443 (https)
for /f "tokens=1-6" %%i in ('curl --max-time 1 -6 -s --write-out "%%{time_namelookup} %%{time_connect} %%{time_starttransfer} %%{time_total} %%{size_download}" -o NUL https://%mire%/1G.iso') do (
	set namelookup=%%i
	set connect=%%j
	set starttransfer=%%k
	set total=%%l
	set size=%%m
)
set namelookup=%namelookup:,=%
set /a namelookup = 1%namelookup%-(11%namelookup%-1%namelookup%)/10
set /a namelookupMS = %namelookup%/1000
set connect=%connect:,=%
set /a connect = 1%connect%-(11%connect%-1%connect%)/10
set /a connectMS = %connect%/1000
set /a PingMS=connectMS-namelookupMS
set starttransfer=%starttransfer:,=%
set /a starttransfer = 1%starttransfer%-(11%starttransfer%-1%starttransfer%)/10
set /a starttransferMS = %starttransfer%/1000
set /a GetMS=starttransferMS-connectMS
set total=%total:,=%
set /a total = 1%total%-(11%total%-1%total%)/10
set /a totalMS = %total%/1000
set /a temps_transfert=total-starttransfer
set /a temps_transfertMS=totalMS-starttransferMS
set /a sizeKO = %size%/1000
set /a temps_calcul = temps_transfert/8000
set /a Debit_utileMB = size/(temps_calcul*1000)
set /a Debit_utileKB = size/temps_calcul
set /a Debit_utileDE=Debit_utileKB-(Debit_utileMB*1000)
echo IPv6 Port443    https: %Debit_utileMB%,%Debit_utileDE% Mb/s - %sizeKO% Ko (DNS:%namelookupMS%ms+SYN:%PingMS%ms+GET:%GetMS%ms+Down:%temps_transfertMS%ms)

set port=0
:bv6down
set /a port = port + 1
if %port%==32768 goto finbv6down
REM IPv4: Download port %port% (https)
for /f "tokens=1-6" %%i in ('curl --max-time 1 -4 -s --write-out "%%{time_namelookup} %%{time_connect} %%{time_starttransfer} %%{time_total} %%{size_download}" -o NUL https://%mire%:%port%/1G.iso') do (
	set namelookup=%%i
	set connect=%%j
	set starttransfer=%%k
	set total=%%l
	set size=%%m
)
set namelookup=%namelookup:,=%
set /a namelookup = 1%namelookup%-(11%namelookup%-1%namelookup%)/10
set /a namelookupMS = %namelookup%/1000
set connect=%connect:,=%
set /a connect = 1%connect%-(11%connect%-1%connect%)/10
set /a connectMS = %connect%/1000
set /a PingMS=connectMS-namelookupMS
set starttransfer=%starttransfer:,=%
set /a starttransfer = 1%starttransfer%-(11%starttransfer%-1%starttransfer%)/10
set /a starttransferMS = %starttransfer%/1000
set /a GetMS=starttransferMS-connectMS
set total=%total:,=%
set /a total = 1%total%-(11%total%-1%total%)/10
set /a totalMS = %total%/1000
set /a temps_transfert=total-starttransfer
set /a temps_transfertMS=totalMS-starttransferMS
set /a sizeKO = %size%/1000
set /a temps_calcul = temps_transfert/8000
set /a Debit_utileMB = size/(temps_calcul*1000)
set /a Debit_utileKB = size/temps_calcul
set /a Debit_utileDE=Debit_utileKB-(Debit_utileMB*1000)
echo IPv4 Port%port% https: %Debit_utileMB%,%Debit_utileDE% Mb/s - %sizeKO% Ko (DNS:%namelookupMS%ms+SYN:%PingMS%ms+GET:%GetMS%ms+Down:%temps_transfertMS%ms)
goto bv6down
:finbv6down

:TestUpload
if %UL%==0 goto FinDownload
REM TELECHARGEMENT DU FICHIER A ENVOYER (TEST DEBIT MONTANT)
if exist "temp.iso" del temp.iso >NUL
curl --max-time 5 -s -o temp.iso http://%mire%/1G.iso
for /f "delims=/ tokens=1,2,3" %%a in ('date /t') do set jour=%%a
for /f "delims=/ tokens=1,2,3" %%a in ('date /t') do set mois=%%b
for /f "delims=/ tokens=1,2,3" %%a in ('date /t') do set annee=%%c
echo %jour%/%mois%/%annee%%time:~0,8% Emission vers %mire% :

REM IPv4: Upload Port 80 (http)
for /f "tokens=1-6" %%i in ('curl --max-time 1 -4 -s --write-out "%%{time_namelookup} %%{time_connect} %%{time_starttransfer} %%{time_total} %%{size_upload}" -o NUL -F "filecontent=@temp.iso" http://%mire%') do (
	set namelookup=%%i
	set connect=%%j
	set starttransfer=%%k
	set total=%%l
	set size=%%m
)
echo size : %size%
set namelookup=%namelookup:,=%
set /a namelookup = 1%namelookup%-(11%namelookup%-1%namelookup%)/10
set /a namelookupMS = %namelookup%/1000
set connect=%connect:,=%
set /a connect = 1%connect%-(11%connect%-1%connect%)/10
set /a connectMS = %connect%/1000
set /a PingMS=connectMS-namelookupMS
set starttransfer=%starttransfer:,=%
set /a starttransfer = 1%starttransfer%-(11%starttransfer%-1%starttransfer%)/10
set /a starttransferMS = %starttransfer%/1000
set /a GetMS=starttransferMS-connectMS
set total=%total:,=%
set /a total = 1%total%-(11%total%-1%total%)/10
set /a totalMS = %total%/1000
set /a temps_transfert=total-starttransfer
set /a temps_transfertMS=totalMS-starttransferMS
set /a sizeKO = %size%/1000
set /a temps_calcul = temps_transfert/8000
set /a Debit_utileMB = size/(temps_calcul*1000)
set /a Debit_utileKB = size/temps_calcul
set /a Debit_utileDE=Debit_utileKB-(Debit_utileMB*1000)
echo IPv4 Port80     http : %Debit_utileMB%,%Debit_utileDE% Mb/s - %sizeKO% Ko (DNS:%namelookupMS%ms+SYN:%PingMS%ms+POST:%GetMS%ms+Up:%temps_transfertMS%ms)

REM Test de la connectivit‚ IPv6
ping -n 1 -w 1500 -6 %mire% >nul: 2>nul:
IF ERRORLEVEL 1 goto FinUpload



REM FIN DU SCRIPT : SUPRESSION DU FICHIER TEMPORAIRE
:FinUpload
del temp.iso >NUL
:FinDownload
for /f "delims=/ tokens=1,2,3" %%a in ('date /t') do set jour=%%a
for /f "delims=/ tokens=1,2,3" %%a in ('date /t') do set mois=%%b
for /f "delims=/ tokens=1,2,3" %%a in ('date /t') do set annee=%%c
echo %jour%/%mois%/%annee%%time:~0,8% Appuyez sur une touche pour quitter.
pause >NUL
:Fin
