# PC Upgrade Project Summary

This document summarizes the final hardware selection and the plan for automating the Windows 11 installation.

## Final Hardware Selection

The following components have been selected and ordered:

*   **CPU:** AMD Ryzen 7 9800X3D
*   **Motherboard:** GIGABYTE B850 AORUS ELITE WIFI7 ICE
*   **RAM:** 64GB (2x32GB) Corsair Vengeance DDR5 6000MHz CL30 (Model: `CMK64GX5M2B6000Z30`)
*   **Primary SSD:** 1TB Kingston FURY Renegade PCIe 5.0 NVMe M.2 SSD

### Storage Strategy

*   The **1TB PCIe 5.0 SSD** will be installed in the primary Gen5 M.2 slot.
*   This drive will be used as the main boot drive (C:) for the Windows OS, core work applications, and most-played games.
*   It is critical to use the motherboard's M.2 heatsink on this drive.

## Windows 11 Installation Plan

The goal is to automate the post-installation setup of applications and settings using a PowerShell script.

### Key Principles

1.  **Use Official Windows Media:** Install Windows 11 using the official installer from Microsoft's website. Avoid any pre-modified or "optimized" ISOs.
2.  **Automate with PowerShell and `winget`:** A single PowerShell script (`.ps1`) will be created to handle the setup.
3.  **Document via Script:** The script itself will serve as documentation for the system's setup.

### Scripting Guide

*   **Script Name:** `MySetup.ps1`
*   **Execution:** After Windows is installed, the script must be run from PowerShell opened **as an Administrator**.
*   **Execution Policy:** The execution policy may need to be set once by running `Set-ExecutionPolicy RemoteSigned`.
*   **`winget` Commands:** Applications will be installed using the Windows Package Manager (`winget`).
    *   Find application IDs with `winget search "Application Name"`.
    *   Install applications silently in the script using the format:
        ```powershell
        winget install --id <AppId> -e --accept-package-agreements --accept-source-agreements
        ```
*   **Customization:** PowerShell commands can be added to the script to tweak Windows settings, such as showing file extensions.
    ```powershell
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0
    ```
