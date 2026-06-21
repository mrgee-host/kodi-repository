# -*- coding: utf-8 -*-
from __future__ import annotations
import base64
import hashlib
import re
import shutil
from datetime import datetime
from pathlib import Path

DEFAULT_SKIN_1080I = Path(r"E:\Kodi\portable_data\addons\skin.arctic.fuse.3\1080i")
VERSION = "1.3.82"

NATIVE_RE = re.compile(r'(?s)\n?[ \t]*<include\s+content=["\']Info_Meta_Ratings["\'][^>]*>.*?</include>')
NATIVE_MARKER_RE = re.compile(r'(?s)\s*<!-- LRS-AF3-NATIVE-RATINGS-DISABLED-START -->.*?<!-- LRS-AF3-NATIVE-RATINGS-DISABLED-END -->')
NATIVE_B64_RE = re.compile(r'LRS-AF3-NATIVE-RATINGS-ORIGINAL-B64:([A-Za-z0-9+/=]+)')


def slot_obj(idx, imdb_width=False):
    iconfile = 'Window(Home).Property(LibraryRatings.ListItem.RatingSlot%d_IconFile)' % idx
    label = 'Window(Home).Property(LibraryRatings.ListItem.RatingSlot%d_Label)' % idx
    extra = ' + !String.IsEqual(Window(Home).Property(LibraryRatings.ListItem.DBType),episode)' if idx >= 3 else ''
    width = '\n                <param name="icon_w">52</param>' if imdb_width else ''
    return '''            <include content="Info_Meta_Object">
                <param name="icon">flags/$VAR[Color_Directory]/ratings/$INFO[%s]</param>
                <param name="label">$INFO[%s]</param>
                <param name="visible">[$PARAM[visible]]%s + !String.IsEmpty(%s) + !String.IsEmpty(%s)</param>
                <param name="colordiffuse">$PARAM[colordiffuse]</param>%s
            </include>''' % (iconfile, label, extra, iconfile, label, width)

LRS_INCLUDE_DEF = '''<!-- LRS-AF3-INCLUDE-DEF-START -->
    <!-- LRS-AF3-1.3.82: clean slots 1-6, icon filename fix, awards/status always data-driven -->
    <include name="LRS_Info_Meta_Ratings">
        <param name="visible">true</param>
        <param name="colordiffuse">main_fg</param>
        <definition>
%s
%s
%s
%s
%s
%s
            <include content="Info_Meta_Object">
                <param name="icon">flags/$VAR[Color_Directory]/ratings/oscar.png</param>
                <param name="label">$INFO[Window(Home).Property(LibraryRatings.ListItem.Oscar_Wins),x,]</param>
                <param name="visible">[$PARAM[visible]] + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.Oscar_Wins))</param>
                <param name="colordiffuse">$PARAM[colordiffuse]</param>
            </include>
            <include content="Info_Meta_Object">
                <param name="icon">flags/$VAR[Color_Directory]/ratings/emmy.png</param>
                <param name="label">$INFO[Window(Home).Property(LibraryRatings.ListItem.Emmy_Wins),x,]</param>
                <param name="visible">[$PARAM[visible]] + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.Emmy_Wins))</param>
                <param name="colordiffuse">$PARAM[colordiffuse]</param>
            </include>
            <include content="Info_Meta_Object">
                <param name="icon">flags/$VAR[Color_Directory]/ratings/ends.png</param>
                <param name="label">$INFO[Window(Home).Property(LibraryRatings.ListItem.Series_StatusLabel)]</param>
                <param name="visible">[$PARAM[visible]] + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.Series_StatusLabel))</param>
                <param name="colordiffuse">$PARAM[colordiffuse]</param>
            </include>
        </definition>
    </include>
    <!-- LRS-AF3-INCLUDE-DEF-END -->''' % tuple(slot_obj(i, i==1) for i in range(1,7))

