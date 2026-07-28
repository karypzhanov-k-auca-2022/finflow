import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/budget_model.dart';

abstract class FirestoreBudgetDataSource {
  Future<List<BudgetModel>> fetchBudgets();
  Future<void> saveBudget(BudgetModel item);
  Future<void> deleteBudget(String id);
  Stream<List<BudgetModel>> watchBudgets();
}

class FirestoreBudgetDataSourceImpl implements FirestoreBudgetDataSource {
  FirestoreBudgetDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>>? get _collection {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('budgets');
  }

  @override
  Future<List<BudgetModel>> fetchBudgets() async {
    final col = _collection;
    if (col == null) return [];
    final snapshot = await col.get();
    return snapshot.docs
        .map((doc) => BudgetModel.fromJson({'id': doc.id, ...doc.data()}))
        .toList();
  }

  @override
  Future<void> saveBudget(BudgetModel item) async {
    final col = _collection;
    if (col == null) return;
    await col.doc(item.id).set(item.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteBudget(String id) async {
    final col = _collection;
    if (col == null) return;
    await col.doc(id).delete();
  }

  @override
  Stream<List<BudgetModel>> watchBudgets() {
    final col = _collection;
    if (col == null) return Stream.value([]);
    return col.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => BudgetModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    });
  }
}
