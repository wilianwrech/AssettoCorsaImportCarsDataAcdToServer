Add-Type -AssemblyName System.Windows.Forms
$AssettoPath = "${env:ProgramFiles(x86)}\Steam\steamapps\common\assettocorsa"
$AssettoPathExists = Test-Path $AssettoPath -PathType Container
If (-Not $AssettoPathExists) {
	$DialogChooser = New-Object -Typename System.Windows.Forms.FolderBrowserDialog
	$DialogChooser.ShowDialog()
	$AssettoPath = $DialogChooser.SelectedPath
}
If ($AssettoPath -Eq "") {
	Return
}
$CarsPath = "$($AssettoPath)\content\cars"
$ServerCarsPath = "$($AssettoPath)\server\content\cars"
Write-Host "Assetto Corsa path: $($AssettoPath)`n" -ForegroundColor "Blue"
Get-ChildItem -Path $CarsPath -Directory | ForEach-Object {	
	$CarPath = $_
	$ServerCarPath = "$($ServerCarsPath)\$($CarPath.Name)"
	$ServerCarPathExists = Test-Path $ServerCarPath -PathType Container
	If (-Not $ServerCarPathExists) {
		$Null = New-Item -Path $ServerCarPath -ItemType Directory
		Write-Host "$($CarPath.Name) - Car folder created" -ForegroundColor "Green"
	}
	$DataAdcFileName = "data.acd"
	$DataAcdFilePath = "$($CarPath.FullName)\$($DataAdcFileName)"
	$ServerDataAcdFilePath = "$($ServerCarPath)\$($DataAdcFileName)"
	If (Test-Path $ServerDataAcdFilePath -PathType Leaf) {
		If ($NotReplaceAll) {
			Return
		}
		If (-Not $ReplaceAll) {
			$InvalidAnswer = $True
			While ($InvalidAnswer)
			{
				$InvalidAnswer = $False
				$Answer = Read-Host "$($CarPath.Name) - Data.acd already exists do you want to replace it? (y) yes | (n) no | (ya) yes to all | (na) no to all"
				Switch ($Answer) {
					"y" {}
					"n" { Return }
					"ya" { $ReplaceAll = $True }
					"na" {
						$NotReplaceAll = $True
						Return
					}
					default { $InvalidAnswer = $True }
				}
			}
		}
	}
	If (Test-Path $DataAcdFilePath -PathType Leaf) {
		Copy-Item -Path $DataAcdFilePath -Destination $ServerDataAcdFilePath -Force
		Write-Host "$($CarPath.Name) - Data.acd file copied" -ForegroundColor "Green"
	}
}
Write-Host "Done importing all cars" -ForegroundColor "Green"