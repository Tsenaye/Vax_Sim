"""Package Final_Delivery without unpacking or rewriting its SLX."""
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED
import hashlib

ROOT=Path(__file__).resolve().parents[1]
FOLDER=ROOT/'Final_Delivery'
DEST=ROOT/'Vataleni_PMSG_SSO_Final_Delivery.zip'
SLX=FOLDER/'Vataleni_PMSG_SSO_Final.slx'
assert SLX.is_file()
for name in ('Vataleni_PMSG_SSO_Three_Slide_Presentation.pptx',
             'Vataleni_PMSG_SSO_Three_Page_Explainer.docx',
             'Vataleni_PMSG_SSO_Three_Page_Explainer.pdf',
             'README_START_HERE.md','Results/README_RESULTS.md'):
    assert (FOLDER/name).is_file(),name
with ZipFile(DEST,'w',compression=ZIP_DEFLATED,compresslevel=6) as z:
    for path in sorted(FOLDER.rglob('*')):
        if not path.is_file() or path.name.startswith('scope_work_'):
            continue
        z.write(path,path.relative_to(ROOT).as_posix())
with ZipFile(DEST) as z:
    bad=z.testzip();assert bad is None,bad
    member='Final_Delivery/Vataleni_PMSG_SSO_Final.slx'
    assert z.namelist().count(member)==1
    inside=hashlib.sha256(z.read(member)).hexdigest()
    outside=hashlib.sha256(SLX.read_bytes()).hexdigest()
    assert inside==outside
print('ZIP',DEST,'bytes',DEST.stat().st_size,'SLX_SHA256',outside)
