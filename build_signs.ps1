# Downloads UnicodeData.txt, builds sign lookup, writes signs.json with provenance.

$resp = Invoke-WebRequest -Uri "https://unicode.org/Public/UCD/latest/ucd/UnicodeData.txt" -UseBasicParsing
$ucdVersion = "unicode.org/Public/UCD/latest/ucd/UnicodeData.txt (fetched $(Get-Date -Format 'yyyy-MM-dd'))"

$allLines = $resp.Content -split "`n"
$lookup = @{}
foreach ($line in $allLines) {
    if ($line -match "^([0-9A-Fa-f]+);CUNEIFORM SIGN ([^;]+);") {
        $lookup[$Matches[2]] = $Matches[1].ToUpper()
    }
}

# Syllable table: syl, sign (OGSL name as spelled in UCD), note
# note="" means straightforward attested; note starts with FLAG: means uncertain
$table = @(
    # --- Pure vowels ---
    [pscustomobject]@{syl="a";  sign="A";    note=""},
    [pscustomobject]@{syl="e";  sign="E";    note=""},
    [pscustomobject]@{syl="i";  sign="I";    note=""},
    [pscustomobject]@{syl="u";  sign="U";    note=""},

    # --- B-group ---
    [pscustomobject]@{syl="ba"; sign="BA";   note=""},
    [pscustomobject]@{syl="bi"; sign="BI";   note=""},
    [pscustomobject]@{syl="bu"; sign="BU";   note=""},
    [pscustomobject]@{syl="be"; sign="BE";   note="FLAG:no standard BE sign in UCD; needs OGSL verification"},

    # --- D-group ---
    [pscustomobject]@{syl="da"; sign="DA";   note=""},
    [pscustomobject]@{syl="di"; sign="DI";   note=""},
    [pscustomobject]@{syl="du"; sign="DU";   note=""},
    [pscustomobject]@{syl="de"; sign="DE";   note="FLAG:no standard DE sign; NE carries de2 reading per OGSL"},

    # --- G-group ---
    [pscustomobject]@{syl="ga"; sign="GA";   note=""},
    [pscustomobject]@{syl="gi"; sign="GI";   note=""},
    [pscustomobject]@{syl="gu"; sign="GU";   note=""},
    [pscustomobject]@{syl="ge"; sign="GE22"; note="FLAG:verify GE22 carries ge reading in OGSL"},

    # --- H-group (Akkadian ḫ, encoded H in UCD) ---
    [pscustomobject]@{syl="ha"; sign="HA";   note="Akkadian ḫa"},
    [pscustomobject]@{syl="hi"; sign="HI";   note="Akkadian ḫi"},
    [pscustomobject]@{syl="hu"; sign="HU";   note="Akkadian ḫu"},

    # --- K-group ---
    [pscustomobject]@{syl="ka"; sign="KA";   note=""},
    [pscustomobject]@{syl="ki"; sign="KI";   note=""},
    [pscustomobject]@{syl="ku"; sign="KU";   note=""},
    [pscustomobject]@{syl="ke"; sign="KE";   note="FLAG:no standard KE sign in UCD"},

    # --- L-group ---
    [pscustomobject]@{syl="la"; sign="LA";   note=""},
    [pscustomobject]@{syl="li"; sign="LI";   note=""},
    [pscustomobject]@{syl="lu"; sign="LU";   note=""},
    [pscustomobject]@{syl="le"; sign="LE";   note="FLAG:no standard LE sign in UCD"},

    # --- M-group ---
    [pscustomobject]@{syl="ma"; sign="MA";   note=""},
    [pscustomobject]@{syl="me"; sign="ME";   note=""},
    [pscustomobject]@{syl="mi"; sign="MI";   note=""},
    [pscustomobject]@{syl="mu"; sign="MU";   note=""},

    # --- N-group ---
    [pscustomobject]@{syl="na"; sign="NA";   note=""},
    [pscustomobject]@{syl="ne"; sign="NE";   note=""},
    [pscustomobject]@{syl="ni"; sign="NI";   note=""},
    [pscustomobject]@{syl="nu"; sign="NU";   note=""},

    # --- P-group ---
    [pscustomobject]@{syl="pa"; sign="PA";   note=""},
    [pscustomobject]@{syl="pi"; sign="PI";   note=""},
    [pscustomobject]@{syl="pu"; sign="PU";   note="FLAG:no PU sign; BU carries pu2 reading per OGSL"},
    [pscustomobject]@{syl="pe"; sign="PE";   note="FLAG:no standard PE sign in UCD"},

    # --- R-group ---
    [pscustomobject]@{syl="ra"; sign="RA";   note=""},
    [pscustomobject]@{syl="ri"; sign="RI";   note=""},
    [pscustomobject]@{syl="ru"; sign="RU";   note=""},

    # --- S-group ---
    [pscustomobject]@{syl="sa"; sign="SA";   note=""},
    [pscustomobject]@{syl="si"; sign="SI";   note=""},
    [pscustomobject]@{syl="su"; sign="SU";   note=""},
    [pscustomobject]@{syl="se"; sign="SE";   note="FLAG:no standard SE sign in UCD"},

    # --- SH-group (Akkadian š) ---
    [pscustomobject]@{syl="sha"; sign="SHA"; note="Akkadian ša"},
    [pscustomobject]@{syl="she"; sign="SHE"; note="Akkadian še"},
    [pscustomobject]@{syl="shi"; sign="SHI"; note="FLAG:no SHI sign in UCD; ši has no single canonical sign"},
    [pscustomobject]@{syl="shu"; sign="SHU"; note="Akkadian šu"},

    # --- T-group ---
    [pscustomobject]@{syl="ta"; sign="TA";   note=""},
    [pscustomobject]@{syl="te"; sign="TE";   note=""},
    [pscustomobject]@{syl="ti"; sign="TI";   note=""},
    [pscustomobject]@{syl="tu"; sign="TU";   note=""},

    # --- Z-group ---
    [pscustomobject]@{syl="za"; sign="ZA";   note=""},
    [pscustomobject]@{syl="ze"; sign="ZE2";  note="FLAG:verify ZE2 carries ze reading in OGSL"},
    [pscustomobject]@{syl="zi"; sign="ZI";   note=""},
    [pscustomobject]@{syl="zu"; sign="ZU";   note=""},

    # --- VC endings ---
    [pscustomobject]@{syl="ab"; sign="AB";   note=""},
    [pscustomobject]@{syl="ad"; sign="AD";   note=""},
    [pscustomobject]@{syl="ak"; sign="AK";   note=""},
    [pscustomobject]@{syl="al"; sign="AL";   note=""},
    [pscustomobject]@{syl="am"; sign="AM";   note="FLAG:no AM sign; check IM for am reading"},
    [pscustomobject]@{syl="an"; sign="AN";   note=""},
    [pscustomobject]@{syl="ar"; sign="AR";   note="FLAG:no standalone AR sign in UCD"},
    [pscustomobject]@{syl="as"; sign="AS";   note="FLAG:no AS sign; ASH exists but is different"},
    [pscustomobject]@{syl="at"; sign="AT";   note="FLAG:no AT sign in UCD"},
    [pscustomobject]@{syl="el"; sign="EL";   note=""},
    [pscustomobject]@{syl="em"; sign="EM";   note="FLAG:no EM sign in UCD"},
    [pscustomobject]@{syl="en"; sign="EN";   note=""},
    [pscustomobject]@{syl="er"; sign="ER";   note="FLAG:no ER sign in UCD"},
    [pscustomobject]@{syl="ib"; sign="IB";   note=""},
    [pscustomobject]@{syl="ig"; sign="IG";   note=""},
    [pscustomobject]@{syl="il"; sign="IL";   note=""},
    [pscustomobject]@{syl="im"; sign="IM";   note=""},
    [pscustomobject]@{syl="in"; sign="IN";   note=""},
    [pscustomobject]@{syl="ir"; sign="IR";   note=""},
    [pscustomobject]@{syl="ub"; sign="UB";   note=""},
    [pscustomobject]@{syl="ud"; sign="UD";   note=""},
    [pscustomobject]@{syl="ul"; sign="UL";   note="FLAG:no UL sign in UCD"},
    [pscustomobject]@{syl="um"; sign="UM";   note=""},
    [pscustomobject]@{syl="un"; sign="UN";   note=""},
    [pscustomobject]@{syl="ur"; sign="UR";   note=""},
    [pscustomobject]@{syl="us"; sign="US";   note="FLAG:no US sign; USH exists but is different"}
)

