# Agent Guidelines

## Project Overview
PowerShell and Bash automation scripts for Windows 11 fresh installation setup. Automates bloatware removal, privacy settings, developer tools, WSL/Ubuntu configuration, and application installation using winget.

## Commands
No build/test/lint commands - this is a script repository. Test scripts manually in appropriate environments (PowerShell as Admin for .ps1, WSL for .sh).

## Code Style

### PowerShell (.ps1)
- Header: `# Script Title`, `# @author: Ovestokke`, `# @version: X.X`, optional usage comment
- Structure: Use `#region Name` / `#endregion` to organize sections (Setup, Functions, Privacy, UI/UX, Developer, etc.)
- Variables: camelCase (e.g., `$bloatware`, `$appsToInstall`), arrays use `@()` syntax
- Error handling: Use `try/catch` blocks, check `$LASTEXITCODE`, use `-ErrorAction Stop` or `SilentlyContinue`
- Admin check: Scripts requiring elevation check for Administrator role: `([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")`
- Logging: Use `Start-Transcript` / `Stop-Transcript` for important scripts, store logs with timestamp: `Setup-Script-Log-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').txt`
- Output: Colored `Write-Host` (`-ForegroundColor Cyan/Green/Red/Yellow/Gray`), format: `[OK]`, `[FAIL]`, `[SKIP]`, `- Not installed`, `→`
- Helper functions: Use `Write-Success`, `Write-Fail`, `Write-Skip`, `Write-Info` for consistent output formatting
- Functions: PascalCase names, use `param()` blocks with typed parameters, include error handling
- Registry: Use helper function `Set-RegistryValue` that creates path if missing, use `-Force`, always comment registry purpose
- Winget: `winget install --id <ExactID> -e --accept-package-agreements --accept-source-agreements`, check exit codes (0=success, -1978335189=already installed)
- Include comment: "NOTE: You can find the exact ID of an application by running 'winget search "Application Name"' on your Windows machine. Using the exact ID is more reliable."

### Bash (.sh for WSL)
- Header: `#!/bin/bash`, `# Script Title`, `# @author: Ovestokke`, `# @version: X.X`, usage comment
- Use `set -e` to exit on error at script start
- Color variables: Define at top: `RED`, `GREEN`, `YELLOW`, `CYAN`, `NC` using `\033` escape codes
- Helper functions: `print_success` (✓), `print_error` (✗), `print_warning` (!), `print_info` (→), `print_header` (with separators)
- Output: Section headers with 40 `=` characters, use colored echo with unicode symbols
- Checks: Verify environment (e.g., `grep -qi microsoft /proc/version`), check if tools/directories exist before installing
- Commands: Use `command -v <tool> &> /dev/null` to check if installed, use `apt-cache show <package>` before apt installs
- Variables: UPPER_CASE for configuration values, check if empty with `[ -z "$VAR" ]`
