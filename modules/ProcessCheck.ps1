function Get-SuspiciousProcesses {
    <#
    .SYNOPSIS
    Поиск подозрительных процессов
    
    .DESCRIPTION
    Сканирует запущенные процессы на наличие известных читов и подозрительных паттернов
    #>
    
    param(
        [switch]$Detailed = $false
    )
    
    $results = @()
    $suspiciousCount = 0
    
    Write-Host "[+] Сканирование запущенных процессов..." -ForegroundColor Cyan
    
    try {
        $signaturesPath = Join-Path $PSScriptRoot "..\config\signatures.json"
        $signatures = Get-Content $signaturesPath -Raw | ConvertFrom-Json
        
        $processes = Get-Process | Select-Object Name, Id, Path, Company, Description
        
        foreach ($process in $processes) {
            $processName = $process.Name.ToLower()
            $isSuspicious = $false
            $detectionType = ""
            
            foreach ($cheat in $signatures.process_signatures.known_cheats) {
                $cheatName = $cheat.ToLower()
                if ($processName -eq $cheatName) {
                    $isSuspicious = $true
                    $detectionType = "KNOWN_CHEAT"
                    break
                }
            }
            
            if (-not $isSuspicious) {
                foreach ($pattern in $signatures.process_signatures.suspicious_patterns) {
                    if ($processName -like $pattern.ToLower()) {
                        $isSuspicious = $true
                        $detectionType = "SUSPICIOUS_PATTERN"
                        break
                    }
                }
            }
            
            # Проверка на отсутствие информации о компании (может быть признаком)
            if (-not $isSuspicious -and $Detailed) {
                if ([string]::IsNullOrEmpty($process.Company) -and 
                    [string]::IsNullOrEmpty($process.Description) -and 
                    -not [string]::IsNullOrEmpty($process.Path)) {
                    $isSuspicious = $true
                    $detectionType = "NO_COMPANY_INFO"
                }
            }
            
            if ($isSuspicious) {
                $suspiciousCount++
                $result = [PSCustomObject]@{
                    Name = $process.Name
                    ID = $process.Id
                    Path = $process.Path
                    Detection = $detectionType
                    Status = "SUSPICIOUS"
                    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                }
                $results += $result
                
                Write-Host "   [SUSPICIOUS] Найден подозрительный процесс: $($process.Name) (ID: $($process.Id))" -ForegroundColor Yellow
            }
        }
        
        if ($suspiciousCount -eq 0) {
            Write-Host "   [OK] Подозрительные процессы не обнаружены" -ForegroundColor Green
        }
        
    }
    catch {
        Write-Host "   [ERROR] Ошибка при сканировании процессов: $_" -ForegroundColor Red
    }
    
    return $results
}

function Get-ProcessModules {
    <#
    .SYNOPSIS
    Получает модули (DLL) для указанного процесса
    #>
    
    param(
        [int]$ProcessId
    )
    
    $modules = @()
    
    try {
        $process = Get-Process -Id $ProcessId -ErrorAction Stop
        $modules = $process.Modules | Select-Object ModuleName, FileName, FileVersion
    }
    catch {
        Write-Host "Ошибка при получении модулей процесса $ProcessId: $_" -ForegroundColor Red
    }
    
    return $modules
}

function Check-ProcessInjection {
    <#
    .SYNOPSIS
    Проверяет процесс на возможную инъекцию кода
    #>
    
    param(
        [int]$ProcessId
    )
    
    Write-Host "[+] Проверка процесса $ProcessId на инъекции..." -ForegroundColor Cyan
    
    try {
        $modules = Get-ProcessModules -ProcessId $ProcessId
        $suspiciousModules = @()
        
        foreach ($module in $modules) {
            $moduleName = $module.ModuleName.ToLower()
            
            if ($moduleName -like "*cheat*" -or 
                $moduleName -like "*inject*" -or 
                $moduleName -like "*hook*") {
                $suspiciousModules += $module
            }
        }
        
        if ($suspiciousModules.Count -gt 0) {
            Write-Host "   [WARNING] Найдены подозрительные модули в процессе $ProcessId" -ForegroundColor Yellow
            return $suspiciousModules
        }
        else {
            Write-Host "   [OK] Подозрительные модули не обнаружены" -ForegroundColor Green
            return @()
        }
    }
    catch {
        Write-Host "   [ERROR] Ошибка при проверке инъекций: $_" -ForegroundColor Red
        return @()
    }
}

Export-ModuleMember -Function Get-SuspiciousProcesses, Get-ProcessModules, Check-ProcessInjection