# Komorebi - Configuring Games to Open in Specific Workspaces

This guide explains how to configure Komorebi to automatically send games (or any application) to specific workspaces when they launch.

## Quick Answer

To send games to a specific workspace in Komorebi, you need to add **workspace rules** to your configuration. There are two types:

1. **`initial_workspace_rules`** - Moves windows on first show (recommended for games)
2. **`workspace_rules`** - Moves windows every time they appear

## Method 1: Using komorebi.json Configuration File

Edit your `komorebi.json` file (located at `%USERPROFILE%\komorebi.json`):

```json
{
  "initial_workspace_rules": [
    {
      "kind": "Exe",
      "id": "steam.exe",
      "monitor": 0,
      "workspace": 8
    },
    {
      "kind": "Exe",
      "id": "EpicGamesLauncher.exe",
      "monitor": 0,
      "workspace": 8
    },
    {
      "kind": "Exe",
      "id": "Cyberpunk2077.exe",
      "monitor": 0,
      "workspace": 8
    }
  ]
}
```

### Configuration Options:

- **`kind`**: How to identify the application
  - `"Exe"` - Match by executable name (e.g., `"steam.exe"`)
  - `"Class"` - Match by window class name
  - `"Title"` - Match by window title
  - `"Path"` - Match by full executable path

- **`id`**: The identifier string (case-sensitive)
  - For `"Exe"`: just the executable name (e.g., `"steam.exe"`)
  - For `"Class"`: the window class (use `komorebic visible-windows` to find)
  - For `"Title"`: exact or partial window title
  - For `"Path"`: full path to executable

- **`monitor`**: Monitor index (zero-indexed, so 0 = first monitor, 1 = second, etc.)

- **`workspace`**: Workspace index on that monitor (zero-indexed, so 0 = first workspace, 8 = ninth)

## Method 2: Using CLI Commands

You can add rules dynamically using the CLI:

```powershell
# Send Steam to workspace 9 on monitor 1
komorebic initial-workspace-rule exe steam.exe 0 8

# Send Epic Games to workspace 9 on monitor 1  
komorebic initial-workspace-rule exe EpicGamesLauncher.exe 0 8

# Send a specific game by title
komorebic initial-workspace-rule title "Cyberpunk 2077" 0 8

# Reload configuration to apply changes
komorebic reload-configuration
```

**Note:** CLI commands are temporary and won't persist after restart. Add them to your startup script or use the JSON config for permanent rules.

## Finding Application Identifiers

### Method 1: Check Visible Windows

While the application is running:

```powershell
komorebic visible-windows
```

This shows all visible windows with their:
- **Title**
- **Exe** (executable name)
- **Class** (window class)

### Method 2: Use Task Manager

1. Open Task Manager (Ctrl+Shift+Esc)
2. Find your game/application
3. Right-click → Go to details
4. Note the executable name (e.g., `game.exe`)

### Method 3: Check Installation Directory

