$ErrorActionPreference = 'Stop'
$DefaultSkinPath = 'E:\Kodi\portable_data\addons\skin.arctic.fuse.3\1080i'
$SkinPathFile = Join-Path $PSScriptRoot 'af3_lrs_skin_path.txt'

function Get-SkinPath {
    if (Test-Path $SkinPathFile) {
        $p = (Get-Content -LiteralPath $SkinPathFile -Raw).Trim()
        if ($p) { return $p }
    }
    return $DefaultSkinPath
}

function Save-SkinPath([string]$p) {
    Set-Content -LiteralPath $SkinPathFile -Value $p -Encoding UTF8
}

function Read-Utf8([string]$p) {
    return [System.IO.File]::ReadAllText($p, [System.Text.Encoding]::UTF8)
}

function Write-Utf8NoBom([string]$p, [string]$t) {
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($p, $t, $enc)
}

$OldClear = @'
                    <control type="image">
                        <texture background="true">$INFO[Container(1297).ListItem.Art(clearlogo)]</texture>
                        <aspectratio aligny="bottom">keep</aspectratio>
                        <visible>!String.IsEmpty(Container(1297).ListItem.Art(clearlogo))</visible>
                    </control>
'@
$NewCrop = @'
                    <!-- AFM-CROPV2-CLEARLOGO-LRS-START-1.3.87-r3-NATIVE-PRESERVE -->
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
                    <!-- AFM-CROPV2-CLEARLOGO-LRS-END-1.3.87-r3-NATIVE-PRESERVE -->
'@
$OldStar = @'
                <include content="Info_StarRating">
                    <param name="textcolor">yellow_star</param>
                    <param name="rating">Container(1297).ListItem.Rating</param>
                    <param name="size">64</param>
                    <height>80</height>
                    <align>center</align>
                    <centertop>320</centertop>
                    <itemgap>-16</itemgap>
                    <visible>!String.IsEmpty(Container(1297).ListItem.Plot)</visible>
                </include>
