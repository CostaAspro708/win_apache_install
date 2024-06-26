$ProgressPreference = 'SilentlyContinue'
$apacheUrl = 'https://home.apache.org/~steffenal/VC15/binaries/httpd-2.4.54-win64-VC15.zip'
$installDir = 'C:\Apache24'
$logFile = 'C:\install_apache.log'

# Start logging
Start-Transcript -Path $logFile -Append

try {
    # Download Apache
    Write-Output "Downloading Apache from $apacheUrl"
    Invoke-WebRequest -Uri $apacheUrl -OutFile 'C:\apache.zip'
    Write-Output "Downloaded Apache."

    # Extract Apache
    Write-Output "Extracting Apache..."
    Expand-Archive -Path 'C:\apache.zip' -DestinationPath 'C:\apache'
    Move-Item -Path 'C:\apache\Apache24' -Destination $installDir
    Remove-Item -Path 'C:\apache.zip'
    Remove-Item -Path 'C:\apache' -Recurse
    Write-Output "Extracted and moved Apache files."

    # Install Apache service
    Write-Output "Installing Apache service..."
    Start-Process -FilePath "$installDir\bin\httpd.exe" -ArgumentList '-k install' -Wait
    Write-Output "Installed Apache service."

    # Start Apache service
    Write-Output "Starting Apache service..."
    Start-Service -Name 'Apache2.4'
    Write-Output "Started Apache service."

    # Set Apache service to start automatically
    Write-Output "Setting Apache service to start automatically..."
    Set-Service -Name 'Apache2.4' -StartupType Automatic
    Write-Output "Set Apache service to start automatically."

    # Allow HTTP and HTTPS traffic through Windows Firewall
    Write-Output "Configuring firewall rules..."
    New-NetFirewallRule -DisplayName "Allow HTTP" -Direction Inbound -LocalPort 80 -Protocol TCP -Action Allow
    New-NetFirewallRule -DisplayName "Allow HTTPS" -Direction Inbound -LocalPort 443 -Protocol TCP -Action Allow
    Write-Output "Configured firewall rules."

    # Verify Apache service is running
    Write-Output "Verifying Apache service status..."
    $apacheService = Get-Service -Name 'Apache2.4'
    if ($apacheService.Status -eq 'Running') {
        Write-Output "Apache service is running."
    } else {
        Write-Output "Apache service is not running. Starting Apache service..."
        Start-Service -Name 'Apache2.4'
        $apacheService = Get-Service -Name 'Apache2.4'
        if ($apacheService.Status -eq 'Running') {
            Write-Output "Apache service started successfully."
        } else {
            Write-Error "Failed to start Apache service."
        }
    }

    # Create a test HTML page
    Write-Output "Creating test HTML page..."
    $testPagePath = "$installDir\htdocs\test.html"
    '<html><body><h1>Apache is working!</h1></body></html>' | Out-File -FilePath $testPagePath
    Write-Output "Test HTML page created at $testPagePath."
    Write-Output "Visit http://<your-vm-ip-address>/test.html to verify Apache is working."
} catch {
    Write-Error "An error occurred: $_"
}

# Stop logging
Stop-Transcript
