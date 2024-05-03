@echo off
setlocal enabledelayedexpansion
rmdir %cd%\simulation /s /q

"%MODELCONNECT%\user_python\python3\python.exe" {% for software in
parameters.input_parameter.additional_software_stack if software.Script == 'build_model_connect_project' -%}
{%- set path = software.FilePath -%}
{{ path }}
{%- endfor %} ^
--executeSilProject ^
--targetProjectName {{ parameters.input_parameter.project_config.project_name }}.proj ^
--SimStartTime 0 ^
--SimEndTime 100 ^
--SimTimeStep 0.005

for /r ".\simulation" %%i in (*.mf4) do (
	set "recorderfile=%%i"
)

set "clyPath=%cd%\{{ parameters.input_parameter.reporting_stack.TestReportTemplateLibrary[0].SubSys[0].ModuleFilePath}}"

set "found=false"

:search
for /r "%clyPath%\.." %%j in (*.dxv) do (
    set "dxvPath=%%j"
    set "found=true"
    goto found
)

set "clyPath=%clyPath%\.."
if not "!clyPath:~-1!"==":" goto search

echo No ".dxv" file found in or above the directory of the ".cly" file.Can't create report!
goto end

:found
set ARG1=%%WorkEnvPath=%dxvPath%
set ARG2=%%RecorderFilePath=%recorderfile%
for /f "usebackq" %%i in (`powershell -Command "(Get-Date).ToUniversalTime().Ticks"` ) do set UTCTicks=%%i
set ARG3=%%TestReportPath=%cd%\{{ parameters.input_parameter.project_config.project_name }}_%UTCTicks%.pdf
set ARG4=%%LayoutPath=%cd%\{{ parameters.input_parameter.reporting_stack.TestReportTemplateLibrary[0].SubSys[0].ModuleFilePath}}"
set ARGall="%ARG1%,%ARG2%,%ARG3%,%ARG4%"

set SCRIPT_PATH="%cd%\Auto_Report.csf"

echo %ARG1%
echo %ARG2%
echo %ARG3%
echo %ARG4%
echo %SCRIPT_PATH%

set CURRENT_DIR=%cd%
cd %CONCERTO_HOME%
ConcertoNet.Application.exe %SCRIPT_PATH% -var %ARGall%
cd %CURRENT_DIR%

:end
endlocal
pause
