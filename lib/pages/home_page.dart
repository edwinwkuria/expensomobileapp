import 'package:calendar_timeline/calendar_timeline.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenso/pages/widgets/expense_add_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedDate = useState(DateTime.now());
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            right: 16.0,
            left: 16,
            top: 32,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Expenso",
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10,),
              Expanded(
                child: Column(
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
                      locale: 'en_ISO',
                    ),
                    FutureBuilder(
                        future: getExpenses(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Expanded(
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Expanded(
                                child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.grey,
                                  size: 52,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'Failed to load resource',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge,
                                )
                              ],
                            ));
                          }

                          if(snapshot.data == null || snapshot.data!.isEmpty) {
                            return const Expanded(child: Center(child: Text('No data yet')));
                          }

                          final data = snapshot.data;
                          return Expanded(
                            child: ListView.builder(
                              itemCount: data!.length,
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final selectedData = data[index];
                                return ListTile(
                                  title: Text(selectedData['title']),
                                  subtitle: Text(selectedData['total']),
                                );
                              },
                            ),
                          );
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: ExpenseAddModal(),
                );
              });
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getExpenses() async {
    final store = FirebaseFirestore.instance.collection('expenses');
    final data = await store.get();
    final allData =
        data.docs.map((e) => e.data().putIfAbsent('id', () => e.id)).toList();
    return allData as List<Map<String, dynamic>>;
  }
}
