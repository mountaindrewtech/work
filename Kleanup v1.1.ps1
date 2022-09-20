#Title: Kleanup v1
#Author: Drew Schmidt
#Date: 9/14/22
#Description: Performs a complete system tune-up via Powershell
#
#Prep Stage: Creates restore point, checks active user, checks Windows version, checks system info, 
#checks serial number, checks drive status, checks free space, verifies WMI repository and rebuilds if necessary.
#
#Clean Stage: Deletes oldest VSS file copies (malware can sometimes be obfuscated here), sets Windows restore points
#max drive space to 5%, deletes temp files and Windows update files, removes several default Windows apps, but leaves
#useful ones like calculator and Xbox etc.,
#
#Disinfect Stage: Runs Windows Defender Quick Scan,
#
#Repair Stage: Runs system file check and disk image services (this is what fixes the majority of computer issues),
#performs a checkdisk on next restart, and resets/repairs network connections as well as flushing DNS cache.
#
#Patch Stage: Checks for Windows updates and installs them.
#
#Optimize Stage: Trim's C:/ drive (this script is currently not for HDD based systems, SSD only), resets DISM base
#(free's up a lot of space by deleting all previous versions of Windows modules).
#
#Wrap Up Stage: Checks disk space again to provide feedback on newly gained space, starts a restart countdown of 5
#minutes so the system can apply pending changes and begin its checkdisk job.
#
#
#
#---------Prep----------

#Create restore point
Checkpoint-Computer -Description KleanupRestore

#Check Active User
(Get-WMIObject -ClassName Win32_ComputerSystem).Username

#Check Windows Version
(Get-WmiObject -class Win32_OperatingSystem).Caption

#Check System Info
Get-WMIObject Win32_ComputerSystem

#Check Serial Number
wmic bios get serialnumber

#Check Drive Status
wmic diskdrive get model,status

#Check Drive Space
Get-WmiObject -Class Win32_logicaldisk

#Check Installed Programs
#Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate

#Check Installed Apps
#Get-AppxPackage -AllUsers | Select Name, PackageFullName

#Check WMI Repository and Rebuild if Necessary
winmgmt /salvagerepository
winmgmt /verifyrepository
	#if the output says it's inconsistent on the second run you'll need to run "winmgmt /resetrepository"
    

#--------Clean----------

#Cleanup Oldest VSS Files for C:/ Drive
vssadmin delete shadows /for=C:/ /oldest /quiet
#Set System Restore Point Max Size
vssadmin resize shadowstorage /on=C: /for=C: /maxsize=5%

#Cleanup Temporary Files
$folders = @("C:\Windows\Temp\*", "C:\Documents and Settings\*\Local Settings\temp\*", "C:\Users\*\Appdata\Local\Temp\*", "C:\Users\*\Appdata\Local\Microsoft\Windows\Temporary Internet Files\*", "C:\Windows\SoftwareDistribution\Download", "C:\Windows\System32\FNTCACHE.DAT")
foreach ($folder in $folders) {Remove-Item $folder -force -recurse -ErrorAction SilentlyContinue}

#Remove Default Windows Apps
Get-AppxPackage *3dbuilder* | Remove-AppxPackage
Get-AppxPackage *windowscommunicationsapps* | Remove-AppxPackage
Get-AppxPackage *windowscamera* | Remove-AppxPackage
Get-AppxPackage *officehub* | Remove-AppxPackage
Get-AppxPackage *skypeapp* | Remove-AppxPackage
Get-AppxPackage *getstarted* | Remove-AppxPackage
Get-AppxPackage *solitairecollection* | Remove-AppxPackage
Get-AppxPackage *bingfinance* | Remove-AppxPackage
Get-AppxPackage *bingnews* | Remove-AppxPackage
Get-AppxPackage *windowsphone* | Remove-AppxPackage
Get-AppxPackage *bingsports* | Remove-AppxPackage
Get-AppxPackage *bingweather* | Remove-AppxPackage
Get-AppxPackage *candycrush* | Remove-AppxPackage

#---------Disinfect--------

#Run Defender Quick Scan
Start-MpScan -ScanType QuickScan -AsJob

#Uncomment to Run Defender Full Scan
#Start-MpScan -ScanType FullScan -AsJob


#---------Repair---------

#System File Checker
sfc /scannow

#Disk Image Servicing and Management
dism /online /cleanup-image /restorehealth

#Checkdisk (Will run on next restart)
echo y | chkdsk /f /x

#Network Repair
netsh int ip delete arpcache
netsh winsock reset catalog
ipconfig /flushdns


#---------Patch-------------

#Check for Windows Updates - this section is forked from Pulseway.
Write-Host "Checking for Windows updates"
$UpdateCollection = New-Object -ComObject Microsoft.Update.UpdateColl
$Searcher = New-Object -ComObject Microsoft.Update.Searcher
$Session = New-Object -ComObject Microsoft.Update.Session

$Searcher = New-Object -ComObject Microsoft.Update.Searcher
$results = $searcher.search("Type='software' AND IsInstalled = 0 AND IsHidden = 0 AND AutoSelectOnWebSites = 1")

# Install Update
if ($results.Updates.Count -eq 0) {
    Write-Host "No updates found"
    # no updates.
} else {
    # setup update collection
    foreach ($update in $results.Updates){
        $UpdateCollection.Add($update) | out-null
    }

    # download update items
    Write-Host "Downloading updates"
    $Downloader = $Session.CreateUpdateDownloader()
    $Downloader.Updates = $UpdateCollection
    $Downloader.Download()

    # install update items
    Write-Host "Installing updates"
    $Installer = New-Object -ComObject Microsoft.Update.Installer
    $Installer.Updates = $UpdateCollection
    $InstallationResult = $Installer.Install()
    # Check Result
    if ($InstallationResult.ResultCode -eq 2){
        Write-Host "Updates installed successfully"
    } else {
        Write-Host "Some updates could not be installed"
    }
    if ($InstallationResult.RebootRequired){
        Write-Host "System needs to reboot"
    }
}


# --------Optimize-----------

#Trim C:\ drive (for SSD)
Optimize-Volume -DriveLetter C -ReTrim -Verbose

#Reset DISM Base
dism /online /cleanup-image /startcomponentcleanup /resetbase


#--------Wrap Up----------

#Check Drive Space After Cleanup
Get-WmiObject -Class Win32_logicaldisk

#Uncomment the following line to automatically reboot the system.
shutdown -r -f -t 300 -c "Your computer will reboot in 5 minutes to finish cleaning up."