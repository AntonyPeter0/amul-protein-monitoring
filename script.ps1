
$webSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession

# Define the URLs
$putUrl = "https://shop.amul.com/entity/ms.settings/_/setPreferences"
$getUrl = "https://shop.amul.com/api/1/entity/ms.products?fields[name]=1&fields[brand]=1&fields[categories]=1&fields[collections]=1&fields[alias]=1&fields[sku]=1&fields[price]=1&fields[compare_price]=1&fields[original_price]=1&fields[images]=1&fields[metafields]=1&fields[discounts]=1&fields[catalog_only]=1&fields[is_catalog]=1&fields[seller]=1&fields[available]=1&fields[inventory_quantity]=1&fields[net_quantity]=1&fields[num_reviews]=1&fields[avg_rating]=1&fields[inventory_low_stock_quantity]=1&fields[inventory_allow_out_of_stock]=1&filters[0][field]=categories&filters[0][value][0]=protein&filters[0][operator]=in&facets=true&facetgroup=default_category_facet&limit=24&total=1&start=0"


$From = $env:MAIL_USERNAME
$To = $env:TO_USERNAME
$Subject = 'Amul Items back in stock'
$SmtpServer = 'smtp.gmail.com'
$Port = 587
$Credential = New-Object pscredential $env:MAIL_USERNAME, $($env:MAIL_PASSWORD | ConvertTo-SecureString -AsPlainText -Force)

# Define the payload for the PUT request
$putPayload = @{
    data = @{
        store = "kerala"
    }
} | ConvertTo-Json -Depth 10


$responsePut = Invoke-RestMethod -Uri $putUrl -Method Put -Body $putPayload -ContentType "application/json" -WebSession $webSession


if ($responsePut) {
    Write-Output "PUT request successful. Preferences set:"
    Write-Output $responsePut
}
else {
    Write-Output "PUT request failed."
    exit
}


$responseGet = Invoke-RestMethod -Uri $getUrl -Method Get -WebSession $webSession


if ($responseGet) {
    Write-Output "GET request successful. Product data retrieved:"
    Write-Output $responseGet
}
else {
    Write-Output "GET request failed."
}

foreach ( $item in $responseGet.data) {
    if (($item.name -match 'Blueberry' -or $item.name -match 'Rose') -and $item.available -eq '0') {  
        $Body += $item.name
        $Body += ' is in stock'
        Send-MailMessage -To $To -From $From -Subject $Subject -Body $Body -Credential $Credential -SmtpServer $SmtpServer -UseSsl -Port $Port
    }
}