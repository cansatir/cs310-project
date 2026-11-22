"""Build the Step 2.2 PDF from actual UI captures (requires reportlab).

Without --commit the output is explicitly a draft. After publishing the reviewed
code, pass its full SHA; verify that it is on GitHub before submitting the PDF.
"""
from pathlib import Path
import argparse
import subprocess

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen import canvas
from reportlab.platypus import Paragraph
from reportlab.lib.utils import ImageReader

ROOT = Path(__file__).resolve().parents[1]
SHOTS = ROOT / 'docs' / 'screenshots'
OUT = ROOT / 'output' / 'pdf'
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--commit', help='Published final code commit SHA')
args = parser.parse_args()
commit = None
if args.commit:
    commit = subprocess.check_output(
        ['git', 'rev-parse', '--verify', args.commit + '^{commit}'],
        cwd=ROOT, text=True,
    ).strip()
    head = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()
    if commit != head:
        parser.error('Check out the reviewed submission commit before generating the final PDF.')
    if subprocess.run(['git', 'diff', '--quiet', 'HEAD', '--', 'lib', 'assets', 'test',
                       'pubspec.yaml', 'pubspec.lock', 'README.md'], cwd=ROOT).returncode:
        parser.error('Commit the application changes before generating the final PDF.')

font_paths = [
    ('/System/Library/Fonts/Supplemental/Arial.ttf',
     '/System/Library/Fonts/Supplemental/Arial Bold.ttf'),
    ('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
     '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'),
]
for regular, bold in font_paths:
    if Path(regular).exists() and Path(bold).exists():
        pdfmetrics.registerFont(TTFont('Body', regular))
        pdfmetrics.registerFont(TTFont('Strong', bold))
        break
else:
    raise SystemExit('Install Arial or DejaVu Sans to render member names correctly.')

OUT.mkdir(parents=True, exist_ok=True)
path = OUT / ('CS310_Group2_Step2.2.pdf' if commit else 'CS310_Group2_Step2.2_DRAFT.pdf')
c = canvas.Canvas(str(path), pagesize=A4)
c.setTitle('SpendWise | CS310 Group 2 | Step 2.2')
c.setAuthor('CS310 Group 2')
W, H = A4
INK = colors.HexColor('#231D34')
PURPLE = colors.HexColor('#6750A4')
MUTED = colors.HexColor('#625D6D')
page = 0


def text(value, x, y, width, size=10, color=INK, bold=False):
    style = ParagraphStyle('p', fontName='Strong' if bold else 'Body', fontSize=size,
                           leading=size * 1.4, textColor=color)
    p = Paragraph(value, style)
    _, height = p.wrap(width, H)
    p.drawOn(c, x, y - height)
    return y - height


def start(title, subtitle):
    global page
    page += 1
    c.setFillColor(PURPLE)
    c.rect(0, H - 9, W, 9, fill=1, stroke=0)
    text('SPENDWISE  /  CS310  /  GROUP 2', 38, H - 30, W - 76, 9, PURPLE, True)
    text(title, 38, H - 54, W - 76, 23, INK, True)
    text(subtitle, 38, H - 93, W - 76, 10, MUTED)
    c.setStrokeColor(colors.HexColor('#E3DCEA'))
    c.line(38, 42, W - 38, 42)
    status = 'Final submission' if commit else 'DRAFT - final published commit SHA pending'
    text(status, 38, 32, W - 100, 8, PURPLE)
    text(str(page), W - 55, 32, 20, 8, MUTED)


def finish():
    c.showPage()


def image_box(filename, x, top, width, height):
    image = ImageReader(str(SHOTS / filename))
    iw, ih = image.getSize()
    scale = min(width / iw, height / ih)
    dw, dh = iw * scale, ih * scale
    c.drawImage(image, x + (width - dw) / 2, top - dh, dw, dh)
    return top - dh


start('UI implementation', 'Step 2.2  |  Verified 22 November 2026  |  Flutter 3.47.6 / Dart 3.13.5')
y = text('Repository: <link href="https://github.com/cansatir/cs310-project" color="#6750A4">'
         'github.com/cansatir/cs310-project</link>', 38, H - 134, W - 76, 11)
y = text('Deadline / submission commit: ' + (commit or '<b>PENDING - DO NOT SUBMIT THIS DRAFT</b>'),
         38, y - 10, W - 76, 10)
y = text('Scope and verification', 38, y - 22, W - 76, 14, bold=True)
y = text('UI-only Login and Sign-up; monthly Dashboard with expense Cards, add/edit and confirmed '
         'removal; Summary with seven category totals; Settings with currency preferences, local/network '
         'images and bundled Roboto Mono. Expenses use the existing local SharedPreferences storage. '
         'Firebase is deferred to Step 3.', 38, y - 8, W - 76)
