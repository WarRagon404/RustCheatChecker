

Write-Host "=== Тестирование модуля ProcessCheck ===" -ForegroundColor Cyan
Import-Module ".\modules\ProcessCheck.ps1" -Force

Write-Host "Тест 1: Поиск подозрительных процессов" -ForegroundColor Yellow
$results = Get-SuspiciousProcesses -Detailed:$true

if ($results.Count -gt 0) {
    Write-Host "Найдено подозрительных процессов: $($results.Count)" -ForegroundColor Yellow
    $results | Format-Table -AutoSize
}
else {
    Write-Host "Подозрительные процессы не найдены" -ForegroundColor Green
}


Write-Host "`nТест 2: Проверка инъекций в процесс Explorer" -ForegroundColor Yellow
$explorerProcess = Get-Process explorer -ErrorAction SilentlyContinue | Select-Object -First 1

if ($explorerProcess) {
    $injections = Check-ProcessInjection -ProcessId $explorerProcess.Id
    
    if ($injections.Count -gt 0) {
        Write-Host "Найдены подозрительные инъекции:" -ForegroundColor Red
        $injections | Format-Table -AutoSize
    }
}


Write-Host "`nТест 3: Получение модулей текущего процесса PowerShell" -ForegroundColor Yellow
$currentProcessId = $PID
$modules = Get-ProcessModules -ProcessId $currentProcessId

Write-Host "Загружено модулей: $($modules.Count)" -ForegroundColor Cyan

Write-Host "`n=== Сводка тестов ===" -ForegroundColor Cyan

$tests = @(
    @{Name="Get-SuspiciousProcesses"; Result=$results -ne $null},
    @{Name="Check-ProcessInjection"; Result=$explorerProcess -ne $null},
    @{Name="Get-ProcessModules"; Result=$modules.Count -gt 0}
)

foreach ($test in $tests) {
    if ($test.Result) {
        Write-Host "[PASS] $($test.Name)" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] $($test.Name)" -ForegroundColor Red
    }
}

Write-Host "`nТестирование завершено" -ForegroundColor Cyan