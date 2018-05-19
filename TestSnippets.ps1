$Title = "Select a color"
$Message = "Select from the list below your favorite color?"
$Choices = ("Red","Green","Blue")
$Choose = @()
foreach ($choice in $Choices) {
 $Choose += New-Object System.Management.Automation.Host.ChoiceDescription "&$choice"
}

$result = $host.ui.PromptForChoice($Title, $Message, $Choose, 1)
#$Choose.Count
Switch($result)
{
 {for ($i = 0; $i -lt $Choose.Count; $i++) {$i}} { $i}
}

Switch($result)
{
   0 { Write-Host  "is selected Red" }
   1 { Write-Host  "is selected Green" }
   2 { Write-Host  "selected Blue" }
}

for ($i = 0; $i -lt $Choose.Count; $i++) {Write-Host "Hello"}