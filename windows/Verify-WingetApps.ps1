#
# Winget Package Verification Script
#
# This script verifies that all packages in the installation list are available on winget
#

# Parameter for which list to verify
param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Basic", "Full")]
    [string]$ListType = "Full"
)

# Load applications list from file
$appsListFile = Join-Path $PSScriptRoot "Apps-List-$ListType.txt"

if (-not (Test-Path $appsListFile)) {
    Write-Host "[FAIL] $appsListFile not found" -ForegroundColor Red
    Write-Host "Available lists: Apps-List-Basic.txt, Apps-List-Full.txt" -ForegroundColor Yellow
    exit 1
}

# Read and parse the apps list file (skip comments and empty lines)
$appsToVerify = Get-Content $appsListFile |
    Where-Object { $_ -notmatch '^\s*#' -and $_ -notmatch '^\s*$' } |
    ForEach-Object { $_.Trim() }

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Winget Package Verification" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$found = @()
$notFound = @()
$total = $appsToVerify.Count
$current = 0

foreach ($app in $appsToVerify) {
    $current++
    Write-Host "[$current/$total] Checking: $app" -NoNewline

    $result = winget show --id $app -e 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host " [OK]" -ForegroundColor Green
        $found += $app
    }
    else {
        Write-Host " [NOT FOUND]" -ForegroundColor Red
        $notFound += $app
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Verification Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total packages: $total"
Write-Host "Found: $($found.Count)" -ForegroundColor Green
Write-Host "Not Found: $($notFound.Count)" -ForegroundColor Red
Write-Host ""

if ($notFound.Count -gt 0) {
    Write-Host "Packages NOT available on winget:" -ForegroundColor Red
    foreach ($app in $notFound) {
        Write-Host "  - $app" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "Please search for alternatives using:" -ForegroundColor Yellow
    Write-Host "  winget search <package_name>" -ForegroundColor Yellow
}
else {
    Write-Host "All packages are available on winget!" -ForegroundColor Green
}

Write-Host ""
