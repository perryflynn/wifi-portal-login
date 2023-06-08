#Requires -Version 5.1
# hotel-rio-karlsruhe.ps1 Login script
# Save file, open powershell, launch:
# .\hotel-rio-karlsruhe.ps1

enum State {
    unknown
    alreadyloggedin = 1
    success = 2
    failure = 4
}

$global:cookies = $null

function Get-TimeStamp {
    return "{0:yyyy-MM-dd}T{0:HH:mm:ss}" -f (Get-Date)
}

function Invoke-Login {
    try {
        $r = Invoke-WebRequest "https://server.frederix-hotspot.de/" `
            -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36" `
            -Headers @{
                'Referer' = 'https://server.frederix-hotspot.de/?auth=free&pageID=page-0'
            } `
            -SessionVariable cookies `
            -MaximumRedirection 42 `
            -UseBasicParsing

        if (-not -not ($r.Content -like "*Login successful*")) {
            return [State]::alreadyloggedin
        }
    } catch { }

    try {
        $r = Invoke-WebRequest "https://server.frederix-hotspot.de/?auth=free&pageID=page-0" `
            -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36" `
            -Headers @{
                'Referer' = 'https://server.frederix-hotspot.de/'
            } `
            -Method "POST" `
            -Body @{
                'auth' = 'free';
                'lp-screen-size' = '1040%3A1920%3A2160%3A3840';
                'submit-login' = 'Anmeldung'
            } `
            -SessionVariable cookies `
            -MaximumRedirection 42 `
            -UseBasicParsing

        if ($r.Content -like "*Login successful*") {
            return [State]::success
        }
    } catch { }

    return [State]::failure
}

function Invoke-TestRequest {
    try {
        $r = Invoke-WebRequest "https://serverless.industries/robots.txt" `
            -UserAgent "Wifi Portal Login Powershell Script" `
            -MaximumRedirection 42 `
            -UseBasicParsing

        return -not -not ($r.Content -like "*User-Agent:*")
    } catch {
        return $false
    }
}

Write-Host "[$(Get-TimeStamp)] Starting"

while ($true) {
    if (-not (Invoke-TestRequest)) {
        Write-Host "[$(Get-TimeStamp)] Login"
        Invoke-Login
    }
    Start-Sleep -Seconds 5
}
