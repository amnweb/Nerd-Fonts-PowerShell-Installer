function DownloadAndInstallFont {
    param(
        [Parameter(Mandatory=$true)]
        [string]$fontName
    )
    $url = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/{0}.zip" -f $fontName
    $LocalAppData = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::LocalApplicationData)
    $DestinationFolder = Join-Path -Path $LocalAppData -ChildPath "Microsoft\Windows\Fonts\$fontName"
    $Temp = $env:TEMP

    # Create the destination folder if it doesn't exist
    if (-not (Test-Path $DestinationFolder)) {
        New-Item -ItemType Directory -Path $DestinationFolder | Out-Null
    }

    try {
            Write-Host "Downloading $fontName..." -ForegroundColor Cyan
            Invoke-WebRequest -Uri $url -OutFile "$Temp\$fontName.zip"

            Write-Host "Extracting $fontName..." -ForegroundColor DarkCyan
            Expand-Archive -Path "$Temp\$fontName.zip" -DestinationPath $DestinationFolder -Force

            $fontFiles = Get-ChildItem -Path $DestinationFolder -Include '*.ttf', '*.otf' -Recurse
            $fileCount = $fontFiles.Count
            $counter = 1
            foreach ($file in $fontFiles) {
                $fontFilePath = $file.FullName
                $fontFileName = $file.Name
                
                # Register the font for the current user by adding it to the registry
                $fontsRegPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"
                $null = Set-ItemProperty -Path $fontsRegPath -Name $fontFileName -Value $fontFilePath
                Write-Host "-Installed ($counter/$fileCount)" -ForegroundColor White
                Start-Sleep -Milliseconds 100
                $counter++
            }
            Remove-Item -Path "$Temp\$fontName.zip" -Force
    } catch {
        Write-Error "An error occurred: $_"
    }
}

try {
    Write-Host "Fetching available Nerd Fonts..." -ForegroundColor Cyan
    
    # Get the latest release info using the GitHub API
    $releaseInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest"
    
    # Extract all assets and filter for .zip files only
    $fontsArray = $releaseInfo.assets | 
                 Where-Object { $_.name -like "*.zip" -and $_.name -notlike "*.tar.xz" } | 
                 ForEach-Object { 
                     # Extract font name without extension
                     $_.name -replace '\.zip$', ''
                 } | 
                 Sort-Object
                 
    if ($fontsArray.Count -eq 0) {
        Write-Host "No fonts found in the latest release." -ForegroundColor Red
        exit
    }
    
    Write-Host "Found $($fontsArray.Count) fonts available for installation." -ForegroundColor Green
}
catch {
    # An error occurred, likely due to a problem with the API request
    Write-Host "An error occurred while trying to fetch fonts from GitHub: $_" -ForegroundColor Red
    exit 
}
 
$ProgressPreference = 'SilentlyContinue'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Nerd Fonts Installer'
$form.Size = New-Object System.Drawing.Size(300,360)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $false

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(75,280)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = 'Install'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(150,280)
$cancelButton.Size = New-Object System.Drawing.Size(75,23)
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Please select a font to install'
$form.Controls.Add($label)

$CheckListBox = New-Object System.Windows.Forms.CheckedListBox
$CheckListBox.Location = New-Object System.Drawing.Point(10,40)
$CheckListBox.Size = New-Object System.Drawing.Size(260,220) 
$CheckListBox.CheckOnClick = $true

if ($fontsArray.Count -gt 0) {
    [void]$CheckListBox.Items.Add("Select All")
    foreach ($font in $fontsArray) {
        [void]$CheckListBox.Items.Add($font)
    }
} else {
    Write-Host "No fonts available to install." -ForegroundColor Red
    exit
}

# Handle the ItemCheck event to select or deselect all items
$CheckListBox.add_ItemCheck({
    param($eventSender, $e)
    if ($e.Index -eq 0) { # Check if the "Select All" checkbox is toggled
        $isChecked = $e.NewValue -eq [System.Windows.Forms.CheckState]::Checked
        for ($i = 1; $i -lt $eventSender.Items.Count; $i++) {
            $eventSender.SetItemChecked($i, $isChecked)
        }
    }
})
$form.Controls.Add($CheckListBox)
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    foreach ($checkbox in $CheckListBox.CheckedItems) {
        if($checkbox -ne 'Select All'){
            DownloadAndInstallFont $checkbox
        }
    }
}
$form.Dispose()