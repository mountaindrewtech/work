# Get a list of all the user group members on the computer
$users = Get-LocalGroupMember -Group Users

# Find the user whose name starts with your input
$xUser = $users | Where-Object {$_.Name -like "START_OF_NAME*"}

# Store the name of the user in a variable
$userName = $xUser.Name

# Trim the domain off the username
$trimName = $userName.TrimStart("DOMAIN\")
