const HTML = `<!doctype html>
<html lang="he" dir="rtl">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
  <meta name="theme-color" content="#2867d8">
  <title>Family OS Builder</title>
  <style>
    :root{font-family:system-ui,-apple-system,"Segoe UI",Arial,sans-serif;color-scheme:light dark;
      --p:#2867d8;--p2:#194fae;--bg:#f3f6fb;--s:#fff;--t:#172033;--m:#68758c;--b:#dce3ef;--ok:#087a55;--bad:#b42318}
    *{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--t)}
    main{width:min(100% - 28px,680px);margin:auto;padding:28px 0 54px}
    header{display:flex;gap:14px;align-items:center;margin-bottom:22px}
    .logo{width:54px;height:54px;border-radius:18px;background:var(--p);color:#fff;display:grid;place-items:center;font-size:26px;font-weight:900}
    h1,h2,p{margin-top:0}.muted{color:var(--m)}
    .card{background:var(--s);border:1px solid var(--b);border-radius:22px;padding:20px;margin-bottom:16px;box-shadow:0 8px 30px #233d6410}
    label{display:grid;gap:8px;font-weight:700;margin:16px 0}
    input{width:100%;min-height:52px;border:1px solid var(--b);border-radius:15px;padding:0 14px;font:inherit;background:var(--s);color:var(--t)}
    button,a.btn{width:100%;min-height:52px;border:0;border-radius:15px;padding:14px 18px;font:inherit;font-weight:800;cursor:pointer;text-decoration:none;text-align:center;display:grid;place-items:center;background:var(--p);color:#fff}
    button:hover{background:var(--p2)}button:disabled{opacity:.55;cursor:not-allowed}
    .secondary{background:transparent!important;color:var(--p)!important;border:1px solid var(--b)!important}
    .picker{min-height:120px;border:2px dashed var(--b);border-radius:18px;display:grid;place-items:center;color:var(--p);cursor:pointer}
    .picker input{display:none}.status{white-space:pre-wrap;min-height:24px;margin:14px 0}.progress{height:10px;border-radius:999px;overflow:hidden;background:var(--b);margin:16px 0}
    .progress div{height:100%;width:0;background:var(--p);transition:width .2s}.hidden{display:none!important}.actions{display:grid;gap:10px}
    ol{line-height:1.9;padding-right:23px}
    @media(prefers-color-scheme:dark){:root{--bg:#0d131d;--s:#151d29;--t:#edf3fb;--m:#aeb9ca;--b:#2b3748}}
  </style>
</head>
<body>
<main>
  <header><div class="logo">F</div><div><h1>Family OS Builder</h1><p class="muted">ZIP נכנס, APK יוצא</p></div></header>
  <section class="card">
    <h2>Build חדש</h2>
    <label>סיסמת Builder<input id="password" type="password" autocomplete="current-password" placeholder="הסיסמה שהגדרת ב-Cloudflare"></label>
    <label>מספר גרסה<input id="version" value="0.1.0" inputmode="decimal"></label>
    <label class="picker"><span>📦 בחר ZIP של הפרויקט</span><input id="file" type="file" accept=".zip,application/zip"></label>
    <p id="fileInfo" class="muted">לא נבחר קובץ</p>
    <button id="build">העלה ובנה APK</button>
    <div id="progress" class="progress hidden"><div></div></div>
    <p id="status" class="status"></p>
    <div class="actions">
      <a id="runLink" class="btn hidden" target="_blank" rel="noopener">פתח את תהליך הבנייה</a>
      <a href="https://github.com/gal67228-source/family-os/releases" class="btn secondary" target="_blank" rel="noopener">הורד APK אחרון</a>
    </div>
  </section>
  <section class="card">
    <h2>מה קורה?</h2>
    <ol><li>ה-ZIP נשמר זמנית ובצורה פרטית.</li><li>GitHub Actions מוריד אותו ומעדכן את הפרויקט.</li><li>Flutter מריץ בדיקות ובונה APK ו-AAB.</li><li>הקבצים מתפרסמים ב-GitHub Releases.</li></ol>
  </section>
</main>
<script>
const file = document.querySelector("#file");
const info = document.querySelector("#fileInfo");
const button = document.querySelector("#build");
const status = document.querySelector("#status");
const progress = document.querySelector("#progress");
const bar = progress.firstElementChild;
const runLink = document.querySelector("#runLink");

file.addEventListener("change", () => {
  const f=file.files[0];
  info.textContent=f ? f.name+" · "+(f.size/1024/1024).toFixed(1)+" MB" : "לא נבחר קובץ";
});

button.addEventListener("click", async () => {
  const f=file.files[0], password=document.querySelector("#password").value;
  const version=document.querySelector("#version").value.trim();
  if(!password){status.textContent="הזן סיסמה.";return}
  if(!f){status.textContent="בחר ZIP.";return}
  if(!/^\\d+\\.\\d+\\.\\d+$/.test(version)){status.textContent="גרסה חייבת להיות בצורה 0.1.0.";return}
  if(f.size>95*1024*1024){status.textContent="הקובץ גדול מ-95MB.";return}

  button.disabled=true;runLink.classList.add("hidden");progress.classList.remove("hidden");bar.style.width="15%";status.textContent="מעלה...";
  try{
    const form=new FormData();form.append("file",f);form.append("version",version);
    bar.style.width="35%";
    const response=await fetch("/api/build",{method:"POST",headers:{"X-Build-Password":password},body:form});
    const body=await response.json();
    if(!response.ok) throw new Error(body.error||"Build failed");
    bar.style.width="100%";status.textContent="ה-Build התחיל. פתח את התהליך ועקוב עד לסימון ירוק.";
    runLink.href=body.htmlUrl;runLink.classList.remove("hidden");
    sessionStorage.setItem("familyOsBuildPassword",password);
  }catch(e){bar.style.width="0";status.textContent="שגיאה: "+e.message}
  finally{button.disabled=false}
});
const saved=sessionStorage.getItem("familyOsBuildPassword");if(saved)document.querySelector("#password").value=saved;
</script>
</body></html>`;

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (request.method === "GET" && url.pathname === "/") {
      return new Response(HTML, {
        headers: {
          "content-type": "text/html; charset=utf-8",
          "cache-control": "no-store",
          "x-content-type-options": "nosniff",
          "referrer-policy": "no-referrer",
        },
      });
    }

    if (request.method === "POST" && url.pathname === "/api/build") {
      return handleBuild(request, env, url);
    }

    if (request.method === "GET" && url.pathname.startsWith("/api/download/")) {
      return handleDownload(request, env, url);
    }

    return new Response("Not found", { status: 404 });
  },

  async scheduled(_event, env, ctx) {
    ctx.waitUntil(cleanOldBuilds(env));
  },
};

