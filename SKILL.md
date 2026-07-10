---
name: pi-twin
description: >-
  Obsidian "Pi Agent" 볼트와 실제 pi 설정(~/.pi/agent) 사이의 수동 양방향
  동기화(디지털 트윈). 자동 동기화 없음 — 사용자가 지시할 때만 에이전트가 적용.
  Triggers — "Obsidian에 반영해", "볼트에 반영해", "pi에 반영해", "트윈 동기화",
  vault/vault 반영, Sync-Map, 디지털 트윈.
---

# pi-twin — Obsidian 볼트 ↔ pi 설정 동기화

Obsidian 볼트의 `Pi Agent/` 폴더가 pi 에이전트의 **디지털 트윈**이다. 이 skill은
양쪽을 수동으로 맞추는 절차를 정의한다.

> **모델:** 수동 양방향 보고서. 자동 동기화·훅·백그라운드 프로세스 **없음**.
> 에이전트가 양 시스템 사이의 적용자다. 사용자가 지시할 때만 한쪽에서 다른 쪽으로 반영한다.

## 경로 (사용자 환경 — 설치 시 설정)

> pi-twin은 **자동 감지/능동 탐지를 지원하지 않습니다** (정직한 한계). 설치 후 아래 4값을 **자기 환경으로 치환**해야 동작합니다. `install.sh`가 입력을 받아 자동 치환합니다.

- **볼트 루트:** `<YOUR_VAULT_ROOT>` (예: `~/Documents/my-vault/`)
- **트윈 폴더:** `<YOUR_VAULT_ROOT>/<twin-folder>/` (예: `Pi Agent/`, git repo, branch `main`)
- **실제 pi:** `~/.pi/agent/` (고정 — pi 표준 경로)
- **Obsidian CLI:** `obsidian vault="<your-vault-name>" ...` (Obsidian 실행 중일 때)

**치환:** `install.sh` 실행 → 4값 입력 → 자동 반영. 또는 SKILL.md 직접 편집. 보안은 아래 🔒 규칙(영구 제외) 따름.

## 매핑 레지스트리

| 볼트 문서 | 실제 pi 대상 | 방향 |
|----------|------------|:----:|
| `Config/AGENTS-Config.md` | `~/.pi/agent/AGENTS.md` | 양방향 (원문 미러) |
| `Config/Settings-Snapshot.md` | `~/.pi/agent/settings.json` | 부분 양방향 (`packages`, `subagents`, `defaultModel`, `defaultProvider`) |
| `Extensions/Extensions.md` | `settings.json` → `packages[]` | 양방향 (전체 패키지 목록) |
| `Extensions/Extension-*.md` | `packages[]` 각 항목 상세 | 양방향 (패키지별 노드: `package`·`version`·`status`; "현재 설정" 섹션) |
| `Agents/Agent-*.md` | `~/.pi/agent/agents/*.md` | 양방향 (커스텀 에이전트 정의) |
| `Agents/Agent-*.md` (builtin) | `pi-subagents/agents/*.md` | 읽기 전용 (패키지 원문 미러, 단방향 가시성) |
| `Skills/*.md` | 각 스킬 `SKILL.md` 원문 | 양방향 (원문 미러 — 볼트 fm에 Bases 속성 추가) |
| `🏠 Dashboard.md` | 전역 상태 (모델·카운트) | pi→볼트 (가시성) |

이 매핑이 진실의 원천이다. Obsidian의 `Config/Sync-Map.md`는 이 표의 가시성 미러.

## Bases 파생 규칙 (1:1 상태 반영)

카운트·목록·합계는 **정적 금지** → Bases 동적 뷰로 파생 (drift 원천 제거).

**1:1 원칙** (불변): pi에 실존하는 속성만 사용. 임의 주제 분류(`category`) 생성·부여 금지 — 상태 왜곡·혼란.
- 스킬: `source` · `tags` · `status` · `description_tokens` → `Skills/index.base`
- 확장: `package` · `version` · `status` → `Extensions/Extensions.base`

**속성값 정의** (임의 해석 방지 — 재현성):
- `source` (스킬 원본 설치 위치): `builtin` · `package`(npm) · `git`(깃 클론) · `caveman` · `user`(직접 작성)
- `status`: `active` (정상) · `broken` (오류/사용 불가). 기본 `active`
- `description_tokens`: 원본 `description` 텍스트의 대략적 토큰 수 = `floor(len(description) ÷ 4)`. 근사치 (Bases 정렬/필터용)
- `package`: npm 패키지명 (확장 노드) · `version`: 패키지 버전 문자열

**임베드**: 인덱스 노트는 `![[index.base#전체 요약]]` / `![[Extensions.base#전체 요약]]` 형태.
- 방향 A/B 공통: 정적 카운트·목록 발견 → 대응 base 뷰 임베드로 치환.

**Bases 파일 스키마** (틀리면 Obsidian이 렌더링 실패 — **이 스키마 그대로 작성**):

```yaml
filters: file.hasTag("skill")     # 함수 표현식 문자열 하나. and:/or: 맵 ❌
views:                             # 반드시 **배열** (- name: 항목). 객체(이름:) ❌
  - name: 소스별 요약
    type: table
    groupBy:                       # 그룹화만 지원. order:/sort:/columnSize ❌
      property: source
      direction: asc
  - name: 전체 요약
    type: table
```

