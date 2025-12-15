-- 플랫폼별 업로드된 콘텐츠 수
SELECT p.name, SUM(cp.is_uploaded) AS uploaded_count
FROM platforms p
LEFT JOIN content_platform cp ON cp.platform_id = p.platform_id
GROUP BY p.platform_id
ORDER BY uploaded_count DESC;

-- 아직 업로드 안된 콘텐츠 
SELECT c.content_id, c.title, c.plan_date
FROM contents c
WHERE c.plan_done = 1
AND NOT EXISTS (
  SELECT 1 FROM content_platform cp
  WHERE cp.content_id = c.content_id AND cp.is_uploaded = 1
)
ORDER BY c.plan_date DESC;

-- 최근 7일 업로드 콘텐츠
SELECT c.title, p.name, cp.upload_date, cp.views
FROM content_platform cp
JOIN contents c ON c.content_id = cp.content_id
JOIN platforms p ON p.platform_id = cp.platform_id
WHERE cp.is_uploaded = 1
AND cp.upload_date >= date('now','-7 day')
ORDER BY cp.upload_date DESC;



-- 키워드별 콘텐츠 개수 TOP
SELECT k.keyword, COUNT(*) AS cnt
FROM content_keyword ck
JOIN keywords k ON k.keyword_id = ck.keyword_id
GROUP BY k.keyword_id
ORDER BY cnt DESC
LIMIT 10;


-- 조회수 TOP 
SELECT c.title, p.name, cp.views
FROM content_platform cp
JOIN contents c ON c.content_id = cp.content_id
JOIN platforms p ON p.platform_id = cp.platform_id
WHERE cp.is_uploaded = 1
ORDER BY cp.views DESC
LIMIT 10;


