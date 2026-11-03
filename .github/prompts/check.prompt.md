---
description: "Перевірити повноту, збірку, тести та CI Rust/Cargo проєкту в режимі лише читання."
agent: build-engineer
---

# Check

## Режим роботи

Працюй **тільки в режимі читання**. Не створюй і не змінюй файли проєкту.
Тимчасові каталоги `target/` дозволені, оскільки вони мають бути в
`.gitignore`.

## Передумови

- Поточний каталог є Git-репозиторієм.
- Доступні `cargo`, `git` і Python або `actionlint`.
- Перевірки виконуються без виправлення знайдених проблем.

## Перевірки

Виконай усі перевірки та виведи таблицю з колонками `#`, `Перевірка`,
`Статус`, `Деталі`, де `Статус` має значення `PASS` або `FAIL`.

1. Перевір, що існують `.github/agents/build-engineer.agent.md` і три файли:
   `.github/skills/project-scaffold/SKILL.md`,
   `.github/skills/build-and-test/SKILL.md`,
   `.github/skills/github-actions/SKILL.md`.
2. Перевір, що кожен із трьох skill-файлів має розділи `Вхід`, `Вихід` і
   `Перевірки`.
3. Перевір існування `src/lib.rs`, `src/main.rs`, `tests/test_basic.rs`,
   `Cargo.toml`, `Cargo.lock`, `ci.sh` і `ci.bat`.
4. Виконай `cargo build --release`.
5. Виконай `cargo test --release` і перевір, що вивід містить
   `test basic_addition ... ok`.
6. Перевір наявність виконуваного файла `hello` у
   `target/release/hello` або `target\release\hello.exe`.
7. Перевір `.github/workflows/ci.yml`: YAML має бути валідним, файл має
   містити `ubuntu-latest`, `windows-latest` і `macos-latest`, а поля `run`
   можуть викликати лише `ci.sh` або `ci.bat`; прямі команди `cargo` та
   `rustc` заборонені.
8. Виконай `git ls-files` і переконайся, що результат не містить `target/`,
   `build/`, `dist/`, `.env`, `*.key` або `*.pem`.
9. Перевір, що `.gitignore` містить `target/`, `build/` і `dist/`.

Для перевірки YAML використай:

```text
python -c "import yaml, pathlib; yaml.safe_load(pathlib.Path('.github/workflows/ci.yml').read_text())"
```

Якщо Python-модуль `yaml` недоступний, використай `actionlint`, якщо він
встановлений. Не встановлюй залежності та не змінюй файли в цьому режимі.

## Повідомлення про помилку

Якщо будь-яка перевірка не проходить, познач саме її як `FAIL`, наведи
причину та релевантний вивід. Після таблиці виведи:

```text
Status: FAILED
```

Не виправляй помилку автоматично і не вважай перевірку успішною.

Якщо всі перевірки проходять, виведи:

```text
Status: PASSED
```

У разі помилки `cargo` повідом, що потрібен Rust toolchain через `rustup`.
