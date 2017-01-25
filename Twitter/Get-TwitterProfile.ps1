Function Get-TwitterProfile
{
    [cmdletbinding()]
    Param(
            $URL = "https://twitter.com/followers"
    )

    Begin
    {}
    Process
    {
        Write-Verbose "Instantiating InternetExplorer.Application COM Object"
        $ie = New-Object -ComObject "internetexplorer.application" -Property `
        @{
            Navigate = $URL
            visible = $true
        }
        # Wait unitl IE is busy
        While($ie.busy){ Write-Verbose "Internet Explorer is Busy, waiting for few seconds";Start-Sleep -Seconds 5 }
        $start = Get-Date
        $VerticalScroll = 0

        Write-Verbose "Scrolling the WebPage : $URL , to auto-populate all profiles for next 30 Secs" 

        # 30 Secs to Infinitely scroll webpage, So that all items are populated that only come when you scroll down
        While((Get-Date) -lt $($start + [timespan]::new(0,0,30)))
        {
            $ie.Document.parentWindow.scrollTo(0,$VerticalScroll)
            $VerticalScroll = $VerticalScroll + 100
        }

        Write-Verbose "Data Scraping user profile info from WebPage and Converting them to [PSObjects]"
        # Grab the target HTML tags in which User Profile info is sitting, Convert them to [PSObjects]
        
        $SavePreference  = $VerbosePreference
        $VerbosePreference = "SilentlyContinue"

        $ie.Document.getElementsByTagName('div') |`
        ?{$_.classname -eq "profilecard-content"}|` 
        ForEach-Object {
            $item = $_
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

        $VerbosePreference = $SavePreference
    }
    End
    {
        $IE.Quit()
        Remove-variable IE
        [GC]::collect()
    }

    #iwr $UserProfiles[0].ImageURL -OutFile ".\ProfilePictures\$($UserProfiles[0].DisplayName.trim()).png" -Verbose

}

Get-TwitterProfile -URL "https://twitter.com/followers" -Verbose -OutVariable Resultsaving images from twitter to your local drive
#iwr $UserProfiles[0].ImageURL -OutFile ".\ProfilePictures\$($UserProfiles[0].DisplayName.trim()).png" -Verbose
