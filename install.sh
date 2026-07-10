#!/usr/bin/env bash
# pi-twin 스킬 설치 — 자기 환경 4값으로 경로 치환 후 pi 스킬 디렉토리에 복사
set -euo pipefail

SKILL_DIR="${HOME}/.pi/agent/skills/pi-twin"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="${SCRIPT_DIR}/SKILL.md"

if [ ! -f "$SRC" ]; then
  echo "❌ SKILL.md 를 찾을 수 없음: $SRC" >&2
  exit 1
fi

echo "=== pi-twin 설치 (자기 환경 입력) ==="
echo

read -rp "볼트 루트 절대경로 (예: ${HOME}/Documents/my-vault): " VAULT_ROOT
read -rp "트윈 폴더명 (볼트 루트 하위, 예: Pi Agent): " TWIN_FOLDER
read -rp "Obsidian 볼트 이름 (obsidian CLI용, 예: my-vault): " VAULT_NAME

VAULT_ROOT="${VAULT_ROOT%/}"
TWIN_FOLDER="${TWIN_FOLDER%/}"
TWIN_PATH="${VAULT_ROOT}/${TWIN_FOLDER}"

echo
echo "설정값 확인:"
echo "  볼트 루트   : ${VAULT_ROOT}"
echo "  트윈 폴더   : ${TWIN_PATH}"
echo "  볼트 이름   : ${VAULT_NAME}"
echo "  pi 경로     : \${HOME}/.pi/agent/ (고정)"
echo
read -rp "이 값으로 설치? [y/N] " CONFIRM
[ "$CONFIRM" = "y" ] || { echo "취소됨"; exit 0; }

mkdir -p "$SKILL_DIR"
TMP="$(mktemp)"
# placeholder 치환
sed \
  -e "s|<YOUR_VAULT_ROOT>|${VAULT_ROOT}|g" \
  -e "s|<your-vault-name>|${VAULT_NAME}|g" \
  -e "s|<twin-folder>|${TWIN_FOLDER}|g" \
  "$SRC" > "$TMP"

# 트윈 폴더 예시 줄(Pi Agent/) 치환 — 일반적 예시 보존
cp "$TMP" "${SKILL_DIR}/SKILL.md"
rm -f "$TMP"

echo "✅ 설치 완료: ${SKILL_DIR}/SKILL.md"
echo
echo "다음 단계:"
echo "  1. 트윈 폴더 생성 + git init:  mkdir -p \"${TWIN_PATH}\" && cd \"${TWIN_PATH}\" && git init"
echo "  2. pi 에이전트에서 'pi-twin' 스킬 호출"
