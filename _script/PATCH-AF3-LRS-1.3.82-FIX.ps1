# AF3 + LRS 1.3.82 patcher - PowerShell only, no external Python needed
$ErrorActionPreference = 'Stop'
$Version = '1.3.82'
$DefaultSkin1080i = 'E:\Kodi\portable_data\addons\skin.arctic.fuse.3\1080i'
$script:Skin1080i = $DefaultSkin1080i

function Read-Text($Path) { return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8) }
function Write-Text($Path, $Text) { [System.IO.File]::WriteAllText($Path, $Text, (New-Object System.Text.UTF8Encoding($false))) }
function Backup-File($Path) { $bak = "$Path.lrs-$Version-psbackup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"; Copy-Item -LiteralPath $Path -Destination $bak -Force; return $bak }
function Sha8($Text) { $sha=[System.Security.Cryptography.SHA1]::Create(); $b=[System.Text.Encoding]::UTF8.GetBytes($Text); return ([BitConverter]::ToString($sha.ComputeHash($b)).Replace('-','').ToLower()).Substring(0,8) }
function FTime($Path) { if(Test-Path -LiteralPath $Path){ return (Get-Item -LiteralPath $Path).LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss') } return '-' }
function File-In-Skin($Name) { $p = Join-Path $script:Skin1080i $Name; if(!(Test-Path -LiteralPath $p)){ throw "File tidak ditemukan: $p" }; return $p }
function Remove-Between($Text,$Start,$End) { $pat='(?s)\s*'+[regex]::Escape($Start)+'.*?'+[regex]::Escape($End); return [regex]::Replace($Text,$pat,'') }
function Replace-Between([string]$Text,[string]$Start,[string]$End,[string]$Repl,[ref]$Count) { $pat='(?s)\s*'+[regex]::Escape($Start)+'.*?'+[regex]::Escape($End); $m=[regex]::Matches($Text,$pat).Count; $Count.Value=$m; return [regex]::Replace($Text,$pat,"`n$Repl") }

$NativeRe = '(?s)\n?[ \t]*<include\s+content=["'']Info_Meta_Ratings["''][^>]*>.*?</include>'
$NativeMarkerRe = '(?s)\s*<!-- LRS-AF3-NATIVE-RATINGS-DISABLED-START -->.*?<!-- LRS-AF3-NATIVE-RATINGS-DISABLED-END -->'

function Slot-Obj($Idx, [bool]$ImdbWidth=$false) {
    $extra = if($Idx -ge 3){ ' + !String.IsEqual(Window(Home).Property(LibraryRatings.ListItem.DBType),episode)' } else { '' }
    $width = if($ImdbWidth){ "`n                <param name=`"icon_w`">52</param>" } else { '' }
@"
            <include content="Info_Meta_Object">
                <param name="icon">flags/`$VAR[Color_Directory]/ratings/`$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot$($Idx)_IconFile)]</param>
                <param name="label">`$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot$($Idx)_Label)]</param>
                <param name="visible">[`$PARAM[visible]]$extra + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot$($Idx)_IconFile)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot$($Idx)_Label))</param>
                <param name="colordiffuse">`$PARAM[colordiffuse]</param>$width
            </include>
"@
}

$Slots = (1..6 | ForEach-Object { Slot-Obj $_ ($_ -eq 1) }) -join "`n"
$LrsIncludeDef = @"
<!-- LRS-AF3-INCLUDE-DEF-START -->
    <!-- LRS-AF3-1.3.82: clean slots 1-6, icon filename fix, display extras toggles -->
    <include name="LRS_Info_Meta_Ratings">
        <param name="visible">true</param>
        <param name="colordiffuse">main_fg</param>
        <definition>
$Slots
            <include content="Info_Meta_Object">
                <param name="icon">flags/`$VAR[Color_Directory]/ratings/oscar.png</param>
                <param name="label">`$INFO[Window(Home).Property(LibraryRatings.ListItem.Oscar_Wins),x,]</param>
                <param name="visible">[`$PARAM[visible]] + String.IsEqual(Window(Home).Property(LibraryRatings.ListItem.Display_Awards),true) + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.Oscar_Wins))</param>
                <param name="colordiffuse">`$PARAM[colordiffuse]</param>
            </include>
            <include content="Info_Meta_Object">
                <param name="icon">flags/`$VAR[Color_Directory]/ratings/emmy.png</param>
                <param name="label">`$INFO[Window(Home).Property(LibraryRatings.ListItem.Emmy_Wins),x,]</param>
                <param name="visible">[`$PARAM[visible]] + String.IsEqual(Window(Home).Property(LibraryRatings.ListItem.Display_Awards),true) + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.Emmy_Wins))</param>
                <param name="colordiffuse">`$PARAM[colordiffuse]</param>
            </include>
            <include content="Info_Meta_Object">
                <param name="icon">flags/`$VAR[Color_Directory]/ratings/ends.png</param>
                <param name="label">`$INFO[Window(Home).Property(LibraryRatings.ListItem.Series_StatusLabel)]</param>
                <param name="visible">[`$PARAM[visible]] + String.IsEqual(Window(Home).Property(LibraryRatings.ListItem.Display_TVStatus),true) + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.Series_StatusLabel))</param>
                <param name="colordiffuse">`$PARAM[colordiffuse]</param>
            </include>
        </definition>
    </include>
    <!-- LRS-AF3-INCLUDE-DEF-END -->
"@

$LrsMetaCall = @"
<!-- LRS-AF3-META-CALL-START -->
                    <include content="LRS_Info_Meta_Ratings">
                        <param name="visible">String.IsEqual(`$PARAM[container]`$PARAM[listitem].DBType,movie) | String.IsEqual(`$PARAM[container]`$PARAM[listitem].DBType,tvshow) | String.IsEqual(`$PARAM[container]`$PARAM[listitem].DBType,season) | String.IsEqual(`$PARAM[container]`$PARAM[listitem].DBType,episode) | `$PARAM[override_movie] | `$PARAM[override_tvshow] | Window.IsActive(videoosd)</param>
                        <param name="colordiffuse">main_fg</param>
                    </include>
                    <!-- LRS-AF3-META-CALL-END -->
"@

$CropBlock = @'
<!-- AFM-CROPV2-CLEARLOGO-LRS-START -->
<control type="image">
    <texture background="true">$INFO[Window(Home).Property(TMDbHelper.ListITem.CropImage)]</texture>
    <aspectratio aligny="bottom">keep</aspectratio>
    <visible>!String.IsEmpty(Window(Home).Property(TMDbHelper.ListITem.CropImage)) + String.IsEqual(Window(Home).Property(TMDbHelper.ListITem.Title),Container(1297).ListItem.Title)</visible>
</control>
<control type="image">
    <texture background="true">$INFO[Window(Home).Property(TMDbHelper.ListItem.CropImage)]</texture>
    <aspectratio aligny="bottom">keep</aspectratio>
    <visible>[String.IsEmpty(Window(Home).Property(TMDbHelper.ListITem.CropImage)) | !String.IsEqual(Window(Home).Property(TMDbHelper.ListITem.Title),Container(1297).ListItem.Title)] + !String.IsEmpty(Window(Home).Property(TMDbHelper.ListItem.CropImage)) + String.IsEqual(Window(Home).Property(TMDbHelper.ListItem.Title),Container(1297).ListItem.Title)</visible>
</control>
<control type="image">
    <texture background="true">$INFO[Container(1297).ListItem.Art(clearlogo)]</texture>
    <aspectratio aligny="bottom">keep</aspectratio>
    <visible>[String.IsEmpty(Window(Home).Property(TMDbHelper.ListITem.CropImage)) | !String.IsEqual(Window(Home).Property(TMDbHelper.ListITem.Title),Container(1297).ListItem.Title)] + [String.IsEmpty(Window(Home).Property(TMDbHelper.ListItem.CropImage)) | !String.IsEqual(Window(Home).Property(TMDbHelper.ListItem.Title),Container(1297).ListItem.Title)] + !String.IsEmpty(Container(1297).ListItem.Art(clearlogo))</visible>
</control>
<!-- AFM-CROPV2-CLEARLOGO-LRS-END -->
'@
$TitleVisible = '<visible>String.IsEmpty(Container(1297).ListItem.Art(clearlogo)) + [String.IsEmpty(Window(Home).Property(TMDbHelper.ListITem.CropImage)) | !String.IsEqual(Window(Home).Property(TMDbHelper.ListITem.Title),Container(1297).ListItem.Title)] + [String.IsEmpty(Window(Home).Property(TMDbHelper.ListItem.CropImage)) | !String.IsEqual(Window(Home).Property(TMDbHelper.ListItem.Title),Container(1297).ListItem.Title)]</visible>'

function Inline-Obj($Idx,$Width) {
    $labelWidth=[Math]::Max(40,$Width-54)
@"
<control type="group"><width>$Width</width><height>54</height><visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot$($Idx)_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot$($Idx)_IconFile))</visible><control type="image"><left>0</left><centertop>27</centertop><width>44</width><height>28</height><texture>flags/`$VAR[Color_Directory]/ratings/`$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot$($Idx)_IconFile)]</texture><aspectratio>keep</aspectratio></control><control type="label"><left>52</left><centertop>27</centertop><height>54</height><width>$labelWidth</width><font>font_main_mono</font><textcolor>main_fg_70</textcolor><aligny>center</aligny><label>`$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot$($Idx)_Label)]</label></control></control>
"@
}
$InlineSlots = (1..6 | ForEach-Object { Inline-Obj $_ $(if($_ -eq 1){128}else{112}) }) -join ''
$InlineRatings = @"
<!-- LRS-AFM-INLINE-RATINGS-START -->
$InlineSlots
<control type="group"><width>76</width><height>54</height><visible>String.IsEqual(Window(Home).Property(LibraryRatings.ListItem.Display_Awards),true) + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.Oscar_Wins))</visible><control type="image"><left>0</left><centertop>27</centertop><width>36</width><height>32</height><texture>flags/`$VAR[Color_Directory]/ratings/oscar.png</texture><aspectratio>keep</aspectratio></control><control type="label"><left>42</left><centertop>27</centertop><height>54</height><width>34</width><font>font_main_mono</font><textcolor>main_fg_70</textcolor><aligny>center</aligny><label>`$INFO[Window(Home).Property(LibraryRatings.ListItem.Oscar_Wins),x,]</label></control></control>
<control type="group"><width>76</width><height>54</height><visible>String.IsEqual(Window(Home).Property(LibraryRatings.ListItem.Display_Awards),true) + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.Emmy_Wins))</visible><control type="image"><left>0</left><centertop>27</centertop><width>36</width><height>32</height><texture>flags/`$VAR[Color_Directory]/ratings/emmy.png</texture><aspectratio>keep</aspectratio></control><control type="label"><left>42</left><centertop>27</centertop><height>54</height><width>34</width><font>font_main_mono</font><textcolor>main_fg_70</textcolor><aligny>center</aligny><label>`$INFO[Window(Home).Property(LibraryRatings.ListItem.Emmy_Wins),x,]</label></control></control>
<!-- LRS-AFM-INLINE-RATINGS-END -->
"@

function Disable-Native($Text, [ref]$Count) {
    $m=[regex]::Matches($Text,$NativeRe)
    $Count.Value=$m.Count
    if($m.Count -eq 0){ return $Text }
    $orig = ($m | ForEach-Object { $_.Value.Trim("`r","`n") }) -join "`n"
    $encoded=[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($orig))
    $Text=[regex]::Replace($Text,$NativeRe,'')
    if($Text -notmatch 'LRS-AF3-NATIVE-RATINGS-DISABLED-START'){
        $marker="`n                    <!-- LRS-AF3-NATIVE-RATINGS-DISABLED-START -->`n                    <!-- Native AF3/TMDbHelper rating rows disabled so only LRS rating slots are shown. -->`n                    <!-- LRS-AF3-NATIVE-RATINGS-ORIGINAL-B64:$encoded-->`n                    <!-- LRS-AF3-NATIVE-RATINGS-DISABLED-END -->"
        if($Text.Contains('<!-- LRS-AF3-META-CALL-END -->')){ $Text=$Text.Replace('<!-- LRS-AF3-META-CALL-END -->','<!-- LRS-AF3-META-CALL-END -->'+$marker) }
        elseif($Text.Contains('<!-- Ratings -->')){ $Text=$Text.Replace('<!-- Ratings -->','<!-- Ratings -->'+$marker) }
    }
    return $Text
}
function Restore-Native($Text, [ref]$Restored) {
    $Restored.Value=$false
    $m=[regex]::Match($Text,$NativeMarkerRe)
    if(!$m.Success){ return $Text }
    $orig=''
    $b=[regex]::Match($m.Value,'LRS-AF3-NATIVE-RATINGS-ORIGINAL-B64:([A-Za-z0-9+/=]+)')
    if($b.Success){ try { $orig=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($b.Groups[1].Value)) } catch {} }
    $Restored.Value=$true
    return $Text.Substring(0,$m.Index) + "`n" + $orig + $Text.Substring($m.Index+$m.Length)
}