# --- Run lookup ---
$results = @()
foreach ($row in $table) {
    $sn = $row.sign
    if ($lookup.ContainsKey($sn)) {
        $status = "EXACT"
        $cp = "U+" + $lookup[$sn]
    } else {
        $status = "MISSING"
        $cp = "---"
    }
    $results += [pscustomobject]@{
        syl    = $row.syl
        sign   = $sn
        cp     = $cp
        status = $status
        note   = $row.note
        source = $ucdVersion
    }
}

# --- Print table ---
"{0,-6} {1,-8} {2,-10} {3,-8} {4}" -f "SYL","SIGN","CODE PT","STATUS","NOTE"
"-" * 80
foreach ($r in $results) {
    "{0,-6} {1,-8} {2,-10} {3,-8} {4}" -f $r.syl, $r.sign, $r.cp, $r.status, $r.note
}

# --- Summary ---
$exact   = ($results | Where-Object { $_.status -eq "EXACT" }).Count
$missing = ($results | Where-Object { $_.status -eq "MISSING" }).Count
""
"EXACT: $exact   MISSING: $missing   TOTAL: $($results.Count)"

# --- Save JSON ---
$results | ConvertTo-Json -Depth 4 | Out-File -FilePath "signs.json" -Encoding utf8
"signs.json written."
