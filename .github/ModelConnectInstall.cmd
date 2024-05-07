SET VERSION=<<MCBaseVersion>>
SET LICSERVER=<<LicenseServer>>
SET LICPORT=<<LicenceServerPort>>

SET INSTTEMP=%TEMP%\simsuite_%RANDOM%
mkdir %INSTTEMP%
pushd %INSTTEMP%

SET TOKEN=<<JfrogToken>>

ECHO download from artifactory
curl -u%TOKEN% -L -O "https://avlartiedgeew1.jfrog.io/artifactory/generic/avl/devopspilot/Software/Simulation_Suite/%VERSION%/AVL_SIMULATION_SUITE_R%VERSION%_SETUP.exe"
ECHO Install silent
"AVL_SIMULATION_SUITE_R%VERSION%_SETUP.exe" --mode unattended
SETX AVL_LICENSE_FILE %LICPORT%@%LICSERVER% /M
ECHO Done