'@
$NewRow = @'
                <!-- LRS-AF3-SCREENSAVER-AF3-ROW-START-1.3.87-r3-NATIVE-PRESERVE -->
                <control type="grouplist">
                    <orientation>horizontal</orientation>
                    <align>center</align>
                    <height>54</height>
                    <centertop>320</centertop>
                    <itemgap>12</itemgap>
                    <visible>String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.HasData),true)</visible>
                    <!-- LRS RatingSlot1 -->
                    <control type="image">
                        <width>52</width>
                        <height>32</height>
                        <aspectratio>keep</aspectratio>
                        <centertop>50%</centertop>
                        <texture colordiffuse="main_fg_90">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot1_IconFile)]</texture>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot1_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot1_IconFile)) + String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot1_Source),imdb)</visible>
                    </control>
                    <control type="image">
                        <width>32</width>
                        <height>32</height>
                        <aspectratio>keep</aspectratio>
                        <centertop>50%</centertop>
                        <texture colordiffuse="main_fg_90">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot1_IconFile)]</texture>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot1_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot1_IconFile)) + !String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot1_Source),imdb)</visible>
                    </control>
                    <control type="label">
                        <aligny>center</aligny>
                        <label>$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot1_Label)]</label>
                        <textcolor>main_fg_70</textcolor>
                        <font>font_main</font>
                        <width max="680">auto</width>
                        <textoffsetx>0</textoffsetx>
                        <texturefocus />
                        <texturenofocus />
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot1_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot1_IconFile))</visible>
                    </control>
                    <control type="group">
                        <width>-4</width>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot1_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot1_IconFile))</visible>
                    </control>
                    <!-- LRS RatingSlot2 -->
                    <control type="image">
                        <width>52</width>
                        <height>32</height>
                        <aspectratio>keep</aspectratio>
                        <centertop>50%</centertop>
                        <texture colordiffuse="main_fg_90">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot2_IconFile)]</texture>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot2_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot2_IconFile)) + String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot2_Source),imdb)</visible>
                    </control>
                    <control type="image">
                        <width>32</width>
                        <height>32</height>
                        <aspectratio>keep</aspectratio>
                        <centertop>50%</centertop>
                        <texture colordiffuse="main_fg_90">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot2_IconFile)]</texture>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot2_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot2_IconFile)) + !String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot2_Source),imdb)</visible>
                    </control>
                    <control type="label">
                        <aligny>center</aligny>
                        <label>$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot2_Label)]</label>
                        <textcolor>main_fg_70</textcolor>
                        <font>font_main</font>
                        <width max="680">auto</width>
                        <textoffsetx>0</textoffsetx>
                        <texturefocus />
                        <texturenofocus />
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot2_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot2_IconFile))</visible>
                    </control>
                    <control type="group">
                        <width>-4</width>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot2_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot2_IconFile))</visible>
                    </control>
                    <!-- LRS RatingSlot3 -->
                    <control type="image">
                        <width>52</width>
                        <height>32</height>
                        <aspectratio>keep</aspectratio>
                        <centertop>50%</centertop>
                        <texture colordiffuse="main_fg_90">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot3_IconFile)]</texture>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot3_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot3_IconFile)) + String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot3_Source),imdb)</visible>
                    </control>
                    <control type="image">
                        <width>32</width>
                        <height>32</height>
                        <aspectratio>keep</aspectratio>
                        <centertop>50%</centertop>
                        <texture colordiffuse="main_fg_90">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot3_IconFile)]</texture>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot3_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot3_IconFile)) + !String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot3_Source),imdb)</visible>
                    </control>
                    <control type="label">
                        <aligny>center</aligny>
                        <label>$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot3_Label)]</label>
                        <textcolor>main_fg_70</textcolor>
                        <font>font_main</font>
                        <width max="680">auto</width>
                        <textoffsetx>0</textoffsetx>
                        <texturefocus />
                        <texturenofocus />
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot3_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot3_IconFile))</visible>
                    </control>
                    <control type="group">
                        <width>-4</width>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot3_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot3_IconFile))</visible>
                    </control>
                    <!-- LRS RatingSlot4 -->
                    <control type="image">
                        <width>52</width>
                        <height>32</height>
                        <aspectratio>keep</aspectratio>
                        <centertop>50%</centertop>
                        <texture colordiffuse="main_fg_90">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot4_IconFile)]</texture>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot4_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot4_IconFile)) + String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot4_Source),imdb)</visible>
                    </control>
                    <control type="image">
                        <width>32</width>
                        <height>32</height>
                        <aspectratio>keep</aspectratio>
                        <centertop>50%</centertop>
                        <texture colordiffuse="main_fg_90">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot4_IconFile)]</texture>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot4_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot4_IconFile)) + !String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot4_Source),imdb)</visible>
                    </control>
                    <control type="label">
                        <aligny>center</aligny>
                        <label>$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot4_Label)]</label>
                        <textcolor>main_fg_70</textcolor>
                        <font>font_main</font>
                        <width max="680">auto</width>
                        <textoffsetx>0</textoffsetx>
                        <texturefocus />
                        <texturenofocus />
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot4_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot4_IconFile))</visible>
                    </control>
                    <control type="group">
                        <width>-4</width>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot4_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot4_IconFile))</visible>
                    </control>
                    <!-- LRS RatingSlot5 -->
                    <control type="image">
                        <width>52</width>
                        <height>32</height>
                        <aspectratio>keep</aspectratio>
                        <centertop>50%</centertop>
                        <texture colordiffuse="main_fg_90">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot5_IconFile)]</texture>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot5_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot5_IconFile)) + String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot5_Source),imdb)</visible>
                    </control>
                    <control type="image">
                        <width>32</width>
                        <height>32</height>
                        <aspectratio>keep</aspectratio>
                        <centertop>50%</centertop>
                        <texture colordiffuse="main_fg_90">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot5_IconFile)]</texture>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot5_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot5_IconFile)) + !String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot5_Source),imdb)</visible>
                    </control>
                    <control type="label">
                        <aligny>center</aligny>
                        <label>$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot5_Label)]</label>
                        <textcolor>main_fg_70</textcolor>
                        <font>font_main</font>
                        <width max="680">auto</width>
                        <textoffsetx>0</textoffsetx>
                        <texturefocus />
                        <texturenofocus />
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot5_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot5_IconFile))</visible>
                    </control>
                    <control type="group">
                        <width>-4</width>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot5_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot5_IconFile))</visible>
                    </control>
                    <!-- LRS RatingSlot6 -->
                    <control type="image">
                        <width>52</width>
                        <height>32</height>
                        <aspectratio>keep</aspectratio>
                        <centertop>50%</centertop>
                        <texture colordiffuse="main_fg_90">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot6_IconFile)]</texture>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot6_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot6_IconFile)) + String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot6_Source),imdb)</visible>
                    </control>
                    <control type="image">
                        <width>32</width>
                        <height>32</height>
                        <aspectratio>keep</aspectratio>
                        <centertop>50%</centertop>
                        <texture colordiffuse="main_fg_90">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot6_IconFile)]</texture>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot6_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot6_IconFile)) + !String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot6_Source),imdb)</visible>
                    </control>
                    <control type="label">
                        <aligny>center</aligny>
                        <label>$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot6_Label)]</label>
                        <textcolor>main_fg_70</textcolor>
                        <font>font_main</font>
                        <width max="680">auto</width>
                        <textoffsetx>0</textoffsetx>
                        <texturefocus />
                        <texturenofocus />
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot6_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot6_IconFile))</visible>
                    </control>
                    <control type="group">
                        <width>-4</width>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot6_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot6_IconFile))</visible>
                    </control>
                    <!-- LRS Oscar -->
                    <control type="image">
                        <width>32</width>
                        <height>32</height>
                        <aspectratio>keep</aspectratio>
                        <centertop>50%</centertop>
                        <texture colordiffuse="main_fg_90">flags/$VAR[Color_Directory]/ratings/oscars.png</texture>
                        <visible>String.IsEqual(Window(Home).Property(LibraryRatings.Display.Awards),true) + String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.DBType),movie) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.Oscar_Wins))</visible>
                    </control>
                    <control type="label">
                        <aligny>center</aligny>
                        <label>$INFO[Window(Home).Property(LibraryRatings.Screensaver.Oscar_Wins),x,]</label>
                        <textcolor>main_fg_70</textcolor>
                        <font>font_main</font>
                        <width max="680">auto</width>
                        <textoffsetx>0</textoffsetx>
                        <texturefocus />
                        <texturenofocus />
                        <visible>String.IsEqual(Window(Home).Property(LibraryRatings.Display.Awards),true) + String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.DBType),movie) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.Oscar_Wins))</visible>
                    </control>
                    <control type="group">
                        <width>-4</width>
                        <visible>String.IsEqual(Window(Home).Property(LibraryRatings.Display.Awards),true) + String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.DBType),movie) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.Oscar_Wins))</visible>
                    </control>
                    <!-- LRS Emmy -->
                    <control type="image">
                        <width>32</width>
                        <height>32</height>
                        <aspectratio>keep</aspectratio>
                        <centertop>50%</centertop>
                        <texture colordiffuse="main_fg_90">flags/$VAR[Color_Directory]/ratings/emmys.png</texture>
                        <visible>String.IsEqual(Window(Home).Property(LibraryRatings.Display.Awards),true) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.Emmy_Wins))</visible>
                    </control>
                    <control type="label">
                        <aligny>center</aligny>
                        <label>$INFO[Window(Home).Property(LibraryRatings.Screensaver.Emmy_Wins),x,]</label>
                        <textcolor>main_fg_70</textcolor>
                        <font>font_main</font>
                        <width max="680">auto</width>
                        <textoffsetx>0</textoffsetx>
                        <texturefocus />
                        <texturenofocus />
                        <visible>String.IsEqual(Window(Home).Property(LibraryRatings.Display.Awards),true) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.Emmy_Wins))</visible>
                    </control>
                    <control type="group">
                        <width>-4</width>
                        <visible>String.IsEqual(Window(Home).Property(LibraryRatings.Display.Awards),true) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.Emmy_Wins))</visible>
                    </control>
                    <!-- LRS TV status -->
                    <control type="image">
                        <width>32</width>
                        <height>32</height>
                        <aspectratio>keep</aspectratio>
                        <centertop>50%</centertop>
                        <texture colordiffuse="main_fg_90">flags/$VAR[Color_Directory]/ratings/ends.png</texture>
                        <visible>String.IsEqual(Window(Home).Property(LibraryRatings.Display.TVStatus),true) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.Series_StatusLabel))</visible>
                    </control>
                    <control type="label">
                        <aligny>center</aligny>
                        <label>$INFO[Window(Home).Property(LibraryRatings.Screensaver.Series_StatusLabel)]</label>
                        <textcolor>main_fg_70</textcolor>
                        <font>font_main</font>
                        <width max="680">auto</width>
                        <textoffsetx>0</textoffsetx>
                        <texturefocus />
                        <texturenofocus />
                        <visible>String.IsEqual(Window(Home).Property(LibraryRatings.Display.TVStatus),true) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.Series_StatusLabel))</visible>
                    </control>
                    <control type="group">
                        <width>-4</width>
                        <visible>String.IsEqual(Window(Home).Property(LibraryRatings.Display.TVStatus),true) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.Series_StatusLabel))</visible>
                    </control>
                </control>
                <!-- LRS-AF3-SCREENSAVER-AF3-ROW-END-1.3.87-r3-NATIVE-PRESERVE -->