LRS_META_CALL = '''<!-- LRS-AF3-META-CALL-START -->
                    <include content="LRS_Info_Meta_Ratings">
                        <param name="visible">String.IsEqual($PARAM[container]$PARAM[listitem].DBType,movie) | String.IsEqual($PARAM[container]$PARAM[listitem].DBType,tvshow) | String.IsEqual($PARAM[container]$PARAM[listitem].DBType,season) | String.IsEqual($PARAM[container]$PARAM[listitem].DBType,episode) | $PARAM[override_movie] | $PARAM[override_tvshow] | Window.IsActive(videoosd)</param>
                        <param name="colordiffuse">main_fg</param>
                    </include>
                    <!-- LRS-AF3-META-CALL-END -->'''

CROP_BLOCK = '''<!-- AFM-CROPV2-CLEARLOGO-LRS-START -->
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
<!-- AFM-CROPV2-CLEARLOGO-LRS-END -->'''

TITLE_VISIBLE = '<visible>String.IsEmpty(Container(1297).ListItem.Art(clearlogo)) + [String.IsEmpty(Window(Home).Property(TMDbHelper.ListITem.CropImage)) | !String.IsEqual(Window(Home).Property(TMDbHelper.ListITem.Title),Container(1297).ListItem.Title)] + [String.IsEmpty(Window(Home).Property(TMDbHelper.ListItem.CropImage)) | !String.IsEqual(Window(Home).Property(TMDbHelper.ListItem.Title),Container(1297).ListItem.Title)]</visible>'


def inline_rating_obj(idx, x):
    return '''<control type="group"><width>%d</width><height>54</height><visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot%d_Label)) + !String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.RatingSlot%d_IconFile))</visible><control type="image"><left>0</left><centertop>27</centertop><width>44</width><height>28</height><texture>flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot%d_IconFile)]</texture><aspectratio>keep</aspectratio></control><control type="label"><left>52</left><centertop>27</centertop><height>54</height><width>%d</width><font>font_main_mono</font><textcolor>main_fg_70</textcolor><aligny>center</aligny><label>$INFO[Window(Home).Property(LibraryRatings.ListItem.RatingSlot%d_Label)]</label></control></control>''' % (x, idx, idx, idx, max(40, x-54), idx)

INLINE_RATINGS = '''<!-- LRS-AFM-INLINE-RATINGS-START -->
%s
%s
%s
%s
%s
%s
<control type="group"><width>76</width><height>54</height><visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.Oscar_Wins))</visible><control type="image"><left>0</left><centertop>27</centertop><width>36</width><height>32</height><texture>flags/$VAR[Color_Directory]/ratings/oscar.png</texture><aspectratio>keep</aspectratio></control><control type="label"><left>42</left><centertop>27</centertop><height>54</height><width>34</width><font>font_main_mono</font><textcolor>main_fg_70</textcolor><aligny>center</aligny><label>$INFO[Window(Home).Property(LibraryRatings.ListItem.Oscar_Wins),x,]</label></control></control>
<control type="group"><width>76</width><height>54</height><visible>!String.IsEmpty(Window(Home).Property(LibraryRatings.ListItem.Emmy_Wins))</visible><control type="image"><left>0</left><centertop>27</centertop><width>36</width><height>32</height><texture>flags/$VAR[Color_Directory]/ratings/emmy.png</texture><aspectratio>keep</aspectratio></control><control type="label"><left>42</left><centertop>27</centertop><height>54</height><width>34</width><font>font_main_mono</font><textcolor>main_fg_70</textcolor><aligny>center</aligny><label>$INFO[Window(Home).Property(LibraryRatings.ListItem.Emmy_Wins),x,]</label></control></control>
<!-- LRS-AFM-INLINE-RATINGS-END -->''' % tuple(inline_rating_obj(i, 128 if i==1 else 112) for i in range(1,7))


def info(msg): print('[INFO] ' + msg)
def ok(msg): print('[OK] ' + msg)
def warn(msg): print('[WARN] ' + msg)
def err(msg): print('[ERROR] ' + msg)

def read_text(path: Path) -> str:
    try:
        return path.read_text(encoding='utf-8-sig')
    except UnicodeDecodeError:
        return path.read_text(encoding='utf-8', errors='replace')

def write_text(path: Path, text: str):
    path.write_text(text, encoding='utf-8', newline='\n')

