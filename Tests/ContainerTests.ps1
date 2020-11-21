$count = 0

$arrayApis = @("http://localhost:4200", "http://localhost:5000/Identity/Login", "http://localhost:5002/Companies/GetCompanyDepartments", "http://localhost:5004/Statistics/Full", "http://localhost:5010/Home/Index", "http://localhost:5006/Drive/MyFolders", "http://localhost:5013/healthchecks-ui")

do {
    $count++
    Write-Output "[$env:STAGE_NAME] Starting container [Attempt: $count]"
	
	for($i = 0; $i -lt $arrayApis.length; $i++){ 
		$testStart = Invoke-WebRequest -Uri $arrayApis[$i] -UseBasicParsing
    
		if ($testStart.statuscode -eq '200' -Or $testStart.statuscode -eq '401') {
			$started = $true
		} else {
			Start-Sleep -Seconds 10
		}
	}
} until ($started -or ($count -eq 3))

if (!$started) {
    exit 1
}