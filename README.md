# check-cbs-corruption
powershell scripts to check CBS logs for CSI Payload Missing and help make repair a little easier

Use check_cbs_corruption.ps1 to scan the CBS log for CSI Payload Missing.  You can specify a specific CBS log from the commandline or by default it will use c:\windows\logs\cbs\cbs.log.  If there are missing payloads, a new .fix file will be created in the directory the script was run from.  this .fix file can be used with cbsfix.ps1.

Using cbsfix.ps1 takes 3 parameters:  fixfile source destination

fixfile is generated from the check_cbs_corruption.ps1

source is the location of the folders that were missing

destination is where to copy the folders to (recursively copies)

Lastly, get-windows-release-information.ps1 just provides a quick way to get the UBR and KB from Microsoft so you can download the KB that contains the missing payloads a little easier.  By default it will scan for server2022 but you can also specify win10, win11, server2019 from the command line when running the script and it'll provide the information specific to those operating systems.
