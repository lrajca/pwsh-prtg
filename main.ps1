#prtgServer URL
$prtgServer = ''

#Credentials (Stored as a CLIXML file)
$CredentialPath = ''


Function Get-FileName($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "CSV (*.csv)| *.csv"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

$importPath = Get-FileName "C:\"


$Count = 0
$Succeeded = 0
$Failed = @('')

if (Get-Module -ListAvailable -Name PrtgAPI){
    Write-Host "Module Installed, continuing."
    }

else {
    Write-Host "Module does not exist, Installing"
    Install-Package PrtgAPI -Confirm:$false -Force
    }
    
$csv = Import-CSV $importPath


try{

    if (Get-PrtgClient){

        Disconnect-PrtgServer

        }

    Connect-PrtgServer -Server $prtgServer -Credential $Credentials

   }


catch{

    Write-Host "Couldn't connect to PRTG. Exiting..."
        
    Start-Sleep 3
    Exit
    }

    
Foreach ($char in $csv){
$Group = 0
$Group = Get-Group -Name $char.Group

    if ($Group){
        
       $Group | Add-Device -Name $char.Device -Host $char.IP -AutoDiscover
       $Succeeded += 1
            
    }
     

     else { 

     $failedGroup = $char.Group
     Write-Host "`nGroup not found: $failedGroup`n"
     $Count +=1 
     $Failed += $char.Device
            }

                }
                

Write-Host "Script Complete"
Write-Host "$Succeeded / $Count Successfully Added`n"

if ($Failed.Count -ge 1){
    Write-Host "`nFailed to add: $Failed"
    }


            

