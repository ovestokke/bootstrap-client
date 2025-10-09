# Agent Guidelines

## Project Overview
PowerShell automation scripts for Windows 11 fresh installation setup. Scripts automate bloatware removal, privacy settings, developer tools, and application installation using winget.

## Commands
No build/test/lint commands - this is a script repository, not a compiled project.

## Code Style

### Language
PowerShell (.ps1 files)

### File Structure
- Header comment block with script title, author, and version
- Region blocks (`#region` / `#endregion`) to organize sections (Setup, Privacy, UI/UX, Developer, Install Applications, etc.)
- Execution policy set at start: `Set-ExecutionPolicy Unrestricted -Force`

### Naming & Conventions
- Variables: camelCase (e.g., `$bloatware`, `$appsToInstall`)
- Arrays: Use `@()` syntax for lists
- Comments: Use `#` for inline comments, provide context for registry edits and external links

### Application Installation
- Use `winget install --id <AppId> -e --accept-package-agreements --accept-source-agreements`
- Include comment: "NOTE: You can find the exact ID of an application by running 'winget search "Application Name"' on your Windows machine. Using the exact ID is more reliable."
- Use exact app IDs (e.g., "Mozilla.Firefox", "Git.Git")

### Registry Edits
- Use `Set-ItemProperty` with `-Force` flag
- Always include comments explaining what the registry edit does

### Output
- End scripts with `Write-Host` message indicating completion
