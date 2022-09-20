:: All these squares make a circle.

@echo off
REM Setting window to minimized.
	if not "%minimized%"=="" goto :start
	set minimized=true
	start /min cmd /C "%~dpnx0"
	
REM Checking network drive error status, if errored goto "unmap", if not goto "map".
	:start
	cls
	color A
	net use
	if %errorlevel% equ 0 goto unmap
	if not %errorlevel% equ 0 goto map
	
REM Unmap network drives.
	:unmap
	net use p: /delete /y
	net use s: /delete /y
	
REM Map network drives.
	:map
	net use p:
	net use s:
	
REM Verify network drive error status, if errored goto "contact", or "end of file" - end script.
	net use
	if %errorlevel% equ 0 goto contact
	goto :EOF
	
	:contact
	color C
	echo Please contact IT.
	Timeout 15
exit