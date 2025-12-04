Write-Host "=== Альтернативный тест 2: Тест производительности ===" -ForegroundColor Blue

Import-Module ".\modules\ProcessCheck.ps1" -Force

Measure-Command -Expression {
    Write-Host "Тест 1: Быстрый поиск (без деталей)..." -ForegroundColor Gray
    $null = Get-SuspiciousProcesses -Detailed:$false
} | Select-Object TotalMilliseconds | ForEach-Object {
    Write-Host "Время выполнения: $($_.TotalMilliseconds) мс" -ForegroundColor Yellow
}

Measure-Command -Expression {
    Write-Host "`nТест 2: Детальный поиск..." -ForegroundColor Gray
    $null = Get-SuspiciousProcesses -Detailed:$true
} | Select-Object TotalMilliseconds | ForEach-Object {
    Write-Host "Время выполнения: $($_.TotalMilliseconds) мс" -ForegroundColor Yellow
}
$processes = Get-Process | Select-Object -First 5
Write-Host "`nТест 3: Проверка инъекций для 5 процессов..." -ForegroundColor Gray

$totalTime = Measure-Command -Expression {
    foreach ($proc in $processes) {
        try {
            $null = Check-ProcessInjection -ProcessId $proc.Id
        }
        catch {
            # Игнорируем ошибки для теста производительности
        }
    }
}

Write-Host "Общее время: $($totalTime.TotalMilliseconds) мс" -ForegroundColor Yellow
Write-Host "Среднее время на процесс: $([math]::Round($totalTime.TotalMilliseconds / $processes.Count, 2)) мс" -ForegroundColor Yellow
Write-Host "`nТест 4: Использование памяти..." -ForegroundColor Gray
$memoryBefore = [System.GC]::GetTotalMemory($true)

$null = Get-SuspiciousProcesses -Detailed:$true

$memoryAfter = [System.GC]::GetTotalMemory($true)
$memoryUsed = $memoryAfter - $memoryBefore

Write-Host "Использовано памяти: $([math]::Round($memoryUsed / 1MB, 2)) MB" -ForegroundColor Yellow

Write-Host "`nТест 5: Стресс-тест (многократный вызов)..." -ForegroundColor Gray
$iterations = 10
$times = @()

for ($i = 1; $i -le $iterations; $i++) {
    $time = Measure-Command -Expression {
        $null = Get-SuspiciousProcesses -Detailed:$false
    }
    $times += $time.TotalMilliseconds
}

$averageTime = ($times | Measure-Object -Average).Average
$minTime = ($times | Measure-Object -Minimum).Minimum
$maxTime = ($times | Measure-Object -Maximum).Maximum

Write-Host "Итераций: $iterations" -ForegroundColor Cyan
Write-Host "Среднее время: $([math]::Round($averageTime, 2)) мс" -ForegroundColor Green
Write-Host "Минимальное время: $([math]::Round($minTime, 2)) мс" -ForegroundColor Green
Write-Host "Максимальное время: $([math]::Round($maxTime, 2)) мс" -ForegroundColor Green

Write-Host "`nТест производительности завершен" -ForegroundColor Blue