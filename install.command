#!/bin/bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

pause_before_exit() {
  local status=$?
  if [[ -t 0 ]]; then
    if (( status == 0 )); then
      read -r -p $'\nНажмите Enter, чтобы закрыть это окно… ' _ || true
    else
      read -r -p $'\nУстановка остановилась с ошибкой. Скопируйте сообщение выше. Нажмите Enter, чтобы закрыть окно… ' _ || true
    fi
  fi
}
trap pause_before_exit EXIT

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Этот установщик предназначен для macOS."
  exit 1
fi

if ! command -v go >/dev/null 2>&1; then
  echo "Go не найден. Установите Go 1.25 или новее с https://go.dev/dl/, затем запустите install.command снова."
  exit 1
fi

GO_VERSION="$(go version | awk '{print $3}')"
VERSION="${GO_VERSION#go}"
GO_MAJOR="${VERSION%%.*}"
GO_MINOR="${VERSION#*.}"
GO_MINOR="${GO_MINOR%%.*}"
if (( GO_MAJOR < 1 || (GO_MAJOR == 1 && GO_MINOR < 25) )); then
  echo "Нужен Go 1.25 или новее; обнаружен ${GO_VERSION}."
  exit 1
fi

echo "Go ${GO_VERSION} найден. Собираю Native Messaging host…"
bash ./native/build.sh

echo "Регистрирую Native Messaging host…"
bash ./native/install.sh

if [[ -d "/Applications/Google Chrome.app" || -d "$HOME/Applications/Google Chrome.app" ]]; then
  echo "Открываю страницу расширений Chrome…"
  open -a "Google Chrome" "chrome://extensions/"
else
  echo "Откройте страницу расширений вашего браузера: chrome://extensions, edge://extensions или brave://extensions."
fi

cat <<'EOF'

Остался один ручной шаг Chrome: включите «Режим разработчика», нажмите
«Загрузить распакованное расширение» и выберите папку extension в этой папке.
Не перемещайте папку проекта после установки.
EOF
