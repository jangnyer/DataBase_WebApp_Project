-- 1) 콘텐츠 기본
CREATE TABLE contents (
  content_id INTEGER PRIMARY KEY AUTOINCREMENT,
  plan_done INTEGER NOT NULL DEFAULT 0,   -- 0/1
  plan_date TEXT,                         -- 'YYYY-MM-DD'
  title TEXT NOT NULL,
  description TEXT,
  script TEXT,
  thumbnail_concept TEXT,
  sponsored INTEGER NOT NULL DEFAULT 0,   -- 0/1
  created_at TEXT DEFAULT (datetime('now'))
);

-- 2) 플랫폼
CREATE TABLE platforms (
  platform_id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE              -- YouTube Shorts, TikTok, Reels, Xiaohongshu
);

-- 3) 콘텐츠-플랫폼 업로드/성과
CREATE TABLE content_platform (
  content_id INTEGER NOT NULL,
  platform_id INTEGER NOT NULL,
  is_uploaded INTEGER NOT NULL DEFAULT 0,
  upload_date TEXT,
  upload_url TEXT,
  views INTEGER DEFAULT 0,
  PRIMARY KEY (content_id, platform_id),
  FOREIGN KEY (content_id) REFERENCES contents(content_id),
  FOREIGN KEY (platform_id) REFERENCES platforms(platform_id)
);

-- 4) 키워드
CREATE TABLE keywords (
  keyword_id INTEGER PRIMARY KEY AUTOINCREMENT,
  keyword TEXT NOT NULL UNIQUE
);

-- 5) 콘텐츠-키워드 연결
CREATE TABLE content_keyword (
  content_id INTEGER NOT NULL,
  keyword_id INTEGER NOT NULL,
  PRIMARY KEY (content_id, keyword_id),
  FOREIGN KEY (content_id) REFERENCES contents(content_id),
  FOREIGN KEY (keyword_id) REFERENCES keywords(keyword_id)
);
