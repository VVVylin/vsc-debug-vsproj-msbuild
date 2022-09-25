@echo off

SET __BUILDER=
SET __CONFIG=
SET __SLNFILE=
SET __WINSDKVER=
SET __ACTION=

SET __TARGET=
SET __PLATFORM_BAT=
SET __PLATFORM_BUILD=
SET __BUILDBAT=""

SET BUILDBAT_VS2010=D:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat
SET BUILDBAT_VS2015=D:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat

:checkopts
IF "%1" == "/help" goto USAGE
IF "%1" == "/builder" (SET __BUILDER=%~2) && shift && shift && goto checkopts
IF "%1" == "/config" (SET __CONFIG=%~2) && shift && shift && goto checkopts
IF "%1" == "/slnfile" (SET __SLNFILE=%~2) && shift && shift && goto checkopts
IF "%1" == "/winsdkver" (SET __WINSDKVER=%~2) && shift && shift && goto checkopts
IF "%1" == "/action" (SET __ACTION=%~2) && shift && shift && goto checkopts
IF NOT "%1" == "" (echo invalid parameter %1 >&2) && (echo=) && goto USAGE

IF "%__BUILDER%" == "" (
    echo builder is not specified >&2
    goto USAGE
)

IF "%__CONFIG%" == "" (
    echo config is not specified >&2
    goto USAGE
)

IF "%__SLNFILE%" == "" (
    echo slnfile is not specified >&2
    goto USAGE
)

IF "%__ACTION%" == "" (
	echo action is not specified >&2
	goto USAGE
)

IF %__BUILDBAT% == "" IF "%__BUILDER%" == "vs2010" SET __BUILDBAT="%BUILDBAT_VS2010%"
IF %__BUILDBAT% == "" IF "%__BUILDER%" == "vs2015" SET __BUILDBAT="%BUILDBAT_VS2015%"
IF %__BUILDBAT% == "" (
	echo builder %__BUILDER% value error >&2
	goto USAGE
)

Set ver=%__WINSDKVER%
IF "%__BUILDER%" == "vs2015" (
    IF NOT "%__WINSDKVER%"=="8.1" IF NOT "%ver%:~0,3%"=="10." (
        echo winsdkver %__WINSDKVER% value error >&2
        goto USAGE
    )
)

IF NOT "%__ACTION%"=="build" IF NOT "%__ACTION%"=="rebuild" IF NOT "%__ACTION%"=="clean" (
    echo action %__ACTION% value error >&2
    goto USAGE
)

IF "%__TARGET%" == "" IF "%__CONFIG%" == "Debug" (
	SET __TARGET=Debug
	SET __PLATFORM_BAT=x86
	IF "%__BUILDER%" == "vs2010" (SET __PLATFORM_BUILD=Win32) ELSE (SET __PLATFORM_BUILD=x86)
)
IF "%__TARGET%" == "" IF "%__CONFIG%" == "Debug64" (
	SET __TARGET="Debug"
	SET __PLATFORM_BAT=x64
	SET __PLATFORM_BUILD=x64
)
IF "%__TARGET%" == "" IF "%__CONFIG%" == "Release" (
	SET __TARGET=Release
	SET __PLATFORM_BAT=x86
	IF "%__BUILDER%" == "vs2010" (SET __PLATFORM_BUILD=Win32) ELSE (SET __PLATFORM_BUILD=x86)
)
IF "%__TARGET%" == "" IF "%__CONFIG%" == "Release64" (
	SET __TARGET=Release
	SET __PLATFORM_BAT=x64
	SET __PLATFORM_BUILD=x64
)
IF "%__TARGET%" == "" (
	echo config %__CONFIG% value error >&2
    goto USAGE
)

IF "%__BUILDER%" == "vs2010" (call %__BUILDBAT% %__PLATFORM_BAT%) ELSE (call %__BUILDBAT% %__PLATFORM_BAT% %__WINSDKVER%)
MSBuild "%__SLNFILE%" /t:%__ACTION% /p:Configuration=%__TARGET%;Platform=%__PLATFORM_BUILD% /m
exit /B %ERRORLEVEL%

:USAGE
    echo Usage:
    echo   build-vs.bat [OPTIONS]
    echo=
    echo Application Options:
    echo   /builder       Build environment(vs2010^|vs2015).
    echo   /config        Build config(Debug^|Release^|Debug64^|Release64)
    echo   /slnfile       SLN file name(*.sln)
    echo   /winsdkver     Windows SDK version for vs2015(8.1 or 10.0.18362.0 e.g)
    echo   /action        Build action(build^|rebuild^|clean)
    echo=
    echo Help Options:
    echo   /help          Show this help message
    echo= 
    exit /B 1