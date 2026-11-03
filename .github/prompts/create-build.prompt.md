---
description: "Налаштувати збірку, тестування та локальні CI-скрипти Rust/Cargo проєкту за skill build-and-test."
agent: build-engineer
---

# Create Build

## Передумови

- У поточному каталозі існують `src/lib.rs` і `src/main.rs`.
- Перед початком перевір їх наявність.
- Skill [build-and-test](../skills/build-and-test/SKILL.md) має бути
  доступний.

## Дії

1. Перевір наявність `src/lib.rs` і `src/main.rs`.
2. Виконай усі інструкції зі skill
   [build-and-test](../skills/build-and-test/SKILL.md).
3. Перевір існування цільових файлів перед створенням або оновленням.
4. Не перезаписуй несумісні наявні файли та не дублюй секції або команди.
5. Згенеруй `Cargo.lock` командою `cargo build`, якщо `cargo` доступний.
6. Зроби `ci.sh` виконуваним через
   `git update-index --chmod=+x ci.sh`.
7. Перед завершенням покажи diff і список змінених файлів.

## Очікувані файли

Після успішного виконання мають існувати:

```text
Cargo.toml
Cargo.lock
tests/test_basic.rs
ci.sh
ci.bat
```

`Cargo.toml` має описувати пакет `hello`, бібліотеку `hello_lib` і binary
`hello`. `tests/test_basic.rs` має містити тест `basic_addition`.

## Команди перевірки

Виконай:

```text
cargo build
cargo test
cargo build --release
```

Перевір, що `cargo test` показує `test basic_addition ... ok`, а release
виконуваний файл `hello` існує у `target/release/hello` або
`target\release\hello.exe`. Перевір також `ci.sh`, `ci.bat`, каталог
`dist/` і результат `git diff --check`.

## Повідомлення про помилку

Якщо `src/lib.rs` або `src/main.rs` відсутній, зупинись і повідом повний
шлях до відсутнього файла. Якщо `cargo` не знайдено, повідом, що потрібен
Rust через `rustup`, і не вважай роботу успішною.

Для конфлікту вмісту, помилки тесту, помилки збірки, відсутності
виконуваного файла або невдалого CI-скрипта покажи команду, код завершення
та причину. Не приховуй помилку і не перезаписуй файли.

## Ідемпотентність

Повторний запуск не повинен дублювати секції у `Cargo.toml`, тест у
`tests/test_basic.rs` або команди в `ci.sh` чи `ci.bat`. Правильні наявні
файли залишай без змін. Якщо файл існує з іншим вмістом, повідом конфлікт і
зупинись.
