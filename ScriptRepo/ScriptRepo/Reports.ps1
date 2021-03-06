# First lets create a text file, where we will later save the freedisk space info
$freeSpaceFileName = 'c:\temp\FreeSpace.htm'
$serverlist = Get-Content "c:\scripts\_input\serverlist1.txt"
$warning = 25
$critical = 10
$date = ( get-date ).ToString('yyyy/MM/dd HH:MM')
New-Item -ItemType file $freeSpaceFileName -Force
# Getting the freespace info using WMI
#Get-WmiObject win32_logicaldisk  | Where-Object {$_.drivetype -eq 3} | format-table DeviceID, VolumeName,status,Size,FreeSpace | Out-File FreeSpace.txt
# Function to write the HTML Header to the file
Function writeHtmlHeader
{
param($fileName)
$date = ( get-date ).ToString('yyyy/MM/dd HH:MM')
Add-Content $fileName '
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'
 Add-Content $fileName "<title>GFS Service Report $date</title>"
 Add-Content $fileName '
 		<STYLE TYPE="text/css">
 			<!--
  				td {
  					font-family: Tahoma;
  					font-size: 11px;
  					border-top: 1px solid #999999;
  					border-right: 1px solid #999999;
  					border-bottom: 1px solid #999999;
  					border-left: 1px solid #999999;
  					padding-top: 0px;
  					padding-right: 0px;
  					padding-bottom: 0px;
  					padding-left: 0px;
  				}
  				body {
  					margin-left: 5px;
  					margin-top: 5px;
  					margin-right: 0px;
  					margin-bottom: 10px;
				}
  
  				table {
  					border: thin solid #000000;
					table-layout:fixed;
  				}
  			-->
  		</style>
 	</head>
<body>'

add-content $fileName  '
<table width="100%">
<tr bgcolor="#CCCCCC">
<td colspan="7" height="25" align="center">
<font face="tahoma" color="#003399" size="4">'
add-content $fileName "<strong>GFS Service Report - $date</strong></font>"
add-content $fileName '
</td>
</tr>
</table>'

}

# Function to write the HTML Header to the file
Function writeDiskTableHeader
{
param($fileName)

 Add-Content $fileName "<tr bgcolor=#CCCCCC>
 <td width='10%' align='center'>Drive</td>
 <td width='50%' align='center'>Drive Label</td>
 <td width='10%' align='center'>Total Capacity(GB)</td>
 <td width='10%' align='center'>Used Capacity(GB)</td>
 <td width='10%' align='center'>Free Space(GB)</td>
 <td width='10%' align='center'>Freespace %</td>
 </tr>"
}

Function writeServiceTableHeader
{
param($fileName)

 Add-Content $fileName "<tr bgcolor=#CCCCCC>
 <td align='center'>Service Name</td>
 <td align='center' colspan='5'>Service Status</td>
 </tr>"
}

Function writeHtmlFooter
{
param($fileName)

Add-Content $fileName '</body>
</html>'
}

Function writeDiskInfo
{
param($fileName,$devId,$volName,$frSpace,$totSpace)
$totSpace=[math]::Round(($totSpace/1073741824),2)
$frSpace=[Math]::Round(($frSpace/1073741824),2)
$usedSpace = $totSpace - $frspace
$usedSpace=[Math]::Round($usedSpace,2)
$freePercent = ($frspace/$totSpace)*100
$freePercent = [Math]::Round($freePercent,0)
if ($freePercent -gt $warning)
{
Add-Content $fileName "<tr>"
Add-Content $fileName "<td>$devid</td>"
Add-Content $fileName "<td>$volName</td>"

Add-Content $fileName "<td>$totSpace</td>"
Add-Content $fileName "<td>$usedSpace</td>"
Add-Content $fileName "<td>$frSpace</td>"
Add-Content $fileName "<td>$freePercent</td>"
Add-Content $fileName "</tr>"
}
elseif ($freePercent -le $critical)
{
Add-Content $fileName "<tr>"
Add-Content $fileName "<td>$devid</td>"
Add-Content $fileName "<td>$volName</td>"
Add-Content $fileName "<td>$totSpace</td>"
Add-Content $fileName "<td>$usedSpace</td>"
Add-Content $fileName "<td>$frSpace</td>"
Add-Content $fileName "<td bgcolor='#FF0000' align=center>$freePercent</td>"
#<td bgcolor='#FF0000' align=center>
Add-Content $fileName "</tr>"
}
else
{
Add-Content $fileName "<tr>"
Add-Content $fileName "<td>$devid</td>"
Add-Content $fileName "<td>$volName</td>"
Add-Content $fileName "<td>$totSpace</td>"
Add-Content $fileName "<td>$usedSpace</td>"
Add-Content $fileName "<td>$frSpace</td>"
Add-Content $fileName "<td bgcolor='#FBB917' align=center>$freePercent</td>"
# #FBB917
Add-Content $fileName "</tr>"
}
}

