<# 
 .Synopsis
  Send a remote keypress to a Freesat on the local network

 .Description
  Discovers a Freesat box on the local network that matches a serial number provided.
  Once discovered the remote keypress code is sent to the Freesat box

 .Parameter serialNumber
  Serial Number of the Freesat box

 .Parameter code
  Remote keypress code to send.

 .Example
   # Send Channel Up.
   example usage: SendRemoteCode -serialNumber "FS-HMX-01A-0000-0000" -code 427

   Freesat App key codes identified so far
      13 - OK
      19 - Pause
      27 - Exit
      37 - Left
      38 - Up
      39 - Right
      40 - Down
      48 - 0
      49 - 1
      50 - 2
      51 - 3
      52 - 4
      53 - 5
      54 - 6
      55 - 7
      56 - 8
      57 - 9
      403 - Red
      404 - Green
      405 - Yellow
      406 - Blue
      412 - Rewind
      415 - Play/Pause
      417 - Fast Forward
      424 - Previous
      425 - Next
      427 - Channel Up
      428 - Channel Down
      447 - Volume Up
      448 - Volume Down
      449 - Mute
      450 - Audio Description
      460 - Subtitles
      461 - Back
#>

# store this so we don't have to discover the box for each keypress
$Global:FreesatBoxURI = $null

Function DiscoverFreesatBox($SerialNumber){

	#Use unused port or it will fail
	$Port = 65437
    
    $LocalEndPoint = New-Object System.Net.IPEndPoint([ipaddress]::Any,$Port)
    $MulticastEndPoint = New-Object System.Net.IPEndPoint([ipaddress]::Parse("239.255.255.250"),1900)

    $UDPSocket = New-Object System.Net.Sockets.Socket([System.Net.Sockets.AddressFamily]::InterNetwork,[System.Net.Sockets.SocketType]::Dgram,[System.Net.Sockets.ProtocolType]::Udp)
    $UDPSocket.SetSocketOption([System.Net.Sockets.SocketOptionLevel]::Socket, [System.Net.Sockets.SocketOptionName]::ReuseAddress,$true)
    $UDPSocket.Bind($LocalEndPoint)
    $UDPSocket.SetSocketOption([System.Net.Sockets.SocketOptionLevel]::IP,[System.Net.Sockets.SocketOptionName]::AddMembership, (New-Object System.Net.Sockets.MulticastOption($MulticastEndPoint.Address, [ipaddress]::Any)))
    $UDPSocket.SetSocketOption([System.Net.Sockets.SocketOptionLevel]::IP, [System.Net.Sockets.SocketOptionName]::MulticastTimeToLive, 2)
    $UDPSocket.SetSocketOption([System.Net.Sockets.SocketOptionLevel]::IP, [System.Net.Sockets.SocketOptionName]::MulticastLoopback, $true)

    #Write-Host "UDP-Socket setup done...`r`n"
    #All SSDP Search
    $SearchString = @"
M-SEARCH * HTTP/1.1
HOST:239.255.255.250:1900
MAN:"ssdp:discover"
ST: urn:dial-multiscreen-org:service:dial:1
MX:3


"@

    $UDPSocket.SendTo([System.Text.Encoding]::UTF8.GetBytes($SearchString), [System.Net.Sockets.SocketFlags]::None, $MulticastEndPoint) #| Out-Null

    [byte[]]$RecieveBuffer = New-Object byte[] 64000
    [int]$RecieveBytes = 0

    $Response_RAW = ""
    $Timer = [System.Diagnostics.Stopwatch]::StartNew()
    $Delay = $True

    while($Delay){
        #2 Second delay so it does not run forever
        if($Timer.Elapsed.TotalSeconds -ge 2){Remove-Variable Timer; $Delay = $false}
        if($UDPSocket.Available -gt 0){
            $RecieveBytes = $UDPSocket.Receive($RecieveBuffer, [System.Net.Sockets.SocketFlags]::None)

            if($RecieveBytes -gt 0){
                $Text = "$([System.Text.Encoding]::UTF8.GetString($RecieveBuffer, 0, $RecieveBytes))"

                $deviceLocation = [regex]::Matches($Text, "LOCATION: (http://\d+\.\d+\.\d+\.\d+:\d+/device.xml)").captures.groups[1].value
				
				[xml]$doc = (New-Object System.Net.WebClient).DownloadString($deviceLocation)
				
				if($doc.root.device.serialNumber -eq $SerialNumber)
				{
					$UDPSocket.Close()
				
					$boxURI = [regex]::Matches($deviceLocation, "(http://\d+\.\d+\.\d+\.\d+:\d+)").captures.groups[1].value
					
					return $boxURI
				}
            }
        }
    }

	$UDPSocket.Close()
	
	return null
}

Function SendRemoteCode($serialNumber, $code)
{
	if($Global:FreesatBoxURI -eq $null)
	{
		$Global:FreesatBoxURI = DiscoverFreesatBox -SerialNumber $serialNumber
	}

	if($Global:FreesatBoxURI -ne $null)
	{
		$Global:FreesatBoxURI += "/rc/remote"
		
		$body = '<?xml version="1.0" ?><remote><key code="'+$code+'"/></remote>'
		
		Invoke-WebRequest $freesatBoxURI -body $body -Method POST -UserAgent "FreesatRemoteControlClient"
	}
	else
	{
		write-host "Unable to find Freesat box" -foregroundcolor "red"
	}
	
}

export-modulemember -function SendRemoteCode