def backup(path: Path) -> Path:
    stamp = datetime.now().strftime('%Y%m%d-%H%M%S')
    bak = path.with_name(path.name + f'.lrs-{VERSION}-pybackup-' + stamp)
    shutil.copy2(str(path), str(bak))
    return bak

def remove_between(text, start, end):
    pat = re.compile(r'(?s)\s*' + re.escape(start) + r'.*?' + re.escape(end))
    return pat.subn('', text)

def replace_between(text, start, end, repl):
    pat = re.compile(r'(?s)\s*' + re.escape(start) + r'.*?' + re.escape(end))
    new, n = pat.subn('\n' + repl, text)
    return new, n

def sha8(text):
    return hashlib.sha1(text.encode('utf-8', 'ignore')).hexdigest()[:8]

def file_state(path):
    try:
        st=path.stat()
        return datetime.fromtimestamp(st.st_mtime).strftime('%Y-%m-%d %H:%M:%S')
    except Exception:
        return '-'

def disable_native_rating_rows(text: str):
    matches = NATIVE_RE.findall(text)
    if not matches:
        return text, False, 0
    original = '\n'.join(m.strip('\n') for m in matches).strip()
    text = NATIVE_RE.sub('', text)
    if 'LRS-AF3-NATIVE-RATINGS-DISABLED-START' not in text:
        encoded = base64.b64encode(original.encode('utf-8')).decode('ascii')
        marker = '''
                    <!-- LRS-AF3-NATIVE-RATINGS-DISABLED-START -->
                    <!-- Native AF3/TMDbHelper rating rows disabled so only LRS rating slots are shown. -->
                    <!-- LRS-AF3-NATIVE-RATINGS-ORIGINAL-B64:%s-->
                    <!-- LRS-AF3-NATIVE-RATINGS-DISABLED-END -->''' % encoded
        anchor = '<!-- LRS-AF3-META-CALL-END -->'
        if anchor in text:
            text = text.replace(anchor, anchor + marker, 1)
        else:
            text = text.replace('<!-- Ratings -->', '<!-- Ratings -->' + marker, 1)
    return text, True, len(matches)

def restore_native_rating_rows(text: str):
    m = NATIVE_MARKER_RE.search(text)
    if not m:
        return text, False
    block = m.group(0)
    b64 = NATIVE_B64_RE.search(block)
    original = ''
    if b64:
        try:
            original = base64.b64decode(b64.group(1).encode('ascii')).decode('utf-8')
        except Exception:
            original = ''
    text = text[:m.start()] + ('\n' + original if original else '') + text[m.end():]
    return text, True

