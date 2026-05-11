from pathlib import Path
import re
root = Path('lib')
patterns = [
    r'package:mobile/features/',
    r'import .*property\.dart',
    r'import .*property_media\.dart',
    r'import .*notification\.dart',
    r'AuthService\(',
    r'\bProperty\b',
    r'\bPropertyMedia\b',
    r'\bNotificationModel\b',
    r'\bFavorite\b',
    r'\bBoostPackage\b',
    r'\bFeedback\b',
    r'\bVisitRequest\b',
    r'\bProfile\b',
]
folders = [root/'ui'/'screens', root/'ui'/'widgets']
for folder in folders:
    for path in sorted(folder.rglob('*.dart')):
        text = path.read_text(encoding='utf-8')
        for p in patterns:
            if re.search(p, text):
                print(path, p)
                break
