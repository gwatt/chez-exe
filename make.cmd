 
 @echo off

setlocal

if "%scheme%" == "" (
	echo Must specify scheme
	goto out
)

if "%bootpath%" == "" (
	echo Must specify bootpath
	goto out
)

nmake /NOLOGO /F Makefile.win %*

:out
