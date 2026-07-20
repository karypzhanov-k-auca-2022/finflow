# Предполагаемый REST API

Base URL задаётся через `--dart-define=API_BASE_URL=https://api.example.com`. Все запросы и ответы используют `application/json`; даты — ISO 8601, суммы — JSON number. Ошибка сервера имеет форму:

```json
{"code":"validation_error","message":"Amount must be positive","details":{"amount":"Must be greater than zero"}}
```

## Transactions

### `GET /transactions`

Ответ `200`:

```json
[
  {
    "id": "tx-101",
    "title": "Супермаркет",
    "amount": 7850.0,
    "type": "expense",
    "category": "groceries",
    "date": "2026-07-10T00:00:00.000",
    "note": "Покупки на неделю",
    "createdAt": "2026-07-10T12:30:00.000Z",
    "updatedAt": "2026-07-10T12:30:00.000Z"
  }
]
```

### `POST /transactions`

Запрос:

```json
{"title":"Кофе","amount":350.0,"type":"expense","category":"cafe","date":"2026-07-18T00:00:00.000","note":""}
```

Ответ `201` — созданная Transaction со сгенерированными `id`, `createdAt`, `updatedAt`.

### `PUT /transactions/:id`

Запрос и ответ имеют полную форму Transaction. Ответы: `200`, `404`, `422`.

### `DELETE /transactions/:id`

Ответ `204`, если удалено; `404`, если ID не найден. Тело отсутствует.

## Budgets

### `GET /budgets`

Ответ `200`:

```json
[
  {"id":"budget-groceries","categoryId":"groceries","limit":24000.0,"spent":19500.0,"month":7,"year":2026}
]
```

### `POST /budgets`

Запрос:

```json
{"categoryId":"transport","limit":5000.0,"month":7,"year":2026}
```

Ответ `201` — созданный Budget.

### `PUT /budgets/:id`

```json
{"id":"budget-groceries","categoryId":"groceries","limit":26000.0,"spent":19500.0,"month":7,"year":2026}
```

Ответы: `200`, `404`, `422`.

### `DELETE /budgets/:id`

Ответ `204` без тела.

## Analytics

### `GET /analytics?months=6`

Этот endpoint предусмотрен для будущей серверной агрегации. Текущая версия считает аналитику локально.

Ответ `200`:

```json
{
  "monthlyExpenses":[{"month":"2026-02","amount":68200.0},{"month":"2026-03","amount":70150.0}],
  "byCategory":{"rent":252000.0,"groceries":74100.0,"transport":14400.0},
  "averageMonthly":69425.0,
  "topCategory":"rent"
}
```

## HTTP-статусы

- `200/201/204` — успех;
- `400` — некорректный JSON;
- `401` — нужна авторизация;
- `404` — ресурс не найден;
- `409` — конфликт версии при синхронизации;
- `422` — доменная валидация;
- `500/503` — сервер временно недоступен.
