##########################################################
#
#	Function.ps1
#	Date : 2018.08.03
#	V0.01 Add function WriteLog
#
##########################################################


Function WriteLog(
    [Parameter(Mandatory = $true)] $msg,
    [Parameter(Mandatory = $true)] $function,
    [Parameter(Mandatory = $true)] $app,
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