Navigate to where the game is installed and find the `.exe` file:
- Steam: Usually `C:\Program Files (x86)\Steam\steamapps\common\GameName\`
- Epic: Usually `C:\Program Files\Epic Games\GameName\`
- Xbox/Game Pass: Check `C:\XboxGames\` or use PowerShell:
  ```powershell
  Get-AppxPackage | Where-Object {$_.Name -like "*GameName*"}
  ```

## Common Game Launchers

Add these to your `komorebi.json` to organize game launchers:

```json
{
  "initial_workspace_rules": [
    {
      "kind": "Exe",
      "id": "steam.exe",
      "monitor": 0,
      "workspace": 8
    },
    {
      "kind": "Exe",
      "id": "EpicGamesLauncher.exe",
      "monitor": 0,
      "workspace": 8
    },
    {
      "kind": "Exe",
      "id": "Battle.net.exe",
      "monitor": 0,
      "workspace": 8
    },
    {
      "kind": "Exe",
      "id": "Riot Client.exe",
      "monitor": 0,
      "workspace": 8
    },
    {
      "kind": "Exe",
      "id": "EADesktop.exe",
      "monitor": 0,
      "workspace": 8
    }
  ]
}
```

## Complete Example Configuration

Here's a complete `komorebi.json` with game workspaces configured:

```json
{
  "$schema": "https://raw.githubusercontent.com/LGUG2Z/komorebi/master/schema.json",
  "app_specific_configuration_path": "applications.yaml",
  "window_hiding_behaviour": "Cloak",
  "cross_monitor_move_behaviour": "Swap",
  "default_workspace_padding": 10,
  "default_container_padding": 10,
  "border": true,
  "border_width": 8,
  "border_offset": -1,
  
  "initial_workspace_rules": [
    {
      "kind": "Exe",
      "id": "steam.exe",
      "monitor": 0,
      "workspace": 8,
      "comment": "Steam launcher on workspace 9"
    },
    {
      "kind": "Exe",
      "id": "EpicGamesLauncher.exe",
      "monitor": 0,
      "workspace": 8,
      "comment": "Epic Games on workspace 9"
    },
    {
      "kind": "Exe",
      "id": "Discord.exe",
      "monitor": 0,
      "workspace": 7,
      "comment": "Discord on workspace 8"
    },
    {
      "kind": "Exe",
      "id": "Spotify.exe",
      "monitor": 0,
      "workspace": 6,
      "comment": "Spotify on workspace 7"
    }
  ],
  
  "float_rules": [
    {
      "kind": "Exe",
      "id": "steam.exe",
      "comment": "Steam overlay windows should float"
    }
  ]
}
```

## Tips and Best Practices

### 1. Use Workspace 9 for Games (Index 8)

By convention, many users dedicate the last workspace for gaming:

```json
{
  "initial_workspace_rules": [
    {
      "kind": "Exe",
      "id": "your-game.exe",
      "monitor": 0,
      "workspace": 8
    }
  ]
}
```

### 2. Float Game Launchers (Optional)

Some game launchers (like Steam) work better as floating windows:

```json
{
  "float_rules": [
    {
      "kind": "Exe",
      "id": "steam.exe"
    }
  ]
}
```

### 3. Use Initial vs Regular Workspace Rules

- **`initial_workspace_rules`**: Only moves window on first appearance (better for games)
- **`workspace_rules`**: Moves window every time it appears (can be annoying)

For games, use `initial_workspace_rules` so you can manually move them if needed.

### 4. Multi-Monitor Setups

If you have multiple monitors and want games on your second monitor's workspace 5:

```json
{
  "initial_workspace_rules": [
    {
      "kind": "Exe",
      "id": "game.exe",
      "monitor": 1,
      "workspace": 4
    }
  ]
}
```

### 5. Fullscreen Games

Most fullscreen games automatically go borderless. If tiling interferes:

```json
{
  "float_rules": [
    {
      "kind": "Exe",
      "id": "fullscreen-game.exe"
    }
  ]
}
```

Or add to the ignore list in `applications.yaml`.

## Troubleshooting

### Game Doesn't Go to Workspace

1. **Check the executable name is correct**
   ```powershell
   komorebic visible-windows
   ```

2. **Make sure Komorebi is running**
   ```powershell
   komorebic check
   ```

3. **Reload configuration**
   ```powershell
   komorebic reload-configuration
   ```

4. **Check if the game is being ignored**
   Look in `applications.yaml` for ignore rules

### Game Launches on Wrong Workspace

- Verify monitor index (0 = first monitor)
- Verify workspace index (0 = first workspace, not 1)
- Check for conflicting rules in `applications.yaml`

### Game Crashes or Doesn't Tile Properly

Add the game to float rules or ignore it:

```json
{
  "float_rules": [
    {
      "kind": "Exe",
      "id": "problematic-game.exe"
    }
  ]
}
```

## Related Commands

```powershell
# View current workspace rules
komorebic state

# Clear all workspace rules
komorebic clear-all-workspace-rules

# Test by manually moving window to workspace
komorebic move-to-workspace 8

# Enforce workspace rules (re-apply all rules)
komorebic enforce-workspace-rules
```

## See Also

- [Komorebi Documentation](https://lgug2z.github.io/komorebi/)
- [Komorebi Configuration Schema](https://komorebi.lgug2z.com/schema)
- [Application-Specific Configuration](https://github.com/LGUG2Z/komorebi-application-specific-configuration)

## Example: Popular Games

```json
{
  "initial_workspace_rules": [
    {"kind": "Exe", "id": "csgo.exe", "monitor": 0, "workspace": 8},
    {"kind": "Exe", "id": "Valorant.exe", "monitor": 0, "workspace": 8},
    {"kind": "Exe", "id": "RocketLeague.exe", "monitor": 0, "workspace": 8},
    {"kind": "Exe", "id": "LeagueClient.exe", "monitor": 0, "workspace": 8},
    {"kind": "Exe", "id": "overwatch.exe", "monitor": 0, "workspace": 8},
    {"kind": "Exe", "id": "Minecraft.exe", "monitor": 0, "workspace": 8}
  ]
}
```
