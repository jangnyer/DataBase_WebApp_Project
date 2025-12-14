from flask import Flask, render_template, request
import sqlite3

APP_TITLE = "Shortform Marketing Dashboard"
DB_PATH = "shortform.db"

app = Flask(__name__)

def get_db():
    con = sqlite3.connect(DB_PATH)
    con.row_factory = sqlite3.Row
    return con

@app.route("/")
def dashboard():
    con = get_db()
    cur = con.cursor()

    # 카드 지표
    total_contents = cur.execute("SELECT COUNT(*) AS n FROM contents").fetchone()["n"]
    sponsored_cnt = cur.execute("SELECT COUNT(*) AS n FROM contents WHERE sponsored=1").fetchone()["n"]
    total_uploads = cur.execute("SELECT COALESCE(SUM(is_uploaded),0) AS n FROM content_platform").fetchone()["n"]
    total_views = cur.execute("SELECT COALESCE(SUM(views),0) AS n FROM content_platform WHERE is_uploaded=1").fetchone()["n"]

    # 플랫폼별 업로드 수
    platform_uploads = cur.execute("""
        SELECT p.name, COALESCE(SUM(cp.is_uploaded),0) AS uploaded_count
        FROM platforms p
        LEFT JOIN content_platform cp ON cp.platform_id = p.platform_id
        GROUP BY p.platform_id
        ORDER BY uploaded_count DESC
    """).fetchall()

    # 최근 업로드 10개
    recent_uploads = cur.execute("""
        SELECT c.title, p.name AS platform, cp.upload_date, cp.views
        FROM content_platform cp
        JOIN contents c ON c.content_id = cp.content_id
        JOIN platforms p ON p.platform_id = cp.platform_id
        WHERE cp.is_uploaded = 1
        ORDER BY cp.upload_date DESC
        LIMIT 10
    """).fetchall()

    # 키워드 TOP 10
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
    # 필터(선택)
    q = (request.args.get("q") or "").strip()
    platform = (request.args.get("platform") or "").strip()
    uploaded = (request.args.get("uploaded") or "").strip()   # "1" or "0" or ""
    sponsored = (request.args.get("sponsored") or "").strip() # "1" or "0" or ""

    con = get_db()
    cur = con.cursor()

    platforms = cur.execute("SELECT name FROM platforms ORDER BY name").fetchall()

    where = []
    params = []

    # 제목 검색
    if q:
        where.append("c.title LIKE ?")
        params.append(f"%{q}%")

    # 협찬 여부
    if sponsored in ("0", "1"):
        where.append("c.sponsored = ?")
        params.append(int(sponsored))

    # 업로드 여부(전체 플랫폼 중 하나라도 업로드 됐는지)
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

    # 특정 플랫폼 업로드 여부
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
          -- 업로드된 플랫폼 목록
          COALESCE((
            SELECT GROUP_CONCAT(p.name, ', ')
            FROM content_platform cp
            JOIN platforms p ON p.platform_id = cp.platform_id
            WHERE cp.content_id = c.content_id AND cp.is_uploaded = 1
          ), '-') AS uploaded_platforms,
          -- 키워드 목록
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

if __name__ == "__main__":
    app.run(debug=True)