async function handleBuild(request, env, url) {
  try {
    const supplied = request.headers.get("X-Build-Password") ?? "";
    if (!supplied || !env.BUILD_PASSWORD || !constantTimeEqual(supplied, env.BUILD_PASSWORD)) {
      return json({ error: "סיסמה שגויה." }, 401);
    }

    const form = await request.formData();
    const file = form.get("file");
    const version = String(form.get("version") ?? "");

    if (!(file instanceof File) || !file.name.toLowerCase().endsWith(".zip")) {
      return json({ error: "יש לבחור קובץ ZIP." }, 400);
    }
    if (!/^\d+\.\d+\.\d+$/.test(version)) {
      return json({ error: "מספר גרסה לא תקין." }, 400);
    }
    if (file.size > 95 * 1024 * 1024) {
      return json({ error: "הקובץ גדול מ-95MB." }, 413);
    }

    const id = crypto.randomUUID();
    const token = randomHex(32);
    const tokenHash = await sha256(token);
    const key = `uploads/${Date.now()}-${id}.zip`;
    const expiresAt = Date.now() + 30 * 60 * 1000;

    await env.BUILDS.put(key, file.stream(), {
      httpMetadata: { contentType: "application/zip" },
      customMetadata: {
        tokenHash,
        expiresAt: String(expiresAt),
        originalName: file.name,
      },
    });

    const downloadUrl =
      `${url.origin}/api/download/${encodeURIComponent(key)}?token=${token}`;

    const dispatch = await fetch(
      `https://api.github.com/repos/${env.GITHUB_OWNER}/${env.GITHUB_REPO}/actions/workflows/${env.GITHUB_WORKFLOW}/dispatches`,
      {
        method: "POST",
        headers: {
          "Accept": "application/vnd.github+json",
          "Authorization": `Bearer ${env.GITHUB_TOKEN}`,
          "X-GitHub-Api-Version": "2026-03-10",
          "Content-Type": "application/json",
          "User-Agent": "family-os-cloud-builder",
        },
        body: JSON.stringify({
          ref: "main",
          inputs: {
            zip_url: downloadUrl,
            version,
            upload_key: key,
          },
        }),
      },
    );

    const responseText = await dispatch.text();
    if (!dispatch.ok) {
      await env.BUILDS.delete(key);
      console.error(responseText);
      return json({ error: `GitHub החזיר שגיאה ${dispatch.status}.` }, 502);
    }

    const data = responseText ? JSON.parse(responseText) : {};
    return json({
      ok: true,
      htmlUrl:
        data.html_url ??
        `https://github.com/${env.GITHUB_OWNER}/${env.GITHUB_REPO}/actions`,
    });
  } catch (error) {
    console.error(error);
    return json({ error: error?.message ?? "שגיאה לא צפויה." }, 500);
  }
}

