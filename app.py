from flask import Flask, render_template, request, redirect, url_for, abort
import sqlite3

APP_TITLE = "Shortform Marketing Dashboard"
DB_PATH = "shortform.db"

app = Flask(__name__)

def get_db():
    con = sqlite3.connect(DB_PATH)
    con.row_factory = sqlite3.Row
    return con

def parse_keywords(s: str):
    if not s:
        return []
    parts = [x.strip() for x in s.split(",")]
    parts = [x for x in parts if x]
    seen = set()
    out = []
    for x in parts:
        if x.lower() not in seen:
            seen.add(x.lower())
            out.append(x)
    return out

def set_keywords(con, content_id: int, keywords_list):
    cur = con.cursor()
    cur.execute("DELETE FROM content_keyword WHERE content_id=?", (content_id,))
    for kw in keywords_list:
        cur.execute("INSERT OR IGNORE INTO keywords(keyword) VALUES (?)", (kw,))
        kid = cur.execute("SELECT keyword_id FROM keywords WHERE keyword=?", (kw,)).fetchone()["keyword_id"]
        cur.execute("INSERT OR IGNORE INTO content_keyword(content_id, keyword_id) VALUES (?,?)", (content_id, kid))

def ensure_platform_rows(con, content_id: int):
    cur = con.cursor()
    platforms = cur.execute("SELECT platform_id FROM platforms").fetchall()
    for p in platforms:
        cur.execute(
            "INSERT OR IGNORE INTO content_platform(content_id, platform_id, is_uploaded, upload_date, upload_url, views) VALUES (?,?,?,?,?,?)",
            (content_id, p["platform_id"], 0, None, None, 0)
        )

@app.route("/")
def dashboard():
    con = get_db()
    cur = con.cursor()

    total_contents = cur.execute("SELECT COUNT(*) AS n FROM contents").fetchone()["n"]
    sponsored_cnt = cur.execute("SELECT COUNT(*) AS n FROM contents WHERE sponsored=1").fetchone()["n"]
    total_uploads = cur.execute("SELECT COALESCE(SUM(is_uploaded),0) AS n FROM content_platform").fetchone()["n"]
    total_views = cur.execute("SELECT COALESCE(SUM(COALESCE(views,0)),0) AS n FROM content_platform WHERE is_uploaded=1").fetchone()["n"]

    platform_uploads = cur.execute("""
        SELECT p.name, COALESCE(SUM(cp.is_uploaded),0) AS uploaded_count
        FROM platforms p
        LEFT JOIN content_platform cp ON cp.platform_id = p.platform_id
        GROUP BY p.platform_id
        ORDER BY uploaded_count DESC
    """).fetchall()

    recent_uploads = cur.execute("""
        SELECT c.title, p.name AS platform, cp.upload_date, cp.views
        FROM content_platform cp
        JOIN contents c ON c.content_id = cp.content_id
        JOIN platforms p ON p.platform_id = cp.platform_id
        WHERE cp.is_uploaded = 1
        ORDER BY cp.upload_date DESC
        LIMIT 10
    """).fetchall()

    top_keywords = cur.execute("""
        SELECT k.keyword, COUNT(*) AS cnt
        FROM content_keyword ck
        JOIN keywords k ON k.keyword_id = ck.keyword_id
        GROUP BY k.keyword_id
        ORDER BY cnt DESC
        LIMIT 10
    """).fetchall()

    con.close()

    return render_template(
        "dashboard.html",
        app_title=APP_TITLE,
        total_contents=total_contents,
        sponsored_cnt=sponsored_cnt,
        total_uploads=total_uploads,
        total_views=total_views,
        platform_uploads=platform_uploads,
        recent_uploads=recent_uploads,
        top_keywords=top_keywords,
    )

