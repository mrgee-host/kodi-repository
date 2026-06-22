$ErrorActionPreference = "Stop"
$DefaultSkin1080i = "E:\Kodi\portable_data\addons\skin.arctic.fuse.3\1080i"
$Skin1080i = $DefaultSkin1080i
$PatchVersion = "1.3.91-r7"
function Read-Text($Path) { return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8) }
function Write-Text($Path, $Text) { [System.IO.File]::WriteAllText($Path, $Text, [System.Text.UTF8Encoding]::new($false)) }
function Backup-Once($Path) { $b = "$Path.lrs-1386-before"; if ((Test-Path $Path) -and !(Test-Path $b)) { Copy-Item -LiteralPath $Path -Destination $b -Force } }
function Replace-Regex($Text, $Pattern, $Replacement, $Count = 0) {
    $rx = [System.Text.RegularExpressions.Regex]::new($Pattern, ([System.Text.RegularExpressions.RegexOptions]::Singleline -bor [System.Text.RegularExpressions.RegexOptions]::Multiline))
    if ($Count -gt 0) { return $rx.Replace($Text, $Replacement, $Count) }
    return $rx.Replace($Text, $Replacement)
}
$RatingCall = @'
                    <!-- Ratings -->
                    <!-- LRS-AF3-META-CALL-START-1.3.87 -->
                    <include content="LRS_Info_Meta_Ratings">
                        <param name="visible">String.IsEqual($PARAM[container]$PARAM[listitem].DBType,movie) | String.IsEqual($PARAM[container]$PARAM[listitem].DBType,tvshow) | String.IsEqual($PARAM[container]$PARAM[listitem].DBType,season) | String.IsEqual($PARAM[container]$PARAM[listitem].DBType,episode) | $PARAM[override_movie] | $PARAM[override_tvshow] | Window.IsActive(videoosd)</param>
                        <param name="colordiffuse">main_fg</param>
                    </include>
                    <!-- LRS-AF3-META-CALL-END-1.3.87 -->
'@
$LrsIncludeDef = @'
    <!-- LRS-AF3-INCLUDE-DEF-START -->
    <!-- LRS-AF3-1.3.87: AF3-native spacing. IMDb icon_w=52, all other icons default 32. -->
    <include name="LRS_Info_Meta_Ratings">
        <param name="visible">true</param>
        <param name="colordiffuse">main_fg</param>
        <definition>
            <include content="Info_Meta_Object">
                <param name="icon">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot1_IconFile)]</param>
                <param name="label">$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot1_Label)]</param>
                <param name="visible">[$PARAM[visible]] + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot1_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot1_IconFile)) + String.IsEqual(Window(Home).Property(LibraryRatings.ListItem.RatingSlot1_Source),imdb)</param>
                <param name="colordiffuse">$PARAM[colordiffuse]</param>
                <param name="icon_w">52</param>
            </include>
            <include content="Info_Meta_Object">
                <param name="icon">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot1_IconFile)]</param>
                <param name="label">$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot1_Label)]</param>
                <param name="visible">[$PARAM[visible]] + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot1_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot1_IconFile)) + !String.IsEqual(Window(Home).Property(LibraryRatings.ListItem.RatingSlot1_Source),imdb)</param>
                <param name="colordiffuse">$PARAM[colordiffuse]</param>
            </include>
            <include content="Info_Meta_Object">
                <param name="icon">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot2_IconFile)]</param>
                <param name="label">$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot2_Label)]</param>
                <param name="visible">[$PARAM[visible]] + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot2_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot2_IconFile)) + String.IsEqual(Window(Home).Property(LibraryRatings.ListItem.RatingSlot2_Source),imdb)</param>
                <param name="colordiffuse">$PARAM[colordiffuse]</param>
                <param name="icon_w">52</param>
            </include>
            <include content="Info_Meta_Object">
                <param name="icon">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot2_IconFile)]</param>
                <param name="label">$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot2_Label)]</param>
                <param name="visible">[$PARAM[visible]] + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot2_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot2_IconFile)) + !String.IsEqual(Window(Home).Property(LibraryRatings.ListItem.RatingSlot2_Source),imdb)</param>
                <param name="colordiffuse">$PARAM[colordiffuse]</param>
            </include>
            <include content="Info_Meta_Object">
                <param name="icon">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot3_IconFile)]</param>
                <param name="label">$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot3_Label)]</param>
                <param name="visible">[$PARAM[visible]] + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot3_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot3_IconFile)) + String.IsEqual(Window(Home).Property(LibraryRatings.ListItem.RatingSlot3_Source),imdb)</param>
                <param name="colordiffuse">$PARAM[colordiffuse]</param>
                <param name="icon_w">52</param>
            </include>
            <include content="Info_Meta_Object">
                <param name="icon">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot3_IconFile)]</param>
                <param name="label">$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot3_Label)]</param>
                <param name="visible">[$PARAM[visible]] + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot3_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot3_IconFile)) + !String.IsEqual(Window(Home).Property(LibraryRatings.ListItem.RatingSlot3_Source),imdb)</param>
                <param name="colordiffuse">$PARAM[colordiffuse]</param>
            </include>
            <include content="Info_Meta_Object">
                <param name="icon">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot4_IconFile)]</param>
                <param name="label">$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot4_Label)]</param>
                <param name="visible">[$PARAM[visible]] + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot4_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot4_IconFile)) + String.IsEqual(Window(Home).Property(LibraryRatings.ListItem.RatingSlot4_Source),imdb)</param>
                <param name="colordiffuse">$PARAM[colordiffuse]</param>
                <param name="icon_w">52</param>
            </include>
            <include content="Info_Meta_Object">
                <param name="icon">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot4_IconFile)]</param>
                <param name="label">$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot4_Label)]</param>
                <param name="visible">[$PARAM[visible]] + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot4_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot4_IconFile)) + !String.IsEqual(Window(Home).Property(LibraryRatings.ListItem.RatingSlot4_Source),imdb)</param>
                <param name="colordiffuse">$PARAM[colordiffuse]</param>
            </include>
            <include content="Info_Meta_Object">
                <param name="icon">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot5_IconFile)]</param>
                <param name="label">$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot5_Label)]</param>
                <param name="visible">[$PARAM[visible]] + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot5_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot5_IconFile)) + String.IsEqual(Window(Home).Property(LibraryRatings.ListItem.RatingSlot5_Source),imdb)</param>
                <param name="colordiffuse">$PARAM[colordiffuse]</param>
                <param name="icon_w">52</param>
            </include>
            <include content="Info_Meta_Object">
                <param name="icon">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot5_IconFile)]</param>
                <param name="label">$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot5_Label)]</param>
                <param name="visible">[$PARAM[visible]] + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot5_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot5_IconFile)) + !String.IsEqual(Window(Home).Property(LibraryRatings.ListItem.RatingSlot5_Source),imdb)</param>
                <param name="colordiffuse">$PARAM[colordiffuse]</param>
            </include>
            <include content="Info_Meta_Object">
                <param name="icon">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot6_IconFile)]</param>
                <param name="label">$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot6_Label)]</param>
                <param name="visible">[$PARAM[visible]] + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot6_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot6_IconFile)) + String.IsEqual(Window(Home).Property(LibraryRatings.ListItem.RatingSlot6_Source),imdb)</param>
                <param name="colordiffuse">$PARAM[colordiffuse]</param>
                <param name="icon_w">52</param>
            </include>
            <include content="Info_Meta_Object">
                <param name="icon">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot6_IconFile)]</param>
                <param name="label">$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot6_Label)]</param>
                <param name="visible">[$PARAM[visible]] + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot6_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot6_IconFile)) + !String.IsEqual(Window(Home).Property(LibraryRatings.ListItem.RatingSlot6_Source),imdb)</param>
                <param name="colordiffuse">$PARAM[colordiffuse]</param>
            </include>
            <include content="Info_Meta_Object">
                <param name="icon">flags/$VAR[Color_Directory]/ratings/oscars.png</param>
                <param name="label">$INFO[Window(Home).Property(LibraryRatings.ListItem.Oscar_Wins),x,]</param>
                <param name="visible">[$PARAM[visible]] + String.IsEqual(Window(Home).Property(LibraryRatings.Display.Awards),true) + String.IsEqual(Window(Home).Property(LibraryRatings.ListItem.DBType),movie) + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.Oscar_Wins))</param>
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
                    <!-- AFM-CROPV2-CLEARLOGO-LRS-START-1.3.87 -->
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
                    <!-- AFM-CROPV2-CLEARLOGO-LRS-END-1.3.87 -->
