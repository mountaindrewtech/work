$action = (New-ScheduledTaskAction -Execute 'powershell.exe' "Stop-Process -Name Acrobat -Force"),
    (New-ScheduledTaskAction -Execute 'Z:\obfuscated') 
 $tr =  New-ScheduledTaskTrigger -Daily -At "11am"
 $pr = New-ScheduledTaskPrincipal  -Groupid  "INTERACTIVE" 
 Register-ScheduledTask  -TaskName "Task Name" -Description "Task Description" -Trigger $tr -Action $action -Principal $pr