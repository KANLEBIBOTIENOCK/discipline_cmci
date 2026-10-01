import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/discipline_state.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);

  final disciplineState = DisciplineState();
  await disciplineState.initialize();

  runApp(DisciplineCmciApp(state: disciplineState));
}

class DisciplineCmciApp extends StatelessWidget {
  final DisciplineState state;

  const DisciplineCmciApp({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, child) {
        return MaterialApp(
          title: 'Aline',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: state.isLoading
              ? const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryRose,
                    ),
                  ),
                )
              : HomeScreen(state: state),
        );
      },
    );
  }
}
