# Архітектура AI-агента

## 1. Які проблеми вирішує агент

Агент автоматизує створення кросплатформного Rust/Cargo Hello World
проєкту. Він готує структуру бібліотеки та binary-застосунку, налаштовує
збірку і тести, створює скрипти для Linux/macOS та Windows, а також додає
GitHub Actions CI для трьох операційних систем.

Агент також перевіряє ідемпотентність змін, не перезаписує несумісні
наявні файли, не дублює конфігурацію та надає підсумок перевірок.

## 2. Skills та їх відповідальність

- `project-scaffold` — створює базову структуру Rust-проєкту:
  `src/lib.rs`, `src/main.rs`, `tests/`, `docs/` і `README.md`.
- `build-and-test` — налаштовує `Cargo.toml`, інтеграційний тест,
  `Cargo.lock`, а також скрипти `ci.sh` і `ci.bat`; виконує збірку та тести.
- `github-actions` — створює workflow `.github/workflows/ci.yml` з matrix
  для Ubuntu, Windows і macOS та завантаженням артефактів.

## 3. Commands, доступні користувачу

- `/git-init` — перевіряє Git-репозиторій і налаштовує `.gitignore`.
- `/create-project` — створює структуру Rust/Cargo проєкту.
- `/create-build` — налаштовує Cargo, тести та скрипти збірки.
- `/create-actions` — створює GitHub Actions workflow.
- `/check` — виконує повну перевірку в режимі лише читання.
- `/init` — послідовно запускає всі етапи та фінальну перевірку.

## 4. Передавання даних між етапами

Етапи використовують результати попередніх етапів як вхідні дані:

```text
project_name=hello
        |
        v
src/lib.rs + src/main.rs
        |
        v
Cargo.toml + tests/test_basic.rs + Cargo.lock
        |
        v
ci.sh + ci.bat
        |
        v
.github/workflows/ci.yml
```

`project_name=hello` визначає ім’я застосунку. Scaffold створює `src/`,
після чого `Cargo.toml` пов’язує бібліотеку `hello_lib` і binary `hello` з
відповідними файлами. `ci.sh` і `ci.bat` використовують цю Cargo-конфігурацію
для release-збірки, тестів і копіювання виконуваного файла в `dist/`.
Workflow запускає потрібний скрипт на відповідній операційній системі та
завантажує вміст `dist/`.

## 5. Обробка помилок оркестратором `init`

Оркестратор читає prompt-файли та виконує п’ять етапів строго по порядку:

1. `git-init`;
2. `create-project`;
3. `create-build`;
4. `create-actions`;
5. `check`.

Після кожного етапу він перевіряє результат. Якщо крок завершується
помилкою, оркестратор негайно зупиняється, не запускає наступні кроки,
показує номер і назву кроку, причину та необхідне виправлення. Успіх
оголошується лише після статусу `PASSED` від `check`.

## 6. Відповідність файлів ролям

| Роль | Каталог або файл |
|---|---|
| Agent | `.github/agents/build-engineer.agent.md` |
| Skills | `.github/skills/` |
| `project-scaffold` | `.github/skills/project-scaffold/SKILL.md` |
| `build-and-test` | `.github/skills/build-and-test/SKILL.md` |
| `github-actions` | `.github/skills/github-actions/SKILL.md` |
| Commands | `.github/prompts/` |
| `git-init` | `.github/prompts/git-init.prompt.md` |
| `create-project` | `.github/prompts/create-project.prompt.md` |
| `create-build` | `.github/prompts/create-build.prompt.md` |
| `create-actions` | `.github/prompts/create-actions.prompt.md` |
| `check` | `.github/prompts/check.prompt.md` |
| `init` | `.github/prompts/init.prompt.md` |

## 7. Формат VS Code Copilot

Проєкт використовує формат VS Code Copilot: custom agents
(`*.agent.md`), prompt files (`*.prompt.md`) і agent skills
(`SKILL.md`). Ці компоненти зберігаються у `.github/` та працюють як
інструкції й повторно використовувані workflow для Copilot Chat.
