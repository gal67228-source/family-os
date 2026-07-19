# Family OS Cloud Builder — הוראות מלאות

הפתרון משתמש ב:

- Cloudflare Worker להצגת הפורטל ולהפעלת GitHub.
- Cloudflare R2 לאחסון זמני של ZIP.
- GitHub Actions לבניית APK/AAB.
- GitHub Releases להורדה מהטלפון.

## חלק א — GitHub

### 1. העלאת Workflow

ב-repository `gal67228-source/family-os` צור את הקובץ:

```text
.github/workflows/cloud-builder.yml
```

והדבק את תוכן:

```text
github/cloud-builder.yml
```

בצע Commit ל-main.

### 2. הרשאות GitHub Actions

פתח:

```text
family-os → Settings → Actions → General
```

תחת Workflow permissions בחר:

```text
Read and write permissions
```

ושמור.

### 3. יצירת Fine-grained Token

פתח בחשבון GitHub:

```text
Settings
→ Developer settings
→ Personal access tokens
→ Fine-grained tokens
→ Generate new token
```

הגדר:

- Repository access: רק `family-os`
- Actions: Read and write
- Metadata: Read-only

העתק את ה-Token. אל תכניס אותו לקוד ואל תשלח אותו לאף אחד.

## חלק ב — Cloudflare

### 4. יצירת חשבון

פתח חשבון חינמי ב-Cloudflare.

### 5. יצירת R2 Bucket

פתח:

```text
R2 Object Storage → Create bucket
```

שם:

```text
family-os-builds
```

Storage class:

```text
Standard
```

### 6. יצירת Worker

פתח:

```text
Workers & Pages → Create application → Create Worker
```

שם:

```text
family-os-builder
```

לאחר יצירה, פתח Edit Code, מחק את הקוד הקיים והדבק את:

```text
cloudflare/src/worker.js
```

לחץ Deploy.

### 7. חיבור R2

פתח את ה-Worker:

```text
Settings → Bindings → Add binding → R2 bucket
```

הגדר:

```text
Variable name: BUILDS
R2 bucket: family-os-builds
```

שמור ופרוס מחדש אם תתבקש.

### 8. הוספת Secrets

פתח:

```text
Settings → Variables and Secrets
```

הוסף כ-Secrets:

```text
BUILD_PASSWORD
GITHUB_TOKEN
```

`BUILD_PASSWORD` היא סיסמה חזקה שתזין בפורטל.

הוסף כ-Variables או Secrets:

```text
GITHUB_OWNER=gal67228-source
GITHUB_REPO=family-os
GITHUB_WORKFLOW=cloud-builder.yml
```

### 9. Cron לניקוי ZIP

פתח:

```text
Settings → Triggers → Cron Triggers
```

הוסף:

```text
15 * * * *
```

כך קובצי ZIP ישנים יימחקו אוטומטית.

## חלק ג — בדיקה

### 10. פתיחת הפורטל

Cloudflare יציג כתובת דומה ל:

```text
https://family-os-builder.<your-subdomain>.workers.dev
```

פתח אותה בטלפון.

### 11. Build ראשון

1. הזן את `BUILD_PASSWORD`.
2. הזן גרסה: `0.1.0`.
3. בחר את ZIP הפרויקט.
4. לחץ "העלה ובנה APK".
5. לחץ "פתח את תהליך הבנייה".
6. המתן לסימון ירוק.
7. פתח GitHub Releases.
8. הורד את קובץ ה-APK.

## עדכונים עתידיים

בכל פעם שאקבל ממך שינוי, אכין ZIP חדש. מהטלפון:

1. פותחים את הפורטל.
2. בוחרים ZIP.
3. משנים מספר גרסה.
4. לוחצים Build.
5. מורידים APK.

## מגבלות

- ZIP עד 95MB.
- כתובת ההורדה הזמנית תקפה 30 דקות.
- ה-ZIP נמחק אוטומטית לאחר כשעתיים.
- גרסת ה-AAB אינה מוכנה לפרסום ב-Google Play עד שנגדיר Upload Keystore.
