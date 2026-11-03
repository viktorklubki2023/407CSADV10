# Інструкції для Copilot

## Контекст репозиторію

Цей репозиторій містить конфігурацію VS Code Copilot і згенерований
кросплатформний Rust/Cargo Hello World проєкт. Agent
[`build-engineer`](./agents/build-engineer.agent.md) оркеструє scaffold,
збірку, тести та GitHub Actions CI. Поточний шар конфігурації містить
README, документацію, custom agent, skills і prompt files; Cargo-файли,
вихідний код, тести, build-скрипти та workflow вже відповідають цьому
контракту.

## Build, test і lint

Після генерації Rust-проєкту використовуйте:

```text
cargo fmt --check
cargo build
cargo build --release
cargo test
cargo test --release
```

Для запуску одного інтеграційного тесту:

```text
cargo test --release --test test_basic basic_addition
```

Очікуваний результат тесту містить `test basic_addition ... ok`. Після
release-збірки Windows-виконуваний файл має бути
`target\release\hello.exe`, а CI-скрипт копіює його в `dist\hello.exe`;
на Unix використовуються відповідні шляхи без `.exe`.

Для Windows-скрипта:

```text
ci.bat
```

Для Unix-подібних систем:

```text
./ci.sh
```

Основна перевірка виконується prompt-командою [`/check`](./prompts/check.prompt.md)
у режимі лише читання. Вона додатково перевіряє структуру, YAML workflow,
Git-ігнорування артефактів і наявність release-виконуваного файла. Для YAML
використовуйте Python із `yaml` або `actionlint`, якщо він доступний:

```text
python -c "import yaml, pathlib; yaml.safe_load(pathlib.Path('.github/workflows/ci.yml').read_text())"
```

Кросплатформну перевірку збірки запускайте через скрипти, а не дублюйте їхні
команди у workflow:

```text
./ci.sh
ci.bat
```

`ci.sh` має виконуваний режим. На Unix його режим перевіряється або
встановлюється через:

```text
git update-index --chmod=+x ci.sh
```

Після змін спочатку виконайте відповідну prompt-команду, а для повного
pipeline — `/init` у VS Code Copilot Chat. Після генерації запускайте
`/check`; його `PASSED` є необхідною умовою завершення. Якщо Rust toolchain
відсутній, встановіть його через `rustup` перед повторенням Cargo-перевірок.

## Архітектура

Потік даних має фіксований порядок:

```text
project_name=hello
    -> src/lib.rs + src/main.rs
    -> Cargo.toml + tests/test_basic.rs + Cargo.lock
    -> ci.sh + ci.bat
    -> .github/workflows/ci.yml
```

`project-scaffold` створює бібліотеку `hello_lib` з `add(i32, i32) -> i32`
і binary `hello`, який друкує `Hello, World!`. `build-and-test` пов’язує ці
файли через `Cargo.toml`, додає `basic_addition`, генерує `Cargo.lock` і
готує Unix/Windows build-скрипти. Скрипти виконують release-збірку, release
тести та копіюють виконуваний файл у `dist/`. `github-actions` створює один
matrix job для `ubuntu-latest`, `windows-latest` і `macos-latest`; workflow
запускає лише `ci.sh` або `ci.bat`, після чого завантажує `dist/`.

Повний оркестратор [`/init`](./prompts/init.prompt.md) читає та виконує
послідовно `git-init`, `create-project`, `create-build`, `create-actions`,
потім `check`. Наступний крок не запускається, якщо попередній завершився
помилкою; фінальний успіх можливий лише зі статусом `PASSED` від `check`.

## Ключові conventions

- Інструкції та повідомлення пишуться українською; імена файлів, commands,
  Rust-ідентифікатори й shell-команди залишаються англійською.
- Перед кожним записом перевіряйте існування та вміст файла. Несумісний
  наявний файл — явний конфлікт, а не привід для перезапису.
- Повторний запуск має бути ідемпотентним: не дублюйте секції
  `Cargo.toml`, тести, команди скриптів, workflow-кроки або `.gitignore`
  правила.
- Кожен skill має зберігати узгоджені розділи `Вхід`, `Вихід` і
  `Перевірки`; зміна формату skill порушує перевірку `/check`.
- Не видаляйте файли, не переписуйте Git-історію, не виконуйте
  `git push --force` і не працюйте із секретами чи токенами.
- `check` є read-only перевіркою: він може створювати лише тимчасові
  артефакти під `target/`, але не виправляє файли проєкту.
- CI workflow не повинен містити прямих команд `cargo` або `rustc` у `run`;
  збірка та тести належать `ci.sh`/`ci.bat`.
- Очікувані імена Cargo API фіксовані: пакет і binary — `hello`, library —
  `hello_lib`, тест — `basic_addition`.
- `ci.sh` збирає release-версію, запускає release-тести та копіює
  `target/release/hello` у `dist/`; `ci.bat` виконує еквівалентний Windows
  flow і копіює `target\release\hello.exe` у `dist\hello.exe`.
- `.github/workflows/ci.yml` має одну matrix job для Ubuntu, Windows і macOS;
  workflow запускає лише `ci.sh`/`ci.bat`, а не прямі Cargo-команди.
- Перед завершенням змін показуйте `git diff` і список змінених файлів;
  для текстових файлів перевіряйте `git diff --check`.

## Доступні workflow-команди

- [`git-init`](./prompts/git-init.prompt.md) — перевіряє репозиторій і
  доповнює `.gitignore` правилами `target/`, `build/`, `dist/`, `out/`,
  `.vs/`, `.env`, `*.pem`, `*.key` без дублів.
- [`create-project`](./prompts/create-project.prompt.md) — виконує
  `project-scaffold` для `language=Rust`, `project_name=hello`.
- [`create-build`](./prompts/create-build.prompt.md) — виконує
  `build-and-test` і налаштовує Cargo, тестування та скрипти.
- [`create-actions`](./prompts/create-actions.prompt.md) — виконує
  `github-actions` і створює CI workflow.
- [`check`](./prompts/check.prompt.md) — перевіряє результат без змін.
- [`init`](./prompts/init.prompt.md) — виконує весь pipeline строго по
  порядку.