class Patcher:
    def __init__(self, skin_1080i: Path): self.skin = skin_1080i
    def file(self, name: str) -> Path:
        p = self.skin / name
        if not p.exists(): raise FileNotFoundError(str(p))
        return p

    def patch_info(self):
        p=self.file('Includes_Info.xml'); s=read_text(p); original=s
        s,n=replace_between(s,'<!-- LRS-AF3-INCLUDE-DEF-START -->','<!-- LRS-AF3-INCLUDE-DEF-END -->',LRS_INCLUDE_DEF)
        if n: ok('Updated LRS include definition')
        elif 'LRS-AF3-INCLUDE-DEF-START' not in s:
            if '</includes>' in s:
                s=s.replace('</includes>', LRS_INCLUDE_DEF+'\n</includes>',1); ok('Injected LRS include definition')
            else: raise RuntimeError('Includes_Info.xml tidak punya </includes>')
        s,n=replace_between(s,'<!-- LRS-AF3-META-CALL-START -->','<!-- LRS-AF3-META-CALL-END -->',LRS_META_CALL)
        if n: ok('Updated LRS rating row call')
        elif 'LRS-AF3-META-CALL-START' not in s:
            if '<!-- Ratings -->' in s:
                s=s.replace('<!-- Ratings -->','<!-- Ratings -->\n'+LRS_META_CALL,1); ok('Injected LRS rating row call')
            else: warn('Tidak menemukan marker <!-- Ratings -->; hanya include definition dipasang')
        s,_=remove_between(s,'<!-- LRS-AF3-NATIVE-STATUS-DISABLED-START -->','<!-- LRS-AF3-NATIVE-STATUS-DISABLED-END -->')
        s,disabled,count=disable_native_rating_rows(s)
        if disabled: ok('Disabled native AF3/TMDbHelper rating rows: %d block(s)'%count)
        if s==original: ok('SKIP Includes_Info.xml: sudah sesuai'); return
        bak=backup(p); write_text(p,s); info('Backup safety: '+str(bak))

    def remove_info(self):
        p=self.file('Includes_Info.xml'); s=read_text(p); original=s
        s,_=remove_between(s,'<!-- LRS-AF3-META-CALL-START -->','<!-- LRS-AF3-META-CALL-END -->')
        s,_=remove_between(s,'<!-- LRS-AF3-INCLUDE-DEF-START -->','<!-- LRS-AF3-INCLUDE-DEF-END -->')
        s,_=restore_native_rating_rows(s)
        s,_=remove_between(s,'<!-- LRS-AF3-NATIVE-STATUS-DISABLED-START -->','<!-- LRS-AF3-NATIVE-STATUS-DISABLED-END -->')
        if s==original: warn('Includes_Info.xml: tidak ada block LRS untuk dihapus'); return
        bak=backup(p); write_text(p,s); ok('Removed LRS Includes_Info patch from current XML'); info('Backup safety: '+str(bak))

    def _patch_crop_blocks(self, s):
        s,n=replace_between(s,'<!-- AFM-CROPV2-CLEARLOGO-LRS-START -->','<!-- AFM-CROPV2-CLEARLOGO-LRS-END -->',CROP_BLOCK)
        if n: return s,n
        pat=re.compile(r'(?s)<control type="image">\s*<texture background="true">\$INFO\[Container\(1297\)\.ListItem\.Art\(clearlogo\)\]</texture>.*?</control>')
        return pat.subn(CROP_BLOCK, s, count=2)

    def patch_screensaver(self):
        p=self.file('screensaver-arctic-mirage.xml'); s=read_text(p); original=s
        s,n=self._patch_crop_blocks(s)
        if n: ok('Patched CropV2 clearlogo block: %d occurrence(s)'%n)
        else: warn('Clearlogo block standar tidak ditemukan')
        # Title fallback visibility: allow title only when no valid CropV2 and no Kodi clearlogo.
        s=re.sub(r'<visible>String\.IsEmpty\(Window\(Home\)\.Property\(LibraryRatings\.Screensaver\.CropV2Image\)\) \+ String\.IsEmpty\(Container\(1297\)\.ListItem\.Art\(clearlogo\)\)</visible>', TITLE_VISIBLE, s)
        s=s.replace('<visible>String.IsEmpty(Container(1297).ListItem.Art(clearlogo))</visible>', TITLE_VISIBLE)
        # Replace old invalid include call with self-contained inline controls.
        inc_pat=re.compile(r'(?s)\s*<include\s+content=["\']LRS_Info_Meta_Ratings["\'][^>]*>.*?</include>')
        s,n2=inc_pat.subn('\n                    '+INLINE_RATINGS.replace('\n','\n                    '), s)
        if n2: ok('Replaced screensaver LRS include with inline rating controls: %d occurrence(s)'%n2)
        elif 'LRS-AFM-INLINE-RATINGS-START' not in s: warn('Screensaver rating include tidak ditemukan')
        if 'Container(1297).ListItem.Plot' not in s: warn('PERINGATAN: plot screensaver tidak ditemukan di XML ini')
        if s==original: ok('SKIP screensaver-arctic-mirage.xml: sudah sesuai'); return
        bak=backup(p); write_text(p,s); info('Backup safety: '+str(bak))

    def remove_screensaver(self):
        p=self.file('screensaver-arctic-mirage.xml'); s=read_text(p); original=s
        default='<control type="image">\n    <texture background="true">$INFO[Container(1297).ListItem.Art(clearlogo)]</texture>\n    <aspectratio aligny="bottom">keep</aspectratio>\n    <visible>!String.IsEmpty(Container(1297).ListItem.Art(clearlogo))</visible>\n</control>'
        s,_=replace_between(s,'<!-- AFM-CROPV2-CLEARLOGO-LRS-START -->','<!-- AFM-CROPV2-CLEARLOGO-LRS-END -->',default)
        s,_=remove_between(s,'<!-- LRS-AFM-INLINE-RATINGS-START -->','<!-- LRS-AFM-INLINE-RATINGS-END -->')
        if s==original: warn('screensaver-arctic-mirage.xml: tidak ada patch LRS untuk dihapus'); return
        bak=backup(p); write_text(p,s); ok('Removed screensaver LRS/CropV2 patch from current XML'); info('Backup safety: '+str(bak))

    def check(self):
        try:
            inc_path=self.file('Includes_Info.xml'); scr_path=self.file('screensaver-arctic-mirage.xml')
            inc=read_text(inc_path); scr=read_text(scr_path)
        except Exception as exc:
            err(str(exc)); return
        native_count=len(NATIVE_RE.findall(inc)); disabled='LRS-AF3-NATIVE-RATINGS-DISABLED-START' in inc
        lrs_def='LRS-AF3-INCLUDE-DEF-START' in inc and 'RatingSlot6_IconFile' in inc
        lrs_call='LRS-AF3-META-CALL-START' in inc
        if lrs_def and lrs_call and disabled and native_count==0: state='PATCHED'
        elif not lrs_def and not lrs_call and not disabled and native_count>0: state='CLEAN/ORIGINAL'
        else: state='PARTIAL/UNKNOWN'
        print('\nSTATUS')
        print('  Skin path                  : '+str(self.skin))
        print('  Includes_Info modified/hash: %s / %s'%(file_state(inc_path), sha8(inc)))
        print('  Includes state             : '+state)
        print('  Includes LRS slot 1-6      : '+('YES' if lrs_def else 'NO'))
        print('  LRS meta call              : '+('YES' if lrs_call else 'NO'))
        print('  Native disabled marker     : '+('YES' if disabled else 'NO'))
        print('  Native row calls remaining : '+str(native_count))
        print('  Screensaver modified/hash  : %s / %s'%(file_state(scr_path), sha8(scr)))
        print('  Screensaver plot preserved : '+('YES' if 'Container(1297).ListItem.Plot' in scr else 'NO'))
        print('  Screensaver CropV2 direct  : '+('YES' if 'TMDbHelper.ListITem.CropImage' in scr and 'AFM-CROPV2-CLEARLOGO-LRS-START' in scr else 'NO'))
        print('  Screensaver inline ratings : '+('YES' if 'LRS-AFM-INLINE-RATINGS-START' in scr else 'NO'))
        print('  Invalid LRS include left   : '+('YES' if 'include content="LRS_Info_Meta_Ratings"' in scr else 'NO'))

