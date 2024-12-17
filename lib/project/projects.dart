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

    void _addProject() {
      if (titleController.text.isEmpty ||
          dateController.text.isEmpty ||
          descriptionController.text.isEmpty ||
          clientController.text.isEmpty ||
          costController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('모든 필드를 입력해주세요')),
        );
        return;
      }

      try {
        DateTime.parse(dateController.text); // 날짜 검증
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('날짜 형식이 잘못되었습니다 (YYYY-MM-DD)')),
        );
        return;
      }

      firebaseService.addProject({
        'title': titleController.text,
        'date': Timestamp.fromDate(DateTime.parse(dateController.text)),
        'description': descriptionController.text,
        'client': clientController.text,
        'cost': int.tryParse(costController.text) ?? 0,
      }).then((_) {
        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('프로젝트 추가 중 오류가 발생했습니다')),
        );
      });
    }

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
                  keyboardType: TextInputType.number,
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
              onPressed: _addProject,
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
                subtitle: Text(project['date'] is Timestamp
                    ? (project['date'] as Timestamp).toDate().toString()
                    : project['date'].toString()),
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
