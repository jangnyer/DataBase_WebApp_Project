# Shortform Marketing Dashboard (Data-Driven Web Application)

여러 숏폼 플랫폼(YouTube Shorts / TikTok / Instagram Reels / Xiaohongshu)에 업로드한 콘텐츠를 한 곳에서 관리하는 **데이터 기반 웹 응용(Data-driven Web Application)** 입니다.  
대시보드에서 지표를 확인하고, 웹에서 **CRUD(추가/조회/수정/삭제)** 및 검색/필터링이 가능합니다.

---

## 👤 Team
- 1인 프로젝트 (201802302 최지혜)

---

## 🧰 Tech Stack / Environment
- **Language**: Python 3.x, HTML/CSS
- **Web Framework**: Flask
- **DBMS**: SQLite3 (`shortform.db`)
- **Template Engine**: Jinja2
- **OS**: Windows (PowerShell)

---

## ✨ Features

### Dashboard
- 총 콘텐츠 수 / 총 업로드 수 / 협찬 콘텐츠 수 / 총 조회수
- 플랫폼별 업로드 수
- 최근 업로드 10개
- 키워드 TOP 10

### Contents Management (CRUD)
- 콘텐츠 목록 + 검색/필터
- 콘텐츠 **상세 보기** (설명문/대본 포함)
- 콘텐츠 **추가 / 수정 / 삭제**
- 플랫폼별 업로드 정보(업로드 여부/날짜/URL/조회수) 저장

---

## 🗂 Project Structure

```text
final_project/
  app.py
  seed.sql
  shortform.db
  templates/
    dashboard.html
    contents.html
    content_form.html
    content_detail.html
  static/
    style.css