function Patch-Info {
    $p=File-In-Skin 'Includes_Info.xml'; $s=Read-Text $p; $orig=$s
    $cnt=0; $s=Replace-Between $s '<!-- LRS-AF3-INCLUDE-DEF-START -->' '<!-- LRS-AF3-INCLUDE-DEF-END -->' $LrsIncludeDef ([ref]$cnt)
    if($cnt -eq 0 -and $s -notmatch 'LRS-AF3-INCLUDE-DEF-START'){
        if($s.Contains('</includes>')){ $s=$s.Replace('</includes>', $LrsIncludeDef+"`n</includes>") } else { throw 'Includes_Info.xml tidak punya </includes>' }
    }
    $cnt=0; $s=Replace-Between $s '<!-- LRS-AF3-META-CALL-START -->' '<!-- LRS-AF3-META-CALL-END -->' $LrsMetaCall ([ref]$cnt)
    if($cnt -eq 0 -and $s -notmatch 'LRS-AF3-META-CALL-START'){
        if($s.Contains('<!-- Ratings -->')){ $s=$s.Replace('<!-- Ratings -->', "<!-- Ratings -->`n$LrsMetaCall") } else { Write-Host '[WARN] marker <!-- Ratings --> tidak ditemukan' }
    }
    $s=Remove-Between $s '<!-- LRS-AF3-NATIVE-STATUS-DISABLED-START -->' '<!-- LRS-AF3-NATIVE-STATUS-DISABLED-END -->'
    $n=0; $s=Disable-Native $s ([ref]$n); if($n -gt 0){ Write-Host "[OK] Disabled native AF3/TMDbHelper rating rows: $n block(s)" }
    if($s -eq $orig){ Write-Host '[OK] Includes_Info.xml sudah sesuai'; return }
    $bak=Backup-File $p; Write-Text $p $s; Write-Host "[OK] Patched Includes_Info.xml"; Write-Host "[INFO] Backup safety: $bak"
}
function Remove-Info {
    $p=File-In-Skin 'Includes_Info.xml'; $s=Read-Text $p; $orig=$s
    $s=Remove-Between $s '<!-- LRS-AF3-META-CALL-START -->' '<!-- LRS-AF3-META-CALL-END -->'
    $s=Remove-Between $s '<!-- LRS-AF3-INCLUDE-DEF-START -->' '<!-- LRS-AF3-INCLUDE-DEF-END -->'
    $r=$false; $s=Restore-Native $s ([ref]$r)
    if($s -eq $orig){ Write-Host '[WARN] Tidak ada patch LRS Includes_Info untuk dihapus'; return }
    $bak=Backup-File $p; Write-Text $p $s; Write-Host '[OK] Removed Includes_Info LRS patch'; Write-Host "[INFO] Backup safety: $bak"
}
function Patch-Screensaver {
    $p=File-In-Skin 'screensaver-arctic-mirage.xml'; $s=Read-Text $p; $orig=$s
    $cnt=0; $s=Replace-Between $s '<!-- AFM-CROPV2-CLEARLOGO-LRS-START -->' '<!-- AFM-CROPV2-CLEARLOGO-LRS-END -->' $CropBlock ([ref]$cnt)
    if($cnt -eq 0){ $pat='(?s)<control type="image">\s*<texture background="true">\$INFO\[Container\(1297\)\.ListItem\.Art\(clearlogo\)\]</texture>.*?</control>'; $m=[regex]::Matches($s,$pat).Count; if($m -gt 0){ $s=[regex]::Replace($s,$pat,$CropBlock,1); Write-Host '[OK] Patched CropV2 clearlogo block' } else { Write-Host '[WARN] Clearlogo standar tidak ditemukan' } }
    $s=$s.Replace('<visible>String.IsEmpty(Container(1297).ListItem.Art(clearlogo))</visible>',$TitleVisible)
    $s=[regex]::Replace($s,'<visible>String\.IsEmpty\(Window\(Home\)\.Property\(LibraryRatings\.Screensaver\.CropV2Image\)\) \+ String\.IsEmpty\(Container\(1297\)\.ListItem\.Art\(clearlogo\)\)</visible>',$TitleVisible)
    $incPat='(?s)\s*<include\s+content=["'']LRS_Info_Meta_Ratings["''][^>]*>.*?</include>'
    $n=[regex]::Matches($s,$incPat).Count
    if($n -gt 0){ $s=[regex]::Replace($s,$incPat,"`n                    "+$InlineRatings.Replace("`n","`n                    ")); Write-Host "[OK] Replaced screensaver LRS include with inline controls: $n" }
    elseif($s -notmatch 'LRS-AFM-INLINE-RATINGS-START') { Write-Host '[WARN] Screensaver rating include tidak ditemukan' }
    if($s -notmatch 'Container\(1297\)\.ListItem\.Plot'){ Write-Host '[WARN] Plot screensaver tidak ditemukan di XML ini' }
    if($s -eq $orig){ Write-Host '[OK] screensaver-arctic-mirage.xml sudah sesuai'; return }
    $bak=Backup-File $p; Write-Text $p $s; Write-Host '[OK] Patched screensaver-arctic-mirage.xml'; Write-Host "[INFO] Backup safety: $bak"
}
function Remove-Screensaver {
    $p=File-In-Skin 'screensaver-arctic-mirage.xml'; $s=Read-Text $p; $orig=$s
    $default='<control type="image">' + "`n" + '    <texture background="true">$INFO[Container(1297).ListItem.Art(clearlogo)]</texture>' + "`n" + '    <aspectratio aligny="bottom">keep</aspectratio>' + "`n" + '    <visible>!String.IsEmpty(Container(1297).ListItem.Art(clearlogo))</visible>' + "`n" + '</control>'
    $cnt=0; $s=Replace-Between $s '<!-- AFM-CROPV2-CLEARLOGO-LRS-START -->' '<!-- AFM-CROPV2-CLEARLOGO-LRS-END -->' $default ([ref]$cnt)
    $s=Remove-Between $s '<!-- LRS-AFM-INLINE-RATINGS-START -->' '<!-- LRS-AFM-INLINE-RATINGS-END -->'
    if($s -eq $orig){ Write-Host '[WARN] Tidak ada patch screensaver untuk dihapus'; return }
    $bak=Backup-File $p; Write-Text $p $s; Write-Host '[OK] Removed screensaver patch'; Write-Host "[INFO] Backup safety: $bak"
}
function Check-Status {
    $incPath=File-In-Skin 'Includes_Info.xml'; $scrPath=File-In-Skin 'screensaver-arctic-mirage.xml'
    $inc=Read-Text $incPath; $scr=Read-Text $scrPath
    $native=[regex]::Matches($inc,$NativeRe).Count; $disabled=($inc -match 'LRS-AF3-NATIVE-RATINGS-DISABLED-START')
    $lrsDef=($inc -match 'LRS-AF3-INCLUDE-DEF-START' -and $inc -match 'RatingSlot6_IconFile')
    $lrsCall=($inc -match 'LRS-AF3-META-CALL-START')
    if($lrsDef -and $lrsCall -and $disabled -and $native -eq 0){ $state='PATCHED' }
    elseif(!$lrsDef -and !$lrsCall -and !$disabled -and $native -gt 0){ $state='CLEAN/ORIGINAL' }
    else { $state='PARTIAL/UNKNOWN' }
    Write-Host "`nSTATUS"
    Write-Host "  Skin path                  : $script:Skin1080i"
    Write-Host "  Includes_Info modified/hash: $(FTime $incPath) / $(Sha8 $inc)"
    Write-Host "  Includes state             : $state"
    Write-Host "  Includes LRS slot 1-6      : $(if($lrsDef){'YES'}else{'NO'})"
    Write-Host "  LRS meta call              : $(if($lrsCall){'YES'}else{'NO'})"
    Write-Host "  Native disabled marker     : $(if($disabled){'YES'}else{'NO'})"
    Write-Host "  Native row calls remaining : $native"
    Write-Host "  Screensaver modified/hash  : $(FTime $scrPath) / $(Sha8 $scr)"
    Write-Host "  Screensaver plot preserved : $(if($scr -match 'Container\(1297\)\.ListItem\.Plot'){'YES'}else{'NO'})"
    Write-Host "  Screensaver CropV2 direct  : $(if($scr -match 'TMDbHelper\.ListITem\.CropImage' -and $scr -match 'AFM-CROPV2-CLEARLOGO-LRS-START'){'YES'}else{'NO'})"
    Write-Host "  Screensaver inline ratings : $(if($scr -match 'LRS-AFM-INLINE-RATINGS-START'){'YES'}else{'NO'})"
    Write-Host "  Invalid LRS include left   : $(if($scr -match 'include content="LRS_Info_Meta_Ratings"'){'YES'}else{'NO'})"
}