> **자주 틀리는 함정** (재현 시 이 3개가 계속 틀림):
> - `filters: and: [...]` → `filters: file.hasTag("...")` 표현식으로
> - `views: <이름>:` (객체) → `views:` 아래 `- name: <이름>` (배열)로 — 아니면 "뷰는 반드시 배열이어야 함" 에러
> - `order:`/`sort:` → 미지원. 그룹화는 `groupBy: {property, direction}` 만

**도구**: Obsidian 코어 Bases **단일**. Dataview/CustomJS 미사용 (③ 런타임 메타 자동화 필요 시 별도 검토).

### 스킬 노트 1:1 원문 미러 (불변)

- 볼트 `Skills/*.md`의 **body는 pi 원본 `SKILL.md` 원문 그대로** (요약·재작성 금지).
- **원본 탐색** (볼트 노트 `<name>.md` → 원본, 이 glob 순서대로 첫 매칭 사용):
  1. `~/.pi/agent/skills/<name>/SKILL.md`
  2. `~/.pi/agent/skills/<name>--*/SKILL.md` (해시 디렉토리)
  3. `~/.pi/agent/npm/node_modules/*/skills/<name>/SKILL.md` (패키지 스킬)
  4. `~/.pi/agent/git/*/*/*/skills/<name>/SKILL.md` (superpowers 등 깊은 클론)
  5. `~/.pi/agent/git/*/skills/<name>/SKILL.md`
  6. `~/.pi/caveman/skills/<name>/SKILL.md` 및 `<name>--*/`
- 볼트 **frontmatter**에 Bases 속성(`tags: skill` · `source` · `status` · `description_tokens`) 보존 + 원본 메타(`name` · `description`) 병합.
- 원본의 상대 링크(`references/...`)는 볼트에서 **깨질 수 있음을 수용** (1:1은 파일 내용 기준).
- **동기화**: 스킬 원본이 바뀌면 방향 B로 볼트 body 재복사 (frontmatter는 보존).
- **검증 (재현성, 결정론적)**: 파일을 `'---\n'` 로 split → `parts[2]` 가 body (frontmatter는 첫 `---\n`…둘째 `---\n` 사이; **body는 그 직후부터 파일 끝까지, trim/strip 없이**). 원본·볼트 body 의 `sha256` 이 같으면 1:1. **정규식 기반 추출 금지** — 개행 처리가 달라 해시가 틀림. split 기반 고정.

## 방향 A — Obsidian → pi  *(사용자: "… pi에 반영해")*

1. **읽기** — 볼트 미러 문서에서 "원문 (이 블록을 편집)" 코드블록 추출.
2. **적용** — 실제 pi 파일에 `edit`/`write`. 코드블록 내용이 곧 파일 원문.
3. **검증** —
   - JSON 파일: `python3 -m json.tool` 로 유효성
   - AGENTS.md / 에이전트 .md: frontmatter 구조 + 구문
   - `subagent({action:"list"})` 로 에이전트/설정 반영 확인
4. **보고** — 변경 파일 + 검증 증거(명령 exit code).

## 방향 B — pi → Obsidian  *(사용자: "… Obsidian에 반영해" / "볼트에 반영해")*

1. **읽기** — 실제 pi 파일/상태 확인.
2. **갱신** — 볼트 미러 노드의 "원문" 블록과 요약 표를 실제 파일 기준으로 맞춤.
3. **커밋** — `cd "Pi Agent/" && git add -A && git commit -m "<컨벤션 메시지>"`.
4. **보고** — 커밋 해시(`git rev-parse --short HEAD`) + 변경 요약.

커밋 후 **키 노출 재스캔** 권장 (아래 보안).

## 🔒 보안 규칙 (불변)

> **키/민감정보는 트윈에서 영구 제외.** 다음은 절대 볼트에 복사하거나 git 커밋하지 않는다:
> - `~/.pi/agent/auth.json` — API 키 (각 LLM provider)
> - `~/.pi/agent/telegram.json` — 봇 토큰
> - `~/.pi/agent/locks.json`
> - `models.json` / `settings.json` 내 `apiKey`, `$ENV_*` 값 → 스냅샷 시 `***` 마스킹

`.gitignore`가 1차 방어. 에이전트는 적용·커밋 시에도 이 값을 복사하지 않는다.
**유저 질의**는 "추가 제외 대상 확인" 용도로만 — **포함 허용 없음** (영구 제외 불변).
방향 B 커밋 전, 실제 키 값이 볼트 파일에 없는지 스캔한다.

## 커밋 컨벤션

| 접두어 | 의미 |
|--------|------|
| `twin: reflect <대상> to vault` | 방향 B — pi→볼트 반영 |
| `twin: apply <대상> to pi` | 방향 A — 볼트→pi 적용 완료 |
| `docs(<영역>): ...` | 일반 문서 작성/수정 |
| `chore: ...` | 구조/설정 정리 |

## 검증 체크리스트

지시 처리 전·후 확인:
- [ ] 매핑된 실제 파일이 존재하는가?
- [ ] 변경 후 JSON/구문이 유효한가? (방향 A)
- [ ] 키/민감값이 누출되지 않았는가? (양방향)
- [ ] 커밋 메시지가 컨벤션을 따르는가? (방향 B)
- [ ] 위키링크가 미해결로 남지 않았는가? (방향 B)

## 동적 상태 (선택 가시성)

- `🏠 Dashboard.md` 상단 `last updated` 갱신
- 활성 패키지/스킬/에이전트 카운트 유지
- 트윈 폴더는 항상 `git status` clean 유지
