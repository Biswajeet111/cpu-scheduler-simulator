import 'package:flutter_test/flutter_test.dart';
import 'package:cpu_scheduler/main.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(CpuSchedulerApp());
    expect(find.byType(CpuSchedulerApp), findsOneWidget);

  });
}
