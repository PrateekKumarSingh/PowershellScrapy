function Get-YouTubeVideo{
    [cmdletBinding()]
    param(
        [string]$Username
    )
    $URI = "https://www.youtube.com/user/$Username/videos?view=0&sort=dd&flow=grid"
    $HTML = Invoke-WebRequest -Uri $URI 
    $HTML.ParsedHtml.getElementsByTagName('a') |
             Where-Object{$_.nameProp -like '*watch*' -and ![string]::IsNullOrWhiteSpace($_.innertext)} |
             ForEach-Object {
                 [PSCustomObject] @{                     
                     title=$_.innertext
                     url= "https://youtube.com/{0}" -f $_.nameProp
                 }
             }
}
