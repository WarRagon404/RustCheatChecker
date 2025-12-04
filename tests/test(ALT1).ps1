

Write-Host "=== Альтернативный тест 1: Мок-тестирование ===" -ForegroundColor Magenta

$testSignatures = @{
    process_signatures = @{
        known_cheats = @("testcheat.exe", "fakeprocess.exe")
        suspicious_patterns = @("*test*", "*fake*")
    }
}

$testConfigPath = ".\test_signatures.json"
$testSignatures | ConvertTo-Json | Out-File $testConfigPath -Encoding UTF8

function Test-ProcessDetection {
    param(
        [string]$ProcessName,
        [hashtable]$Signatures
    )
    
    $isDetected = $false
    $detectionType = ""
    
    foreach ($cheat in $Signatures.process_signatures.known_cheats) {
        if ($ProcessName -eq $cheat) {
            $isDetected = $true
            $detectionType = "KNOWN_CHEAT"
            break
        }
    }
    
    if (-not $isDetected) {
        foreach ($pattern in $Signatures.process_signatures.suspicious_patterns) {
            if ($ProcessName -like $pattern) {
                $isDetected = $true
                $detectionType = "PATTERN_MATCH"
                break
            }
        }
    }
    
    return @{
        Detected = $isDetected
        Type = $detectionType
    }
}

$testCases = @(
    @{Name="testcheat.exe"; Expected=$true},
    @{Name="legitapp.exe"; Expected=$false},
    @{Name="faketest.exe"; Expected=$true},
    @{Name="normalapp.exe"; Expected=$false}
)

Write-Host "Запуск тестовых сценариев..." -ForegroundColor Yellow

foreach ($testCase in $testCases) {
    $result = Test-ProcessDetection -ProcessName $testCase.Name -Signatures $testSignatures
    
    if ($result.Detected -eq $testCase.Expected) {
        Write-Host "[PASS] $($testCase.Name): Ожидалось $($testCase.Expected), получено $($result.Detected)" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] $($testCase.Name): Ожидалось $($testCase.Expected), получено $($result.Detected)" -ForegroundColor Red
    }
}

Remove-Item $testConfigPath -ErrorAction SilentlyContinue

Write-Host "`nМок-тестирование завершено" -ForegroundColor Magenta