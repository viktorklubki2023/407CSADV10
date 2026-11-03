---
description: "Створити та перевірити GitHub Actions workflow для Rust/Cargo проєкту через ci.sh і ci.bat."
agent: build-engineer
---

# Create Actions

## Передумови

- У поточному каталозі існують `ci.sh` і `ci.bat`.
- Перед початком перевір їх наявність та виконуваний режим `ci.sh`.
- Skill [github-actions](../skills/github-actions/SKILL.md) має бути доступний.

## Дії

1. Перевір наявність `ci.sh` і `ci.bat`.
2. Перевір, що `ci.sh` має виконуваний режим:
   `git update-index --chmod=+x ci.sh`.
3. Виконай усі інструкції зі skill
   [github-actions](../skills/github-actions/SKILL.md).
4. Перевір існування `.github/workflows/ci.yml` перед створенням.
5. Не перезаписуй несумісний наявний workflow.
6. Перед завершенням покажи diff і список змінених файлів.

## Очікувані файли

Після успішного виконання має існувати:

```text
.github/workflows/ci.yml
```

Workflow має містити push і pull request для `develop` та `master`, один
matrix job для `ubuntu-latest`, `windows-latest` і `macos-latest`, а також
завантаження артефакту з `dist/`.

## Команди перевірки

Перевір YAML одним із способів:

```text
python -c "import yaml, pathlib; yaml.safe_load(pathlib.Path('.github/workflows/ci.yml').read_text())"
```

або:

```text
actionlint .github/workflows/ci.yml
```

Додатково перевір, що workflow містить усі три ОС і що в полях `run`
викликаються лише `./ci.sh` або `ci.bat`. Прямі команди `cargo` і `rustc`
у workflow заборонені. Перевір також `git diff --check`.

## Повідомлення про помилку

Якщо `ci.sh` або `ci.bat` відсутній, повідом повний шлях і зупинись.
Якщо `ci.sh` не має прав на виконання, покажи причину та виправ режим
через `git update-index --chmod=+x ci.sh`.

Якщо YAML невалідний, відсутня ОС або workflow містить заборонену команду,
покажи конкретну перевірку, причину та релевантний фрагмент. Не вважай
роботу успішною і не перезаписуй несумісний файл.

## Ідемпотентність

Повторний запуск не повинен дублювати jobs, кроки, тригери або workflow.
Якщо `.github/workflows/ci.yml` уже відповідає skill, залиш його без змін.
Якщо файл існує з іншим вмістом, повідом конфлікт і зупинись.
