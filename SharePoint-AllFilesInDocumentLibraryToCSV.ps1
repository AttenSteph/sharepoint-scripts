<#
.SYNOPSIS
    Creates a .csv file from all documents in a SharePoint Online library.
.DESCRIPTION
    Creates a .csv file from all documents in a SharePoint Online library.
.PARAMETER SiteURL
    e.g. "https://contoso.sharepoint.com/sites/Marketing"
.PARAMETER ListName
    Document library - Defaults to "Documents"
.PARAMETER OutFile
    Output file - Defaults to document_library_list.csv
.EXAMPLE
    C:\PS> SharePoint-ListAllFilesInDocumentLibrary.ps1 -SiteURL "https://contoso.sharepoint.com/sites/Marketing"
    C:\PS> SharePoint-ListAllFilesInDocumentLibrary.ps1 -SiteURL "https://contoso.sharepoint.com/sites/Marketing" -ListName CustomLibraryName -OutFile custom_file_name.csv
.NOTES
    From Powershell 7.2+ install the latest pnp modules. You may need to uninstall old ones. See the following article:
    https://www.sharepointdiary.com/2021/02/how-to-install-pnp-powershell-module-for-sharepoint-online.html#h-step-1-uninstall-the-legacy-sharepointpnppowershellonline-module
    Adapted from https://www.sharepointdiary.com/2018/08/sharepoint-online-powershell-to-get-all-files-in-document-library.html#ixzz8kDuoZoLI
#>
param(
    [Parameter(Mandatory=$true)]
    [String]$SiteURL,
    [String]$ListName = "Documents",
    [String]$OutFile = "document_library_list.csv"
)
  
#Connect to PnP Online
Connect-PnPOnline -Url $SiteURL -Interactive
 
#Get All Files from the document library - In batches of 500
$ListItems = Get-PnPListItem -List $ListName -PageSize 500 | Where {$_.FileSystemObjectType -eq "File"}
  
#Loop through all documents
# $DocumentsData=@()
$FileData = @()
ForEach($Item in $ListItems)
{
    $FileData += [PSCustomObject][ordered]@{
        FileName  = $Item.FieldValues.FileLeafRef
        URL            = $Item.FieldValues.FileRef
        LastModified    = $Item.FieldValues.SMLastModifiedDate
        SizeInMB            = [math]::Round(($Item.FieldValues.SMTotalFileStreamSize/1MB),2)
    }
}

# Export CSV
$FileData | Sort-object URL -Descending | out-null
$FileData | Export-Csv -Path $OutFile -NoTypeInformation
