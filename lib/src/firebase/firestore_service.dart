import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  /// sets the [data] given at the specified [path]
  Future<void> setData({
    required String path,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    final reference = FirebaseFirestore.instance.doc(path);
    debugPrint('$path: $data');
    await reference.set(data, SetOptions(merge: merge));
  }

  /// sets the [data] given at the specified [path]
  Future<DocumentReference> addData({
    required String path,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    final reference = FirebaseFirestore.instance.collection(path);
    debugPrint('$path: $data');
    return reference.add(data);
  }

  /// updates the [data] given at the specified [path]
  Future<void> updateData({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    final reference = FirebaseFirestore.instance.doc(path);
    debugPrint('$path: $data');
    await reference.update(data);
  }

  /// deletes the data at the given [path]
  Future<void> deleteData({required String path}) async {
    final reference = FirebaseFirestore.instance.doc(path);
    debugPrint('delete: $path');
    await reference.delete();
  }

  /// a future that when complete gives the first document in a collection
  /// that fits the [queryBuilder] constraints
  Future<T> documentFutureFromCollection<T>({
    required String path,
    required T Function(Map<String, dynamic>? data, String documentID) builder,
    required Query<Map<String, dynamic>> Function(
            Query<Map<String, dynamic>> query)?
        queryBuilder,
    int Function(T lhs, T rhs)? sort,
  }) {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    final Future<QuerySnapshot<Map<String, dynamic>>> snapshots = query.get();
    return snapshots.then((snapshot) {
      final result = snapshot.docs
          .map((snapshot) => builder(snapshot.data(), snapshot.id))
          .where((value) => value != null)
          .toList();
      if (sort != null) {
        result.sort(sort);
      }
      if (result.isNotEmpty) {
        return result.first;
      } else {
        return Future.value();
      }
    });
  }

  /// a stream that gives updates of all of the documents at a given [path]
  /// based on the [queryBuilder] queries
  Stream<List<T>> collectionStream<T>({
    required String path,
    required T Function(Map<String, dynamic>? data, String documentID) builder,
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> query)?
        queryBuilder,
    int Function(T lhs, T rhs)? sort,
  }) {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    final Stream<QuerySnapshot<Map<String, dynamic>>> snapshots =
        query.snapshots();
    return snapshots.map((snapshot) {
      final result = snapshot.docs
          .map((snapshot) => builder(snapshot.data(), snapshot.id))
          .where((value) => value != null)
          .toList();
      if (sort != null) {
        result.sort(sort);
      }
      return result;
    });
  }

  /// a future that gives the documents in a given collection
  /// MAKE SURE TO USE THE BUILDER TO LIMIT THE NUMBER OF DOCUMENTS
  Future<List<T>> collectionFuture<T>({
    required String path,
    required T Function(Map<String, dynamic>? data, String documentID) builder,
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> query)?
        queryBuilder,
  }) {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    final Future<QuerySnapshot<Map<String, dynamic>>> snapshots = query.get();
    return snapshots.then((snapshot) {
      final result = snapshot.docs
          .map((snapshot) => builder(snapshot.data(), snapshot.id))
          .where((value) => value != null)
          .toList();
      return result;
    });
  }

  /// a stream that gives updates of all of the documents in a given [groupTerm]
  /// based on the [queryBuilder] queries
  Stream<List<T>> collectionGroupStream<T>({
    required String groupTerm,
    required T Function(Map<String, dynamic>? data, String documentID) builder,
    required Query<Map<String, dynamic>> Function(
            Query<Map<String, dynamic>> query)?
        queryBuilder,
    int Function(T lhs, T rhs)? sort,
  }) {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collectionGroup(groupTerm);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    final Stream<QuerySnapshot<Map<String, dynamic>>> snapshots =
        query.snapshots();
    return snapshots.map((snapshot) {
      final result = snapshot.docs
          .map((snapshot) => builder(snapshot.data(), snapshot.id))
          .where((value) => value != null)
          .toList();
      if (sort != null) {
        result.sort(sort);
      }
      return result;
    });
  }

  /// a stream that gives updates of all of the data at a given [path]
  Stream<T> documentStream<T>({
    required String path,
    required T Function(Map<String, dynamic>? data, String documentID) builder,
  }) {
    final DocumentReference<Map<String, dynamic>> reference =
        FirebaseFirestore.instance.doc(path);
    final Stream<DocumentSnapshot<Map<String, dynamic>>> snapshots =
        reference.snapshots();
    return snapshots.map((snapshot) => builder(snapshot.data(), snapshot.id));
  }

  /// a future that when complete gives all of the data at a given [path]
  Future<T> documentFuture<T>({
    required String path,
    required T Function(Map<String, dynamic>? data, String documentID) builder,
  }) {
    final DocumentReference<Map<String, dynamic>> reference =
        FirebaseFirestore.instance.doc(path);
    final Future<DocumentSnapshot<Map<String, dynamic>>> snapshots =
        reference.get();
    return snapshots.then((snapshot) => builder(snapshot.data(), snapshot.id));
  }
}