'@
$ScreenRatingRow = @'
                <!-- LRS-AF3-SCREENSAVER-AF3-ROW-START-1.3.87 -->
                <control type="grouplist">
                    <orientation>horizontal</orientation>
                    <align>center</align>
                    <height>54</height>
                    <centertop>320</centertop>
                    <itemgap>12</itemgap>
                    <visible>String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.HasData),true) + String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.ClearLogoFinalTitle),Container(1297).ListItem.Title)</visible>
                    <control type="image">
                        <width>52</width><height>32</height><aspectratio>keep</aspectratio><centertop>50%</centertop>
                        <texture colordiffuse="main_fg_90">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot1_IconFile)]</texture>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot1_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot1_IconFile)) + String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot1_Source),imdb)</visible>
                    </control>
                    <control type="image">
                        <width>32</width><height>32</height><aspectratio>keep</aspectratio><centertop>50%</centertop>
                        <texture colordiffuse="main_fg_90">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot1_IconFile)]</texture>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot1_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot1_IconFile)) + !String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot1_Source),imdb)</visible>
                    </control>
                    <control type="label">
                        <aligny>center</aligny><label>$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot1_Label)]</label>
                        <textcolor>main_fg_70</textcolor><font>font_main</font>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot1_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot1_IconFile))</visible>
                        <width max="680">auto</width><textoffsetx>0</textoffsetx><texturefocus /><texturenofocus />
                    </control>
                    <control type="group"><visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot1_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot1_IconFile))</visible><width>-4</width></control>
                    <control type="image">
                        <width>52</width><height>32</height><aspectratio>keep</aspectratio><centertop>50%</centertop>
                        <texture colordiffuse="main_fg_90">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot2_IconFile)]</texture>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot2_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot2_IconFile)) + String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot2_Source),imdb)</visible>
                    </control>
                    <control type="image">
                        <width>32</width><height>32</height><aspectratio>keep</aspectratio><centertop>50%</centertop>
                        <texture colordiffuse="main_fg_90">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot2_IconFile)]</texture>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot2_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot2_IconFile)) + !String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot2_Source),imdb)</visible>
                    </control>
                    <control type="label">
                        <aligny>center</aligny><label>$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot2_Label)]</label>
                        <textcolor>main_fg_70</textcolor><font>font_main</font>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot2_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot2_IconFile))</visible>
                        <width max="680">auto</width><textoffsetx>0</textoffsetx><texturefocus /><texturenofocus />
                    </control>
                    <control type="group"><visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot2_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot2_IconFile))</visible><width>-4</width></control>
                    <control type="image">
                        <width>52</width><height>32</height><aspectratio>keep</aspectratio><centertop>50%</centertop>
                        <texture colordiffuse="main_fg_90">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot3_IconFile)]</texture>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot3_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot3_IconFile)) + String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot3_Source),imdb)</visible>
                    </control>
                    <control type="image">
                        <width>32</width><height>32</height><aspectratio>keep</aspectratio><centertop>50%</centertop>
                        <texture colordiffuse="main_fg_90">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot3_IconFile)]</texture>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot3_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot3_IconFile)) + !String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot3_Source),imdb)</visible>
                    </control>
                    <control type="label">
                        <aligny>center</aligny><label>$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot3_Label)]</label>
                        <textcolor>main_fg_70</textcolor><font>font_main</font>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot3_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot3_IconFile))</visible>
                        <width max="680">auto</width><textoffsetx>0</textoffsetx><texturefocus /><texturenofocus />
                    </control>
                    <control type="group"><visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot3_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot3_IconFile))</visible><width>-4</width></control>
                    <control type="image">
                        <width>52</width><height>32</height><aspectratio>keep</aspectratio><centertop>50%</centertop>
                        <texture colordiffuse="main_fg_90">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot4_IconFile)]</texture>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot4_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot4_IconFile)) + String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot4_Source),imdb)</visible>
                    </control>
                    <control type="image">
                        <width>32</width><height>32</height><aspectratio>keep</aspectratio><centertop>50%</centertop>
                        <texture colordiffuse="main_fg_90">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot4_IconFile)]</texture>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot4_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot4_IconFile)) + !String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot4_Source),imdb)</visible>
                    </control>
                    <control type="label">
                        <aligny>center</aligny><label>$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot4_Label)]</label>
                        <textcolor>main_fg_70</textcolor><font>font_main</font>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot4_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot4_IconFile))</visible>
                        <width max="680">auto</width><textoffsetx>0</textoffsetx><texturefocus /><texturenofocus />
                    </control>
                    <control type="group"><visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot4_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot4_IconFile))</visible><width>-4</width></control>
                    <control type="image">
                        <width>52</width><height>32</height><aspectratio>keep</aspectratio><centertop>50%</centertop>
                        <texture colordiffuse="main_fg_90">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot5_IconFile)]</texture>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot5_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot5_IconFile)) + String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot5_Source),imdb)</visible>
                    </control>
                    <control type="image">
                        <width>32</width><height>32</height><aspectratio>keep</aspectratio><centertop>50%</centertop>
                        <texture colordiffuse="main_fg_90">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot5_IconFile)]</texture>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot5_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot5_IconFile)) + !String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot5_Source),imdb)</visible>
                    </control>
                    <control type="label">
                        <aligny>center</aligny><label>$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot5_Label)]</label>
                        <textcolor>main_fg_70</textcolor><font>font_main</font>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot5_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot5_IconFile))</visible>
                        <width max="680">auto</width><textoffsetx>0</textoffsetx><texturefocus /><texturenofocus />
                    </control>
                    <control type="group"><visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot5_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot5_IconFile))</visible><width>-4</width></control>
                    <control type="image">
                        <width>52</width><height>32</height><aspectratio>keep</aspectratio><centertop>50%</centertop>
                        <texture colordiffuse="main_fg_90">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot6_IconFile)]</texture>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot6_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot6_IconFile)) + String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot6_Source),imdb)</visible>
                    </control>
                    <control type="image">
                        <width>32</width><height>32</height><aspectratio>keep</aspectratio><centertop>50%</centertop>
                        <texture colordiffuse="main_fg_90">flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot6_IconFile)]</texture>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot6_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot6_IconFile)) + !String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot6_Source),imdb)</visible>
                    </control>
                    <control type="label">
                        <aligny>center</aligny><label>$INFO[Window(Home).Property(LibraryRatings.Screensaver.RatingSlot6_Label)]</label>
                        <textcolor>main_fg_70</textcolor><font>font_main</font>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot6_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot6_IconFile))</visible>
                        <width max="680">auto</width><textoffsetx>0</textoffsetx><texturefocus /><texturenofocus />
                    </control>
                    <control type="group"><visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot6_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.RatingSlot6_IconFile))</visible><width>-4</width></control>
                    <control type="image">
                        <width>32</width><height>32</height><aspectratio>keep</aspectratio><centertop>50%</centertop>
                        <texture colordiffuse="main_fg_90">flags/$VAR[Color_Directory]/ratings/oscars.png</texture>
                        <visible>String.IsEqual(Window(Home).Property(LibraryRatings.Display.Awards),true) + String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.DBType),movie) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.Oscar_Wins))</visible>
                    </control>
                    <control type="label">
                        <aligny>center</aligny><label>$INFO[Window(Home).Property(LibraryRatings.Screensaver.Oscar_Wins),x,]</label>
                        <textcolor>main_fg_70</textcolor><font>font_main</font>
                        <visible>String.IsEqual(Window(Home).Property(LibraryRatings.Display.Awards),true) + String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.DBType),movie) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.Oscar_Wins))</visible>
                        <width max="680">auto</width><textoffsetx>0</textoffsetx><texturefocus /><texturenofocus />
                    </control>
                    <control type="group"><visible>String.IsEqual(Window(Home).Property(LibraryRatings.Display.Awards),true) + String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.DBType),movie) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.Oscar_Wins))</visible><width>-4</width></control>
                    <control type="image">
                        <width>32</width><height>32</height><aspectratio>keep</aspectratio><centertop>50%</centertop>
                        <texture colordiffuse="main_fg_90">flags/$VAR[Color_Directory]/ratings/emmys.png</texture>
                        <visible>String.IsEqual(Window(Home).Property(LibraryRatings.Display.Awards),true) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.Emmy_Wins))</visible>
                    </control>
                    <control type="label">
                        <aligny>center</aligny><label>$INFO[Window(Home).Property(LibraryRatings.Screensaver.Emmy_Wins),x,]</label>
                        <textcolor>main_fg_70</textcolor><font>font_main</font>
                        <visible>String.IsEqual(Window(Home).Property(LibraryRatings.Display.Awards),true) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.Emmy_Wins))</visible>
                        <width max="680">auto</width><textoffsetx>0</textoffsetx><texturefocus /><texturenofocus />
                    </control>
                    <control type="group"><visible>String.IsEqual(Window(Home).Property(LibraryRatings.Display.Awards),true) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.Emmy_Wins))</visible><width>-4</width></control>
                    <control type="image">
                        <width>32</width><height>32</height><aspectratio>keep</aspectratio><centertop>50%</centertop>
                        <texture colordiffuse="main_fg_90">flags/$VAR[Color_Directory]/ratings/ends.png</texture>
                        <visible>String.IsEqual(Window(Home).Property(LibraryRatings.Display.TVStatus),true) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.Series_StatusLabel))</visible>
                    </control>
                    <control type="label">
                        <aligny>center</aligny><label>$INFO[Window(Home).Property(LibraryRatings.Screensaver.Series_StatusLabel)]</label>
                        <textcolor>main_fg_70</textcolor><font>font_main</font>
                        <visible>String.IsEqual(Window(Home).Property(LibraryRatings.Display.TVStatus),true) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.Series_StatusLabel))</visible>
                        <width max="680">auto</width><textoffsetx>0</textoffsetx><texturefocus /><texturenofocus />
                    </control>
                    <control type="group"><visible>String.IsEqual(Window(Home).Property(LibraryRatings.Display.TVStatus),true) + !String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.Series_StatusLabel))</visible><width>-4</width></control>
                </control>
                <!-- LRS-AF3-SCREENSAVER-AF3-ROW-END-1.3.87 -->
