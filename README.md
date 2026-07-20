# FinFlow — Personal Finance Tracker

FinFlow — законченное Flutter-приложение для учёта доходов, расходов и месячных бюджетов. Проект работает без backend, сохраняет данные между запусками и показывает продуктовый подход: feature-first Clean Architecture, BLoC/Cubit, Repository Pattern, Dependency Injection, GoRouter, Dio, Material 3 и автоматические тесты.

## Возможности

- dashboard с балансом, доходами/расходами месяца, прогрессом бюджета, диаграммой и последними операциями;
- добавление и редактирование транзакций с валидацией и защитой несохранённых изменений;
- поиск, фильтры по типу/категории/датам, сортировка, группировка по дням и swipe-to-delete;
- CRUD месячных бюджетов, предупреждение после 80% и отдельное состояние превышения;
- аналитика за 3, 6 или 12 месяцев: столбчатый график, средний расход и топ-категория;
- системная, светлая и тёмная тема с сохранением выбора;
- очистка и детерминированное восстановление demo-данных за шесть месяцев;
- loading, success, empty и failure состояния с Retry;
- опциональная синхронизация с REST API и fallback на локальный cache.

## Скриншоты

Папка `docs/screenshots/` подготовлена для портфолио. После запуска добавьте туда `dashboard.png`, `transactions.png`, `budgets.png`, `analytics.png` и замените этот блок изображениями. Это осознанно не подменено нарисованными мокапами: скриншоты должны показывать фактически запущенную сборку на вашем устройстве.

## Технологии

Flutter 3.41.2, Dart 3.11, Material 3, `flutter_bloc`, `equatable`, `go_router`, `dio`, `get_it`, `intl`, `fl_chart`, `shared_preferences`, `bloc_test`, `mocktail`, `flutter_test`.

## Структура

```text
lib/
  app/                  # запуск, DI, router, splash
  core/                 # ошибки, Dio, тема, форматтеры, общие widgets
  features/
    dashboard/          # обзор финансов
    transactions/       # data/domain/presentation и форма
    budgets/            # data/domain/presentation
    analytics/          # domain-вычисления, BLoC и UI
    settings/           # тема, данные и about
test/
  unit/ repository/ bloc/ widget/
docs/
```

Подробная карта находится в [docs/project_structure.md](docs/project_structure.md), архитектура — в [docs/architecture.md](docs/architecture.md), контракт backend — в [docs/api_contract.md](docs/api_contract.md).

## Clean Architecture

- **Presentation** знает Flutter и BLoC. Widget отправляет событие и отображает State.
- **Domain** содержит Entity, Repository-контракты, UseCase и чистые расчёты. Он не импортирует Flutter (исключение — настройки темы, потому что `ThemeMode` является UI-настройкой приложения).
- **Data** знает JSON, SharedPreferences и Dio. Реализация Repository скрывает выбор источника.

Поток данных:

```text
UI → Event → BLoC → UseCase → Repository → DataSource
                                      ↓
UI ← State ← BLoC ← Result/Failure ←
```

## Repository Pattern и offline-first

UI и BLoC зависят от `TransactionRepository`/`BudgetRepository`, а не от SharedPreferences или Dio. Чтение по умолчанию локальное. При `refresh: true` и заданном `API_BASE_URL` Repository пробует remote, сохраняет ответ в cache и возвращает данные. При сетевой ошибке возвращается cache. Создание, изменение и удаление сначала применяются локально, поэтому приложение остаётся полезным без сети; remote-вызов является best effort.

## Dependency Injection

`get_it` настраивается один раз в `dependency_injection.dart`. DataSource, Repository и UseCase — lazy singleton; BLoC/Cubit — factory. Бизнес-классы получают зависимости через конструктор и не обращаются к service locator. `getIt` используется только в composition root.

## Ошибки

Приложение использует типизированные `NetworkFailure`, `TimeoutFailure`, `ServerFailure`, `CacheFailure`, `ValidationFailure`, `UnknownFailure` и `Result<T>`. `mapDioException` переводит технические Dio-ошибки в доменные. UI получает безопасный текст, не raw exception. Для восстанавливаемых ошибок есть Retry.

## Запуск

```bash
flutter pub get
flutter run
```

Для выбора устройства: `flutter devices`, затем `flutter run -d <device-id>`. Backend не нужен: на первом запуске splash заполнит локальное хранилище demo-данными.

## Тесты и качество

```bash
dart format .
flutter analyze
flutter test
```

Тесты покрывают расчёты, фильтры и сортировку, прогресс бюджета, аналитику, Repository/fallback/Failure, состояния BLoC, создание и удаление, а также ключевые Widget-состояния и валидацию формы.

## Подключение backend

```bash
flutter run --dart-define=API_BASE_URL=https://api.example.com
```

Сервер должен реализовать контракт из `docs/api_contract.md`. Не храните токены в исходном коде; для production добавьте auth-interceptor и безопасное хранилище токена. Без define remote полностью отключён и заведомо не ломает приложение.

## Архитектурные решения и компромиссы

- SharedPreferences хранит JSON: для объёма pet-проекта это прозрачно и легко объяснить; при десятках тысяч записей стоит перейти на SQLite/Drift или Isar.
- Локальная запись считается успешной даже при недоступном remote. Production-версия потребует outbox, retry и явного sync-status.
- Analytics вычисляется на устройстве. Для больших данных агрегацию лучше перенести на backend/БД.
- UseCase объединены по feature в небольшие фасады, чтобы не создавать класс на каждую однострочную операцию.
- BLoC используется там, где есть события и несколько переходов состояния; Cubit — для линейной формы и темы.
- UUID-пакет не добавлялся: локальные ID строятся из microseconds, чего достаточно для single-device demo.

## Почему я принял такие решения

- **BLoC** делает переходы состояний явными и хорошо тестируется.
- **GoRouter** даёт декларативные маршруты, deep links, shell-навигацию и error page.
- **Repository** скрывает local/remote и позволяет заменить инфраструктуру без изменения UI.
- **Domain не зависит от Flutter**, поэтому расчёты быстрые, переносимые и тестируются без Widget binding.
- **Работа без backend** делает проект воспроизводимым на интервью; Dio-слой при этом настоящий и подключается define-параметром.
- **Без лишних абстракций**: небольшие функции расчёта остаются чистыми функциями, а связанные CRUD-use cases собраны в понятные фасады.

## Дальнейшее развитие

Авторизация, валюты и курсы, SQLite/Drift, пагинация, outbox-синхронизация, recurring payments, экспорт CSV/PDF, push-напоминания, биометрическая защита, accessibility-аудит, golden/integration tests и CI/CD.

Для подготовки к защите проекта используйте [INTERVIEW_GUIDE.md](INTERVIEW_GUIDE.md).
