---
name: github-actions
description: "Застосовуй для створення та перевірки GitHub Actions CI для Rust/Cargo проєкту на Ubuntu, Windows і macOS через спільні ci.sh та ci.bat."
---

# GitHub Actions

## Вхід

Перед початком перевір, що існують `ci.sh` і `ci.bat`, а `ci.sh` має
виконуваний режим.

## Вихід

Створи workflow `.github/workflows/ci.yml` із такими властивостями:

- тригери `push` і `pull_request` лише для гілок `develop` та `master`;
- одна job із matrix `os: [ubuntu-latest, windows-latest, macos-latest]`;
- `fail-fast: false`;
- крок checkout;
- запуск `./ci.sh` на Ubuntu і macOS із `shell: bash`;
- запуск `ci.bat` на Windows із `shell: cmd`;
- завантаження `dist/` через `actions/upload-artifact@v4`;
- унікальне ім'я артефакту `hello-${{ matrix.os }}`;
- `if-no-files-found: error`.

Очікувана структура workflow:

```yaml
name: CI

on:
  push:
    branches: [develop, master]
  pull_request:
    branches: [develop, master]

jobs:
  build:
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - name: Run Unix CI
        if: runner.os != 'Windows'
        shell: bash
        run: ./ci.sh
      - name: Run Windows CI
        if: runner.os == 'Windows'
        shell: cmd
        run: ci.bat
      - uses: actions/upload-artifact@v4
        with:
          name: hello-${{ matrix.os }}
          path: dist/
          if-no-files-found: error
```

У `run` workflow не можна додавати команди `cargo` або `rustc` напряму.
Єдиними командами запуску в CI мають бути `./ci.sh` та `ci.bat`.
Workflow не повинен містити облікових даних або конфіденційних значень.

## Правила виконання

1. Перевір наявність `ci.sh` і `ci.bat` перед створенням workflow.
2. Перевір, що `ci.sh` має виконуваний режим:
   `git update-index --chmod=+x ci.sh`.
3. Не перезаписуй наявний `.github/workflows/ci.yml` без перевірки.
4. Якщо наявний файл відрізняється, повідом конфлікт і зупинись.
5. Не додавай додаткові jobs або прямі команди збірки до workflow.
6. Перед завершенням покажи diff і список змінених файлів.

## Перевірки

1. Перевір YAML через:

   ```text
   python -c "import yaml, pathlib; yaml.safe_load(pathlib.Path('.github/workflows/ci.yml').read_text())"
   ```

   Якщо доступний `actionlint`, можна використати його замість Python.
2. Перевір наявність усіх трьох значень:
   `ubuntu-latest`, `windows-latest`, `macos-latest`.
3. Перевір наявність тригерів `push` і `pull_request` для `develop` та
   `master`.
4. Перевір, що є один matrix job із `fail-fast: false`.
5. Перевір, що Unix-крок запускає `./ci.sh` через `bash`, а Windows-крок —
   `ci.bat` через `cmd`.
6. Перевір, що `run` не містить `cargo` або `rustc` напряму.
7. Перевір, що workflow не містить слів `token`, `password` або `secret`.
8. Перевір `actions/upload-artifact@v4`, шлях `dist/`, унікальне ім'я та
   `if-no-files-found: error`.

## Типова помилка

Якщо `ci.sh` не має прав на виконання, виправ режим через
`git update-index --chmod=+x ci.sh` і повтори перевірки. Не замінюй запуск
скрипта прямими командами Rust у workflow.

## Приклад

### Вхід

```text
ci.sh існує та має виконуваний режим
ci.bat існує
```

### Очікуваний результат

Створено `.github/workflows/ci.yml` з одним matrix job для Ubuntu, Windows
і macOS. Для Unix запускається `./ci.sh`, для Windows — `ci.bat`, після
чого артефакт із `dist/` завантажується під унікальним ім'ям. YAML
проходить перевірку, а прямі команди `cargo` і `rustc` у `run` відсутні.
