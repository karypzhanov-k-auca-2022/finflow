# FinFlow: подготовка к собеседованию

## Краткая презентация проекта

> FinFlow — мой pet-проект на Flutter для учёта личных финансов. В нём можно вести доходы и расходы, искать и фильтровать операции, задавать месячные бюджеты и смотреть аналитику за разные периоды. Я использовал feature-first Clean Architecture: UI отправляет события в BLoC, тот вызывает UseCase, а Repository скрывает локальный SharedPreferences и опциональный REST-источник на Dio. Приложение offline-first, поэтому запускается без backend и при первой установке создаёт стабильные данные за шесть месяцев. Я отдельно реализовал типизированные ошибки, DI через get_it, GoRouter с shell-навигацией, светлую/тёмную тему и unit, repository, BLoC и widget-тесты.

Это занимает около 50 секунд в спокойном темпе.

## Архитектура простыми словами

- **Presentation** — страницы, widgets, BLoC/Cubit. Принимает действия пользователя и показывает State.
- **Domain** — смысл приложения: Entity, контракты Repository, UseCase, расчёты. Не знает, где физически лежат данные.
- **Data** — детали хранения и сети: Model, JSON, SharedPreferences, Dio и RepositoryImpl.
- **Repository** — единая точка доступа к данным; решает local или remote и fallback.
- **UseCase** — понятная операция приложения и граница между состоянием и данными.
- **DataSource** — один конкретный источник: локальное хранилище или REST.
- **Dependency Injection** — создание и связывание объектов снаружи через `get_it`, зависимости передаются в конструктор.

## Поток выполнения запроса

Пример открытия списка транзакций:

1. Пользователь открывает вкладку Transactions.
2. Splash или UI отправляет `TransactionsRequested`.
3. `TransactionsBloc` переходит в loading.
4. BLoC вызывает `TransactionUseCases.load()`.
5. UseCase обращается к интерфейсу `TransactionRepository`.
6. `TransactionRepositoryImpl` читает local или пробует remote с fallback.
7. `Result<List<FinanceTransaction>>` возвращается в BLoC.
8. BLoC выдаёт success, empty или failure.
9. `BlocBuilder` перестраивает только нужную часть UI.

## Возможные вопросы senior-разработчика

### 1. Почему выбран BLoC?

Он делает события, состояния и переходы явными, отделяет бизнес-логику от Widget и удобно тестируется последовательностями State.

### 2. Чем Bloc отличается от Cubit?

Cubit вызывается методами и сразу меняет State. Bloc принимает типизированные Event и лучше подходит для нескольких источников действий или сложных переходов. Поэтому список — Bloc, форма и тема — Cubit.

### 3. Почему Repository находится между Domain и DataSource?

Domain описывает, какие данные нужны, а RepositoryImpl решает, откуда их получить. BLoC не меняется при замене SharedPreferences на SQLite.

### 4. Зачем нужны UseCase?

Они создают стабильную границу сценария, не дают BLoC знать детали Repository и являются местом для координации правил. Однострочные операции собраны в feature-фасад без десятков классов.

### 5. Почему нельзя вызывать Dio прямо из Widget?

Widget стал бы одновременно отвечать за UI, сеть, parsing и ошибки; его труднее тестировать и переиспользовать, а lifecycle мог бы приводить к setState после dispose.

### 6. Как обрабатываются ошибки?

Инфраструктурные исключения перехватываются в Data/Repository и превращаются в `Failure`. BLoC выдаёт failure-State, UI показывает безопасное сообщение и Retry.

### 7. Как работает fallback на локальные данные?

При refresh с backend Repository сначала вызывает remote. Если Dio бросает ошибку, Repository читает local cache и возвращает Success с ним.

### 8. Что будет без интернета?

Без `API_BASE_URL` сеть вообще не вызывается. С URL чтение fallback-ится на cache, а локальные изменения остаются успешными.

### 9. Как работает Dependency Injection?

В composition root регистрируются реализации по интерфейсам. GetIt создаёт граф объектов, а каждый бизнес-класс получает зависимости через конструктор.

### 10. Почему зависимости передаются через конструктор?

Они видны в API класса, обязательны при создании, легко заменяются mock-объектами и не скрывают глобальное состояние.