async function handleDownload(_request, env, url) {
  const prefix = "/api/download/";
  const key = decodeURIComponent(url.pathname.slice(prefix.length));
  const token = url.searchParams.get("token") ?? "";
  if (!key || !token) return new Response("Unauthorized", { status: 401 });

  const object = await env.BUILDS.get(key);
  if (!object) return new Response("Not found", { status: 404 });

  const expiresAt = Number(object.customMetadata?.expiresAt ?? "0");
  const expectedHash = object.customMetadata?.tokenHash ?? "";
  const actualHash = await sha256(token);

  if (Date.now() > expiresAt || !constantTimeEqual(actualHash, expectedHash)) {
    return new Response("Expired or unauthorized", { status: 401 });
  }

  return new Response(object.body, {
    headers: {
      "content-type": "application/zip",
      "content-disposition": 'attachment; filename="family-os-upload.zip"',
      "cache-control": "no-store",
    },
  });
}

async function cleanOldBuilds(env) {
  let cursor;
  do {
    const listed = await env.BUILDS.list({ prefix: "uploads/", cursor });
    for (const item of listed.objects) {
      if (Date.now() - item.uploaded.getTime() > 2 * 60 * 60 * 1000) {
        await env.BUILDS.delete(item.key);
      }
    }
    cursor = listed.truncated ? listed.cursor : undefined;
  } while (cursor);
}

function json(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "content-type": "application/json; charset=utf-8",
      "cache-control": "no-store",
      "x-content-type-options": "nosniff",
    },
  });
}

function randomHex(bytes) {
  const data = new Uint8Array(bytes);
  crypto.getRandomValues(data);
  return [...data].map((value) => value.toString(16).padStart(2, "0")).join("");
}

async function sha256(value) {
  const digest = await crypto.subtle.digest(
    "SHA-256",
    new TextEncoder().encode(value),
  );
  return [...new Uint8Array(digest)]
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
}

function constantTimeEqual(left, right) {
  if (left.length !== right.length) return false;
  let result = 0;
  for (let index = 0; index < left.length; index += 1) {
    result |= left.charCodeAt(index) ^ right.charCodeAt(index);
  }
  return result === 0;
}