Function writeServiceInfo
{
param($fileName, $Computers, $servicec)
$ComputerName
$serviceworker = Get-Service -ComputerName $Computers -Name $servicec
$MachineName = $serviceworker.MachineName
$Name = $serviceworker.Name
$DisplayName = $serviceworker.DisplayName
$ServiceStatus = $serviceworker.Status
if ($ServiceStatus -match "Running")
{
Add-Content $fileName "<tr>"
Add-Content $fileName "<td>$Name</td>"
Add-Content $fileName "<td bgcolor='#00FF00' colspan='5'>$ServiceStatus</td>"
Add-Content $fileName "</tr>"
}
elseif ($ServiceStatus -match "Stopped")
{
Add-Content $fileName "<tr>"
Add-Content $fileName "<td>$Name</td>"
Add-Content $fileName "<td bgcolor='#FF0000' colspan='5'>$ServiceStatus</td>"
Add-Content $fileName "</tr>"
#<td bgcolor='#FF0000' align=center>
Add-Content $fileName "</tr>"
}
elseif ([System.Exception])
{
Add-Content $fileName "<tr>"
Add-Content $fileName "<td>$servicec</td>"
Add-Content $fileName "<td colspan='5'>Not Present</td>"
Add-Content $fileName "</tr>"
#<td bgcolor='#FF0000' align=center>
Add-Content $fileName "</tr>"
}
else
{
Add-Content $fileName "<tr>"
Add-Content $fileName "<td>$devid</td>"
Add-Content $fileName "<td>$volName</td>"
Add-Content $fileName "<td>$totSpace</td>"
Add-Content $fileName "<td>$usedSpace</td>"
Add-Content $fileName "<td>$frSpace</td>"
Add-Content $fileName "<td bgcolor='#FBB917' align=center>$freePercent</td>"
# #FBB917
Add-Content $fileName "</tr>"
}
}






<#####
Main Loop
####>
writeHtmlHeader $freeSpaceFileName
foreach ($server in $serverlist)
{
Add-Content $freeSpaceFileName "<table width='100%'><tbody>"
Add-Content $freeSpaceFileName "<TD bgcolor='#CCCCCC' align='center' rowSpan='100%' width='150'><font face='tahoma' color='#003399' size='2'><strong> $server </strong></font>"
Add-Content $freeSpaceFileName "</TD>"

writeServiceTableHeader $freeSpaceFileName
writeServiceInfo -fileName $freeSpaceFileName -Computers $server -servicec "wuauserv"
writeServiceInfo -fileName $freeSpaceFileName -Computers $server -servicec "adtagent"
writeServiceInfo -fileName $freeSpaceFileName -Computers $server -servicec "healthservice"
writeServiceInfo -fileName $freeSpaceFileName -Computers $server -servicec "Symantec AntiVirus"
writeServiceInfo -fileName $freeSpaceFileName -Computers $server -servicec "dgagent-standard"
writeServiceInfo -fileName $freeSpaceFileName -Computers $server -servicec "W3SVC"
writeDiskTableHeader $freeSpaceFileName

$dp = Get-WmiObject win32_logicaldisk -ComputerName $server |  Where-Object {$_.drivetype -eq 3}
foreach ($item in $dp)
{
Write-Host  $item.DeviceID  $item.VolumeName $item.FreeSpace $item.Size
writeDiskInfo $freeSpaceFileName $item.DeviceID $item.VolumeName $item.FreeSpace $item.Size

}
Add-Content $freeSpaceFileName "</table>"
}

writeHtmlFooter $freeSpaceFileName

Function sendEmail
{ param($from,$to,$subject,$smtphost,$htmlFileName)
$body = Get-Content $htmlFileName
$smtp= New-Object System.Net.Mail.SmtpClient $smtphost
$msg = New-Object System.Net.Mail.MailMessage $from, $to, $subject, $body
$msg.isBodyhtml = $true
$smtp.send($msg)

}
#sendEmail cdarwin@evolve.com cdarwin@evolve.com "Disk Space Report - $Date" hub1 $freeSpaceFileName
start "c:\temp\FreeSpace.htm"
