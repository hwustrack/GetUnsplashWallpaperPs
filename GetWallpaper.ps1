#Requires -Modules CredentialManager

# secrets
$creds = Get-StoredCredential -Target unsplash
$access_key = $creds.GetNetworkCredential().password

# query parameters
$collections = "437035,3652377,8362253"

# request parameters
$baseUrl = "https://api.unsplash.com"
$randomPhotoUrl = $baseUrl + "/photos/random"
$headers = @{ "Accept-Version" = "v1"; Authorization = "Client-ID $access_key" }
$params = @{ collections = $collections; orientation = "landscape" }

# make API requests to Unsplash for a random photo
$response = Invoke-WebRequest $randomPhotoUrl -Method Get -Headers $headers -Body $params
$content = $response | ConvertFrom-Json
$imgUrl = $content.urls.raw
$id = $content.id
Invoke-WebRequest $imgUrl -Headers $headers -Body @{ fm = "jpg"; w = "1920"; q = "80" } -OutFile ".\$id.jpg"
Invoke-WebRequest "$baseUrl/photos/$id/download" -Headers $headers

# write img metadata to file
$sel = $content | 
    Select-Object @{n = "link"; e = { $_.links.html } }, @{n = "name"; e = { $_.user.name } }, 
        description, @{n = "location"; e = { $_.location.title } }, @{n = "retrieval time"; e = { Get-Date } }
$sel | Format-List | Out-File -FilePath ".\$id.txt"

# remove old files
Get-ChildItem -Path .\* -Include ("*.jpg", "*.txt") | Where-Object {$_.CreationTime -lt (Get-Date).AddMinutes(-60)} | Remove-Item