# Nerd Fonts PowerShell Installer

This repository hosts a PowerShell script designed to automate the installation of <a href="https://github.com/ryanoasis/nerd-fonts" tagret="_blank">Nerd Fonts</a> on your system. Nerd Fonts patches developer-targeted fonts with a high number of glyphs (icons). Specifically, it targets coding-related and UI-enhancement purposes.


<img src="images/screenshot.gif" width="1066" alt="Nerd Fonts PowerShell Installer" />


## Features

- **Automated Installation**: Quickly install Nerd Fonts without manual downloading and installing.
- **Customization**: Choose which Nerd Font families you want to install.
- **Convenience**: Install multiple fonts at once with minimal user interaction.

## Prerequisites

Before running the installation script, ensure that:

- You are using a Windows operating system with PowerShell.

## Installation

To install Nerd Fonts using the PowerShell script, follow these steps:

1. Open PowerShell.
2. Clone script ```git clone https://github.com/amnweb/nf-installer```
3. Navigate to the directory where you've saved the script.
4. Execute the script:

```powershell
.\install.ps1
```
or run directly from github
1. Open PowerShell.
2. Copy and paste this command
```
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/amnweb/nf-installer/main/install.ps1'))
```


## Usage

Once the fonts are installed, you can select them in your terminal or code editor settings by looking for font names prefixed with 'NF' (e.g., `FiraCode NF`).

For example, to set a Nerd Font in Visual Studio Code, go to `Settings > Text Editor > Font` and enter the name of the Nerd Font you installed.