'@
$OldTitleVisible = '<visible>String.IsEmpty(Container(1297).ListItem.Art(clearlogo))</visible>'
$NewTitleVisible = '<visible>String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.CropV2Image)) + String.IsEmpty(Container(1297).ListItem.Art(clearlogo))</visible>'

function Count-Text([string]$Text, [string]$Needle) {
    return ([regex]::Matches($Text, [regex]::Escape($Needle))).Count
}

function Patch-Screensaver {
    $skin = Get-SkinPath
    $file = Join-Path $skin 'screensaver-arctic-mirage.xml'
    if (!(Test-Path $file)) { throw "File tidak ditemukan: $file" }
    $backup = $file + '.lrs-1.3.87-r3-native-preserve-backup'
    if (!(Test-Path $backup)) {
        Copy-Item -LiteralPath $file -Destination $backup -Force
        Write-Host "[OK] Backup dibuat: $backup"
    } else {
        Write-Host "[INFO] Backup sudah ada: $backup"
    }

    $t = Read-Utf8 $file
    $t = $t -replace "`r`n", "`n"

    if ($t.Contains('LRS-AF3-SCREENSAVER-AF3-ROW-START') -or $t.Contains('AFM-CROPV2-CLEARLOGO-LRS-START')) {
        throw 'File sudah punya patch LRS/CropV2 lama. Restore dulu ke screensaver asli AF3, lalu jalankan patch r3 ini. Tidak menulis file.'
    }

    $clearCount = Count-Text $t $OldClear
    $starCount = Count-Text $t $OldStar
    $titleCount = Count-Text $t $OldTitleVisible

    if ($clearCount -ne 2) { throw "Clearlogo block asli harus 2, ketemu $clearCount. Tidak menulis file." }
    if ($starCount -ne 2) { throw "Info_StarRating asli harus 2, ketemu $starCount. Tidak menulis file." }
    if ($titleCount -ne 2) { throw "Title fallback visible asli harus 2, ketemu $titleCount. Tidak menulis file." }

    $t = $t.Replace($OldTitleVisible, $NewTitleVisible)
    $t = $t.Replace($OldClear, $NewCrop)
    $t = $t.Replace($OldStar, $NewRow)

    try { [xml]$null = $t } catch { throw "XML hasil patch invalid: $($_.Exception.Message)" }

    Write-Utf8NoBom $file $t
    Write-Host '[OK] screensaver-arctic-mirage.xml patched. AF3 native effects dipertahankan.'
}

