import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../screens/course_screen.dart';
import '../widgets/course_card.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService api = ApiService();
  bool loading = true;
  List courses = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  void _loadCourses() async {
    try {
      List fetchedCourses = await api.fetchCourses();
      setState(() {
        courses = fetchedCourses;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to load courses")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                var course = courses[index];
                return CourseCard(
                  course: course,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourseScreen(courseId: course['id'], title: course['title']),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
