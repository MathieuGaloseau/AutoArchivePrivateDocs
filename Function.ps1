##########################################################
#
#	Function.ps1
#	Date : 2018.08.03
#   Author : Galoseau Mathieu
#	V0.01 Add function WriteLog
#   V0.02 Add Archive
#   V0.03 Add Encrypt
#   V0.04 Add ArchiveAllSubFolders
#
##########################################################


#region WriteLog msg function app color
Function WriteLog(
    [Parameter(Mandatory = $true)] [string] $msg,
    [Parameter(Mandatory = $true)] [string] $function,
    [Parameter(Mandatory = $false)] [string] $app = "AutoArchivePrivateDocs",
    [Parameter(Mandatory = $false)] [string] $color = "white"
) {
    try {
        if ($color.Length -eq 0 ) {
            $color = "white"
        }

        $msg = "[{0}] [{1}] {2}" -f (Get-Date).ToString("yyyy/MM/dd HH:mm"), $function, $msg

        Write-Host $msg -foregroundcolor $color

        $logfolder =".\logs\"

        $path = $logfolder + (Get-Date).ToString("yyyyMMdd")+"_$($app).log"

        if ((Test-Path $logfolder) -eq $false)
        {
            New-Item -ItemType directory -Path $logfolder
        }

        $msg | Add-Content -Path $path
    }
    catch {
        Write-Host ("[Function] [WriteLog] ERROR : {0}; WriteLog message : {1}" -f $_.Exception.Message , $msg) -foregroundcolor $color
    }
}
#endregion

#region Archive folder fullpath output compressingLvl password app
Function Archive(
    [Parameter(Mandatory = $true)][string] $folder,
    [Parameter(Mandatory = $true)][string] $fullpath,
    [Parameter(Mandatory = $true)][string] $output,
    [Parameter(Mandatory = $false)][int] $compressingLvl = 9,
    [Parameter(Mandatory = $false)][string] $password,
    [Parameter(Mandatory = $false)][string] $app = "Archive"
) {
    try{
        if (test-path "$env:ProgramFiles\7-Zip\7z.exe")
        {
            #a (Add)
            #-m	Set Compression Method
            #-p	Set Password (-psecret using the password "secret")
            #-t	Type of archive (type of archive: 7z,   zip,   gzip,   bzip2,   tar)
            #-w	Set Working directory	 (w c:\temp)
            #a  -t7z 

            #x=[0 | 1 | 3 | 5 | 7 | 9 ]
            #Exemple -mx=9
            # Level	Method	Dictionary	FastBytes	MatchFinder	Filter	Description
            #0	Copy	
            #1	LZMA	64 KB	32	HC4	BCJ	Fastest compressing
            #3	LZMA	1 MB	32	HC4	BCJ	Fast compressing
            #5	LZMA	16 MB	32	BT4	BCJ	Normal compressing
            #7	LZMA	32 MB	64	BT4	BCJ	Maximum compressing
            #9	LZMA	64 MB	64	BT4	BCJ2	Ultra compressing

            WriteLog ("START Archive : {0} to {1} with compressing lvl : {2}" -f $folder, $output , $compressingLvl) "Archive"

            WriteLog ("'$env:ProgramFiles\7-Zip\7z.exe' '-mx=$($compressingLvl)' a '$($output)' -t7z '$($fullpath)\' '-p$($password)'") "Archive"

            if($password)
            {
                & "$env:ProgramFiles\7-Zip\7z.exe" "-mx=$($compressingLvl)" a "$($output)" -t7z "$($fullpath)\" "-p$($password)"
            }else {
                & "$env:ProgramFiles\7-Zip\7z.exe" "-mx=$($compressingLvl)" a "$($output)" -t7z "$($fullpath)\"
            }
           
            WriteLog ("END Archive : {0} to {1} with compressing lvl : {2}" -f $folder, $output , $compressingLvl) "Archive"
    }else
    {
        WriteLog ("7z not found") "Archive"
    }
    }catch
    {
        WriteLog $_.Exception.Message "Archive" $app "Red"
    }
}
#endregion

#region encrypt
Function Encrypt(
    [Parameter(Mandatory = $true)][string] $Path
) {
    try{
        gpg -se -r 'galoseau.mathieu@gmail.com' $Path
    }catch
    {
        WriteLog $_.Exception.Message "Archive" $app "Red"
    }
}
#endregion

#region ArchiveAllSubFolders inputfolder output compressingLvl password app
Function ArchiveAllSubFolders(
    [Parameter(Mandatory = $true)][string] $inputfolder,
    [Parameter(Mandatory = $true)][string] $output,
    [Parameter(Mandatory = $false)][int] $compressingLvl = 9,
    [Parameter(Mandatory = $false)][string] $password = $null,
    [Parameter(Mandatory = $false)][string] $app = "Archive"
)
{
    WriteLog ("password {0}" -f $password) "ArchiveAllSubFolders"
    try{
        WriteLog ("START Archive All Sub Folders : {0} to {1} with compressing lvl : {2}" -f $inputfolder, $output , $compressingLvl) "ArchiveAllSubFolders"
        
        Get-ChildItem $inputfolder -Directory | Select-Object Name, FullName `
        | ForEach-Object -Process {
                WriteLog ("Folders Name : {0}; FullName : {1}" -f $_.Name, $_.FullName) "ArchiveAllSubFolders"
                $outputtemps = ("{0}\{1}.7z" -f $output, $_.Name)
                Archive $_.Name $_.FullName $outputtemps $compressingLvl $password $app

                WriteLog ("Encrypt File : {0}" -f $outputtemps) "ArchiveAllSubFolders"
                Encrypt $outputtemps

                WriteLog ("Remove-Item : {0}" -f $outputtemps) "ArchiveAllSubFolders"
                Remove-Item $outputtemps
            }

        WriteLog ("END Archive All Sub Folders : {0} to {1} with compressing lvl : {2}" -f $inputfolder, $output , $compressingLvl) "ArchiveAllSubFolders"
    }catch
    {
        WriteLog $_.Exception.Message "Archive" $app "Red"
    }
}
#endregion