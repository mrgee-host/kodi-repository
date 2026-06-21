
$ErrorActionPreference = "Stop"
$DefaultSkin1080i = "E:\Kodi\portable_data\addons\skin.arctic.fuse.3\1080i"
$Skin1080i = $DefaultSkin1080i

function Read-Text($Path) { return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8) }
function Write-Text($Path, $Text) { [System.IO.File]::WriteAllText($Path, $Text, [System.Text.UTF8Encoding]::new($false)) }
function Backup-Once($Path) { $b = "$Path.lrs-1384-before"; if ((Test-Path $Path) -and !(Test-Path $b)) { Copy-Item -LiteralPath $Path -Destination $b -Force } }
function Replace-Regex($Text, $Pattern, $Replacement, $Count = 0) {
    $rx = [System.Text.RegularExpressions.Regex]::new($Pattern, ([System.Text.RegularExpressions.RegexOptions]::Singleline -bor [System.Text.RegularExpressions.RegexOptions]::Multiline))
    if ($Count -gt 0) { return $rx.Replace($Text, $Replacement, $Count) }
    return $rx.Replace($Text, $Replacement)
}

$RatingCall = @'
                    <!-- Ratings -->
                    <!-- LRS-AF3-META-CALL-START-1.3.84 -->
                    <include content="LRS_Info_Meta_Ratings">
                        <param name="visible">String.IsEqual($PARAM[container]$PARAM[listitem].DBType,movie) | String.IsEqual($PARAM[container]$PARAM[listitem].DBType,tvshow) | String.IsEqual($PARAM[container]$PARAM[listitem].DBType,season) | String.IsEqual($PARAM[container]$PARAM[listitem].DBType,episode) | $PARAM[override_movie] | $PARAM[override_tvshow] | Window.IsActive(videoosd)</param>
                        <param name="colordiffuse">main_fg</param>
                    </include>
                    <!-- LRS-AF3-META-CALL-END-1.3.84 -->

'@

$LrsIncludeDef = @'
    <!-- LRS-AF3-INCLUDE-DEF-START -->
    <!-- LRS-AF3-1.3.84: 6 slots, IconFile paths, oscars/emmys icons, Display toggles -->
    <include name="LRS_Info_Meta_Ratings">
        <param name="visible">true</param>
        <param name="colordiffuse">main_fg</param>
        <definition>
            <include content="Info_Meta_Object">
                <param name="icon">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot1_IconFile)]</param>
                <param name="label">$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot1_Label)]</param>
                <param name="visible">[$PARAM[visible]] + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot1_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot1_IconFile))</param>
                <param name="colordiffuse">$PARAM[colordiffuse]</param>
                <param name="icon_w">52</param>
            </include>
            <include content="Info_Meta_Object">
                <param name="icon">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot2_IconFile)]</param>
                <param name="label">$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot2_Label)]</param>
                <param name="visible">[$PARAM[visible]] + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot2_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot2_IconFile))</param>
                <param name="colordiffuse">$PARAM[colordiffuse]</param>
                <param name="icon_w">52</param>
            </include>
            <include content="Info_Meta_Object">
                <param name="icon">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot3_IconFile)]</param>
                <param name="label">$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot3_Label)]</param>
                <param name="visible">[$PARAM[visible]] + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot3_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot3_IconFile))</param>
                <param name="colordiffuse">$PARAM[colordiffuse]</param>
                <param name="icon_w">52</param>
            </include>
            <include content="Info_Meta_Object">
                <param name="icon">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot4_IconFile)]</param>
                <param name="label">$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot4_Label)]</param>
                <param name="visible">[$PARAM[visible]] + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot4_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot4_IconFile))</param>
                <param name="colordiffuse">$PARAM[colordiffuse]</param>
                <param name="icon_w">52</param>
            </include>
            <include content="Info_Meta_Object">
                <param name="icon">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot5_IconFile)]</param>
                <param name="label">$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot5_Label)]</param>
                <param name="visible">[$PARAM[visible]] + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot5_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot5_IconFile))</param>
                <param name="colordiffuse">$PARAM[colordiffuse]</param>
                <param name="icon_w">52</param>
            </include>
            <include content="Info_Meta_Object">
                <param name="icon">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot6_IconFile)]</param>
                <param name="label">$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot6_Label)]</param>
                <param name="visible">[$PARAM[visible]] + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot6_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot6_IconFile))</param>
                <param name="colordiffuse">$PARAM[colordiffuse]</param>
                <param name="icon_w">52</param>
            </include>
            <include content="Info_Meta_Object">
                <param name="icon">flags/$VAR[Color_Directory]/ratings/oscars.png</param>
                <param name="label">$INFO[Window(Home).Property(LibraryRatings.ListItem.Oscar_Wins),x,]</param>
                <param name="visible">[$PARAM[visible]] + String.IsEqual(Window(Home).Property(LibraryRatings.Display.Awards),true) + [String.IsEqual(Window(Home).Property(LibraryRatings.ListItem.DBType),movie)] + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.Oscar_Wins))</param>
                <param name="colordiffuse">$PARAM[colordiffuse]</param>
            </include>
            <include content="Info_Meta_Object">
                <param name="icon">flags/$VAR[Color_Directory]/ratings/emmys.png</param>
                <param name="label">$INFO[Window(Home).Property(LibraryRatings.ListItem.Emmy_Wins),x,]</param>
                <param name="visible">[$PARAM[visible]] + String.IsEqual(Window(Home).Property(LibraryRatings.Display.Awards),true) + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.Emmy_Wins))</param>
                <param name="colordiffuse">$PARAM[colordiffuse]</param>
            </include>
            <include content="Info_Meta_Object">
                <param name="icon">flags/$VAR[Color_Directory]/ratings/ends.png</param>
                <param name="label">$INFO[Window(Home).Property(LibraryRatings.ListItem.Series_StatusLabel)]</param>
                <param name="visible">[$PARAM[visible]] + String.IsEqual(Window(Home).Property(LibraryRatings.Display.TVStatus),true) + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.Series_StatusLabel))</param>
                <param name="colordiffuse">$PARAM[colordiffuse]</param>
            </include>
        </definition>
    </include>
    <!-- LRS-AF3-INCLUDE-DEF-END -->
