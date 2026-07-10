# pi-twin

> **Obsidian 볼트 ↔ pi(`@earendil-works/pi-coding-agent`) 설정의 수동 양방향 디지털 트윈.**
> 자동 동기화·훅·백그라운드 프로세스 없음 — 사용자가 지시할 때만 에이전트가 적용한다.

`pi-twin` 스킬은 pi 코딩 에이전트에게 **트윈 폴더를 pi 실제 설정의 정확한 미러로 유지**하는 절차를 알려준다. 상태는 항상 **1:1**로 반영되고, 카운트·목록은 **Obsidian Bases** 동적 뷰로 파생되어 drift가 발생하지 않는다.

---

## ✨ 특징

- **1:1 원문 미러** — 스킬/에이전트 노트의 body는 원본과 **sha256이 동일**. 요약·재작성 금지.
- **Bases 동적 집계** — 카운트·목록은 정적 표 대신 `.base` 파일이 폴더에서 자동 파생. drift 원천 제거.
- **정직한 한계** — 자동 감지/능동 탐지/백그라운드 동기화를 **지원하지 않음**을 명시. 거짓 자동화 약속 없음.
- **검증된 재현성** — 결정론적 sha256 검증 절차. 다른 에이전트가 같은 절차 → 같은 결론(writing-skills TDD 통과).
- **보안 단일 정책** — 키/민감정보는 트윈에서 **영구 제외**(포함 허용 없음).

---

## 📋 전제조건

- [pi coding agent](https://github.com/earendil-works/pi-coding-agent) (`@earendil-works/pi-coding-agent`)
- [Obsidian](https://obsidian.md/) + **Bases 코어 플러그인** 활성화
- `pi-subagents` 패키지 (builtin 에이전트 미러 시)

---

## 🚀 설치

```bash
git clone https://github.com/<you>/pi-twin.git
cd pi-twin
./install.sh
```

`install.sh`가 4값(볼트 루트 / 트윈 폴더명 / Obsidian 볼트 이름 / pi 경로는 고정)을 입력받아 `~/.pi/agent/skills/pi-twin/SKILL.md`로 자동 치환·복사한다.

> 수동 설치를 원하면 `SKILL.md`를 `~/.pi/agent/skills/pi-twin/SKILL.md`로 복사한 뒤, 상단 **경로** 섹션의 `<YOUR_VAULT_ROOT>` / `<your-vault-name>` / `<twin-folder>` placeholder를 자기 환경으로 치환한다.

---

## 📖 사용법

설치 후 pi 세션에서 자연어로 지시한다.

| 지시 | 동작 |
|------|------|
| **"볼트에 반영해" / "Obsidian에 반영해"** | **방향 B** (pi → 볼트): 실제 pi 상태를 트윈 미러로 갱신 + git 커밋 |
| **"pi에 반영해"** | **방향 A** (볼트 → pi): 트윈 미러의 "원문" 블록을 실제 pi 파일에 적용 |

### 트윈 폴더 구조

[`examples/vault-structure.md`](examples/vault-structure.md) 참고 — Dashboard / Config / Agents / Skills / Extensions 와 `.base` 동적 인덱스 구성.

---

## 🔒 보안

- `auth.json`, `telegram.json`, `locks.json`, `*.key`, `*.pem`, `.env*` 등 키/민감정보는 **절대 트윈에 복사하거나 git 커밋하지 않는다.**
- `settings.json` 스냅숏의 `apiKey`/`$ENV_*` 값은 `***`로 마스킹.
- `.gitignore`가 1차 방어(권장 내용은 `examples/vault-structure.md`).
- 유저 질의는 "추가 제외 대상 확인" 용도로만 — **포함 허용 없음**(영구 제외 불변).

---

## 🧪 품질 / 검증

이 스킬은 [writing-skills TDD](https://github.com/obra/superpowers) (RED → REFACTOR → GREEN)로 검증됐다:

- **재현성**: frontmatter 제거 후 body `sha256` 비교 — 원본과 볼트가 같은 해시면 1:1 (결정론적).
- **정직성**: 능동 탐지 구호 제거, "이 기기/환경 고정" 한계 명시.
- **일관성**: 보안 정책 단일화, 1:1 원칙 전 영역 정합.

---

## 📁 구성

```
pi-twin/
├── SKILL.md                    # 스킬 본문 (경로 placeholder — 설치 시 치환)
├── README.md                   # 이 파일
├── LICENSE                     # MIT
├── install.sh                  # 자기 환경 입력 → pi 스킬 디렉토리 설치
└── examples/
    └── vault-structure.md      # 트윈 볼트 구조 예시 + .gitignore 최소 예시
```

---

## 📝 라이선스

[MIT](LICENSE) © 2026 pinion
