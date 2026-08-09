# Data and sync semantics

These are current behaviors, not a target architecture. Do not change them incidentally.

## Active storage

- SharedPreferences is the primary finance store.
- Transactions use finflow_transactions_guest_v1 for guest data and finflow_transactions_user_<uid> for authenticated users.
- Budgets use equivalent guest/user-specific keys.
- New authenticated users are seeded with empty transaction and budget lists. Guest storage receives deterministic demo data.
- Categories use global keys and are not user-specific.
- Theme and locale settings are also global.
- Transactions embed category JSON. Budgets retain categoryId and derive spent from matching transactions.

AppInitializer seeds categories, transactions, and budgets through local datasources before initial feature loads. Repository access also seeds user-specific storage as needed.

## Optional REST

API_BASE_URL is a compile-time dart define read by lib/core/network/dio_factory.dart. When it is empty, transaction and budget repositories disable REST behavior.

Normal reads return local data. A refresh can request REST:

- Transactions replace the local transaction snapshot after a successful remote fetch and report whether the result came from cache.
- Budgets save remote items into local storage individually; stale local items are not pruned.
- A Dio failure falls back to non-empty cached data. If the relevant cache is empty, a mapped Failure is returned.

Writes and deletes are local-first. The repository attempts REST afterward, swallows Dio failures, emits a change notification, and reports local success. There is no durable retry queue.

## Notifications and connectivity

Transaction, budget, and category repositories expose broadcast Stream<void> change notifications. Dashboard, analytics, budget, category, and transaction BLoCs use these to reload. Preserve emission and subscription cleanup when modifying mutations.

ConnectionCubit reports interface availability for OfflineGate. It is a UI hint, not proof that the REST server is reachable; repository Dio handling remains authoritative.

## Firebase and unresolved backend direction

Firebase Authentication is active, including a persisted local-guest fallback when anonymous sign-in cannot reach Firebase.

Firestore transaction and budget datasources exist under their feature data/datasources directories, but they are not registered in dependency_injection.dart and are dormant in the active finance data path.

It is unresolved whether REST or Firestore is intended as the future production finance backend. Do not select, merge, or migrate these approaches without an explicit decision.

There is currently no outbox, retry scheduler, sync status, record versioning, conflict resolution, or REST auth interceptor.

