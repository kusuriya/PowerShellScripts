$hostname = $env:COMPUTERNAME
$Counters ="\Processor(*)\% processor time","\Processor(*)\Interrupts/sec","\LogicalDisk(*)\% Free Space","\PhysicalDisk(*)\Current Disk Queue Length","\PhysicalDisk(*)\Disk Reads/sec","\PhysicalDisk(*)\Disk Writes/sec","\Memory\% Committed Bytes In Use","\Memory\Page Faults/sec","\Memory\Available MBytes","\Process(_Total)\% User Time","\Process(_Total)\Private Bytes","\Process(_Total)\Working Set","\Network Interface(*)\Bytes Received/sec","\Network Interface(*)\Bytes Sent/sec","\Network Interface(*)\Current Bandwidth","\Network Interface(*)\Output Queue Length","\System\% Registry Quota in Use","\System\Processor Queue length","\System\System Up Time","\Paging File(*)\% Usage"
get-counter -SampleInterval 1 -MaxSamples 30 -Counter $Counters |Export-Clixml "c:\temp\$hostname.xml"
$xml = Import-Clixml "c:\temp\$hostname.xml"
$header = '"Path","InstanceName","Value"'
$rundate = Get-Date -format MM.dd.yyyy
$header|Out-File -Force "c:\temp\$hostname-Perfdata-$rundate.csv"
	foreach ($entry in $xml) {
			$sample = $entry.CounterSamples
			$totsample = $sample.count
			$CurrentSample = 0
			While ($currentSample -ne $Totsample){
				$path = $entry.countersamples[$currentSample].Path
				$InstanceName = $entry.countersamples[$currentSample].InstanceName
				$CookedValue = $entry.countersamples[$currentSample].CookedValue
				$text = "$path"+","+"$InstanceName"+","+"$CookedValue"
				$text | Out-File -Append -Force "c:\temp\$hostname-Perfdata.csv"
				$currentsample ++
			}
	}
Copy-Item "c:\temp\$hostname-Perfdata-$rundate.csv" -Destination "\\sagfslab11\c$\Scripts\_output\PerfData\" -Force