### 11. Почему используется GoRouter?

Он декларативно описывает маршруты, поддерживает path parameters, deep links, error page и `StatefulShellRoute` для пяти вкладок.

### 12. Чем `go` отличается от `push`?

`go` меняет текущую локацию и подходит для основных разделов; `push` добавляет экран поверх стека и подходит для формы или About.

### 13. Как сохраняется состояние темы?

`ThemeCubit` меняет `ThemeMode`, а `SettingsRepositoryImpl` сохраняет его name в SharedPreferences. При создании Cubit значение читается обратно.

### 14. Почему State должен быть immutable?

Так переход — новое значение, его легче сравнивать, логировать, тестировать и безопасно использовать с реактивной перестройкой.

### 15. Чем Entity отличается от Model?

Entity отражает бизнес-смысл и не знает JSON. Model находится в Data, умеет `fromJson/toJson` и переводится в Entity.

### 16. Где выполняется маппинг Model в Entity?

В Data-слое. Model расширяет неизменяемую Entity для простого чтения, а `fromEntity` используется перед сохранением.

### 17. Как реализована Null Safety?

Обязательные поля имеют `required`, необязательные — nullable или безопасное значение по умолчанию. Перед использованием nullable-полей выполняется проверка.

### 18. Где используются generics?

`Result<T>`, `Success<T>`, `Bloc<Event, State>`, коллекции Entity и generic API методов Dio.

### 19. Где используются enum?

Тип транзакции, категория, период, поле сортировки, направление сортировки, статусы BLoC и формы, ThemeMode.

### 20. Где используется Future?

Инициализация, DataSource, Repository, UseCase, submit формы, подтверждения и pull-to-refresh — это асинхронные операции с одним результатом.

### 21. Где может использоваться Stream?

BLoC предоставляет Stream состояний. В production Stream также полезен для live-изменений БД или WebSocket-синхронизации.

### 22. Какие тесты добавлены?

Unit для расчётов, repository для local/remote/fallback/error, BLoC/Cubit для переходов и widget для loading/empty/list/error/validation.

### 23. Как тестируется BLoC?

`bloc_test` задаёт mock Repository, отправляет Event и проверяет точную последовательность State без UI.

### 24. Почему SharedPreferences, а не SQLite?

Для небольшого детерминированного demo JSON проще объяснить и поддерживать. Для больших данных, запросов и миграций я выбрал бы Drift/SQLite.

### 25. Что бы ты улучшил в production?

SQLite, пагинацию, авторизацию, secure storage, outbox/retry, conflict resolution, crash reporting, localization, CI и integration/golden tests.

### 26. Какие части можно масштабировать?

DataSource можно заменить независимо, feature можно вынести в package, серверную аналитику подключить через контракт, а новый feature добавить отдельной вертикалью.

### 27. Какие архитектурные компромиссы сделаны?

UseCase сгруппированы, JSON хранится целым массивом, remote write — best effort без очереди, аналитика считается in-memory, ID локальные.

### 28. Как предотвращён повторный submit?

`TransactionFormCubit` игнорирует submit в saving, а кнопка блокируется и показывает индикатор.

### 29. Как защищены несохранённые изменения?

Страница отслеживает dirty-state и через `PopScope` просит подтверждение. После успешного сохранения выход разрешается.

### 30. Почему расчёты не находятся в `build`?

Они являются бизнес-логикой, поэтому вынесены в чистые Domain-функции/UseCase. Build только превращает готовые данные в widgets.

### 31. Как обеспечена производительность списка?

Используется `ListView.builder`, стабильные `ValueKey` по id и предварительно отфильтрованный State; Widget не делает сетевые запросы при build.

### 32. Почему demo-данные детерминированные?

Стабильные суммы и категории делают графики и демонстрацию воспроизводимыми. Даты привязаны к текущему месяцу, чтобы dashboard всегда был заполнен.

## Карта проекта

