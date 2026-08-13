$ErrorActionPreference = 'Stop'
$reportDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$wordPath = 'C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE'
if (-not (Test-Path -LiteralPath $wordPath)) { throw 'Microsoft Word is required for DOCX-to-PDF export.' }
$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0
try {
    $pairs = @(
        @('Vataleni_PMSG_SSO_Technical_Report.docx','Vataleni_PMSG_SSO_Technical_Report.pdf'),
        @('Vataleni_PMSG_SSO_Progress_Explainer.docx','Vataleni_PMSG_SSO_Progress_Explainer.pdf')
    )
    foreach ($pair in $pairs) {
        $docx = Join-Path $reportDir $pair[0]
        $pdf = Join-Path $reportDir $pair[1]
        $doc = $word.Documents.Open($docx, $false, $true)
        try { $doc.ExportAsFixedFormat($pdf, 17) } finally { $doc.Close($false) }
    }
} finally {
    $word.Quit()
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($word) | Out-Null
}
Write-Output 'PDF reports exported with Microsoft Word.'
