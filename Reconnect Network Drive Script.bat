:: All these squares make a circle.

@echo off
REM Setting window to minimized.
	if not "%minimized%"=="" goto start
	set minimized=true
	start /min cmd /C "%~dpnx0"
	goto EOF
REM Checking network drive error status, if there's errors, goto remap.
	:start
	cls
	color A
	net use x: \\filepath
	net use y: \\filepath
	net use x:
	if not %errorlevel% equ 0 goto remap
	net use y:
	if not %errorlevel% equ 0 goto remap
:: goto "End Of File" - end script
	goto EOF
	
REM Remap network drives.
	:remap
	net use x: /delete /y
	net use y: /delete /y
	net use x: \\filepath
	net use y: \\filepath

REM Verify network drive error status, if errored, goto "contact".
	net use
	if not %errorlevel% equ 0 goto contact
:: goto "End Of File" - end script
	goto EOF
	
	:contact
	color C
	echo Please contact IT.
	Timeout 60
exit
