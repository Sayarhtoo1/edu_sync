import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/models/exam.dart';
import 'package:edu_sync/providers/exam_provider.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/screens/admin/exam/exam_management_screen.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'exam_management_screen_test.mocks.dart';
@GenerateMocks([ExamProvider, SchoolProvider])

void main() {
  group('ExamManagementScreen', () {
    late MockExamProvider mockExamProvider;
    late MockSchoolProvider mockSchoolProvider;

    setUp(() {
      mockExamProvider = MockExamProvider();
      mockSchoolProvider = MockSchoolProvider();
    });

    testWidgets('should display a list of exams', (WidgetTester tester) async {
      // Arrange
      final exams = [
        Exam(id: '1', name: 'Midterm', classId: 1, schoolId: 1, examDate: DateTime.now(), examinerName: 'John Doe', createdAt: DateTime.now()),
        Exam(id: '2', name: 'Final', classId: 1, schoolId: 1, examDate: DateTime.now(), examinerName: 'Jane Doe', createdAt: DateTime.now()),
      ];
      when(mockExamProvider.exams).thenReturn(exams);

      // Act
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ExamProvider>.value(value: mockExamProvider),
            ChangeNotifierProvider<SchoolProvider>.value(value: mockSchoolProvider),
          ],
          child: MaterialApp(
            home: ExamManagementScreen(),
          ),
        ),
      );

      // Assert
      expect(find.text('Midterm'), findsOneWidget);
      expect(find.text('Final'), findsOneWidget);
    });

    testWidgets('should show add exam screen when floating action button is tapped', (WidgetTester tester) async {
      // Arrange
      when(mockExamProvider.exams).thenReturn([]);

      // Act
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ExamProvider>.value(value: mockExamProvider),
            ChangeNotifierProvider<SchoolProvider>.value(value: mockSchoolProvider),
          ],
          child: MaterialApp(
            home: ExamManagementScreen(),
          ),
        ),
      );
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Add Exam'), findsOneWidget);
    });

    testWidgets('should show edit exam screen when edit button is tapped', (WidgetTester tester) async {
      // Arrange
      final exams = [
        Exam(id: '1', name: 'Midterm', classId: 1, schoolId: 1, examDate: DateTime.now(), examinerName: 'John Doe', createdAt: DateTime.now()),
      ];
      when(mockExamProvider.exams).thenReturn(exams);

      // Act
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ExamProvider>.value(value: mockExamProvider),
            ChangeNotifierProvider<SchoolProvider>.value(value: mockSchoolProvider),
          ],
          child: MaterialApp(
            home: ExamManagementScreen(),
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Edit Exam'), findsOneWidget);
    });

    testWidgets('should delete exam when delete button is tapped', (WidgetTester tester) async {
      // Arrange
      final exams = [
        Exam(id: '1', name: 'Midterm', classId: 1, schoolId: 1, examDate: DateTime.now(), examinerName: 'John Doe', createdAt: DateTime.now()),
      ];
      when(mockExamProvider.exams).thenReturn(exams);

      // Act
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ExamProvider>.value(value: mockExamProvider),
            ChangeNotifierProvider<SchoolProvider>.value(value: mockSchoolProvider),
          ],
          child: MaterialApp(
            home: ExamManagementScreen(),
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Assert
      verify(mockExamProvider.deleteExam('1', '1')).called(1);
    });
  });
}
