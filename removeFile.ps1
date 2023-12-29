# Define the path to the Plink executable
$plinkPath = "C:\removeplugin\plink.exe"

# Define the SSH credentials
$sshUsername = "Example"
$sshPassword = "xxxxxxxx"

# Define the path to the text file containing IP addresses
$ipAddressesFilePath = "C:\removeplugin\ip_addresses.txt"

# Read IP addresses from the text file
$ipAddresses = Get-Content -Path $ipAddressesFilePath

# Define the commands to run on the Linux server
$commands = @(
    "rm -f /home/Example.exe"
)

# Initialize an array to store the results
$results = @()

# Loop through the IP addresses
foreach ($ipAddress in $ipAddresses)
{
    $pingResult = Test-Connection -ComputerName $ipAddress -Count 1 -ErrorAction SilentlyContinue

    if ($pingResult -eq $null)
    {
        $result = [PSCustomObject]@{
            IPAddress = $ipAddress
            Command = "IP is offline"
            Output = "IP is offline"
        }
        $results += $result
    }
    else
    {
        $result = [PSCustomObject]@{
            IPAddress = $ipAddress
        }

        try
        {

            echo "Y" | & $plinkPath -ssh -l $sshUsername -pw $sshPassword -noagent $ipAddress exit
            Write-Host "Linux OS connected: $ipAddress"
            
                foreach ($command in $commands)
                {

                    Write-Host "$command removed file."
                    $sshOutput = & $plinkPath -ssh -l $sshUsername -pw $sshPassword -batch -noagent $ipAddress $command

                }          
        }
        catch
        {
            Write-Host "Warning: $_"
        }
        finally
        {
            $results += $result
        }
    }
}

