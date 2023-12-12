function DownloadFont {
    param(
        [Parameter(Mandatory=$true)]
        [string]$fontname
    )

    # Construct the URL using the format operator -f
    $url = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/{0}.zip" -f $fontname
    
    try {
        Write-Host "Installing " -ForegroundColor White -NoNewLine
        Write-Host $fontname -ForegroundColor Green
        # Download the font zip file
        Invoke-WebRequest -Uri $url -OutFile "$fontname.zip"

        # Expand the downloaded zip file
        Expand-Archive -Path "$fontname.zip" -DestinationPath $fontname -Force

        # Define the destination path for the fonts
        $destinationPath = "C:\Windows\Fonts"
        
        # Ensure destination path exists
        If (-not (Test-Path $destinationPath)) {
            Write-Error "The destination path $destinationPath does not exist."
            return
        }

        # Install the font files
        Get-ChildItem -Path $fontname -Recurse -Filter "*.ttf" | ForEach-Object {
            $fontFilePath = Join-Path $destinationPath $_.Name
            If (-not (Test-Path $fontFilePath)) {        
                # Copy font to the destination
                #Copy-Item $_.FullName -Destination $fontFilePath
            }
        }

        # Clean up the downloaded and extracted files
        Remove-Item -Path $fontname -Recurse -Force
        Remove-Item -Path "$fontname.zip" -Force
    } catch {
        Write-Error "An error occurred: $_"
    }
}
try {
    $fontsList = (Invoke-webrequest -URI "https://raw.githubusercontent.com/amnweb/nf-installer/main/fonts.txt").Content
}
catch {
    # An error occurred, likely due to a problem with the web request
    Write-Host "An error occurred while trying to download the content: $_" -ForegroundColor Red
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

$fontsArray = $fontsList -split "`n"
if ($fontsList.Length) {
    [void]$CheckListBox.Items.Add("Select All")
    foreach ($font in $fontsArray) {
        [void]$CheckListBox.Items.Add($font.Trim())
    }
} else {
    Write-Host "The file $fontsList does not exist." -ForegroundColor Red
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
            DownloadFont $checkbox
        }
        
    }
}
$form.Dispose()
