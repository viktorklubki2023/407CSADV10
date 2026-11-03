1. <current_datetime>2026-11-03T21:53:58.038+02:00</current_datetime>

Я роблю лабораторну роботу: AI-агент для VS Code Copilot, який у репозиторії
генерує кросплатформний Rust проєкт Hello World (Cargo + cargo test) і CI
на GitHub Actions (Windows, Linux, macOS).
Зараз я в гілці develop і створюю ТІЛЬКИ інструкції агента (manifest, skills,
prompts-команди, документацію). Не створюй src/, tests/, Cargo.toml, ci.yml, ci.sh, ci.bat:
їх згенерує агент пізніше в гілці feature.
Файли створюй по одному, коли я попрошу. Мова інструкцій: українська,
імена файлів і команд: англійською.

2. <current_datetime>2026-11-03T21:54:14.235+02:00</current_datetime>

Створи файл .github/agents/build-engineer.agent.md з YAML frontmatter
(description, tools) і розділами:
1. Роль: build engineer для Rust/Cargo проєктів.
2. Область відповідальності: scaffold, збірка, юніт-тести, CI.
3. Доступні skills: project-scaffold, build-and-test, github-actions (з шляхами).
4. Доступні commands: git-init, create-project, create-build, create-actions,
   check, init (з коротким описом).
5. Правила роботи з файлами: ніколи не перезаписувати наявні файли без
   перевірки; ідемпотентність (повторний запуск не дублює вміст); показувати
   diff/список змін перед завершенням.
6. Заборонені дії: видалення файлів, git push --force, переписування історії,
   зміна захисту гілок, робота з секретами/токенами, публікація даних.
7. Порядок роботи.
8. Критерії успішного завершення: існує виконуваний файл hello (target/release/hello, копія в dist/); тест basic_addition проходить (cargo test); ci.yml містить ubuntu/windows/macos і лише викликає ci.sh/ci.bat; target/ і dist/ не під Git; check завершується без помилок.
9. Поведінка при помилці: зупинитись, показати причину, не вважати роботу успішною.

3. <current_datetime>2026-11-03T21:54:14.235+02:00</current_datetime>

Створи .github/skills/project-scaffold/SKILL.md.
Frontmatter: name: project-scaffold, description (коли застосовувати).
Вхід: language=Rust, project_name=hello.
Вихід: src/lib.rs (pub fn add(a: i32, b: i32) -> i32), src/main.rs (друкує
"Hello, World!" і використовує hello_lib::add), порожні каталоги tests/ та docs/,
README (якщо немає).
Правила: не перезаписувати наявні файли; якщо файл існує і відрізняється, повідомити.
Перевірки: src/main.rs існує; вказана команда запуску (cargo run --release або
./target/release/hello, на Windows target\release\hello.exe). Типова помилка:
файл вже існує з іншим вмістом.
Додай приклад входу та очікуваного результату.

4. <current_datetime>2026-11-03T21:55:16.724+02:00</current_datetime>

Створи .github/skills/build-and-test/SKILL.md.
Frontmatter: name: build-and-test, description (коли застосовувати).
Вхід: наявні src/lib.rs, src/main.rs.
Вихід: Cargo.toml ([package] name = "hello", version = "0.1.0", edition = "2021";
[lib] name = "hello_lib", path = "src/lib.rs"; [[bin]] name = "hello", path = "src/main.rs"),
tests/test_basic.rs з тестом #[test] fn basic_addition() (assert_eq!(hello_lib::add(2, 3), 5)),
Cargo.lock (згенерувати командою cargo build), скрипти ci.sh (bash, set -euo pipefail)
і ci.bat: cargo build --release, cargo test --release і копіювання виконуваного hello
(target/release/hello, на Windows target\release\hello.exe) у dist/. ci.sh має бути
виконуваним (git update-index --chmod=+x). ci.bat після кожної команди перевіряє
%errorlevel% і завершується з ненульовим кодом при помилці.
Перевірки: cargo test показує "test basic_addition ... ok"; існує виконуваний hello.
Типові помилки: cargo не знайдено (потрібен rustup); на Windows файл має розширення .exe;
каталог dist/ не створено перед копіюванням. Ідемпотентність: не дублювати секції
в Cargo.toml.
Додай приклад входу та очікуваного результату.


5. <current_datetime>2026-11-03T21:55:46.921+02:00</current_datetime>