'@

$CropBlock = @'
                    <!-- AFM-CROPV2-CLEARLOGO-LRS-START-1.3.84 -->
                    <control type="image">
                        <texture background="true">$INFO[Window(Home).Property(LibraryRatings.Screensaver.CropV2Image)]</texture>
                        <aspectratio aligny="bottom">keep</aspectratio>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.CropV2Image))</visible>
                    </control>
                    <control type="image">
                        <texture background="true">$INFO[Container(1297).ListItem.Art(clearlogo)]</texture>
                        <aspectratio aligny="bottom">keep</aspectratio>
                        <visible>String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.CropV2Image)) + !String.IsEmpty(Container(1297).ListItem.Art(clearlogo))</visible>
                    </control>
                    <!-- AFM-CROPV2-CLEARLOGO-LRS-END-1.3.84 -->
'@

$ScreenInline = @'
                <!-- LRS-AF3-SCREENSAVER-INLINE-START-1.3.84 -->
                <control type="grouplist">
                    <orientation>horizontal</orientation>
                    <align>center</align>
                    <height>54</height>
                    <centertop>320</centertop>
                    <itemgap>14</itemgap>
                    <visible>String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.HasData),true)</visible>
                    <control type="group"><width>150</width><height>54</height><visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot1_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot1_IconFile))</visible><control type="image"><left>0</left><top>7</top><width>40</width><height>40</height><texture>flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot1_IconFile)]</texture><aspectratio align="center" aligny="center">keep</aspectratio></control><control type="label"><left>52</left><top>0</top><width>96</width><height>54</height><font>font_main</font><textcolor>main_fg_70</textcolor><aligny>center</aligny><label>$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot1_Label)]</label></control></control>
                    <control type="group"><width>150</width><height>54</height><visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot2_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot2_IconFile))</visible><control type="image"><left>0</left><top>7</top><width>40</width><height>40</height><texture>flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot2_IconFile)]</texture><aspectratio align="center" aligny="center">keep</aspectratio></control><control type="label"><left>52</left><top>0</top><width>96</width><height>54</height><font>font_main</font><textcolor>main_fg_70</textcolor><aligny>center</aligny><label>$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot2_Label)]</label></control></control>
                    <control type="group"><width>150</width><height>54</height><visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot3_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot3_IconFile))</visible><control type="image"><left>0</left><top>7</top><width>40</width><height>40</height><texture>flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot3_IconFile)]</texture><aspectratio align="center" aligny="center">keep</aspectratio></control><control type="label"><left>52</left><top>0</top><width>96</width><height>54</height><font>font_main</font><textcolor>main_fg_70</textcolor><aligny>center</aligny><label>$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot3_Label)]</label></control></control>
                    <control type="group"><width>150</width><height>54</height><visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot4_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot4_IconFile))</visible><control type="image"><left>0</left><top>7</top><width>40</width><height>40</height><texture>flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot4_IconFile)]</texture><aspectratio align="center" aligny="center">keep</aspectratio></control><control type="label"><left>52</left><top>0</top><width>96</width><height>54</height><font>font_main</font><textcolor>main_fg_70</textcolor><aligny>center</aligny><label>$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot4_Label)]</label></control></control>
                    <control type="group"><width>150</width><height>54</height><visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot5_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot5_IconFile))</visible><control type="image"><left>0</left><top>7</top><width>40</width><height>40</height><texture>flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot5_IconFile)]</texture><aspectratio align="center" aligny="center">keep</aspectratio></control><control type="label"><left>52</left><top>0</top><width>96</width><height>54</height><font>font_main</font><textcolor>main_fg_70</textcolor><aligny>center</aligny><label>$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot5_Label)]</label></control></control>
                    <control type="group"><width>150</width><height>54</height><visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot6_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot6_IconFile))</visible><control type="image"><left>0</left><top>7</top><width>40</width><height>40</height><texture>flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot6_IconFile)]</texture><aspectratio align="center" aligny="center">keep</aspectratio></control><control type="label"><left>52</left><top>0</top><width>96</width><height>54</height><font>font_main</font><textcolor>main_fg_70</textcolor><aligny>center</aligny><label>$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot6_Label)]</label></control></control>
                </control>
                <!-- LRS-AF3-SCREENSAVER-INLINE-END-1.3.84 -->