function Restore-Screensaver {
    $skin = Get-SkinPath
    $file = Join-Path $skin 'screensaver-arctic-mirage.xml'
    $backup = $file + '.lrs-1.3.87-r3-native-preserve-backup'
    if (!(Test-Path $backup)) { throw "Backup tidak ditemukan: $backup" }
    Copy-Item -LiteralPath $backup -Destination $file -Force
    Write-Host "[OK] Restored: $file"
}

function Check-Status {
    $skin = Get-SkinPath
    $file = Join-Path $skin 'screensaver-arctic-mirage.xml'
    if (!(Test-Path $file)) { throw "File tidak ditemukan: $file" }
    $t = Read-Utf8 $file
    $vignette = Count-Text $t 'vignette.png'
    $odd = Count-Text $t 'Integer.IsOdd(ListItem.CurrentItem)'
    $zoom = Count-Text $t 'effect="zoom"'
    $slide = Count-Text $t 'effect="slide"'
    $fanart = Count-Text $t 'ListItem.Art(fanart)'
    $star = Count-Text $t 'Info_StarRating'
    $cropStart = Count-Text $t 'AFM-CROPV2-CLEARLOGO-LRS-START-1.3.87-r3-NATIVE-PRESERVE'
    $cropProp = Count-Text $t 'LibraryRatings.Screensaver.CropV2Image'
    $rowStart = Count-Text $t 'LRS-AF3-SCREENSAVER-AF3-ROW-START-1.3.87-r3-NATIVE-PRESERVE'
    $slot = Count-Text $t 'LibraryRatings.Screensaver.RatingSlot1_Label'
    $titleGuard = Count-Text $t 'String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.CropV2Image)) + String.IsEmpty(Container(1297).ListItem.Art(clearlogo))'
    $xmlOk = 'YES'
    try { [xml]$null = $t } catch { $xmlOk = 'NO' }
    Write-Host ''
    Write-Host 'STATUS'
    Write-Host "  Skin path                         : $skin"
    Write-Host "  AF3 vignette preserved            : $([bool]($vignette -eq 2)) ($vignette)"
    Write-Host "  AF3 odd/even preserved            : $([bool]($odd -eq 4)) ($odd)"
    Write-Host "  AF3 fanart zoom/slide preserved   : $([bool](($zoom -eq 1) -and ($slide -eq 1) -and ($fanart -ge 1))) (zoom=$zoom slide=$slide fanart=$fanart)"
    Write-Host "  Native Info_StarRating left       : $star"
    Write-Host "  CropV2 blocks                     : $cropStart"
    Write-Host "  CropV2 property refs              : $cropProp"
    Write-Host "  LRS rating rows                   : $rowStart"
    Write-Host "  Uses Screensaver.RatingSlot       : $([bool]($slot -ge 2))"
    Write-Host "  Title fallback guard              : $titleGuard"
    Write-Host "  XML valid                         : $xmlOk"
    if (($vignette -eq 2) -and ($odd -eq 4) -and ($zoom -eq 1) -and ($slide -eq 1) -and ($fanart -ge 1) -and ($star -eq 0) -and ($cropStart -eq 2) -and ($rowStart -eq 2) -and ($titleGuard -eq 2) -and ($xmlOk -eq 'YES')) {
        Write-Host '  RESULT                            : OK - AF3 asli tetap, CropV2 + LRS kanan/kiri aktif'
    } else {
        Write-Host '  RESULT                            : CHECK - status belum sesuai target'
    }
}

