# Архитектура FinFlow

## Цель

Архитектура показывает production-подход, но остаётся объяснимой Junior-разработчиком. Код организован по feature, а внутри основных feature разделён на Data, Domain и Presentation.

## Слои

### Presentation

Страницы и переиспользуемые widgets отображают immutable State и отправляют Event в BLoC. Форма и тема используют Cubit, потому что их переходы линейны. Widgets не вызывают Dio, SharedPreferences или Repository.

### Domain

Entity описывают бизнес-данные. Repository-интерфейсы задают возможности, но не способ хранения. UseCase координирует операции, чистые функции выполняют расчёты dashboard, analytics, фильтрации и сортировки.

### Data

Model отвечает за JSON и преобразование Entity ↔ Model. LocalDataSource хранит JSON в SharedPreferences. RemoteDataSource реализует REST через Dio. RepositoryImpl выбирает источник, fallback и преобразует технические ошибки в Failure.

## Направление зависимостей

```text
Presentation ─────► Domain ◄───── Data
     │                ▲             │
     └── Event/State  └─ implements ┘
```

Domain не знает конкретные DataSource. Data зависит от Domain, потому что реализует его контракт. Все связи создаются в composition root `app/dependency_injection.dart`.

## Жизненный цикл запуска

1. `main` инициализирует Flutter binding, локаль и DI.
2. Router открывает `/splash`.
3. `AppInitializer` проверяет first-run и детерминированно создаёт demo-данные.
4. Splash отправляет события начальной загрузки feature-BLoC.
5. GoRouter заменяет splash на `/dashboard` без искусственной задержки.

## Offline-first

Локальное хранилище — основной источник. Если передан `API_BASE_URL`, pull-to-refresh запрашивает сервер и обновляет cache. При сетевой ошибке пользователь продолжает работать с cache. Изменения сначала сохраняются локально. Это хороший demo-компромисс; production-синхронизации нужны outbox, версии записей, conflict resolution и retry policy.

## Состояния

Feature-BLoC используют `initial`, `loading`, `success`, `empty`, `failure`. Ошибка хранится как `Failure`, а не Exception. Форма имеет `initial`, `saving`, `success`, `failure`, что блокирует повторный submit.

## Навигация

`StatefulShellRoute.indexedStack` сохраняет состояние пяти вкладок. `go` переключает основное назначение, `push` открывает форму или About поверх текущего стека. Неизвестный URL обрабатывает `errorBuilder`.
