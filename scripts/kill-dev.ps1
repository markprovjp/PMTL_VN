param(
    [switch]$IncludeDatabases,
    [switch]$Aggressive,
    [int[]]$Ports
)

$ErrorActionPreference = 'SilentlyContinue'

$workspaceRoot = Split-Path -Parent $PSScriptRoot
$defaultPorts = @(1337, 3000, 3001, 4173, 4200, 5173, 7700, 9229)
$databasePorts = @(5432, 1433, 1434)
$targetPorts = if ($Ports -and $Ports.Count -gt 0) { $Ports } else { $defaultPorts }

if ($IncludeDatabases) {
    $targetPorts = $targetPorts + $databasePorts
}

$targetPorts = $targetPorts | Sort-Object -Unique
$killed = New-Object System.Collections.Generic.List[string]
$skipped = New-Object System.Collections.Generic.List[string]
$seenPids = @{}

function Add-Result {
    param(
        [string]$Bucket,
        [string]$Message
    )

    if ($Bucket -eq 'Killed') {
        $killed.Add($Message)
        return
    }

    $skipped.Add($Message)
}

function Stop-ProcessSafe {
    param(
        [int]$Pid,
        [string]$Reason
    )

    if ($seenPids.ContainsKey($Pid)) {
        return
    }

    $proc = Get-CimInstance Win32_Process -Filter "ProcessId = $Pid"
    if (-not $proc) {
        return
    }

    $name = $proc.Name
    $cmd = $proc.CommandLine
    $cmdText = if ([string]::IsNullOrWhiteSpace($cmd)) { '(no command line)' } else { $cmd }

    $protectedNames = @(
        'postgres.exe',
        'pg_ctl.exe',
        'sqlservr.exe',
        'mysqld.exe',
        'mongod.exe',
        'Redis.Server.exe'
    )

    if (-not $IncludeDatabases -and $protectedNames -contains $name) {
        Add-Result -Bucket 'Skipped' -Message "skip PID $Pid [$name] $Reason"
        return
    }

    Stop-Process -Id $Pid -Force
    if ($LASTEXITCODE -ne 0 -and -not (Get-Process -Id $Pid)) {
        $LASTEXITCODE = 0
    }

    if (-not (Get-Process -Id $Pid)) {
        $seenPids[$Pid] = $true
        Add-Result -Bucket 'Killed' -Message "killed PID $Pid [$name] $Reason"
        return
    }

    Add-Result -Bucket 'Skipped' -Message "failed PID $Pid [$name] $Reason"
}

Write-Host ''
Write-Host 'PMTL Dev Cleanup'
Write-Host "Workspace: $workspaceRoot"
Write-Host "Ports: $($targetPorts -join ', ')"
Write-Host "Include DB ports: $IncludeDatabases"
Write-Host "Aggressive mode: $Aggressive"

foreach ($port in $targetPorts) {
    $connections = Get-NetTCPConnection -LocalPort $port -State Listen
    foreach ($conn in $connections) {
        Stop-ProcessSafe -Pid $conn.OwningProcess -Reason "listener on port $port"
    }
}

$candidateProcesses = Get-CimInstance Win32_Process | Where-Object {
    $_.Name -in @('node.exe', 'bun.exe', 'deno.exe') -and $_.CommandLine
}

$devPatterns = @(
    'strapi',
    'vite',
    'next',
    'nodemon',
    'tsx',
    'ts-node',
    'webpack-dev-server',
    'react-scripts',
    'turbo',
    'remotion'
)

foreach ($proc in $candidateProcesses) {
    $cmd = $proc.CommandLine.ToLowerInvariant()
    $belongsToWorkspace = $cmd.Contains($workspaceRoot.ToLowerInvariant())
    $looksLikeDevServer = $false

    foreach ($pattern in $devPatterns) {
        if ($cmd.Contains($pattern)) {
            $looksLikeDevServer = $true
            break
        }
    }

    if ($belongsToWorkspace -or $looksLikeDevServer -or $Aggressive) {
        Stop-ProcessSafe -Pid $proc.ProcessId -Reason 'matched dev process'
    }
}

Write-Host ''
if ($killed.Count -gt 0) {
    Write-Host 'Killed:'
    foreach ($item in $killed) {
        Write-Host " - $item"
    }
} else {
    Write-Host 'Killed: none'
}

if ($skipped.Count -gt 0) {
    Write-Host ''
    Write-Host 'Skipped:'
    foreach ($item in $skipped) {
        Write-Host " - $item"
    }
}