'@

function Patch-IncludesInfo {
    $path = Join-Path $Skin1080i "Includes_Info.xml"
    if (!(Test-Path $path)) { Write-Host "[ERROR] Not found: $path"; return }
    Backup-Once $path
    $t = Read-Text $path
    $t = Replace-Regex $t '\s*<!-- LRS-AF3-INCLUDE-DEF-START -->.*?<!-- LRS-AF3-INCLUDE-DEF-END -->\s*' "`r`n"
    $ratingPattern = '(?ms)^\s*<!-- Ratings -->.*?(?=^\s*<!-- Total Episodes)'
    if ([regex]::IsMatch($t, $ratingPattern)) { $t = Replace-Regex $t $ratingPattern $RatingCall 1 } else { $t = $t.Replace('                    <!-- Total Episodes', $RatingCall + '                    <!-- Total Episodes') }
    $t = Replace-Regex $t '\s*<!-- LRS-AF3-NATIVE-STATUS-DISABLED-START -->.*?<!-- LRS-AF3-NATIVE-STATUS-DISABLED-END -->\s*' "`r`n"
    $t = Replace-Regex $t '(?ms)^\s*<!-- Status -->\s*\r?\n\s*<include content="Info_Meta_Object" condition="\$EXP\[Exp_TMDbHelper_IsData\]">.*?</include>\s*\r?\n\s*<!-- Awards -->\s*\r?\n\s*<include content="Info_Meta_Object" condition="\$EXP\[Exp_TMDbHelper_IsData\][^"]*">.*?</include>\s*' '                    <!-- LRS-AF3-NATIVE-STATUS-AWARDS-DISABLED-1.3.84 -->' 1
    $t = Replace-Regex $t '(?ms)^\s*<!-- Status -->\s*\r?\n\s*<include content="Info_Meta_Object" condition="\$EXP\[Exp_TMDbHelper_IsData\]">.*?</include>\s*' '                    <!-- LRS-AF3-NATIVE-STATUS-DISABLED-1.3.84 -->' 1
    $t = Replace-Regex $t '(?ms)^\s*<!-- Awards -->\s*\r?\n\s*<include content="Info_Meta_Object" condition="\$EXP\[Exp_TMDbHelper_IsData\][^"]*">.*?</include>\s*' '                    <!-- LRS-AF3-NATIVE-AWARDS-DISABLED-1.3.84 -->' 1
    if ($t.Contains('</includes>')) { $t = $t.Replace('</includes>', $LrsIncludeDef + "`r`n</includes>") }
    Write-Text $path $t
    Write-Host "[OK] Includes_Info.xml patched"
}

