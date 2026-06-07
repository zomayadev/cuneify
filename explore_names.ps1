$resp = Invoke-WebRequest -Uri "https://unicode.org/Public/UCD/latest/ucd/UnicodeData.txt" -UseBasicParsing
$allLines = $resp.Content -split "`n"

# Filter to cuneiform block
$cunei = $allLines | Where-Object {
    if ($_ -match "^([0-9A-Fa-f]+);") {
        $cp = [Convert]::ToInt32($Matches[1], 16)
        ($cp -ge 0x12000 -and $cp -le 0x1247F)
    }
}

# Collect simple sign names (no TIMES/PLUS/CONTAINING etc.)
$simple = @()
foreach ($line in $cunei) {
    if ($line -match "^([0-9A-Fa-f]+);CUNEIFORM SIGN ([^;]+);") {
        $sn = $Matches[2]
        if ($sn -notmatch "TIMES|PLUS|CONTAINING|TENU|GUNU|NUTUKU|CROSSING|OPPOSING|SQUARED|INVERTED|OVER|BELOW|FACING|REVERSED|VARIANT") {
            $simple += [PSCustomObject]@{ cp = $Matches[1].ToUpper(); name = $sn }
        }
    }
}
Write-Host "Simple sign names: $($simple.Count)"
Write-Host ""

# Show names containing H, SH, GH, KH to understand sibilant/fricative encoding
Write-Host "=== Names containing SH ==="
$simple | Where-Object { $_.name -match "SH" } | ForEach-Object { "U+$($_.cp)  $($_.name)" }
Write-Host ""
Write-Host "=== Names ending in H (possible heth/khet) ==="
$simple | Where-Object { $_.name -match "H$" -or $_.name -match " H " -or $_.name -match "^H[AEIOU]" } |
    ForEach-Object { "U+$($_.cp)  $($_.name)" }
Write-Host ""
Write-Host "=== Full simple sign list (sorted) ==="
$simple | Sort-Object name | ForEach-Object { "U+$($_.cp)  $($_.name)" }
