# Secrets
$creds = Get-StoredCredential -Target unsplash
$access_key = $creds.GetNetworkCredential().password

# Query parameters
$collections = "437035,3652377,8362253"

# Construct Unsplash API request parameters
$url = "https://api.unsplash.com/photos/random"
$headers = @{ "Accept-Version" = "v1"; Authorization = "Client-ID $access_key" }
$params = @{ collections = $collections; featured = "true"; orientation = "landscape" }

# Make API requests to get random photo
$response = Invoke-WebRequest $url -Method Get -Headers $headers -Body $params
$content = $response | ConvertFrom-Json
$imgUrl = $content.urls.full
$id = $content.id
Invoke-WebRequest $imgUrl -OutFile ".\$id.jpg"

# Write img metadata to file
$sel = $content | 
    Select-Object @{n = "link"; e = { $_.links.html } }, @{n = "name"; e = { $_.user.name } }, 
        description, @{n = "location"; e = { $_.location.title } }, @{n = "retrieval time"; e = { Get-Date } }
$sel | Format-List | Out-File -FilePath .\info.txt