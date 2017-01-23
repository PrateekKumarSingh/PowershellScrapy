Function Get-TwitterProfile
{
$ie = New-Object -ComObject "internetexplorer.application" -Property `
@{
    Navigate = "https://twitter.com/followers"
    visible = $true
}

While($ie.busy)
{
    Sleep 5
}

$VerticalScroll = 0
While($true)
{
    $ie.Document.parentWindow.scrollTo(0,$VerticalScroll)
    $VerticalScroll = $VerticalScroll + 100
}

$target = $ie.Document.getElementsByTagName('div') | ?{$_.classname -eq "profilecard-content"}

$UserProfiles = Foreach($item in $target)
{

    $HTML = New-Object -Com "HTMLFile"
    $HTML.IHTMLDocument2_write($($item |% innerhtml))

    [pscustomobject][ordered]@{
    
    ImageURL = $HTML.all.tags('img')|%{$_.src -replace "bigger","400x400"} #Replacing 'Bigger' with '400x400' is a hack to make user thumbnails bigger
    DisplayName = $HTML.all.tags('a') | ?{$_.classname -eq "ProfileNameTruncated-link u-textInheritColor js-nav js-action-profile-name"} | % innertext 
    Twitterhandle = "@$($HTML.all.tags('span') | ?{$_.classname -eq 'u-linkComplex-target'} | % innertext)"
    UserBIO = $HTML.all.tags('p') | % outertext
    Followstatus = $HTML.all.tags('span') | ?{$_.classname -eq 'followStatus'} | % innertext
    
    }
}
# saving images from twitter to your local drive
#iwr $UserProfiles[0].ImageURL -OutFile ".\ProfilePictures\$($UserProfiles[0].DisplayName.trim()).png" -Verbose
}
