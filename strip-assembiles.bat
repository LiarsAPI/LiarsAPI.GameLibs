@echo off
setlocal enabledelayedexpansion

@REM Add all the assemblies you want to publicize in this list
set toPublicize=Assembly-CSharp.dll Assembly-CSharp-firstpass.dll

@REM Add all the assemblies you want to copy as-is to the package in this list
set dontTouch=

@REM Add all the assemblies you want to include in the package in this list, if this list is empty, all assemblies will be included
set toInclude=^
  Assembly-CSharp.dll ^
  Assembly-CSharp-firstpass.dll ^
  com.rlabrecque.steamworks.net.dll ^
  FizzySteamworks.dll ^
  kcp2k.dll ^
  Mirror.dll ^
  Mirror.Transports.dll ^
  Mirror.Components.dll ^
  Mirror.Authenticators.dll ^
  Newtonsoft.Json.dll ^
  Unity.Addressables.dll ^
  Unity.ResourceManager.dll ^
  Unity.TextMeshPro.dll ^
  UnityEngine.UI.dll

set exePath=%1
echo exePath: %exePath% 

@REM Remove quotes
set exePath=%exePath:"=%

set managedPath=%exePath:.exe=_Data\Managed%
echo managedPath: %managedPath%

set outPath=%~dp0\package\lib

@REM Strip assemblies - if toInclude is set, only process listed assemblies; otherwise process all.
if "%toInclude%"=="" (
  %~dp0\tools\NStrip.exe "%managedPath%" -o %outPath%
) else (
  (for %%a in (%toInclude%) do (
    echo a: %%a

    %~dp0\tools\NStrip.exe "%managedPath%\%%a" -o "%outPath%\%%a"
  ))
)

@REM Strip and publicize assemblies from toPublicize.
(for %%a in (%toPublicize%) do (
  echo a: %%a

  %~dp0\tools\NStrip.exe "%managedPath%\%%a" -o "%outPath%\%%a" -cg -p --cg-exclude-events
))

@REM Copy over original assemblies for ones we don't want to touch.
(for %%a in (%dontTouch%) do (
  echo a: %%a

  xcopy "%managedPath%\%%a" "%outPath%\%%a" /y /v
))

@REM Delete any files in the output directory that are not in toInclude.
if not "%toInclude%"=="" (
  for %%f in ("%outPath%\*.dll") do (
    set found=0
    for %%a in (%toInclude%) do (
      if /i "%%~nxf"=="%%a" set found=1
    )
    if !found!==0 (
      echo Deleting unlisted file: %%~nxf
      del "%%f"
    )
  )
)

pause
