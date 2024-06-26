$ProgressPreference = 'SilentlyContinue'
$apacheUrl = 'https://home.apache.org/~steffenal/VC15/binaries/httpd-2.4.54-win64-VC15.zip'
$installDir = 'C:\Apache24'
Invoke-WebRequest -Uri $apacheUrl -OutFile 'C:\apache.zip'
Expand-Archive -Path 'C:\apache.zip' -DestinationPath 'C:\apache'
Move-Item -Path 'C:\apache\Apache24' -Destination $installDir
Remove-Item -Path 'C:\apache.zip'
Remove-Item -Path 'C:\apache' -Recurse
Start-Process -FilePath "$installDir\bin\httpd.exe" -ArgumentList '-k install' -Wait
Start-Service -Name 'Apache2.4'
Set-Service -Name 'Apache2.4' -StartupType Automatic