Створи .github/skills/github-actions/SKILL.md.
Frontmatter: name: github-actions, description (коли застосовувати).
Вихід: .github/workflows/ci.yml: тригери push і pull_request на develop та master;
одна job з matrix os: [ubuntu-latest, windows-latest, macos-latest], fail-fast: false;
кроки: checkout, запуск ./ci.sh (не Windows, shell: bash) або ci.bat (Windows, shell: cmd),
upload-artifact з dist/ (actions/upload-artifact@v4, унікальне ім'я hello-${{ matrix.os }},
if-no-files-found: error). ВАЖЛИВО: у кроках run файлу ci.yml НЕ має бути команд cargo/rustc напряму,
лише запуск ci.sh/ci.bat. Без секретів.
Перевірки: YAML валідний (python -c "import yaml..." або actionlint, якщо є);
у файлі є три ОС; немає слів token/password/secret.
Типова помилка: ci.sh без прав на виконання.
Додай приклад входу та очікуваного результату.

6. <current_datetime>2026-11-03T21:56:16.341+02:00</current_datetime>

Створи .github/prompts/git-init.prompt.md.
Frontmatter: description, agent: build-engineer.
Розділи: Передумови, Дії, Очікувані файли, Команди перевірки, Повідомлення про помилку, Ідемпотентність.
Дії: перевірити, що поточний каталог є git-репозиторієм (git rev-parse); створити .gitignore або ДОПОВНИТИ його без дублів рядками target/, build/, dist/, out/, .vs/, .env, *.pem, *.key; показати git status.
Нічого не видаляти.

7. <current_datetime>2026-11-03T21:56:38.122+02:00</current_datetime>

Створи .github/prompts/create-project.prompt.md.
Frontmatter: description, agent: build-engineer.
Розділи: Передумови (git-репозиторій), Дії (виконати інструкції зі skill .github/skills/project-scaffold/SKILL.md з language=Rust, project_name=hello), Очікувані файли (src/lib.rs, src/main.rs), Команди перевірки (src/main.rs існує), Повідомлення про помилку, Ідемпотентність.

8. <current_datetime>2026-11-03T21:56:58.417+02:00</current_datetime>

Створи .github/prompts/create-build.prompt.md.
Frontmatter: description, agent: build-engineer.
Розділи: Передумови (є src/lib.rs, src/main.rs), Дії (виконати skill .github/skills/build-and-test/SKILL.md), Очікувані файли (Cargo.toml, Cargo.lock, tests/test_basic.rs, ci.sh, ci.bat), Команди перевірки, Повідомлення про помилку, Ідемпотентність.

9. <current_datetime>2026-11-03T21:57:23.796+02:00</current_datetime>

Створи .github/prompts/create-actions.prompt.md.
Frontmatter: description, agent: build-engineer.
Розділи: Передумови (є ci.sh і ci.bat), Дії (виконати skill .github/skills/github-actions/SKILL.md), Очікувані файли (.github/workflows/ci.yml), Команди перевірки (валідність YAML, три ОС, виклик лише ci.sh/ci.bat), Повідомлення про помилку, Ідемпотентність.

10. <current_datetime>2026-11-03T21:57:41.119+02:00</current_datetime>

Створи .github/prompts/check.prompt.md.
Frontmatter: description, agent: build-engineer.
Режим: ТІЛЬКИ ЧИТАННЯ. Не створювати і не змінювати файли проєкту (тимчасові каталоги target/ дозволені, вони в .gitignore).
Виконати перевірки і вивести таблицю PASS/FAIL:
1. Існують .github/agents/build-engineer.agent.md і три SKILL.md.
2. Кожен skill має розділи Вхід, Вихід, Перевірки.
3. Існують src/lib.rs, src/main.rs, tests/test_basic.rs, Cargo.toml, Cargo.lock, ci.sh, ci.bat.
4. cargo build --release проходить.
5. cargo test --release: basic_addition ... ok.
6. Існує виконуваний файл hello (target/release/hello або target\release\hello.exe).
7. ci.yml: валідний YAML, містить ubuntu-latest, windows-latest, macos-latest, у кроках run викликає лише ci.sh/ci.bat (без прямих команд cargo/rustc).
8. git ls-files не містить target/, build/, dist/, .env, *.key, *.pem.
9. .gitignore містить target/, build/ і dist/.
Якщо є хоча б один FAIL: вказати який саме і завершити зі статусом FAILED. Якщо все PASS: статус PASSED.
Додай розділи: Передумови, Повідомлення про помилку.

11. <current_datetime>2026-11-03T21:58:04.594+02:00</current_datetime>

