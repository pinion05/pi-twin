# 트윈 볼트 구조 (예시)

pi-twin이 관리하는 Obsidian 볼트 내 트윈 폴더의 권장 구조입니다.
실제 볼트명/폴더명은 사용자 환경에 맞게(`install.sh` 입력값) 적용됩니다.

아래는 `<YOUR_VAULT_ROOT>/<twin-folder>/` 의 예시(`Pi Agent/`)입니다.

```
<YOUR_VAULT_ROOT>/              ← Obsidian 볼트 루트
└── Pi Agent/                   ← 트윈 폴더 (git repo)
    ├── 🏠 Dashboard.md         ← 전역 상태 (Bases 임베드로 자동 집계)
    ├── 📊 Pi Agent 구조도.md   ← 트윈 맵 (선택)
    ├── Config/
    │   ├── AGENTS-Config.md    ← ~/.pi/agent/AGENTS.md 미러 (양방향)
    │   ├── Settings-Snapshot.md← settings.json 미러 (키 *** 마스킹)
    │   └── Sync-Map.md         ← 매핑 가시성 (스킬 매핑 레지스트리의 미러)
    ├── Agents/
    │   ├── Agent-<Custom>.md   ← ~/.pi/agent/agents/*.md 미러 (양방향)
    │   └── Agent-<Builtin>.md  ← pi-subagents/agents/*.md 미러 (read-only)
    ├── Skills/
    │   ├── index.base          ← 스킬 동적 인덱스 (Bases)
    │   ├── Skills-Index.md     ← index.base 임베드
    │   └── <skill>.md          ← 각 SKILL.md 원문 미러 (body 1:1)
    └── Extensions/
        ├── Extensions.base     ← 확장 동적 인덱스 (Bases)
        ├── Extensions.md       ← Extensions.base 임베드
        └── Extension-<ext>.md  ← settings.json packages[] 미러
```

## 핵심 디자인

- **1:1 원문 미러**: 스킬/에이전트 노트 body는 원본 `SKILL.md`/에이전트 정의와 **바이트 단위 동일**(frontmatter 제거 후 sha256 검증).
- **Bases 동적 집계**: 카운트·목록은 정적 금지 → `.base` 파일이 폴더에서 자동 파생(drift 원천 제거).
- **보안**: `auth.json`/`telegram.json`/`locks.json`/`*.key`/`.env*` 등은 `.gitignore`로 영구 제외.

## .gitignore 최소 예시

트윈 폴더 루트에 두는 방어적 `.gitignore`:

```gitignore
# Obsidian 로컬 상태
.obsidian/workspace*
.obsidian/cache
.obsidian/app.json
.DS_Store

# 키/민감정보 — 절대 커밋 금지
auth.json
telegram.json
locks.json
*-secret*
*.key
*.pem
.env
.env.*
```