@app.route("/contents")
def contents():
    q = (request.args.get("q") or "").strip()
    platform = (request.args.get("platform") or "").strip()
    uploaded = (request.args.get("uploaded") or "").strip()   # "1" / "0" / ""
    sponsored = (request.args.get("sponsored") or "").strip() # "1" / "0" / ""

    con = get_db()
    cur = con.cursor()

    platforms = cur.execute("SELECT name FROM platforms ORDER BY name").fetchall()

    where = []
    params = []

    if q:
        where.append("c.title LIKE ?")
        params.append(f"%{q}%")

    if sponsored in ("0", "1"):
        where.append("c.sponsored = ?")
        params.append(int(sponsored))

    if uploaded in ("0", "1"):
        if uploaded == "1":
            where.append("""
                EXISTS (
                    SELECT 1 FROM content_platform cp
                    WHERE cp.content_id = c.content_id AND cp.is_uploaded = 1
                )
            """)
        else:
            where.append("""
                NOT EXISTS (
                    SELECT 1 FROM content_platform cp
                    WHERE cp.content_id = c.content_id AND cp.is_uploaded = 1
                )
            """)

    if platform:
        where.append("""
            EXISTS (
                SELECT 1
                FROM content_platform cp
                JOIN platforms p ON p.platform_id = cp.platform_id
                WHERE cp.content_id = c.content_id
                  AND p.name = ?
                  AND cp.is_uploaded = 1
            )
        """)
        params.append(platform)

    where_sql = ("WHERE " + " AND ".join(where)) if where else ""

    rows = cur.execute(f"""
        SELECT
          c.content_id,
          c.plan_done,
          c.plan_date,
          c.title,
          c.thumbnail_concept,
          c.sponsored,
          COALESCE((
            SELECT GROUP_CONCAT(p.name, ', ')
            FROM content_platform cp
            JOIN platforms p ON p.platform_id = cp.platform_id
            WHERE cp.content_id = c.content_id AND cp.is_uploaded = 1
          ), '-') AS uploaded_platforms,
          COALESCE((
            SELECT GROUP_CONCAT(k.keyword, ', ')
            FROM content_keyword ck
            JOIN keywords k ON k.keyword_id = ck.keyword_id
            WHERE ck.content_id = c.content_id
          ), '-') AS keywords
        FROM contents c
        {where_sql}
        ORDER BY COALESCE(c.plan_date, '0000-00-00') DESC, c.content_id DESC
        LIMIT 200
    """, params).fetchall()

    con.close()

    return render_template(
        "contents.html",
        app_title=APP_TITLE,
        rows=rows,
        platforms=platforms,
        q=q, platform=platform, uploaded=uploaded, sponsored=sponsored
    )

# -----------------------------
# CREATE (추가)
# -----------------------------
@app.route("/contents/new", methods=["GET", "POST"])
def content_new():
    con = get_db()
    cur = con.cursor()

    platform_rows = cur.execute("SELECT platform_id, name FROM platforms ORDER BY name").fetchall()

    if request.method == "POST":
        title = (request.form.get("title") or "").strip()
        if not title:
            con.close()
            return render_template(
                "content_form.html",
                app_title=APP_TITLE,
                mode="new",
                content=None,
                keyword_text=request.form.get("keywords", ""),
                platforms=platform_rows,
                platform_data={},
                error="제목(title)은 필수야!"
            )

        plan_done = 1 if request.form.get("plan_done") == "1" else 0
        plan_date = (request.form.get("plan_date") or "").strip() or None
        description = (request.form.get("description") or "").strip() or None
        script = (request.form.get("script") or "").strip() or None
        thumbnail_concept = (request.form.get("thumbnail_concept") or "").strip() or None
        sponsored = 1 if request.form.get("sponsored") == "1" else 0

        cur.execute("""
            INSERT INTO contents(plan_done, plan_date, title, description, script, thumbnail_concept, sponsored)
            VALUES (?,?,?,?,?,?,?)
        """, (plan_done, plan_date, title, description, script, thumbnail_concept, sponsored))
        content_id = cur.lastrowid

        # 플랫폼 기본 row 생성 + 폼 값 반영
        ensure_platform_rows(con, content_id)
        for p in platform_rows:
            pid = p["platform_id"]
            is_uploaded = 1 if request.form.get(f"pl_{pid}_uploaded") == "on" else 0
            upload_date = (request.form.get(f"pl_{pid}_date") or "").strip() or None
            upload_url = (request.form.get(f"pl_{pid}_url") or "").strip() or None
            views_raw = (request.form.get(f"pl_{pid}_views") or "").strip()
            try:
                views = int(views_raw) if views_raw else 0
            except ValueError:
                views = 0

            cur.execute("""
                UPDATE content_platform
                SET is_uploaded=?, upload_date=?, upload_url=?, views=?
                WHERE content_id=? AND platform_id=?
            """, (is_uploaded, upload_date, upload_url, views, content_id, pid))

        # 키워드
        keywords = parse_keywords(request.form.get("keywords", ""))
        set_keywords(con, content_id, keywords)

        con.commit()
        con.close()
        return redirect(url_for("contents"))

    con.close()
    return render_template(
        "content_form.html",
        app_title=APP_TITLE,
        mode="new",
        content=None,
        keyword_text="",
        platforms=platform_rows,
        platform_data={},
        error=None
    )