Створи .github/prompts/init.prompt.md.
Frontmatter: description, agent: build-engineer.
Ти оркестратор. Виконуй кроки СТРОГО по порядку, читаючи і виконуючи інструкції з файлів:
1. .github/prompts/git-init.prompt.md
2. .github/prompts/create-project.prompt.md
3. .github/prompts/create-build.prompt.md
4. .github/prompts/create-actions.prompt.md
5. .github/prompts/check.prompt.md
Після кожного кроку перевіряй результат. Якщо крок завершився помилкою: ЗУПИНИСЬ, не виконуй наступні, виведи звіт (який крок, причина, що виправити). Не оголошуй успіх без PASSED від check.
Повторний запуск не повинен руйнувати чи дублювати наявні файли.
У кінці виведи таблицю: крок, статус, створені/змінені файли.
Додай розділи: Передумови, Очікувані файли, Повідомлення про помилку.

12. <current_datetime>2026-11-03T21:58:38.118+02:00</current_datetime>

Онови README.md (зараз там лише назва репозиторія, збережи її): ПІП Клуб Віктор Володимирович, група КІ-407, варіант 10 (Rust, Cargo, cargo test), короткий опис проєкту, розділ "Запуск агента": відкрити папку у VS Code, відкрити Copilot Chat, вибрати агента build-engineer, виконати /init. Додай список commands. Залиш плейсхолдери для ПІП і групи.

13. <current_datetime>2026-11-03T21:58:55.598+02:00</current_datetime>

Створи docs/architecture.md з розділами:
1. Які проблеми вирішує агент.
2. Які skills використовує і за що вони відповідають.
3. Які commands доступні користувачу.
4. Які дані передаються між етапами (project_name -> src/ -> Cargo.toml -> ci.sh/ci.bat -> ci.yml).
5. Як оркестратор init обробляє помилки.
6. Таблиця відповідності файлів ролям: agent -> .github/agents/, skills -> .github/skills/, commands -> .github/prompts/.
7. Примітка, що використано формат VS Code Copilot (custom agents, prompt files, agent skills).

14. <current_datetime>2026-11-03T22:01:56.736+02:00</current_datetime>

Analyze this codebase and create a .github/copilot-instructions.md file to help future Copilot sessions work effectively in this repository.

## What to include

1. **Build, test, and lint commands** - If they exist. Include how to run a single test, not just the full suite
2. **High-level architecture** - Focus on the "big picture" that requires reading multiple files to understand
3. **Key conventions** - Patterns specific to this codebase that aren't obvious from reading a single file

## What NOT to include

- Generic development practices (e.g., "write unit tests", "use meaningful names")
- Obvious instructions that any developer would know
- Exhaustive file/directory listings that can be easily discovered
- Made-up sections like "Tips for Development" unless they exist in actual docs
- Explanations of why something ISN'T relevant (just omit it)

## Integration

- If .github/copilot-instructions.md already exists, suggest improvements rather than replacing it entirely
- Incorporate important parts from README.md, CONTRIBUTING.md, or existing instruction files
- Check for other AI assistant configs and incorporate their important parts:
  - Claude/OpenCode: CLAUDE.md
  - Cursor: .cursorrules, .cursor/rules/
  - Codex/Jules/OpenCode: AGENTS.md
  - Windsurf: .windsurfrules
  - Aider: CONVENTIONS.md, AIDER_CONVENTIONS.md
  - Cline: .clinerules, .cline_rules

## MCP Servers

After creating the file, briefly ask if the user wants to configure any MCP servers relevant to the project type (e.g., Playwright for web projects). If none seem relevant, skip this section entirely - do not explain why MCP servers aren't needed.

## Finishing up

End with a brief summary of what you created and ask if the user wants to adjust anything or add coverage for areas you may have missed. Do not list what you omitted.

Start by exploring the repository structure.

15. <current_datetime>2026-11-03T22:03:20.705+02:00</current_datetime>

/check

16. <current_datetime>2026-11-03T22:05:01.149+02:00</current_datetime>

Analyze this codebase and create a .github/copilot-instructions.md file to help future Copilot sessions work effectively in this repository.

## What to include

1. **Build, test, and lint commands** - If they exist. Include how to run a single test, not just the full suite
2. **High-level architecture** - Focus on the "big picture" that requires reading multiple files to understand
3. **Key conventions** - Patterns specific to this codebase that aren't obvious from reading a single file

## What NOT to include

- Generic development practices (e.g., "write unit tests", "use meaningful names")
- Obvious instructions that any developer would know
- Exhaustive file/directory listings that can be easily discovered
- Made-up sections like "Tips for Development" unless they exist in actual docs
- Explanations of why something ISN'T relevant (just omit it)

## Integration

