<#
.Synopsis
   Get a Quote for any topc
.DESCRIPTION
   Get-Quote cmdlet data harvests a/multiple quote(s) from  Web outputs into your powershell console
.EXAMPLE
   PS > Quote -Topic "success"

   For me success was always going to be a Lamborghini. But now I've got it, it just sits on my drive. 
   Curtis Jackson [50 Cent], American Rapper. From his interview with Louis Gannon for Live magazine, The Mail on Sunday (UK) newspaper, (25 October 2009). 
.EXAMPLE
   PS > "love", "genius"| Quote

   To be able to say how much you love is to love but little. 
   Petrarch, To Laura in Life (c. 1327-1350), Canzone 37 

   Doing easily what others find it difficult is talent; doing what is impossible for talent is genius. 
   Henri-Frédéric Amiel, Journal 

.EXAMPLE
   PS > Get-Quote -Topic "Genius" -Count 2

   No age is shut against great genius. 
   Seneca the Younger, Epistolæ Ad Lucilium, CII 
   
   Genius is a capacity for taking trouble. 
   Leslie Stephen, reported in Bartlett's Familiar Quotations, 10th ed. (1919) 
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   This cmdlet uses "https://en.wikiquote.org" to pull the information
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
function Get-Quote
{
    [CmdletBinding()]
    [Alias("Quote")]
    [OutputType([String])]
    Param
    (
        # Topic of the Quote
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   Position=0)]
        [ValidateNotNullOrEmpty()][String[]]$Topic,
        [Parameter(Position=1)][Int]$Count = 1 ,
        [Parameter(Position=2)][Int]$Length = 150


    )

    Begin
    {

    }
    Process
    {
        Foreach($Item in $Topic)
        {
            $URL = "https://en.wikiquote.org/wiki/$Item"
            Try
            {
                $WebRequest = Invoke-WebRequest $URL
                $WebRequest.ParsedHtml.getElementsByTagName('ul')  |`
                Where{$_.parentElement.id -eq "mw-content-text" -and $_.innertext.length -lt $Length} |`
                Get-Random -Count $Count |` 
                ForEach-Object{ 
                                [Environment]::NewLine            
                                $_.innertext
                }
            }
            catch
            {
                $_.exception
            }
        }
    }
    End
    {
    }
}