function Menu {
    while ($true) {
        $skin = Get-SkinPath
        Clear-Host
        Write-Host 'AF3 LRS Screensaver Native-Preserve Fix - 1.3.87 r3'
        Write-Host '======================================================'
        Write-Host "Skin 1080i: $skin"
        Write-Host '1. Patch screensaver asli AF3: keep vignette/effects + add CropV2 + LRS rating kanan/kiri'
        Write-Host '2. Restore screensaver backup r3'
        Write-Host '3. Check screensaver patch status'
        Write-Host '4. Change skin 1080i path'
        Write-Host '5. Exit'
        $c = Read-Host 'Pilih [1-5]'
        try {
            if ($c -eq '1') { Patch-Screensaver; Read-Host 'Tekan Enter untuk kembali ke menu' }
            elseif ($c -eq '2') { Restore-Screensaver; Read-Host 'Tekan Enter untuk kembali ke menu' }
            elseif ($c -eq '3') { Check-Status; Read-Host 'Tekan Enter untuk kembali ke menu' }
            elseif ($c -eq '4') { $p = Read-Host 'Masukkan path skin 1080i'; if ($p) { Save-SkinPath $p } }
            elseif ($c -eq '5') { break }
        } catch {
            Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red
            Read-Host 'Tekan Enter untuk kembali ke menu'
        }
    }
}

Menu
