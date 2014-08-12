Function Export-Taskbar($configsPath,$configName)
{
    $username = $env:username
    $iconsPath = "C:\Users\$username\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch"

    if(!(Test-Path -Path "$configsPath\$configName")){
     New-Item "$configsPath\$configName" -itemtype directory
    }

    Copy-Item $iconsPath "$configsPath\$configName" -recurse -force

    $ErrorActionPreference = "SilentlyContinue"
    reg export HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband "$configsPath\$configName\registry.reg" /y
    $ErrorActionPreference = "Continue"
}


Function Import-Taskbar($configsPath,$configName)
{
    $username = $env:username
    $iconsPath = "C:\Users\$username\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch"

    Copy-Item "$configsPath\$configName\Quick Launch\*" $iconsPath -recurse -force

    $ErrorActionPreference = "SilentlyContinue"
    reg import "$configsPath\$configName\registry.reg"
    $ErrorActionPreference = "Continue"

    Stop-Process -processname explorer
}

Function Get-TaskbarConfigurations($configsPath) {
    Get-ChildItem $configsPath | Select-Object Name | Sort-Object Name
}


$configsPath = "C:\temp\TaskbarConfigs"

#Export-Taskbar "Visual Studio" $configsPath
#Import-Taskbar "Visual Studio" $configsPath

Function ToArray
{
  begin
  {
    $output = @(); 
  }
  process
  {
    $output += $_; 
  }
  end
  {
    return ,$output; 
  }
}

$DropDownArray = Get-TaskbarConfigurations $configsPath




# This Function Returns the Selected Value and Closes the Form

Function ImportButtonClick($configsPath) {
 $configName = $DropDown.SelectedItem.ToString()
 $Form.Close() 
 Import-Taskbar $configsPath $configName
}

Function ExportButtonClick($configsPath) {
 $configName = $TextBox.Text
 $exists = 0

 ForEach ($Item in $DropDownArray) {
  if($Item.Name -eq $configName) {
    $exists = 1
    break
  }
 }

 if($exists -eq 1){
  $a = new-object -comobject wscript.shell
  $result = $a.popup("$configName already exists. Do you want to overwrite it?",0,"Overwrite?",4) 
  $yes = 6
  if($result -ne $yes) {
    $Form.Close()
    return
  }
 }

 $Form.Close()
 Export-Taskbar $configsPath $configName
}

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")


$Form = New-Object System.Windows.Forms.Form

$Form.width = 310
$Form.height = 110
$Form.Text = ”Context Taskbar”

$TextBox = new-object System.Windows.Forms.TextBox
$TextBox.Location = new-object System.Drawing.Size(10,10)
$TextBox.Size = new-object System.Drawing.Size(130,20)
$TextBox.Text = ""
$form.Controls.Add($TextBox)

$ExpButton = new-object System.Windows.Forms.Button
$ExpButton.Location = new-object System.Drawing.Size(10,30)
$ExpButton.Size = new-object System.Drawing.Size(130,20)
$ExpButton.Text = "Export Taskbar"
$ExpButton.Add_Click({ExportButtonClick $configsPath})
$form.Controls.Add($ExpButton)

$DropDown = new-object System.Windows.Forms.ComboBox
$DropDown.Location = new-object System.Drawing.Size(150,10)
$DropDown.Size = new-object System.Drawing.Size(130,30)

ForEach ($Item in $DropDownArray) {
 [void] $DropDown.Items.Add($Item.Name)
}

$DropDown.SelectedIndex = 0

$Form.Controls.Add($DropDown)

$ImpButton = new-object System.Windows.Forms.Button
$ImpButton.Location = new-object System.Drawing.Size(150,30)
$ImpButton.Size = new-object System.Drawing.Size(130,20)
$ImpButton.Text = "Import Taskbar"
$ImpButton.Add_Click({ImportButtonClick $configsPath})
$form.Controls.Add($ImpButton)

$Form.Add_Shown({$Form.Activate()})
[void] $Form.ShowDialog()
