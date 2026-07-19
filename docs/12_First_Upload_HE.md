# העלאה ראשונה ל-Repository ריק

## מה להעלות

חלץ את קובץ `family-os-complete-v1.0.0.zip`.

העלה את כל הקבצים והתיקיות שבתוכו לשורש ה-Repository:

```text
gal67228-source/family-os
```

אל תעלה את קובץ ה-ZIP עצמו בלבד.

בסיום אמורים להופיע ב-GitHub:

```text
.github/
apps/
backend/
docs/
packages/
tools/
README.md
CHANGELOG.md
LICENSE
```

## העלאה דרך אתר GitHub

1. פתח את ה-Repository.
2. לחץ `Add file`.
3. בחר `Upload files`.
4. גרור את כל תוכן התיקייה שחילצת.
5. כתוב הודעת Commit:

```text
feat: initialize Family OS complete workspace
```

6. לחץ `Commit changes`.

## לאחר ההעלאה

פתח:

```text
Settings → Actions → General
```

ותחת `Workflow permissions` בחר:

```text
Read and write permissions
```

כך תהליכי הבנייה יוכלו ליצור Releases ולעדכן את הקוד.
