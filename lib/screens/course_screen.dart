import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'lesson_screen.dart';

class CourseScreen extends StatefulWidget {
  final String courseId;
  final String title;

  CourseScreen({required this.courseId, required this.title});

  @override
  _CourseScreenState createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  final ApiService api = ApiService();
  bool loading = true;
  List lessons = [];

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  void _loadLessons() async {
    try {
      List fetchedLessons = await api.fetchLessons(widget.courseId);
      setState(() {
        lessons = fetchedLessons;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to load lessons")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                var lesson = lessons[index];
                return ListTile(
                  title: Text(lesson['title']),
                  subtitle: Text(lesson['content']),
                  trailing: Icon(Icons.play_arrow),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LessonScreen(title: lesson['title'], content: lesson['content']),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
