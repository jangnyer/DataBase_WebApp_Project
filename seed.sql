

PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS content_keyword;
DROP TABLE IF EXISTS content_platform;
DROP TABLE IF EXISTS keywords;
DROP TABLE IF EXISTS platforms;
DROP TABLE IF EXISTS contents;

CREATE TABLE contents (
  content_id INTEGER PRIMARY KEY AUTOINCREMENT,
  plan_done INTEGER NOT NULL DEFAULT 0,
  plan_date TEXT,
  title TEXT NOT NULL,
  description TEXT,
  script TEXT,
  thumbnail_concept TEXT,
  sponsored INTEGER NOT NULL DEFAULT 0,
  created_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE platforms (
  platform_id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE
);

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

CREATE TABLE keywords (
  keyword_id INTEGER PRIMARY KEY AUTOINCREMENT,
  keyword TEXT NOT NULL UNIQUE
);

CREATE TABLE content_keyword (
  content_id INTEGER NOT NULL,
  keyword_id INTEGER NOT NULL,
  PRIMARY KEY (content_id, keyword_id),
  FOREIGN KEY (content_id) REFERENCES contents(content_id),
  FOREIGN KEY (keyword_id) REFERENCES keywords(keyword_id)
);


INSERT INTO platforms(platform_id, name) VALUES
(1, '유튜브'),
(2, '틱톡'),
(3, '인스타그램'),
(4, '샤오홍슈');


INSERT INTO keywords(keyword_id, keyword) VALUES
(1,'저당'),
(2,'다이어트'),
(3,'레시피'),
(4,'에어프라이어'),
(5,'알룰로스'),
(6,'아몬드가루'),
(7,'단백질'),
(8,'브이로그'),
(9,'리뷰'),
(10,'꿀팁'),
(11,'루틴'),
(12,'운동'),
(13,'혈당'),
(14,'간식'),
(15,'식단'),
(16,'카페'),
(17,'인천'),
(18,'송도'),
(19,'협찬'),
(20,'썸네일'),
(21,'후킹'),
(22,'콘텐츠기획'),
(23,'대시보드'),
(24,'마케팅');

INSERT INTO contents(content_id, plan_done, plan_date, title, description, script, thumbnail_concept, sponsored) VALUES
(1, 1, '2025-11-02', '저당 파운드케이크 20분 컷', '계란+아몬드가루+알룰로스로 만드는 초간단 저당 파운드. 에어프라이어 한 번에 끝.', '오프닝: 외계인 안경 ON. 오늘은 저당 파운드케이크! 재료 5개만. 20분 뒤 바로 먹는다.', '완성샷 클로즈업 + “20분” 큰 글자', 0),
(2, 1, '2025-11-05', '혈당 스파이크 줄이는 아침 루틴', '아침에 이것만 바꿔도 혈당이 달라진다. 3단계 루틴 정리.', '아침 루틴 1) 물 2) 단백질 3) 10분 산책. 순서가 포인트!', '3단계 체크리스트 썸네일', 0),
(3, 1, '2025-11-07', '편의점 다이어트 간식 TOP5', '바쁜 날에도 실패하지 않는 편의점 간식 추천.', '이거 5개만 기억하면 편의점에서도 다이어트 가능. 마지막이 진짜 꿀팁.', '진열대 배경 + TOP5 랭킹', 0),
(4, 1, '2025-11-09', '인천 송도 카페 저당 디저트 리뷰', '송도 카페에서 먹은 저당 디저트 솔직 후기.', '이거 맛 없으면 바로 아웃인데… 생각보다 괜찮다! 당류 확인도 같이.', '카페 컵 + “저당?” 물음표', 0),
(5, 1, '2025-11-11', '에어프라이어 닭가슴살 촉촉하게 굽는 법', '뻑뻑함 없는 촉촉 닭가슴살 굽기. 시간/온도/뒤집기 팁.', '다이어트 최대 난제: 닭가슴살. 오늘은 촉촉 버전으로 간다.', '단면샷 + “촉촉” 강조', 0),
(6, 1, '2025-11-13', '다이어트 중 야식 땡길 때 대처 3가지', '야식 욕구를 줄이는 실전 대처법. (물/대체간식/환경)', '야식이 땡길 때 의지가 아니라 환경을 바꿔야 한다. 3가지만 해보자.', '밤 배경 + “야식 STOP”', 0),
(7, 1, '2025-11-15', '혈당 낮추는 식사 순서 실험', '채소→단백질→탄수 순서로 먹으면 몸이 어떻게 반응?', '같은 메뉴인데 순서만 바꿨다. 결과가 꽤 차이난다.', '같은 접시 2개 비교', 0),
(8, 1, '2025-11-16', '저당 초코 케이크(카카오 버전)', '기본 반죽에 카카오 넣어서 만드는 저당 초코 케이크.', '오늘은 카카오 넣어서 초코로 간다. 진짜 디저트 느낌!', '초코 가루 뿌리는 장면', 0),
(9, 1, '2025-11-18', '운동 초보 루틴: 15분만', '헬린이도 가능한 15분 루틴(전신).', '딱 15분만! 오늘은 전신 루틴. 힘들면 동작 수를 줄여도 된다.', '타이머 15:00 + 전신 아이콘', 0),
(10,1, '2025-11-19', '썸네일 한 끗 차이: 조회수 2배 사례', '썸네일 문구/구도/색 대비로 조회수 바뀐 사례 공유.', '같은 영상인데 썸네일만 바꿨다. 결과는? 조회수 2배.', '전/후 썸네일 비교', 0),
(11,1, '2025-11-21', '숏폼 후킹 멘트 10개 템플릿', '첫 2초에 쓰는 후킹 멘트 10개. 바로 가져다 쓰기.', '“이거 몰랐지?” 같은 말보다, 상황+이득을 같이 던져야 한다.', '따옴표 말풍선 + “2초 후킹”', 0),
(12,1, '2025-11-23', '인천 콘텐츠 행사 브이로그(짧게)', '행사 현장 분위기, 부스, 사람들 반응을 빠르게.', '여기 분위기 미쳤다. 10초만에 핵심만 보여줄게.', '현장 사람 많은 샷 + “브이로그”', 0),
(13,1, '2025-11-25', '저당 도시락 1주일 구성', '월~금 도시락 구성 아이디어. 단백질/채소/탄수 밸런스.', '도시락은 “반복”이 답. 1주일 구성으로 스트레스 줄이자.', '5칸 도시락 구성 이미지', 0),
(14,1, '2025-11-26', '협찬 영상 표시, 어디까지 해야 안전?', '협찬 표기 방식/문구 예시 정리(실무 관점).', '협찬은 숨기면 리스크. 표시 기준은 딱 이 정도로 하자.', '“협찬” 라벨 크게', 0),
(15,1, '2025-11-28', '샤오홍슈용 자막 스타일 추천', '샤오홍슈에서 잘 먹히는 자막/템포/구도 포인트.', '한 줄이 아니라 “두 줄” 자막이 핵심. 그리고 속도는 빨라야 한다.', '중문 느낌 자막 예시', 0),
(16,1, '2025-11-30', '틱톡 알고리즘이 좋아하는 편집 리듬', '컷 전환, 화면 줌, SFX 타이밍 팁.', '틱톡은 리듬 게임이다. 1.5초마다 정보가 바뀌어야 산다.', '파형 그래프 + “리듬”', 0),
(17,1, '2025-12-02', '조회수 낮을 때 체크리스트 7개', '제목/첫 2초/자막/길이/태그/업로드 시간 점검.', '조회수 낮을 때 “운” 탓하지 말고 체크리스트부터.', '체크박스 7개', 0),
(18,1, '2025-12-04', '인스타 릴스 자막 가독성 꿀팁', '폰 화면에서 읽히는 폰트 크기/위치/배경 처리.', '자막은 예쁘게보다 “읽히게”. 배경 블러/박스가 답이다.', '자막 박스 전/후 비교', 0),
(19,1, '2025-12-06', '저당 쑥 파운드', '기본 반죽 3등분해서 쑥 넣는 버전. 향이 미쳤다.', '쑥 좋아하면 이거 무조건. 한 입 먹으면 “어? 이게 저당?”', '쑥색 반죽 + “쑥향”', 0),
(20,1, '2025-12-08', '숏폼 마케팅 대시보드, 이렇게 쓰면 편함', '여러 플랫폼 업로드/조회수/키워드를 한 번에 관리하는 방식 소개.', '업로드 체크만 해도 일이 줄어든다. 대시보드로 한 방에 관리하자.', '대시보드 화면 모형 + “한눈에”', 0);

-- ===== 콘텐츠-플랫폼 상태(각 콘텐츠마다 4개 플랫폼 행 생성) =====
-- 규칙: 일부만 업로드(시연용), 조회수는 적당히 랜덤
INSERT INTO content_platform(content_id, platform_id, is_uploaded, upload_date, upload_url, views) VALUES
-- content 1
(1,1,1,'2025-11-03','https://example.com/y/shorts/1',18400),
(1,2,1,'2025-11-03','https://example.com/tk/1',9200),
(1,3,1,'2025-11-04','https://example.com/ig/reels/1',7600),
(1,4,0,NULL,NULL,0),

-- content 2
(2,1,1,'2025-11-06','https://example.com/y/shorts/2',11200),
(2,2,0,NULL,NULL,0),
(2,3,1,'2025-11-06','https://example.com/ig/reels/2',5300),
(2,4,0,NULL,NULL,0),

-- content 3
(3,1,1,'2025-11-08','https://example.com/y/shorts/3',9800),
(3,2,1,'2025-11-08','https://example.com/tk/3',15300),
(3,3,0,NULL,NULL,0),
(3,4,0,NULL,NULL,0),

-- content 4
(4,1,0,NULL,NULL,0),
(4,2,0,NULL,NULL,0),
(4,3,1,'2025-11-10','https://example.com/ig/reels/4',4200),
(4,4,1,'2025-11-12','https://example.com/xhs/4',8700),

-- content 5
(5,1,1,'2025-11-12','https://example.com/y/shorts/5',6600),
(5,2,1,'2025-11-12','https://example.com/tk/5',7400),
(5,3,1,'2025-11-13','https://example.com/ig/reels/5',5100),
(5,4,0,NULL,NULL,0),

-- content 6
(6,1,1,'2025-11-14','https://example.com/y/shorts/6',3900),
(6,2,0,NULL,NULL,0),
(6,3,0,NULL,NULL,0),
(6,4,0,NULL,NULL,0),

-- content 7
(7,1,1,'2025-11-16','https://example.com/y/shorts/7',8200),
(7,2,1,'2025-11-16','https://example.com/tk/7',6100),
(7,3,1,'2025-11-17','https://example.com/ig/reels/7',5400),
(7,4,0,NULL,NULL,0),

-- content 8
(8,1,1,'2025-11-18','https://example.com/y/shorts/8',12400),
(8,2,1,'2025-11-18','https://example.com/tk/8',20200),
(8,3,0,NULL,NULL,0),
(8,4,0,NULL,NULL,0),

-- content 9
(9,1,0,NULL,NULL,0),
(9,2,1,'2025-11-20','https://example.com/tk/9',5100),
(9,3,1,'2025-11-20','https://example.com/ig/reels/9',4700),
(9,4,0,NULL,NULL,0),

-- content 10
(10,1,1,'2025-11-20','https://example.com/y/shorts/10',26000),
(10,2,0,NULL,NULL,0),
(10,3,1,'2025-11-21','https://example.com/ig/reels/10',9100),
(10,4,0,NULL,NULL,0),

-- content 11
(11,1,1,'2025-11-22','https://example.com/y/shorts/11',14500),
(11,2,1,'2025-11-22','https://example.com/tk/11',11900),
(11,3,1,'2025-11-23','https://example.com/ig/reels/11',8700),
(11,4,0,NULL,NULL,0),

-- content 12
(12,1,0,NULL,NULL,0),
(12,2,0,NULL,NULL,0),
(12,3,1,'2025-11-24','https://example.com/ig/reels/12',3300),
(12,4,0,NULL,NULL,0),

-- content 13
(13,1,1,'2025-11-26','https://example.com/y/shorts/13',7700),
(13,2,1,'2025-11-26','https://example.com/tk/13',6800),
(13,3,0,NULL,NULL,0),
(13,4,1,'2025-11-27','https://example.com/xhs/13',9900),

-- content 14 (협찬)
(14,1,1,'2025-11-27','https://example.com/y/shorts/14',5200),
(14,2,0,NULL,NULL,0),
(14,3,1,'2025-11-28','https://example.com/ig/reels/14',4100),
(14,4,0,NULL,NULL,0),

-- content 15
(15,1,0,NULL,NULL,0),
(15,2,0,NULL,NULL,0),
(15,3,0,NULL,NULL,0),
(15,4,1,'2025-12-01','https://example.com/xhs/15',15400),

-- content 16
(16,1,1,'2025-12-01','https://example.com/y/shorts/16',6900),
(16,2,1,'2025-12-01','https://example.com/tk/16',13200),
(16,3,0,NULL,NULL,0),
(16,4,0,NULL,NULL,0),

-- content 17
(17,1,1,'2025-12-03','https://example.com/y/shorts/17',4800),
(17,2,0,NULL,NULL,0),
(17,3,1,'2025-12-03','https://example.com/ig/reels/17',4500),
(17,4,0,NULL,NULL,0),

-- content 18
(18,1,0,NULL,NULL,0),
(18,2,0,NULL,NULL,0),
(18,3,1,'2025-12-05','https://example.com/ig/reels/18',7200),
(18,4,0,NULL,NULL,0),

-- content 19
(19,1,1,'2025-12-07','https://example.com/y/shorts/19',20100),
(19,2,1,'2025-12-07','https://example.com/tk/19',17800),
(19,3,1,'2025-12-08','https://example.com/ig/reels/19',9300),
(19,4,0,NULL,NULL,0),

-- content 20
(20,1,1,'2025-12-09','https://example.com/y/shorts/20',6400),
(20,2,0,NULL,NULL,0),
(20,3,0,NULL,NULL,0),
(20,4,0,NULL,NULL,0);

-- ===== 콘텐츠-키워드 연결 =====
-- helper: 각 콘텐츠에 3~5개 키워드 매칭
INSERT INTO content_keyword(content_id, keyword_id) VALUES
-- 1
(1,1),(1,2),(1,3),(1,4),(1,5),(1,6),
-- 2
(2,13),(2,2),(2,11),(2,10),
-- 3
(3,2),(3,14),(3,10),(3,15),
-- 4
(4,16),(4,17),(4,18),(4,9),(4,2),
-- 5
(5,7),(5,2),(5,3),(5,10),
-- 6
(6,2),(6,15),(6,10),(6,11),
-- 7
(7,13),(7,15),(7,2),(7,10),
-- 8
(8,1),(8,2),(8,3),(8,4),(8,5),
-- 9
(9,12),(9,11),(9,2),
-- 10
(10,20),(10,24),(10,23),(10,10),
-- 11
(11,21),(11,22),(11,24),(11,10),
-- 12
(12,8),(12,17),(12,18),
-- 13
(13,15),(13,2),(13,3),(13,10),
-- 14 (협찬)
(14,19),(14,24),(14,10),(14,22),
-- 15
(15,4),(15,24),(15,10),(15,22),
-- 16
(16,24),(16,10),(16,21),(16,22),
-- 17
(17,23),(17,24),(17,10),(17,22),
-- 18
(18,20),(18,24),(18,10),
-- 19
(19,1),(19,2),(19,3),(19,4),(19,5),(19,6),
-- 20
(20,23),(20,24),(20,22),(20,10);

-- ===== 협찬 표시(콘텐츠 14만 협찬=1로 업데이트) =====
UPDATE contents SET sponsored = 1 WHERE content_id = 14;

-- 끝