function Remove-IncludesInfoPatch {
    $path = Join-Path $Skin1080i "Includes_Info.xml"
    if (!(Test-Path $path)) { Write-Host "[ERROR] Not found: $path"; return }
    Backup-Once $path
    $t = Read-Text $path
    $t = Replace-Regex $t '\s*<!-- LRS-AF3-INCLUDE-DEF-START -->.*?<!-- LRS-AF3-INCLUDE-DEF-END -->\s*' "`r`n"
    $t = Replace-Regex $t '(?ms)^\s*<!-- Ratings -->\s*\r?\n\s*<!-- LRS-AF3-META-CALL-START[^>]*-->.*?<!-- LRS-AF3-META-CALL-END[^>]*-->\s*' '                    <!-- Ratings -->' 1
    Write-Text $path $t
    Write-Host "[OK] LRS Includes_Info blocks removed. Native rows are not restored; use skin reinstall if you want factory XML."
}

function Patch-IncludesHubs {
    $path = Join-Path $Skin1080i "Includes_Hubs.xml"
    if (!(Test-Path $path)) { Write-Host "[WARN] Not found: $path"; return }
    Backup-Once $path
    $t = Read-Text $path
    if ($t -notmatch 'LRS\.Active\.ContainerID') {
        Write-Host "[WARN] Includes_Hubs active bridge markers not found; this patcher will not guess the AF3 hub structure."
    } else {
        $t = $t -replace 'LRS-AF3-ACTIVE-BRIDGE-1\.3\.79','LRS-AF3-ACTIVE-BRIDGE-1.3.84'
        Write-Text $path $t
        Write-Host "[OK] Includes_Hubs.xml active bridge present/updated"
    }
}

function Remove-IncludesHubsPatch {
    $path = Join-Path $Skin1080i "Includes_Hubs.xml"
    if (!(Test-Path $path)) { Write-Host "[WARN] Not found: $path"; return }
    Backup-Once $path
    $t = Read-Text $path
    $t = Replace-Regex $t '^\s*<!-- LRS-AF3-ACTIVE-BRIDGE[^>]*-->\s*\r?\n\s*<onload[^>]*LRS\.Active\.ContainerID.*?</onload>\s*\r?\n?' ''
    $t = Replace-Regex $t '^\s*<!-- LRS-AF3-ACTIVE-BRIDGE[^>]*-->\s*\r?\n\s*<onfocus[^>]*LRS\.Active\.ContainerID.*?</onfocus>\s*\r?\n?' ''
    Write-Text $path $t
    Write-Host "[OK] Includes_Hubs LRS bridge lines removed"
}

