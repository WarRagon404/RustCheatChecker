@{

    RustInstallPath = "C:\Program Files (x86)\Steam\steamapps\common\Rust"

    ScanPaths = @(
        "$env:APPDATA\..\LocalLow\Facepunch Studios",
        "$env:APPDATA\Rust",
        "$env:TEMP"
    )

    EnableDeepScan = $false
    EnableMemoryScan = $false
    ScanRegistry = $true
    ScanStartup = $true
    ScanProcesses = $true

    ShowWarnings = $true
    ShowInfo = $false
    ColorOutput = $true

    CheckFileHashes = $true
    CheckFileSizes = $true
    CheckFileDates = $true

    EnableLogging = $true
    LogFilePath = "scan_log.txt"
    LogLevel = "WARNING" # INFO, WARNING, ERROR, DEBUG

    AutoQuarantine = $false
    AutoReport = $false

    ExcludedProcesses = @("explorer", "svchost", "System")
    ExcludedPaths = @("C:\Windows", "C:\Program Files")
}