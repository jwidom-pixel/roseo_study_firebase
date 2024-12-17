import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roseo_study/firebase_service.dart';

class ProjectsPage extends StatefulWidget {
  @override
  _ProjectsPageState createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final FirebaseService firebaseService = FirebaseService();

  void _showAddProjectDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController clientController = TextEditingController();
    final TextEditingController costController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('새 프로젝트 추가'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: '제목'),
                ),
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(labelText: '마감 날짜 (YYYY-MM-DD)'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: '설명'),
                ),
                TextField(
                  controller: clientController,
                  decoration: InputDecoration(labelText: '클라이언트'),
                ),
                TextField(
                  controller: costController,
                  decoration: InputDecoration(labelText: '외주비'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                firebaseService.addProject({
                  'title': titleController.text,
                  'date': dateController.text,
                  'description': descriptionController.text,
                  'client': clientController.text,
                  'cost': costController.text,
                });
                Navigator.pop(context);
              },
              child: Text('저장'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('프로젝트 관리')),
      body: StreamBuilder<QuerySnapshot>(
        stream: firebaseService.getProjects(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final projects = snapshot.data!.docs;

          return ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(project['title']),
                subtitle: Text(project['date']),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProjectDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
