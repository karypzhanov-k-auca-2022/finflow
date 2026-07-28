# Proposed REST API

Base URL is set via `--dart-define=API_BASE_URL=https://api.example.com`. All requests and responses use `application/json`; dates are ISO 8601, amounts are JSON numbers. A server error follows this format:

```json
{"code":"validation_error","message":"Amount must be positive","details":{"amount":"Must be greater than zero"}}
```

## Transactions

### `GET /transactions`

Response `200`:

```json
[
  {
    "id": "tx-101",
    "title": "Supermarket",
    "amount": 7850.0,
    "type": "expense",
    "category": "groceries",
    "date": "2026-07-10T00:00:00.000",
    "note": "Weekly groceries",
    "createdAt": "2026-07-10T12:30:00.000Z",
    "updatedAt": "2026-07-10T12:30:00.000Z"
  }
]
```

### `POST /transactions`

Request:

```json
{"title":"Coffee","amount":350.0,"type":"expense","category":"cafe","date":"2026-07-18T00:00:00.000","note":""}
```

Response `201` — the created Transaction with generated `id`, `createdAt`, and `updatedAt`.

### `PUT /transactions/:id`

Both request and response use the full Transaction format. Responses: `200`, `404`, `422`.

### `DELETE /transactions/:id`

Response `204` if deleted; `404` if ID not found. No body.

## Budgets

### `GET /budgets`

Response `200`:

```json
[
  {"id":"budget-groceries","categoryId":"groceries","limit":24000.0,"spent":19500.0,"month":7,"year":2026}
]
```

### `POST /budgets`

Request:

```json
{"categoryId":"transport","limit":5000.0,"month":7,"year":2026}
```

Response `201` — the created Budget.

### `PUT /budgets/:id`

```json
{"id":"budget-groceries","categoryId":"groceries","limit":26000.0,"spent":19500.0,"month":7,"year":2026}
```

Responses: `200`, `404`, `422`.

### `DELETE /budgets/:id`

Response `204` with no body.

## Analytics

### `GET /analytics?months=6`

This endpoint is intended for future server-side aggregation. The current version calculates analytics locally.

Response `200`:

```json
{
  "monthlyExpenses":[{"month":"2026-02","amount":68200.0},{"month":"2026-03","amount":70150.0}],
  "byCategory":{"rent":252000.0,"groceries":74100.0,"transport":14400.0},
  "averageMonthly":69425.0,
  "topCategory":"rent"
}
```

## HTTP Statuses

- `200/201/204` — Success;
- `400` — Invalid JSON;
- `401` — Authorization required;
- `404` — Resource not found;
- `409` — Version conflict during synchronization;
- `422` — Domain validation error;
- `500/503` — Server temporarily unavailable.