function Patch-Screensaver {
    $path = Join-Path $Skin1080i "screensaver-arctic-mirage.xml"
    if (!(Test-Path $path)) { Write-Host "[ERROR] Not found: $path"; return }
    Backup-Once $path
    $t = Read-Text $path
    $t = Replace-Regex $t '\s*<!-- LRS-AF3-SCREENSAVER-INLINE-START[^>]*-->.*?<!-- LRS-AF3-SCREENSAVER-INLINE-END[^>]*-->\s*' "`r`n"
    $t = Replace-Regex $t '\s*<!-- LRS-AF3-SCREENSAVER-RATINGS-START -->.*?<!-- LRS-AF3-SCREENSAVER-RATINGS-END -->\s*' "`r`n"
    $t = Replace-Regex $t '\s*<control type="grouplist"[^>]*>\s*<orientation>horizontal</orientation>.*?<include content="LRS_Info_Meta_Ratings">.*?</include>\s*</control>\s*' "`r`n"
    $old = $t
    $t = Replace-Regex $t '\s*<include content="Info_StarRating">.*?</include>\s*' ("`r`n" + $ScreenInline + "`r`n")
    if ($t -eq $old -and $t -notmatch 'LRS-AF3-SCREENSAVER-INLINE-START-1\.3\.84') {
        if ($t -match '<!-- AFM-CROPV2-CLEARLOGO-LRS-END') { $t = Replace-Regex $t '(<!-- AFM-CROPV2-CLEARLOGO-LRS-END[^>]*-->)' ('$1' + "`r`n" + $ScreenInline) 1 }
        elseif ($t -match 'Container\(1297\)\.ListItem\.Plot') {
            $beforeInsert = $t
            $t = Replace-Regex $t '(?=\s*<control type="textbox">\s*<font>font_main_plot</font>)' ($ScreenInline + "`r`n") 1
            if ($t -eq $beforeInsert) { $t = Replace-Regex $t '(?=\s*<control type="textbox">\s*\r?\n\s*<font>font_main_plot</font>)' ($ScreenInline + "`r`n") 1 }
        }
        else { $t = $t.Replace('</controls>', $ScreenInline + "`r`n    </controls>") }
    }
    $t = Replace-Regex $t '\s*<!-- AFM-CROPV2-CLEARLOGO-LRS-START[^>]*-->.*?<!-- AFM-CROPV2-CLEARLOGO-LRS-END[^>]*-->\s*' ("`r`n" + $CropBlock + "`r`n")
    $t = Replace-Regex $t '\s*<control type="image">\s*<texture background="true">\$INFO\[Container\(1297\)\.ListItem\.Art\(clearlogo\)\]</texture>\s*<aspectratio aligny="bottom">keep</aspectratio>\s*<visible>!String.IsEmpty\(Container\(1297\)\.ListItem\.Art\(clearlogo\)\)</visible>\s*</control>' ("`r`n" + $CropBlock)
    $t = $t.Replace('<visible>String.IsEmpty(Container(1297).ListItem.Art(clearlogo))</visible>', '<visible>String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.CropV2Image)) + String.IsEmpty(Container(1297).ListItem.Art(clearlogo))</visible>')
    if ($t -notmatch 'Container\(1297\)\.ListItem\.Plot') { $t = $t.Replace('        </control>' + "`r`n" + '    </controls>', '        </control>' + "`r`n" + '            <control type="textbox"><font>font_main_plot</font><textcolor>main_fg_70</textcolor><label>$INFO[Container(1297).ListItem.Plot]</label><bottom>view_pad</bottom><height>120</height><align>center</align></control>' + "`r`n" + '    </controls>') }
    Write-Text $path $t
    Write-Host "[OK] screensaver-arctic-mirage.xml patched"
}

function Remove-ScreensaverPatch {
    $path = Join-Path $Skin1080i "screensaver-arctic-mirage.xml"
    if (!(Test-Path $path)) { Write-Host "[ERROR] Not found: $path"; return }
    Backup-Once $path
    $t = Read-Text $path
    $t = Replace-Regex $t '\s*<!-- LRS-AF3-SCREENSAVER-INLINE-START[^>]*-->.*?<!-- LRS-AF3-SCREENSAVER-INLINE-END[^>]*-->\s*' "`r`n"
    $t = Replace-Regex $t '\s*<!-- AFM-CROPV2-CLEARLOGO-LRS-START[^>]*-->.*?<!-- AFM-CROPV2-CLEARLOGO-LRS-END[^>]*-->\s*' "`r`n"
    Write-Text $path $t
    Write-Host "[OK] screensaver LRS/CropV2 blocks removed"
}