'@
function Patch-IncludesInfo {
    $path = Join-Path $Skin1080i "Includes_Info.xml"
    if (!(Test-Path $path)) { Write-Host "[ERROR] Not found: $path"; return }
    Backup-Once $path
    $t = Read-Text $path
    $t = Replace-Regex $t '\s*<!-- LRS-AF3-INCLUDE-DEF-START -->.*?<!-- LRS-AF3-INCLUDE-DEF-END -->\s*' "`r`n"
    $ratingPattern = '(?ms)^\s*<!-- Ratings -->.*?(?=^\s*<!-- Total Episodes)'
    if ([regex]::IsMatch($t, $ratingPattern)) { $t = Replace-Regex $t $ratingPattern $RatingCall 1 } else { $t = $t.Replace('                    <!-- Total Episodes', $RatingCall + '                    <!-- Total Episodes') }
    $t = Replace-Regex $t '(?ms)^\s*<!-- Status -->\s*
?
\s*<include content="Info_Meta_Object" condition="\$EXP\[Exp_TMDbHelper_IsData\]">.*?</include>\s*
?
\s*<!-- Awards -->\s*
?
\s*<include content="Info_Meta_Object" condition="\$EXP\[Exp_TMDbHelper_IsData\][^"]*">.*?</include>\s*' '                    <!-- LRS-AF3-NATIVE-STATUS-AWARDS-DISABLED-1.3.87 -->' 1
    $t = Replace-Regex $t '(?ms)^\s*<!-- Status -->\s*
