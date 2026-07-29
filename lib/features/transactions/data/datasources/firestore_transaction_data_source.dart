import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';

abstract class FirestoreTransactionDataSource {
  Future<List<TransactionModel>> fetchTransactions();
  Future<void> saveTransaction(TransactionModel item);
  Future<void> deleteTransaction(String id);
  Stream<List<TransactionModel>> watchTransactions();
}

class FirestoreTransactionDataSourceImpl
    implements FirestoreTransactionDataSource {
  FirestoreTransactionDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>>? get _collection {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('transactions');
  }

  @override
  Future<List<TransactionModel>> fetchTransactions() async {
    final col = _collection;
    if (col == null) return [];
    final snapshot = await col.get();
    return snapshot.docs
        .map((doc) => TransactionModel.fromJson({'id': doc.id, ...doc.data()}))
        .toList();
  }

  @override
  Future<void> saveTransaction(TransactionModel item) async {
    final col = _collection;
    if (col == null) return;
    await col.doc(item.id).set(item.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final col = _collection;
    if (col == null) return;
    await col.doc(id).delete();
  }

  @override
  Stream<List<TransactionModel>> watchTransactions() {
    final col = _collection;
    if (col == null) return Stream.value([]);
    return col.snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => TransactionModel.fromJson({'id': doc.id, ...doc.data()}),
          )
          .toList();
    });
  }
}