function Check-Status {
    $infoPath = Join-Path $Skin1080i "Includes_Info.xml"
    $hubPath = Join-Path $Skin1080i "Includes_Hubs.xml"
    $ssPath = Join-Path $Skin1080i "screensaver-arctic-mirage.xml"
    Write-Host "`nSTATUS"
    Write-Host "  Skin path                  : $Skin1080i"
    if (Test-Path $infoPath) {
        $t = Read-Text $infoPath
        $slots = ($t -match 'RatingSlot6_IconFile') -and ($t -match 'RatingSlot6_Label')
        $nativeRatings = [regex]::Matches($t, '<include content="Info_Meta_Ratings" condition="\$EXP\[Exp_TMDbHelper_IsData\]"').Count
        $nativeStatus = ($t -match 'TMDbHelper\.\$PARAM\[service\]\.Status')
        $nativeAwards = ($t -match 'TMDbHelper\.\$PARAM\[service\]\.Oscar_Wins')
        $icons = ($t -match 'oscars\.png') -and ($t -match 'emmys\.png')
        Write-Host "  Includes LRS slot 1-6      : $(if($slots){'YES'}else{'NO'})"
        Write-Host "  Native rating calls left   : $nativeRatings"
        Write-Host "  Native status left         : $(if($nativeStatus){'YES'}else{'NO'})"
        Write-Host "  Native awards left         : $(if($nativeAwards){'YES'}else{'NO'})"
        Write-Host "  Awards icons oscars/emmys  : $(if($icons){'YES'}else{'NO'})"
    }
    if (Test-Path $hubPath) { $h = Read-Text $hubPath; Write-Host "  Includes_Hubs active bridge: $(if($h -match 'LRS\.Active\.ContainerID'){'YES'}else{'NO'})" }
    if (Test-Path $ssPath) {
        $s = Read-Text $ssPath
        Write-Host "  Screensaver plot preserved : $(if($s -match 'Container\(1297\)\.ListItem\.Plot'){'YES'}else{'NO'})"
        Write-Host "  Screensaver CropV2 prop    : $(if($s -match 'LibraryRatings\.Screensaver\.CropV2Image'){'YES'}else{'NO'})"
        Write-Host "  Screensaver inline ratings : $(if($s -match 'LRS-AF3-SCREENSAVER-INLINE-START-1\.3\.84'){'YES'}else{'NO'})"
        Write-Host "  Invalid LRS include left   : $(if($s -match 'LRS_Info_Meta_Ratings'){'YES'}else{'NO'})"
    }
}

function Patch-All { Patch-IncludesInfo; Patch-IncludesHubs; Patch-Screensaver; Check-Status }
function Remove-All { Remove-IncludesInfoPatch; Remove-IncludesHubsPatch; Remove-ScreensaverPatch; Check-Status }

while ($true) {
    Clear-Host
    Write-Host "AF3 + LRS 1.3.84 patcher"
    Write-Host "Skin 1080i: $Skin1080i"
    Write-Host "============================================================"
    Write-Host "1. Patch Includes_Info LRS rating slots 1-6 + disable native rows"
    Write-Host "2. Remove Includes_Info LRS patch"
    Write-Host "3. Patch Includes_Hubs active bridge marker"
    Write-Host "4. Remove Includes_Hubs active bridge"
    Write-Host "5. Patch Arctic Mirage CropV2 clearlogo + inline LRS ratings"
    Write-Host "6. Remove Arctic Mirage CropV2/LRS screensaver block"
    Write-Host "7. Patch all"
    Write-Host "8. Remove all"
    Write-Host "9. Check patch status"
    Write-Host "10. Change skin 1080i path"
    Write-Host "11. Exit"
    $c = Read-Host "Pilih [1-11]"
    try {
        switch ($c) {
            '1' { Patch-IncludesInfo }
            '2' { Remove-IncludesInfoPatch }
            '3' { Patch-IncludesHubs }
            '4' { Remove-IncludesHubsPatch }
            '5' { Patch-Screensaver }
            '6' { Remove-ScreensaverPatch }
            '7' { Patch-All }
            '8' { Remove-All }
            '9' { Check-Status }
            '10' { $new = Read-Host "Masukkan full path folder 1080i"; if ($new.Trim()) { $Skin1080i = $new.Trim() } }
            '11' { break }
            default { Write-Host "Pilihan tidak dikenal" }
        }
    } catch { Write-Host "[ERROR] $($_.Exception.Message)" }
    Write-Host ""
    Read-Host "Tekan Enter untuk kembali ke menu"
}