?
\s*<include content="Info_Meta_Object" condition="\$EXP\[Exp_TMDbHelper_IsData\]">.*?</include>\s*' '                    <!-- LRS-AF3-NATIVE-STATUS-DISABLED-1.3.87 -->' 1
    $t = Replace-Regex $t '(?ms)^\s*<!-- Awards -->\s*
?
\s*<include content="Info_Meta_Object" condition="\$EXP\[Exp_TMDbHelper_IsData\][^"]*">.*?</include>\s*' '                    <!-- LRS-AF3-NATIVE-AWARDS-DISABLED-1.3.87 -->' 1
    if ($t.Contains('</includes>')) { $t = $t.Replace('</includes>', $LrsIncludeDef + "`r`n</includes>") } else { throw "Includes_Info.xml tidak punya </includes>" }
    Write-Text $path $t
    Write-Host "[OK] Includes_Info.xml patched"
}
function Remove-IncludesInfoPatch {
    $path = Join-Path $Skin1080i "Includes_Info.xml"
    if (!(Test-Path $path)) { Write-Host "[ERROR] Not found: $path"; return }
    Backup-Once $path
    $t = Read-Text $path
    $t = Replace-Regex $t '\s*<!-- LRS-AF3-INCLUDE-DEF-START -->.*?<!-- LRS-AF3-INCLUDE-DEF-END -->\s*' "`r`n"
    $t = Replace-Regex $t '(?ms)^\s*<!-- Ratings -->\s*
?
\s*<!-- LRS-AF3-META-CALL-START[^>]*-->.*?<!-- LRS-AF3-META-CALL-END[^>]*-->\s*' '                    <!-- Ratings -->' 1
    Write-Text $path $t
    Write-Host "[OK] LRS Includes_Info blocks removed. Native rows are not restored; use skin reinstall/backup to restore native rows."
}
function Patch-IncludesHubs {
    $path = Join-Path $Skin1080i "Includes_Hubs.xml"
    if (!(Test-Path $path)) { Write-Host "[WARN] Not found: $path"; return }
    Backup-Once $path
    $lines = (Read-Text $path) -split "`r?`n"
    $out = New-Object System.Collections.Generic.List[string]
    $anchors = 0
    foreach($line in $lines) {
        if($line -match 'LRS-AF3-ACTIVE-BRIDGE') { continue }
        if($line -match 'LRS\.Active\.ContainerID') { continue }
        $out.Add($line)
        if($line -match '<on(focus|load)' -and $line -match 'SetProperty\(TMDbHelper\.WidgetContainer') {
            $anchors++
            $indent = ([regex]::Match($line, '^\s*')).Value
            $newLine = $line.Replace('TMDbHelper.WidgetContainer','LRS.Active.ContainerID').Replace('Property(TMDbHelper.WidgetContainer)','Property(LRS.Active.ContainerID)')
            $out.Add($indent + '<!-- LRS-AF3-ACTIVE-BRIDGE-1.3.87 -->')
            $out.Add($newLine)
        }
    }
    $new = [string]::Join("`r`n", $out)
    $needle = '<ondown>SetFocus($INFO[Container(601).ListItem.Property(widget_id)])</ondown>'
    $selector = $needle + "`r`n                    <!-- LRS-AF3-ACTIVE-BRIDGE-1.3.87 -->`r`n                    <onfocus condition=`"!String.IsEmpty(Container(601).ListItem.Property(widget_id))`">SetProperty(LRS.Active.ContainerID,`$INFO[Container(601).ListItem.Property(widget_id)])</onfocus>"
    if($new -notmatch 'SetProperty\(LRS\.Active\.ContainerID,\$INFO\[Container\(601\)') {
        if($new.Contains($needle)) {
            $new = $new.Replace($needle, $selector)
        } elseif($new -match 'Container\(601\)\.ListItem\.Property\(widget_id\)') {
            $new = Replace-Regex $new '(?m)^(\s*<on[^>]+Container\(601\)\.ListItem\.Property\(widget_id\).*?</on[^>]+>)' ('$1' + "`r`n                    <!-- LRS-AF3-ACTIVE-BRIDGE-1.3.87 -->`r`n                    <onfocus condition=`"!String.IsEmpty(Container(601).ListItem.Property(widget_id))`">SetProperty(LRS.Active.ContainerID,`$INFO[Container(601).ListItem.Property(widget_id)])</onfocus>") 1
        }
    }
    Write-Text $path $new
    $lrsCount = ([regex]::Matches($new, 'SetProperty\(LRS\.Active\.ContainerID')).Count
    Write-Host "[OK] Includes_Hubs.xml bridge rebuilt: TMDb anchors=$anchors, LRS bridge lines=$lrsCount"
}
function Remove-IncludesHubsPatch {
    $path = Join-Path $Skin1080i "Includes_Hubs.xml"
    if (!(Test-Path $path)) { Write-Host "[WARN] Not found: $path"; return }
    Backup-Once $path
    $lines = (Read-Text $path) -split "`r?`n"
    $out = New-Object System.Collections.Generic.List[string]
    foreach($line in $lines) {
        if($line -match 'LRS-AF3-ACTIVE-BRIDGE') { continue }
        if($line -match 'LRS\.Active\.ContainerID') { continue }
        $out.Add($line)
    }
    Write-Text $path ([string]::Join("`r`n", $out))
    Write-Host "[OK] Includes_Hubs LRS bridge lines removed"
}
function Patch-Screensaver {
    $path = Join-Path $Skin1080i "screensaver-arctic-mirage.xml"
    if (!(Test-Path $path)) { Write-Host "[ERROR] Not found: $path"; return }
    Backup-Once $path
    $t = Read-Text $path
    $t = Replace-Regex $t '\s*<!-- LRS-AF3-SCREENSAVER-INLINE-START[^>]*-->.*?<!-- LRS-AF3-SCREENSAVER-INLINE-END[^>]*-->\s*' "`r`n"
    $t = Replace-Regex $t '\s*<!-- LRS-AF3-SCREENSAVER-AF3-ROW-START[^>]*-->.*?<!-- LRS-AF3-SCREENSAVER-AF3-ROW-END[^>]*-->\s*' "`r`n"
    $t = Replace-Regex $t '\s*<control type="grouplist"[^>]*>\s*<orientation>horizontal</orientation>.*?<include content="LRS_Info_Meta_Ratings">.*?</include>\s*</control>\s*' "`r`n"
    $t = Replace-Regex $t '\s*<!-- AFM-CROPV2-CLEARLOGO-LRS-START[^>]*-->.*?<!-- AFM-CROPV2-CLEARLOGO-LRS-END[^>]*-->\s*' ("`r`n" + $CropBlock + "`r`n")
    $t = Replace-Regex $t '\s*<control type="image">\s*<texture background="true">\$INFO\[Container\(1297\)\.ListItem\.Art\(clearlogo\)\]</texture>\s*<aspectratio aligny="bottom">keep</aspectratio>\s*<visible>!String.IsEmpty\(Container\(1297\)\.ListItem\.Art\(clearlogo\)\)</visible>\s*</control>' ("`r`n" + $CropBlock)
    $t = $t.Replace('<visible>String.IsEmpty(Container(1297).ListItem.Art(clearlogo))</visible>', '<visible>String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.CropV2Image)) + String.IsEmpty(Container(1297).ListItem.Art(clearlogo))</visible>')
    $pattern = '(<!-- AFM-CROPV2-CLEARLOGO-LRS-END[^>]*-->\s*
?
\s*</control>)'
    if([regex]::IsMatch($t, $pattern)) {
        $t = Replace-Regex $t $pattern ('$1' + "`r`n" + $ScreenRatingRow) 1
    } elseif($t.Contains('</controls>')) {
        $t = $t.Replace('</controls>', $ScreenRatingRow + "`r`n    </controls>")
    } else { throw "screensaver XML tidak punya anchor rating row atau </controls>" }
    Write-Text $path $t
    Write-Host "[OK] screensaver-arctic-mirage.xml patched"
}
function Remove-ScreensaverPatch {
    $path = Join-Path $Skin1080i "screensaver-arctic-mirage.xml"
    if (!(Test-Path $path)) { Write-Host "[ERROR] Not found: $path"; return }
    Backup-Once $path
    $t = Read-Text $path
    $t = Replace-Regex $t '\s*<!-- LRS-AF3-SCREENSAVER-INLINE-START[^>]*-->.*?<!-- LRS-AF3-SCREENSAVER-INLINE-END[^>]*-->\s*' "`r`n"
    $t = Replace-Regex $t '\s*<!-- LRS-AF3-SCREENSAVER-AF3-ROW-START[^>]*-->.*?<!-- LRS-AF3-SCREENSAVER-AF3-ROW-END[^>]*-->\s*' "`r`n"
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
        $imdb52 = (([regex]::Matches($t, '(?s)RatingSlot[0-9]_Source\),imdb\).*?<param name="icon_w">52</param>')).Count -ge 6)
        $wrong52 = ($t -match 'oscars\.png[\s\S]*?<param name="icon_w">52</param>') -or ($t -match 'emmys\.png[\s\S]*?<param name="icon_w">52</param>')
        $nativeRatings = [regex]::Matches($t, '<include content="Info_Meta_Ratings" condition="\$EXP\[Exp_TMDbHelper_IsData\]"').Count
        $nativeStatus = ($t -match 'TMDbHelper\.\$PARAM\[service\]\.Status')
        $nativeAwards = ($t -match 'TMDbHelper\.\$PARAM\[service\]\.Oscar_Wins')
        $icons = ($t -match 'oscars\.png') -and ($t -match 'emmys\.png') -and ($t -notmatch 'goldenglobe\.png')
        Write-Host "  Includes LRS slot 1-6      : $(if($slots){'YES'}else{'NO'})"
        Write-Host "  IMDb-only icon_w 52        : $(if($imdb52 -and -not $wrong52){'YES'}else{'NO'})"
        Write-Host "  Native rating calls left   : $nativeRatings"
        Write-Host "  Native status left         : $(if($nativeStatus){'YES'}else{'NO'})"
        Write-Host "  Native awards left         : $(if($nativeAwards){'YES'}else{'NO'})"
        Write-Host "  Awards icons oscars/emmys  : $(if($icons){'YES'}else{'NO'})"
    }
    if (Test-Path $hubPath) {
        $h = Read-Text $hubPath
        $tmdbAnchors = ([regex]::Matches($h, 'SetProperty\(TMDbHelper\.WidgetContainer')).Count
        $lrsLines = ([regex]::Matches($h, 'SetProperty\(LRS\.Active\.ContainerID')).Count
        $selector = ($h -match 'SetProperty\(LRS\.Active\.ContainerID,\$INFO\[Container\(601\)\.ListItem\.Property\(widget_id\)\]')
        $spotlightButton = ($h -match 'SetProperty\(LRS\.Active\.ContainerID,301,\$PARAM\[window\]\)')
        Write-Host "  Hub TMDb anchors           : $tmdbAnchors"
        Write-Host "  Hub LRS bridge lines       : $lrsLines"
        Write-Host "  Hub selector 601 bridge    : $(if($selector){'YES'}else{'NO'})"
        Write-Host "  Hub spotlight 301 bridge   : $(if($spotlightButton){'YES'}else{'NO'})"
        Write-Host "  Includes_Hubs active bridge: $(if(($lrsLines -ge $tmdbAnchors) -and $selector -and $spotlightButton){'YES'}else{'NO'})"
    }
    if (Test-Path $ssPath) {
        $s = Read-Text $ssPath
        Write-Host "  Screensaver plot preserved : $(if($s -match 'Container\(1297\)\.ListItem\.Plot'){'YES'}else{'NO'})"
        Write-Host "  Screensaver final logo prop: $(if($s -match 'LibraryRatings\.Screensaver\.ClearLogoFinal'){'YES'}else{'NO'})"
        Write-Host "  Screensaver uses SS props  : $(if($s -match 'LibraryRatings\.Screensaver\.RatingSlot1_Label' -and $s -notmatch 'LibraryRatings\.ListItem\.HasData'){'YES'}else{'NO'})"
        Write-Host "  Screensaver itemgap 12     : $(if($s -match '<itemgap>12</itemgap>'){'YES'}else{'NO'})"
        Write-Host "  Screensaver fixed 150 left : $(if($s -match '<width>150</width>' -or $s -match 'LRS_Info_Meta_Ratings'){'YES'}else{'NO'})"
        Write-Host "  Direct default fallback left: $(if($s -match 'String.IsEmpty\(Window\(Home\)\.Property\(LibraryRatings\.Screensaver\.CropV2Image\)\) \+ !String.IsEmpty\(Container\(1297\)\.ListItem\.Art\(clearlogo\)\)'){'YES'}else{'NO'})"
    }
}
function Patch-All { Patch-IncludesInfo; Patch-IncludesHubs; Patch-Screensaver; Check-Status }
function Remove-All { Remove-IncludesInfoPatch; Remove-IncludesHubsPatch; Remove-ScreensaverPatch; Check-Status }

