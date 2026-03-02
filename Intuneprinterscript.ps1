# ================================
# {Printer model} Intune Install
# Printer Name: {Printer name}
# IP Address: {IP Address}
# ================================

$PrinterName = "Printer name" # Change this to what you want your printer name to show up as
$PortName    = "IP_192.168.1.10" # Change this to the IP of your printer
$PrinterIP   = "192.168.1.10" # Change this to the IP of your printer
$DriverName  = "Printerdrive name"   # MUST match exact installed driver name

# Proper path handling for Intune Win32 context
$ScriptFolder = Split-Path -Parent $MyInvocation.MyCommand.Path
$InfPath = Join-Path $ScriptFolder "Printerdriver.inf" # Change this to the printer driver you are using.

Write-Output "====================================="
Write-Output "Starting printer deployment"
Write-Output "Printer: $PrinterName"
Write-Output "Driver: $DriverName"
Write-Output "INF Path: $InfPath"
Write-Output "====================================="

# ---- Validate INF exists ----
if (-not (Test-Path $InfPath)) {
    Write-Output "ERROR: INF file not found at $InfPath"
    exit 1
}

# ---- Exit if printer already exists ----
if (Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue) {
    Write-Output "Printer '$PrinterName' already installed. Exiting successfully."
    exit 0
}

# ---- Install driver if missing ----
if (-not (Get-PrinterDriver -Name $DriverName -ErrorAction SilentlyContinue)) {

    Write-Output "Installing driver package with pnputil..."
    pnputil.exe /add-driver "`"$InfPath`"" /install

    Start-Sleep -Seconds 5

    Write-Output "Adding printer driver to Windows..."
    try {
        Add-PrinterDriver -Name $DriverName -ErrorAction Stop
    }
    catch {
        Write-Output "ERROR: Failed to add printer driver."
        Write-Output $_
        exit 1
    }

    # Verify driver installed
    if (-not (Get-PrinterDriver -Name $DriverName -ErrorAction SilentlyContinue)) {
        Write-Output "ERROR: Driver installation failed."
        exit 1
    }

    Write-Output "Driver installed successfully."
}
else {
    Write-Output "Driver already installed."
}

# ---- Create TCP/IP Port if missing ----
if (-not (Get-PrinterPort -Name $PortName -ErrorAction SilentlyContinue)) {

    Write-Output "Creating TCP/IP port $PortName..."
    try {
        Add-PrinterPort -Name $PortName -PrinterHostAddress $PrinterIP -ErrorAction Stop
    }
    catch {
        Write-Output "ERROR: Failed to create printer port."
        Write-Output $_
        exit 1
    }
}
else {
    Write-Output "Printer port already exists."
}

# ---- Create Printer ----
Write-Output "Creating printer $PrinterName..."

try {
    Add-Printer -Name $PrinterName `
                -DriverName $DriverName `
                -PortName $PortName `
                -ErrorAction Stop
}
catch {
    Write-Output "ERROR: Failed to create printer."
    Write-Output $_
    exit 1
}

# ---- Verify installation ----
if (Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue) {
    Write-Output "Printer deployment completed successfully."
    exit 0
}
else {
    Write-Output "ERROR: Printer was not created."
    exit 1
}