- If .github/copilot-instructions.md already exists, suggest improvements rather than replacing it entirely
- Incorporate important parts from README.md, CONTRIBUTING.md, or existing instruction files
- Check for other AI assistant configs and incorporate their important parts:
  - Claude/OpenCode: CLAUDE.md
  - Cursor: .cursorrules, .cursor/rules/
  - Codex/Jules/OpenCode: AGENTS.md
  - Windsurf: .windsurfrules
  - Aider: CONVENTIONS.md, AIDER_CONVENTIONS.md
  - Cline: .clinerules, .cline_rules

## MCP Servers

After creating the file, briefly ask if the user wants to configure any MCP servers relevant to the project type (e.g., Playwright for web projects). If none seem relevant, skip this section entirely - do not explain why MCP servers aren't needed.

## Finishing up

End with a brief summary of what you created and ask if the user wants to adjust anything or add coverage for areas you may have missed. Do not list what you omitted.

Start by exploring the repository structure.

17. <current_datetime>2026-11-03T22:19:23.752+02:00</current_datetime>

Follow instructions in [init.prompt.md](шлях до файла init.prompt.md).

18. <current_datetime>2026-11-03T22:21:21.564+02:00</current_datetime>

скачай rust toolcahin

19. <current_datetime>2026-11-03T22:23:59.240+02:00</current_datetime>

You have not yet marked the task as complete using the task_complete tool. If you were planning, stop planning and start implementing. You aren't done until you have fully completed the task.

IMPORTANT: Do NOT call task_complete if:
- You have open questions or ambiguities - make good decisions and keep working
- You encountered an error - try to resolve it or find an alternative approach
- There are remaining steps - complete them first

Keep working autonomously until the task is truly finished, then call task_complete.

20. <current_datetime>2026-11-03T22:26:20.764+02:00</current_datetime>

Follow instructions in [init.prompt.md](шлях до файла init.prompt.md).

21. <current_datetime>2026-11-03T22:32:08.921+02:00</current_datetime>

Follow instructions in [init.prompt.md](шлях до файла init.prompt.md).

22. <current_datetime>2026-11-03T22:33:17.996+02:00</current_datetime>

Analyze this codebase and create a .github/copilot-instructions.md file to help future Copilot sessions work effectively in this repository.

## What to include

1. **Build, test, and lint commands** - If they exist. Include how to run a single test, not just the full suite
2. **High-level architecture** - Focus on the "big picture" that requires reading multiple files to understand
3. **Key conventions** - Patterns specific to this codebase that aren't obvious from reading a single file

## What NOT to include

- Generic development practices (e.g., "write unit tests", "use meaningful names")
- Obvious instructions that any developer would know
- Exhaustive file/directory listings that can be easily discovered
- Made-up sections like "Tips for Development" unless they exist in actual docs
- Explanations of why something ISN'T relevant (just omit it)

## Integration

- If .github/copilot-instructions.md already exists, suggest improvements rather than replacing it entirely
- Incorporate important parts from README.md, CONTRIBUTING.md, or existing instruction files
- Check for other AI assistant configs and incorporate their important parts:
  - Claude/OpenCode: CLAUDE.md
  - Cursor: .cursorrules, .cursor/rules/
  - Codex/Jules/OpenCode: AGENTS.md
  - Windsurf: .windsurfrules
  - Aider: CONVENTIONS.md, AIDER_CONVENTIONS.md
  - Cline: .clinerules, .cline_rules

## MCP Servers

After creating the file, briefly ask if the user wants to configure any MCP servers relevant to the project type (e.g., Playwright for web projects). If none seem relevant, skip this section entirely - do not explain why MCP servers aren't needed.

## Finishing up

End with a brief summary of what you created and ask if the user wants to adjust anything or add coverage for areas you may have missed. Do not list what you omitted.

Start by exploring the repository structure.

23. <current_datetime>2026-11-03T22:34:10.303+02:00</current_datetime>

Follow instructions in [init.prompt.md](шлях до файла init.prompt.md).

24. <current_datetime>2026-11-03T22:35:10.177+02:00</current_datetime>

/check

25. <current_datetime>2026-11-03T22:40:03.584+02:00</current_datetime>

при git status Untracked files:
  (use "git add <file>..." to include in what will be committed)
        .github/copilot-instructions.md
        .github/workflows/
        .gitignore
        Cargo.lock
        Cargo.toml
        ci.bat
        src/
        tests/ 
        А в коміт мають попасти тільки перші три. зроби так

26. <current_datetime>2026-11-03T22:40:43.908+02:00</current_datetime>

Створи docs/usage.md: точні команди запуску агента (VS Code, Copilot Chat, агент build-engineer, /init, /check), локальної збірки і перевірки (./ci.sh на Linux/macOS, ci.bat на Windows), запуску hello (./dist/hello або dist\hello.exe), запуску тестів (cargo test --release).
