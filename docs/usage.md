# Використання

## Запуск агента

1. Відкрийте папку репозиторію у VS Code.
2. Відкрийте Copilot Chat.
3. Виберіть агента `build-engineer`.
4. Виконайте команду:

   ```text
   /init
   ```

5. Після завершення pipeline виконайте перевірку:

   ```text
   /check
   ```

## Локальна збірка і перевірка

На Linux/macOS виконайте:

```bash
./ci.sh
```

На Windows виконайте:

```bat
ci.bat
```

Скрипти виконують release-збірку, запускають release-тести та копіюють
виконуваний файл у `dist/`.

## Запуск Hello World

На Linux/macOS:

```bash
./dist/hello
```

На Windows:

```bat
dist\hello.exe
```

## Запуск тестів

```text
cargo test --release
```
