# Cloud Builder יציב

GitHub אינו מאפשר ל-Workflow לשנות קבצים בתוך `.github/workflows`.

לכן הארכיטקטורה החדשה היא:

```text
cloud-builder.yml
  ↓
tools/ci/cloud_build.sh
```

ה-Workflow קבוע ומכיל רק:

- הורדת ZIP
- אימות ZIP
- התקנת Java ו-Flutter
- הפעלת הסקריפט

כל הלוגיקה שנרצה לשפר בעתיד נמצאת ב:

```text
tools/ci/cloud_build.sh
```

הפורטל יכול לעדכן את הסקריפט הזה כחלק מה-ZIP.

## פעולה חד-פעמית

יש להחליף ידנית ב-GitHub את:

```text
.github/workflows/cloud-builder.yml
```

בתוכן הקובץ:

```text
cloud-builder-stable-once.yml
```

לאחר מכן אין צורך לעדכן ידנית את ה-Workflow בגרסאות רגילות.