while($true){
    Write-Host "`n============================================================"
    Write-Host "AF3 + LRS 1.3.82 patcher - PowerShell/no Python"
    Write-Host "Skin 1080i: $script:Skin1080i"
    Write-Host "============================================================"
    Write-Host '1. Patch LRS AF3 rating slots 1-6 + disable native ratings'
    Write-Host '2. Remove LRS AF3 patch from Includes_Info.xml'
    Write-Host '3. Patch Arctic Mirage CropV2 clearlogo + inline LRS ratings'
    Write-Host '4. Remove Arctic Mirage CropV2/LRS screensaver block'
    Write-Host '5. Patch all'
    Write-Host '6. Remove all'
    Write-Host '7. Check patch status'
    Write-Host '8. Change skin 1080i path'
    Write-Host '9. Exit'
    $c=Read-Host 'Pilih [1-9]'
    try {
        switch($c){
            '1'{Patch-Info}
            '2'{Remove-Info}
            '3'{Patch-Screensaver}
            '4'{Remove-Screensaver}
            '5'{Patch-Info; Patch-Screensaver; Check-Status}
            '6'{Remove-Screensaver; Remove-Info; Check-Status}
            '7'{Check-Status}
            '8'{ $n=Read-Host 'Masukkan path folder 1080i'; if($n){ $script:Skin1080i=$n.Trim('"') } }
            '9'{break}
            default{Write-Host '[WARN] Pilihan tidak dikenal'}
        }
    } catch { Write-Host "[ERROR] $($_.Exception.Message)" }
    [void](Read-Host "`nTekan Enter untuk kembali ke menu")
}