# -----------------------------------------------------------------------------
# LRS 1.3.91-r5 merged screensaver final clearlogo fix
# - merged into full PATCH-AF3-LRS-1.3.87-FIX patcher
# - preserves AF3 native vignette / fanart zoom / slide / odd-even layout
# - replaces native Info_StarRating on both sides with LRS row
# - uses one final clearlogo property on both sides; no direct default fallback in XML
# - lowers rating row to centertop 332
# - disables plot textbox autoscroll only; does NOT disable list item cycling
# -----------------------------------------------------------------------------
$R4_OldClear = @'
                    <control type="image">
                        <texture background="true">$INFO[Container(1297).ListItem.Art(clearlogo)]</texture>
                        <aspectratio aligny="bottom">keep</aspectratio>
                        <visible>!String.IsEmpty(Container(1297).ListItem.Art(clearlogo))</visible>
                    </control>
'@
$R4_NewCrop = @'
                    <!-- AFM-CLEARLOGO-FINAL-LRS-START-1.3.91-r7 -->
                    <control type="image">
                        <texture background="true">$INFO[Window(Home).Property(LibraryRatings.Screensaver.ClearLogoFinal)]</texture>
                        <aspectratio aligny="bottom">keep</aspectratio>
                        <visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.ClearLogoFinal)) + String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.ClearLogoFinalTitle),Container(1297).ListItem.Title)</visible>
                    </control>
                    <!-- AFM-CLEARLOGO-FINAL-LRS-END-1.3.91-r7 -->