| Файл | Ответственность | Кто вызывает | Зависимости |
|---|---|---|---|
| `lib/main.dart` | старт binding, locale, DI | Flutter runtime | Flutter, intl, app/DI |
| `lib/app/app.dart` | корневые BlocProvider, темы, router | `main` | feature BLoC, AppTheme, router |
| `lib/app/dependency_injection.dart` | composition root | `main`, router | GetIt, все реализации |
| `lib/app/router.dart` | маршруты, shell, 404 | `FinFlowApp` | GoRouter, pages, form Cubit |
| `lib/app/app_initializer.dart` | first-run seed | Splash | local data sources |
| `lib/app/splash_page.dart` | реальная инициализация и первая загрузка | router | initializer, feature BLoC |
| `lib/core/error/failure.dart` | доменные типы ошибок | Repository/BLoC/UI | Equatable |
| `lib/core/error/result.dart` | Success/Error без throw наверх | Repository/UseCase/BLoC | Failure |
| `lib/core/error/dio_failure_mapper.dart` | DioException → Failure | сетевой Data/Repository | Dio, Failure |
| `lib/core/network/dio_factory.dart` | base URL, timeout, headers, debug log | DI | Dio, foundation |
| `lib/core/theme/app_theme.dart` | Material 3 light/dark | app | Material |
| `transaction.dart` | Entity и enum операций | все transaction-слои | Equatable |
| `transaction_model.dart` | JSON и Entity mapping | data sources/repository | transaction Entity |
| `transaction_local_data_source.dart` | persistence и demo seed | Repository/initializer | SharedPreferences, JSON |
| `transaction_remote_data_source.dart` | REST CRUD | Repository | Dio, Model |
| `transaction_repository.dart` | Domain-контракт | UseCase | Result, Entity |
| `transaction_repository_impl.dart` | offline-first и fallback | DI/UseCase через интерфейс | local, remote, Model |
| `transaction_use_cases.dart` | операции, фильтр, сортировка | BLoC/Cubit | Repository |
| `transactions_bloc.dart` | список, delete, filters, State | page/splash | use cases |
| `transaction_form_cubit.dart` | saving/success/failure | form page | use cases |
| `transactions_page.dart` | поиск, фильтры, grouped list, swipe | router | TransactionsBloc, GoRouter |
| `transaction_form_page.dart` | create/edit UI и validation | router | FormCubit и feature BLoC |
| `budget.dart` | Budget Entity и progress rules | budget/domain/UI | Equatable, category enum |
| `budget_local_data_source.dart` | budgets JSON и seed | Repository/initializer | SharedPreferences |
| `budget_repository_impl.dart` | budget CRUD/fallback | BudgetUseCases | local/remote |
| `budget_use_cases.dart` | CRUD и вычисление spent | BudgetsBloc | repositories/entities |
| `budgets_bloc.dart` | load/save/delete состояния | budgets page/splash | budget + transaction use cases |
| `budgets_page.dart` | карточки, progress, CRUD dialogs | router | BudgetsBloc |
| `build_dashboard.dart` | баланс и агрегаты месяца | DashboardBloc | Transaction/Budget Entity |
| `dashboard_bloc.dart` | loading/empty/error/success обзора | dashboard page/splash | use cases, build function |
| `dashboard_page.dart` | карточки, pie chart, recent list | router | DashboardBloc, fl_chart |
| `calculate_analytics.dart` | агрегация месяцев/категорий | AnalyticsBloc | Transaction Entity |
| `analytics_bloc.dart` | период и состояния analytics | analytics page/splash | use cases, calculator |
| `analytics_page.dart` | chart и summary | router | AnalyticsBloc, fl_chart |
| `theme_cubit.dart` | ThemeMode и persistence | app/settings | SettingsRepository |
| `settings_cubit.dart` | clear/reseed | settings page | transaction/budget use cases |
| `settings_page.dart` | тема и действия с данными | router | settings/theme и feature BLoC |

## Что показать senior-разработчику в IDE

1. Начать с `transactions_bloc.dart`: видны Event/State и отсутствие UI-логики.
2. Перейти в `transaction_use_cases.dart`: показать чистую фильтрацию и контракт Repository.
3. Открыть `transaction_repository_impl.dart`: объяснить offline-first и fallback.
4. Показать `dependency_injection.dart`: как соединяются интерфейсы и реализации.
5. Запустить `flutter test` и открыть по одному тесту каждого уровня.
