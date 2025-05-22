import '../../exports.dart';
import 'budget_details_page.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({Key? key}) : super(key: key);

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  List<CategoryModel> _categories = [];
  int _selectedCategory = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final categoriesStream = getData<CategoryModel>(
        'categories',
        CategoryModel.fromFirestore,
      );
      _categories = await categoriesStream.first;
    } catch (e) {
      print('Error loading categories: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_categories.isEmpty) {
      return const Center(child: Text('No categories found'));
    }

    final categoryNames = _categories.map((category) => category.name).toList();
    final selectedCategory = _categories[_selectedCategory];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        scrollSelectorRow(
          items: categoryNames,
          selectedIndex: _selectedCategory,
          onSelected: (index) {
            setState(() {
              _selectedCategory = index;
            });
          },
        ),
        const SizedBox(height: 8),
        Expanded(
          child: StreamBuilder<List<BudgetModel>>(
            stream: getData<BudgetModel>('budgets', BudgetModel.fromFirestore),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error loading budgets: ${snapshot.error}'),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final allBudgetItems = snapshot.data ?? [];

              // Filter budget items by selected category using live data
              final categoryBudgets =
                  allBudgetItems
                      .where(
                        (budget) => budget.category.id == selectedCategory.id,
                      )
                      .toList();

              if (categoryBudgets.isEmpty) {
                return const Center(
                  child: Text('No budgets found for this category'),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categoryBudgets.length,
                itemBuilder: (context, index) {
                  final budget = categoryBudgets[index];
                  // Fetch associated event name
                  return FutureBuilder<DocumentSnapshot>(
                    future: budget.eventId.get(),
                    builder: (context, eventSnapshot) {
                      String eventName = 'Unknown Event';
                      if (eventSnapshot.hasData && eventSnapshot.data!.exists) {
                        final eventData =
                            eventSnapshot.data!.data() as Map<String, dynamic>;
                        eventName =
                            eventData['name']?.toString() ?? 'Unknown Event';
                      }

                      return InkWell(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => BudgetDetailsPage(budgetItem: budget),
                            ),
                          );
                        },
                        child: standardCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    budget.name,
                                    style: AppStyles.titleStyle.copyWith(
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    eventName,
                                    style: AppStyles.subtitleStyle.copyWith(
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              progressBar(value: budget.Paid / budget.amount),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Paid: ${budget.Paid.toStringAsFixed(2)} \$',
                                    style: AppStyles.subtitleStyle.copyWith(
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    'Amount: ${budget.amount.toStringAsFixed(2)} \$',
                                    style: AppStyles.subtitleStyle.copyWith(
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
