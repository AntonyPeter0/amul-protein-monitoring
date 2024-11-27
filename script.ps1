# Create a web session to persist cookies
$webSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession

# Define the URLs
$putUrl = "https://shop.amul.com/entity/ms.settings/_/setPreferences"
$getUrl = "https://shop.amul.com/api/1/entity/ms.products?fields[name]=1&fields[brand]=1&fields[categories]=1&fields[collections]=1&fields[alias]=1&fields[sku]=1&fields[price]=1&fields[compare_price]=1&fields[original_price]=1&fields[images]=1&fields[metafields]=1&fields[discounts]=1&fields[catalog_only]=1&fields[is_catalog]=1&fields[seller]=1&fields[available]=1&fields[inventory_quantity]=1&fields[net_quantity]=1&fields[num_reviews]=1&fields[avg_rating]=1&fields[inventory_low_stock_quantity]=1&fields[inventory_allow_out_of_stock]=1&filters[0][field]=categories&filters[0][value][0]=protein&filters[0][operator]=in&facets=true&facetgroup=default_category_facet&limit=24&total=1&start=0"

# Define the payload for the PUT request
$putPayload = @{
    data = @{
        store = "kerala"
    }
} | ConvertTo-Json -Depth 10

# Send the PUT request to set preferences
$responsePut = Invoke-RestMethod -Uri $putUrl -Method Put -Body $putPayload -ContentType "application/json" -WebSession $webSession

# Check the response of the PUT request
if ($responsePut) {
    Write-Output "PUT request successful. Preferences set:"
    Write-Output $responsePut
} else {
    Write-Output "PUT request failed."
    exit
}

# Send the GET request to retrieve products
$responseGet = Invoke-RestMethod -Uri $getUrl -Method Get -WebSession $webSession

# Display the GET response
if ($responseGet) {
    Write-Output "GET request successful. Product data retrieved:"
    Write-Output $responseGet
} else {
    Write-Output "GET request failed."
}

$MailArgs = @{
    From       = 'Antony'
    To         = '$env:TO_USERNAME'
    Subject    = 'Amul Product is Back in Stock'
    Body       = 'Urgent Please Buy'
    SmtpServer = 'smtp.gmail.com'
    Port       = 587
    UseSsl     = $true
    Credential = New-Object pscredential '$env:MAIL_USERNAME',$('$env:MAIL_PASSWORD' |ConvertTo-SecureString -AsPlainText -Force)
}
Send-MailMessage @MailArgs