y = text('46 tests passed; flutter analyze reported no issues. The Android API 37.0 arm64 debug build '
         'installed and launched with flutter run. Portrait widget tests cover 320×568 and 430×932, '
         'keyboard-open forms and main screens at 130% text scale. iOS was not tested.',
         38, y - 10, W - 76)
y = text('Member Contributions', 38, y - 22, W - 76, 14, bold=True)
rows = [
    ('Khalil Khalilli', 'Login/Sign-up, validators, password visibility and navigation. Commits: 49c749c, df43bb7, 3549118.'),
    ('Akif Şentürk', 'Add/edit inline validation, successful-save dialog and responsive form tests. Commits: 59d53e8, b5d9c15, 1ab241d.'),
    ('Atilla Mammadzada', 'Monthly/category summary calculations and category charts. Commit: fcb78bf.'),
    ('Harun Can Yurdagül', 'Settings, currency preferences, theme, font and image assets. Commits: 6b5a82a, 422beeb, 6a308e2.'),
    ('Berat Can Satır', 'Dashboard, list/removal confirmation, shared calculations, currency/theme integration, integration tests and delivery preparation. Commits: fca6342, 1dd535a.'),
]
for name, work in rows:
    y = text(name, 38, y - 9, W - 76, 10, bold=True)
    y = text(work, 38, y - 2, W - 76, 9)
y = text('Capture provenance', 38, y - 16, W - 76, 12, bold=True)
y = text('The following pages contain actual Flutter web screenshots at portrait phone viewport sizes. '
         'They are not Android screenshots. Demo records were entered through the UI. Android build/launch '
         'was checked separately. No real authentication or financial account is used.', 38, y - 5, W - 76, 9)
if y < 52:
    raise RuntimeError('Cover content exceeds the page.')
finish()

pairs = [
    ('Account screens', 'UI-only entry; valid input opens Dashboard.',
     [('01-login.jpg', 'Login', '430×932. Local logo, email/password and Sign-up link.'),
      ('02-signup.jpg', 'Sign up', '430×932. Name, email, password and confirmation.')]),
    ('Dashboard and summary', 'Both screens use the same month-filtered expense data and currency preference.',
     [('07-dashboard.jpg', 'Dashboard', '430×932. Month, total, Cards and category insight.'),
      ('08-summary.jpg', 'Summary', '430×932. Category totals and relative bars; all seven categories.')]),
    ('Create and edit expenses', 'One reusable form handles both creation and updates.',
     [('03-add-expense.jpg', 'Add expense', '430×932. Title, amount, date, optional note and category.'),
      ('06-edit-expense.jpg', 'Edit expense', '430×932. Prefilled fields; update preserves the record ID.')]),
    ('Validation and successful save', 'Invalid input remains on the form. A successful submission opens a dialog.',
     [('04-form-validation.jpg', 'Inline validation', '320×568. Required-field and amount errors stay readable.'),
      ('05-save-confirmation.jpg', 'Save confirmation', '430×932. OK closes the dialog and returns to Dashboard.')]),
    ('Preferences and removal', 'Currency changes are locked while expenses exist; deletion requires confirmation.',
     [('09-settings.jpg', 'Settings', '430×932. Currency preference, local mark and network chart image.'),
      ('13-delete-confirmation.jpg', 'Delete confirmation', '320×568. Cancel keeps the record; Delete removes it.')]),
]
for title, subtitle, entries in pairs:
    start(title, subtitle)
    for i, (file, label, caption) in enumerate(entries):
        x = 38 + i * 270
        text(label, x, H - 133, 245, 13, bold=True)
        image_box(file, x, H - 161, 245, 530)
        text(caption, x, H - 709, 245, 9, MUTED)
    finish()

start('Small portrait layout', '320×568 viewport. Main content scrolls while bottom navigation remains available.')
for i, (file, label) in enumerate([
    ('12-dashboard-small.jpg', 'Dashboard - scrolled'),
    ('11-summary-small.jpg', 'Summary - scrolled'),
    ('10-settings-small.jpg', 'Settings'),
]):
    x = 38 + i * 176
    text(label, x, H - 145, 166, 11, bold=True)
    image_box(file, x, H - 179, 166, 300)
text('Responsive verification', 38, H - 515, W - 76, 14, bold=True)
text('These are actual small-viewport captures. The expense list and category chart scroll to expose '
     'all content, and Settings text wraps. Automated tests additionally cover 430×932, 130% text '
     'scaling on the main screens and keyboard-open Add/Edit and auth forms.',
     38, H - 543, W - 76, 11)
text('Images and font', 38, H - 625, W - 76, 13, bold=True)
text('Local SpendWise mark and Roboto Mono are bundled. The Settings chart illustration uses Twemoji '
     '(© Twitter, Inc. and contributors), CC BY 4.0, via a version-pinned jsDelivr URL. '
     'The network image provides loading and error states.', 38, H - 651, W - 76, 10)
finish()
c.save()
print(path)
