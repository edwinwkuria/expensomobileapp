import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ExpensesPage extends HookWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedDate = useState(DateTime.now());
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Text("Expenso", style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 16,),
            Expanded(child: Column(
              children: [
                CalendarTimeline(
                  initialDate: DateTime(2020, 4, 20),
                  firstDate: DateTime(2019, 1, 15),
                  lastDate: DateTime(2020, 11, 20),
                  onDateSelected: (date) {
                    selectedDate.value = date;
                  },
                  leftMargin: 20,
                  monthColor: Colors.blueGrey,
                  dayColor: Colors.teal[200],
                  activeDayColor: Colors.white,
                  activeBackgroundDayColor: Colors.redAccent[100],
                  dotsColor: const Color(0xFF333A47),
                  selectableDayPredicate: (date) => date.day != 23,
                  locale: 'en_ISO',
                ),
                Expanded(
                  child: ListView.builder(itemBuilder: (context, index) {
                    return const ListTile(
                      title: Text('Tuesday'),
                    );
                  }),
                ),
              ],
            )),
          ],
        ),
      )
    );
  }
}