'@
$R4_OldStar = @'
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
$R4_NewRow = @'
                <!-- LRS-AF3-SCREENSAVER-AF3-ROW-START-1.3.87-r4-MERGED -->
                <control type="grouplist">
                    <orientation>horizontal</orientation>
                    <align>center</align>
                    <height>54</height>
                    <centertop>332</centertop>
                    <itemgap>12</itemgap>
                    <visible>String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.HasData),true) + String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.ClearLogoFinalTitle),Container(1297).ListItem.Title)</visible>
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
                <!-- LRS-AF3-SCREENSAVER-AF3-ROW-END-1.3.87-r4-MERGED -->
'@
$R4_OldTitleVisible = @'
<visible>String.IsEmpty(Container(1297).ListItem.Art(clearlogo))</visible>
'@
$R4_NewTitleVisible = @'
<visible>String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.ClearLogoFinalMode),title) + String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.ClearLogoFinalTitle),Container(1297).ListItem.Title)</visible>
'@
$R4_OldPlotBox = @'
            <control type="textbox">
                <font>font_main_plot</font>
                <textcolor>main_fg_70</textcolor>
                <label>$INFO[Container(1297).ListItem.Plot]</label>
                <bottom>view_pad</bottom>
                <height>120</height>
                <align>center</align>
            </control>
'@
$R4_NewPlotBox = @'
            <control type="textbox">
                <font>font_main_plot</font>
                <textcolor>main_fg_70</textcolor>
                <label>$INFO[Container(1297).ListItem.Plot]</label>
                <bottom>view_pad</bottom>
                <height>120</height>
                <align>center</align>
                <autoscroll>false</autoscroll>
            </control>
'@

