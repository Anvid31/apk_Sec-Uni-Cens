import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:caracterizacion_cens/main.dart';
import 'package:caracterizacion_cens/models/unified_survey_state.dart';

void main() {
  testWidgets('muestra la pantalla de selección', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => UnifiedSurveyState(),
        child: const MyApp(),
      ),
    );

    expect(find.text('CENS Caracterización'), findsOneWidget);
    expect(find.text('Formulario de Caracterización'), findsOneWidget);
  });
}
