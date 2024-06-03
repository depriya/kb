SET BASEVERSION=<<MCBaseVersion>>
SET VERSION=<<MCVersion>>

SET INSTTEMP=%TEMP%\simsuite_%RANDOM%

mkdir %INSTTEMP%
pushd %INSTTEMP%

SET TOKEN=<<JfrogToken>>

ECHO download from artifactory
curl -u%TOKEN% -L -O "https://avlartiedgeew1.jfrog.io/artifactory/generic/avl/devopspilot/Software/Simulation_Suite/%VERSION%/r%VERSION%_maintenance-release_winnt.zip"
ECHO Install silent
"%ProgramFiles(x86)%\AVL\R%BASEVERSION%\bin\patch.exe" apply "%INSTTEMP%\r%VERSION%_maintenance-release_winnt.zip"
ECHO Done