# -----------------------------
# UPDATE (수정)
# -----------------------------
@app.route("/contents/<int:content_id>/edit", methods=["GET", "POST"])
def content_edit(content_id: int):
    con = get_db()
    cur = con.cursor()

    content = cur.execute("SELECT * FROM contents WHERE content_id=?", (content_id,)).fetchone()
    if not content:
        con.close()
        abort(404)

    platform_rows = cur.execute("SELECT platform_id, name FROM platforms ORDER BY name").fetchall()
    platform_data = cur.execute("""
        SELECT cp.platform_id, cp.is_uploaded, cp.upload_date, cp.upload_url, COALESCE(cp.views,0) AS views
        FROM content_platform cp
        WHERE cp.content_id=?
    """, (content_id,)).fetchall()
    platform_data = {r["platform_id"]: r for r in platform_data}

    kw_text = cur.execute("""
        SELECT GROUP_CONCAT(k.keyword, ', ') AS s
        FROM content_keyword ck JOIN keywords k ON k.keyword_id=ck.keyword_id
        WHERE ck.content_id=?
    """, (content_id,)).fetchone()["s"] or ""

    if request.method == "POST":
        title = (request.form.get("title") or "").strip()
        if not title:
            con.close()
            return render_template(
                "content_form.html",
                app_title=APP_TITLE,
                mode="edit",
                content=content,
                keyword_text=request.form.get("keywords", kw_text),
                platforms=platform_rows,
                platform_data=platform_data,
                error="제목(title)은 필수야!"
            )

        plan_done = 1 if request.form.get("plan_done") == "1" else 0
        plan_date = (request.form.get("plan_date") or "").strip() or None
        description = (request.form.get("description") or "").strip() or None
        script = (request.form.get("script") or "").strip() or None
        thumbnail_concept = (request.form.get("thumbnail_concept") or "").strip() or None
        sponsored = 1 if request.form.get("sponsored") == "1" else 0

        cur.execute("""
            UPDATE contents
            SET plan_done=?, plan_date=?, title=?, description=?, script=?, thumbnail_concept=?, sponsored=?
            WHERE content_id=?
        """, (plan_done, plan_date, title, description, script, thumbnail_concept, sponsored, content_id))

        ensure_platform_rows(con, content_id)
        for p in platform_rows:
            pid = p["platform_id"]
            is_uploaded = 1 if request.form.get(f"pl_{pid}_uploaded") == "on" else 0
            upload_date = (request.form.get(f"pl_{pid}_date") or "").strip() or None
            upload_url = (request.form.get(f"pl_{pid}_url") or "").strip() or None
            views_raw = (request.form.get(f"pl_{pid}_views") or "").strip()
            try:
                views = int(views_raw) if views_raw else 0
            except ValueError:
                views = 0

            cur.execute("""
                UPDATE content_platform
                SET is_uploaded=?, upload_date=?, upload_url=?, views=?
                WHERE content_id=? AND platform_id=?
            """, (is_uploaded, upload_date, upload_url, views, content_id, pid))

        keywords = parse_keywords(request.form.get("keywords", ""))
        set_keywords(con, content_id, keywords)

        con.commit()
        con.close()
        return redirect(url_for("contents"))

    con.close()
    return render_template(
        "content_form.html",
        app_title=APP_TITLE,
        mode="edit",
        content=content,
        keyword_text=kw_text,
        platforms=platform_rows,
        platform_data=platform_data,
        error=None
    )

# -----------------------------
# DELETE (삭제)
# -----------------------------
@app.route("/contents/<int:content_id>/delete", methods=["POST"])
def content_delete(content_id: int):
    con = get_db()
    cur = con.cursor()

    exists = cur.execute("SELECT 1 FROM contents WHERE content_id=?", (content_id,)).fetchone()
    if not exists:
        con.close()
        abort(404)

    # 연관 테이블 먼저 삭제
    cur.execute("DELETE FROM content_platform WHERE content_id=?", (content_id,))
    cur.execute("DELETE FROM content_keyword WHERE content_id=?", (content_id,))
    cur.execute("DELETE FROM contents WHERE content_id=?", (content_id,))

    con.commit()
    con.close()
    return redirect(url_for("contents"))

if __name__ == "__main__":
    app.run(debug=True)