def menu():
    skin=DEFAULT_SKIN_1080I; p=Patcher(skin)
    while True:
        print('\n============================================================')
        print('AF3 + LRS 1.3.82 patcher')
        print('Skin 1080i: '+str(skin))
        print('============================================================')
        print('1. Patch LRS AF3 rating slots 1-6 + disable native ratings')
        print('2. Remove LRS AF3 patch from Includes_Info.xml')
        print('3. Patch Arctic Mirage CropV2 clearlogo + inline LRS ratings')
        print('4. Remove Arctic Mirage CropV2/LRS screensaver block')
        print('5. Patch all')
        print('6. Remove all')
        print('7. Check patch status')
        print('8. Change skin 1080i path')
        print('9. Exit')
        choice=input('Pilih [1-9]: ').strip()
        try:
            if choice=='1': p.patch_info()
            elif choice=='2': p.remove_info()
            elif choice=='3': p.patch_screensaver()
            elif choice=='4': p.remove_screensaver()
            elif choice=='5': p.patch_info(); p.patch_screensaver(); p.check()
            elif choice=='6': p.remove_screensaver(); p.remove_info(); p.check()
            elif choice=='7': p.check()
            elif choice=='8':
                new=input('Masukkan path folder 1080i: ').strip().strip('"')
                if new: skin=Path(new); p=Patcher(skin)
            elif choice=='9': break
            else: warn('Pilihan tidak dikenal')
        except Exception as exc:
            err(str(exc))
        input('\nTekan Enter untuk kembali ke menu...')

if __name__=='__main__':
    menu()