function R4-ToLF([string]$Text) {
    return $Text.Replace("`r`n", "`n").Replace("`r", "`n")
}
function R4-CountLiteral([string]$Text, [string]$Needle) {
    return ([regex]::Matches($Text, [regex]::Escape($Needle))).Count
}
function R4-NormalizeTemplate([string]$Text) {
    return (R4-ToLF $Text).Trim("`n")
}
function R4-NormalizeScreensaver([string]$Text) {
    $t = R4-ToLF $Text
    $oldClear = R4-NormalizeTemplate $R4_OldClear
    $oldTitle = (R4-NormalizeTemplate $R4_OldTitleVisible)
    $newTitle = (R4-NormalizeTemplate $R4_NewTitleVisible)
    # Revert any previous LRS/CropV2 clearlogo block back to the native clearlogo block first.
    $t = [regex]::Replace($t, '(?s)\s*<!-- AFM-(?:CROPV2-CLEARLOGO|CLEARLOGO-FINAL)-LRS-START.*?<!-- AFM-(?:CROPV2-CLEARLOGO|CLEARLOGO-FINAL)-LRS-END.*?-->\s*', "`n" + $oldClear + "`n")
    # Remove any previous LRS screensaver rating rows.
    $t = [regex]::Replace($t, '(?s)\s*<!-- LRS-AF3-SCREENSAVER-INLINE-START.*?<!-- LRS-AF3-SCREENSAVER-INLINE-END.*?-->\s*', "`n")
    # Keep old accidental include row variants for Patch-Screensaver; they can be replaced with the new row there.
    # Reset title fallback visible condition before applying CropV2 condition again.
    $t = $t.Replace($newTitle, $oldTitle)
    $t = $t.Replace('<visible>String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.CropV2Image)) + String.IsEmpty(Container(1297).ListItem.Art(clearlogo))</visible>', $oldTitle)
    return $t
}
$R7_ProgressActive = 'Window.IsActive(extendedprogressdialog) | Window.IsVisible(extendedprogressdialog) | Window.IsActive(progressdialog) | Window.IsVisible(progressdialog) | Window.IsActive(dialogprogress) | Window.IsVisible(dialogprogress)'
$R7_ProgressInactive = '!Window.IsActive(extendedprogressdialog) + !Window.IsVisible(extendedprogressdialog) + !Window.IsActive(progressdialog) + !Window.IsVisible(progressdialog) + !Window.IsActive(dialogprogress) + !Window.IsVisible(dialogprogress)'
$R7_LeftVisible = "<visible>$R7_ProgressActive | !Integer.IsOdd(ListItem.CurrentItem)</visible>"
$R7_RightVisible = "<visible>$R7_ProgressInactive + Integer.IsOdd(ListItem.CurrentItem)</visible>"
$R7_LeftBase = '<visible>!Integer.IsOdd(ListItem.CurrentItem)</visible>'
$R7_RightBase = '<visible>Integer.IsOdd(ListItem.CurrentItem)</visible>'
$R7_R5MismatchTitle = '<visible>String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.ClearLogoFinal)) | !String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.ClearLogoFinalTitle),Container(1297).ListItem.Title)</visible>'
$R7_StrictTitle = '<visible>String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.ClearLogoFinalMode),title) + String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.ClearLogoFinalTitle),Container(1297).ListItem.Title)</visible>'
$R7_PlainRating = '<visible>String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.HasData),true)</visible>'
$R7_OldTitleRating = '<visible>String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.HasData),true) + String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.Title),Container(1297).ListItem.Title)</visible>'
$R7_GuardRating = '<visible>String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.HasData),true) + String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.ClearLogoFinalTitle),Container(1297).ListItem.Title)</visible>'
function R7-ApplyStrictTitleProgressLeft([string]$Text) {
    $t = R4-ToLF $Text
    # Strict title: title only appears when addon explicitly chose final mode=title for current item.
    $t = $t.Replace($R7_R5MismatchTitle, $R7_StrictTitle)
    # Rating row must also match the current screensaver item, so old item ratings do not flash during transitions.
    $t = $t.Replace($R7_PlainRating, $R7_GuardRating)
    $t = $t.Replace($R7_OldTitleRating, $R7_GuardRating)
    # Normalize previous progress-left patch first, then reapply. Idempotent.
    $t = $t.Replace($R7_LeftVisible, $R7_LeftBase)
    $t = $t.Replace($R7_RightVisible, $R7_RightBase)
    $t = $t.Replace($R7_LeftBase, $R7_LeftVisible)
    $t = $t.Replace($R7_RightBase, $R7_RightVisible)
    return $t
}
function Patch-Screensaver {
    $path = Join-Path $Skin1080i "screensaver-arctic-mirage.xml"
    if (!(Test-Path $path)) { Write-Host "[ERROR] Not found: $path"; return }
    $backup = "$path.lrs-1.3.87-r4-merged-backup"
    if (!(Test-Path $backup)) {
        Copy-Item -LiteralPath $path -Destination $backup -Force
        Write-Host "[OK] Backup dibuat: $backup"
    } else {
        Write-Host "[INFO] Backup sudah ada: $backup"
    }

    $oldClear = R4-NormalizeTemplate $R4_OldClear
    $newCrop = R4-NormalizeTemplate $R4_NewCrop
    $oldStar  = R4-NormalizeTemplate $R4_OldStar
    $newRow   = R4-NormalizeTemplate $R4_NewRow
    $oldTitle = R4-NormalizeTemplate $R4_OldTitleVisible
    $newTitle = R4-NormalizeTemplate $R4_NewTitleVisible
    $oldPlot  = R4-NormalizeTemplate $R4_OldPlotBox
    $newPlot  = R4-NormalizeTemplate $R4_NewPlotBox

    $t = Read-Text $path
    $t = R4-NormalizeScreensaver $t

    $clearCount = R4-CountLiteral $t $oldClear
    $oddBefore = ([regex]::Matches($t, 'Integer\.IsOdd\(ListItem\.CurrentItem\)')).Count
    $expectedSides = $(if ($oddBefore -ge 4) { 2 } else { 1 })
    if ($clearCount -ne $expectedSides) { throw "Clearlogo native block harus $expectedSides sesuai layout aktif, ketemu $clearCount. Tidak menulis file." }
    $starCount = R4-CountLiteral $t $oldStar
    $existingRows = ([regex]::Matches($t, 'LRS-AF3-SCREENSAVER-AF3-ROW-START')).Count
    $includeRows = ([regex]::Matches($t, '(?s)<control type="grouplist"[^>]*>\s*<orientation>horizontal</orientation>.*?<include content="LRS_Info_Meta_Ratings">.*?</include>\s*</control>')).Count
    if ($starCount -gt 0 -and $starCount -ne $expectedSides) { throw "Info_StarRating asli harus $expectedSides atau 0, ketemu $starCount. Tidak menulis file." }
    if ($starCount -eq 0 -and $existingRows -lt $expectedSides -and $includeRows -lt $expectedSides) { throw "Info_StarRating sudah tidak ada tapi LRS row belum lengkap ($existingRows/$expectedSides), includeRows=$includeRows. Restore screensaver asli/r4 atau kirim XML. Tidak menulis file." }

    $t = $t.Replace($oldClear, $newCrop)
    if ($starCount -gt 0) { $t = $t.Replace($oldStar, $newRow) }
    if ($includeRows -gt 0) { $t = [regex]::Replace($t, '(?s)\s*<control type="grouplist"[^>]*>\s*<orientation>horizontal</orientation>.*?<include content="LRS_Info_Meta_Ratings">.*?</include>\s*</control>\s*', "`n" + $newRow + "`n") }
    $t = $t.Replace($oldTitle, $newTitle)
    $plotBefore = R4-CountLiteral $t $oldPlot
    if ($plotBefore -gt 0) { $t = $t.Replace($oldPlot, $newPlot) }
    $t = R7-ApplyStrictTitleProgressLeft $t

    # Strict validation before writing.
    $finalCount = ([regex]::Matches($t, 'AFM-CLEARLOGO-FINAL-LRS-START-1\.3\.91-r7')).Count
    $rowCount = ([regex]::Matches($t, 'LRS-AF3-SCREENSAVER-AF3-ROW-START')).Count
    $starLeft = ([regex]::Matches($t, 'Info_StarRating')).Count
    $vignette = ([regex]::Matches($t, 'vignette\.png')).Count
    $odd = ([regex]::Matches($t, 'Integer\.IsOdd\(ListItem\.CurrentItem\)')).Count
    $expectedRows = $(if ($odd -ge 4) { 2 } else { 1 })
    $noScroll = ([regex]::Matches($t, '<autoscroll>false</autoscroll>')).Count
    $strictTitle = ([regex]::Matches($t, [regex]::Escape($R7_StrictTitle))).Count
    $oldMismatchTitle = ([regex]::Matches($t, [regex]::Escape($R7_R5MismatchTitle))).Count
    $ratingGuard = ([regex]::Matches($t, [regex]::Escape($R7_GuardRating))).Count
    $leftProgress = ([regex]::Matches($t, [regex]::Escape($R7_LeftVisible))).Count
    $rightProgress = ([regex]::Matches($t, [regex]::Escape($R7_RightVisible))).Count
    $directFallback = ($t -match 'Container\(1297\)\.ListItem\.Art\(clearlogo\).*LibraryRatings\.Screensaver\.CropV2Image') -or ($t -match 'String\.IsEmpty\(Window\(Home\)\.Property\(LibraryRatings\.Screensaver\.CropV2Image\)\) \+ !String\.IsEmpty\(Container\(1297\)\.ListItem\.Art\(clearlogo\)\)')
    if ($finalCount -ne $expectedRows -or $rowCount -lt $expectedRows -or $starLeft -ne 0 -or ($expectedRows -eq 2 -and ($vignette -lt 2 -or $odd -lt 4 -or $noScroll -lt 2 -or $strictTitle -lt 2 -or $ratingGuard -lt 2 -or $leftProgress -lt 2 -or $rightProgress -lt 2)) -or $oldMismatchTitle -ne 0 -or $directFallback) {
        throw "Validasi gagal. final=$finalCount row=$rowCount expected=$expectedRows starLeft=$starLeft vignette=$vignette odd=$odd plotNoScroll=$noScroll strictTitle=$strictTitle ratingGuard=$ratingGuard leftProgress=$leftProgress rightProgress=$rightProgress directFallback=$directFallback. Tidak menulis file."
    }
    [xml]$null = $t
    Write-Text $path ($t.Replace("`n", "`r`n"))
    Write-Host "[OK] screensaver-arctic-mirage.xml patched r7: AF3 asli tetap, final clearlogo, strict title, progress dialog forces left"
}
function Remove-ScreensaverPatch {
    $path = Join-Path $Skin1080i "screensaver-arctic-mirage.xml"
    if (!(Test-Path $path)) { Write-Host "[ERROR] Not found: $path"; return }
    $backup = "$path.lrs-1.3.87-r4-merged-backup"
    if (Test-Path $backup) {
        Copy-Item -LiteralPath $backup -Destination $path -Force
        Write-Host "[OK] screensaver restored from r4 backup: $backup"
        return
    }
    Write-Host "[WARN] Backup r4 tidak ada. Restore manual dari backup AF3 asli kalau ingin menghapus patch screensaver."
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
        $imdb52 = (([regex]::Matches($t, '(?s)RatingSlot[0-9]_Source\),imdb\).*?<param name="icon_w">52</param>')).Count -ge 6)
        $wrong52 = ($t -match 'oscars\.png[\s\S]*?<param name="icon_w">52</param>') -or ($t -match 'emmys\.png[\s\S]*?<param name="icon_w">52</param>')
        $nativeRatings = [regex]::Matches($t, '<include content="Info_Meta_Ratings" condition="\$EXP\[Exp_TMDbHelper_IsData\]"').Count
        $nativeStatus = ($t -match 'TMDbHelper\.\$PARAM\[service\]\.Status')
        $nativeAwards = ($t -match 'TMDbHelper\.\$PARAM\[service\]\.Oscar_Wins')
        $icons = ($t -match 'oscars\.png') -and ($t -match 'emmys\.png') -and ($t -notmatch 'goldenglobe\.png')
        Write-Host "  Includes LRS slot 1-6      : $(if($slots){'YES'}else{'NO'})"
        Write-Host "  IMDb-only icon_w 52        : $(if($imdb52 -and -not $wrong52){'YES'}else{'NO'})"
        Write-Host "  Native rating calls left   : $nativeRatings"
        Write-Host "  Native status left         : $(if($nativeStatus){'YES'}else{'NO'})"
        Write-Host "  Native awards left         : $(if($nativeAwards){'YES'}else{'NO'})"
        Write-Host "  Awards icons oscars/emmys  : $(if($icons){'YES'}else{'NO'})"
    }
    if (Test-Path $hubPath) {
        $h = Read-Text $hubPath
        $tmdbAnchors = ([regex]::Matches($h, 'SetProperty\(TMDbHelper\.WidgetContainer')).Count
        $lrsLines = ([regex]::Matches($h, 'SetProperty\(LRS\.Active\.ContainerID')).Count
        $selector = ($h -match 'SetProperty\(LRS\.Active\.ContainerID,\$INFO\[Container\(601\)\.ListItem\.Property\(widget_id\)\]')
        $spotlightButton = ($h -match 'SetProperty\(LRS\.Active\.ContainerID,301,\$PARAM\[window\]\)')
        Write-Host "  Hub TMDb anchors           : $tmdbAnchors"
        Write-Host "  Hub LRS bridge lines       : $lrsLines"
        Write-Host "  Hub selector 601 bridge    : $(if($selector){'YES'}else{'NO'})"
        Write-Host "  Hub spotlight 301 bridge   : $(if($spotlightButton){'YES'}else{'NO'})"
        Write-Host "  Includes_Hubs active bridge: $(if(($lrsLines -ge $tmdbAnchors) -and $selector -and $spotlightButton){'YES'}else{'NO'})"
    }
    if (Test-Path $ssPath) {
        $s = Read-Text $ssPath
        $vignette = ([regex]::Matches($s, 'vignette\.png')).Count
        $odd = ([regex]::Matches($s, 'Integer\.IsOdd\(ListItem\.CurrentItem\)')).Count
        $crop = ([regex]::Matches($s, 'AFM-CLEARLOGO-FINAL-LRS-START-1\.3\.91-r7')).Count
        $rows = ([regex]::Matches($s, 'LRS-AF3-SCREENSAVER-AF3-ROW-START-1\.3\.87-r4-MERGED')).Count
        $star = ([regex]::Matches($s, 'Info_StarRating')).Count
        $centertop332 = ([regex]::Matches($s, '<centertop>332</centertop>')).Count
        $noScroll = ([regex]::Matches($s, '<autoscroll>false</autoscroll>')).Count
        $strictTitle = ([regex]::Matches($s, [regex]::Escape($R7_StrictTitle))).Count
        $oldMismatchTitle = ([regex]::Matches($s, [regex]::Escape($R7_R5MismatchTitle))).Count
        $ratingGuard = ([regex]::Matches($s, [regex]::Escape($R7_GuardRating))).Count
        $leftProgress = ([regex]::Matches($s, [regex]::Escape($R7_LeftVisible))).Count
        $rightProgress = ([regex]::Matches($s, [regex]::Escape($R7_RightVisible))).Count
        $usesSS = ($s -match 'LibraryRatings\.Screensaver\.RatingSlot1_Label') -and ($s -notmatch 'LRS_Info_Meta_Ratings')
        Write-Host "  Screensaver AF3 vignette   : $(if($vignette -ge 2){'YES'}else{'NO'}) ($vignette)"
        Write-Host "  Screensaver odd/even kept  : $(if($odd -ge 4){'YES'}else{'NO'}) ($odd)"
        Write-Host "  Screensaver final logo blocks: $crop"
        Write-Host "  Screensaver LRS rows       : $rows"
        Write-Host "  Native Info_StarRating left: $star"
        Write-Host "  Screensaver rating y=332   : $(if($centertop332 -ge 2){'YES'}else{'NO'}) ($centertop332)"
        Write-Host "  Plot autoscroll false      : $(if($noScroll -ge 2){'YES'}else{'NO'}) ($noScroll)"
        Write-Host "  Strict title fallback      : $(if($strictTitle -ge 2 -and $oldMismatchTitle -eq 0){'YES'}else{'NO'}) ($strictTitle)"
        Write-Host "  Rating title guard         : $(if($ratingGuard -ge 2){'YES'}else{'NO'}) ($ratingGuard)"
        Write-Host "  Progress forces left       : $(if($leftProgress -ge 2 -and $rightProgress -ge 2){'YES'}else{'NO'}) (left=$leftProgress right=$rightProgress)"
        Write-Host "  Screensaver uses SS props  : $(if($usesSS){'YES'}else{'NO'})"
        Write-Host "  RESULT screensaver         : $(if($vignette -ge 2 -and $odd -ge 4 -and $crop -eq 2 -and $rows -eq 2 -and $star -eq 0 -and $centertop332 -ge 2 -and $noScroll -ge 2 -and $strictTitle -ge 2 -and $oldMismatchTitle -eq 0 -and $ratingGuard -ge 2 -and $leftProgress -ge 2 -and $rightProgress -ge 2 -and $usesSS){'OK'}else{'CHECK'})"
    }
}

while ($true) {
    Clear-Host
    Write-Host "AF3 + LRS 1.3.91 r7 merged patcher"
    Write-Host "Skin 1080i: $Skin1080i"
    Write-Host "============================================================"
    Write-Host "1. Patch Includes_Info LRS rating slots + AF3 native spacing"
    Write-Host "2. Remove Includes_Info LRS patch"
    Write-Host "3. Patch Includes_Hubs active bridge robust"
    Write-Host "4. Remove Includes_Hubs active bridge"
    Write-Host "5. Patch Arctic Mirage r7 final clearlogo + strict title + progress-left"
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
