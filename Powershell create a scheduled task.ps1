$action = (New-ScheduledTaskAction -Execute 'executable' "argument") 
 $tr =  New-ScheduledTaskTrigger -Daily -At "11am"
 $pr = New-ScheduledTaskPrincipal  -Groupid  "INTERACTIVE" 
 Register-ScheduledTask  -TaskName "Task Name" -Description "Task Description" -Trigger $tr -Action $action -Principal $pr
