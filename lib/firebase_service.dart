import 'package:cloud_firestore/cloud_firestore.dart';

//firebass
class FirebaseService {
  final CollectionReference projects =
      FirebaseFirestore.instance.collection('projects');

  // 데이터 추가
  Future<void> addProject(Map<String, dynamic> project) async {
    await projects.add(project);
  }

  // 데이터 불러오기
  Stream<QuerySnapshot> getProjects() {
    return projects.snapshots();
  }
}