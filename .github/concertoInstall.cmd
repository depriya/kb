SET VERSION=<<ConcertoVersion>>
SET VERSION_R=<<ConcertoVersionR>>
SET LICSERVER=<<LicenseServer>>
SET LICPORT=<<LicenceServerPort>>

SET INSTTEMP=%TEMP%\Concerto_%RANDOM%
mkdir %INSTTEMP%
pushd %INSTTEMP%

SET TOKEN=<<JfrogToken>>

ECHO download from artifactory
curl -u%TOKEN% -L -O "https://avlartiedgeew1.jfrog.io/artifactory/generic/avl/devopspilot/Software/Concerto/%VERSION%/AVL_CONCERTO_%VERSION_R%.zip"
curl -u%TOKEN% -L -O "https://avlartiedgeew1.jfrog.io/artifactory/generic/avl/devopspilot/Software/Concerto/%VERSION%/Silent.zip"
ECHO Install silent
ECHO Start Silent Install from %INSTTEMP%
for %%f in (AVL_CONCERTO*.zip) do tar -xf %%f

ECHO SERVER %LICSERVER% XXX %LICPORT%>co998.lic
ECHO USE_SERVER>>co998.lic

for %%f in (Concerto*Upgradeable-Installer.exe) do %%f /silent -configfile Silent.zip