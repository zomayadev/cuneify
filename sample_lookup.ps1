$resp = Invoke-WebRequest -Uri "https://unicode.org/Public/UCD/latest/ucd/UnicodeData.txt" -UseBasicParsing
$allLines = $resp.Content -split "`n"

$cunei = $allLines | Where-Object {
    if ($_ -match "^([0-9A-Fa-f]+);") {
        $cp = [Convert]::ToInt32($Matches[1], 16)
        ($cp -ge 0x12000 -and $cp -le 0x1247F)
    }
}

$lookup = @{}
foreach ($line in $cunei) {
    if ($line -match "^([0-9A-Fa-f]+);([^;]+);") {
        $cp    = $Matches[1].ToUpper()
        $uname = $Matches[2]
        if ($uname -match "^CUNEIFORM SIGN (.+)$") {
            $signName = $Matches[1]
            $lookup[$signName] = @{ cp = $cp; uname = $uname }
        }
    }
}

$samples = @(
    @{ syl="a";  sign="A"  },
    @{ syl="ba"; sign="BA" },
    @{ syl="ti"; sign="TI" },
    @{ syl="na"; sign="NA" },
    @{ syl="ma"; sign="MA" },
    @{ syl="li"; sign="LI" },
    @{ syl="tu"; sign="TU" },
    @{ syl="ri"; sign="RI" },
    @{ syl="sa"; sign="SA" },
    @{ syl="me"; sign="ME" }
)

"{0,-6} {1,-10} {2,-10} {3,-7} {4}" -f "SYL","OGSL","U+CODE","STATUS","UNICODE NAME"
"-" * 70
foreach ($s in $samples) {
    $sn = $s.sign
    if ($lookup.ContainsKey($sn)) {
        $r = $lookup[$sn]
        "{0,-6} {1,-10} U+{2,-8} EXACT   {3}" -f $s.syl, $sn, $r.cp, $r.uname
    } else {
        $multi = $lookup.Keys | Where-Object { $_ -match "^${sn}( |$)" } | Sort-Object
        if ($multi) {
            "{0,-6} {1,-10} (multi)    MULTI   candidates: {2}" -f $s.syl, $sn, ($multi -join "; ")
        } else {
            "{0,-6} {1,-10} ---        MISSING not in UCD cuneiform range" -f $s.syl, $sn
        }
    }
}
