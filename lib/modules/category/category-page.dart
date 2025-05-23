import '../../exports.dart';
import '../../layout/main_layout.dart';

class SelectCategoryPage extends StatefulWidget {
  const SelectCategoryPage({Key? key}) : super(key: key);
  @override
  _SelectCategoryPageState createState() => _SelectCategoryPageState();
}

class _SelectCategoryPageState extends State<SelectCategoryPage> {
  int? selectedIndex = null;

  // Helper function to create the icon widget with error handling
  Widget _buildCategoryIcon(CategoryModel category) {
    return Icon(
      IconData(int.parse(category.icon), fontFamily: 'MaterialIcons'),
      color: AppColors.primaryDark,
      size: AppStyles.iconSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.text),
        title: Text(
          'Category',
          style: AppStyles.titleStyle.copyWith(fontSize: 22),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<CategoryModel>>(
        stream: getData<CategoryModel>(
          'categories',
          CategoryModel.fromFirestore,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = snapshot.data ?? [];

          if (categories.isEmpty) {
            return const Center(child: Text('No categories found'));
          }

          return ListView(
            padding: const EdgeInsets.symmetric(
              vertical: AppStyles.smallPadding,
              horizontal: 3,
            ),
            children: [
              for (int index = 0; index < categories.length; index++) ...[
                Dismissible(
                  key: Key(categories[index].id ?? ''),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(
                        AppStyles.borderRadius,
                      ),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) async {
                    try {
                      // Create a reference to the category being deleted
                      final categoryRef = FirebaseFirestore.instance
                          .collection('categories')
                          .doc(categories[index].id);

                      // Delete associated budgets
                      final budgetsQuery =
                          await FirebaseFirestore.instance
                              .collection('budgets')
                              .where('category', isEqualTo: categoryRef)
                              .get();

                      for (var budget in budgetsQuery.docs) {
                        await budget.reference.delete();
                      }

                      // Delete associated checklist items
                      final checklistQuery =
                          await FirebaseFirestore.instance
                              .collection('checklists')
                              .where('category', isEqualTo: categoryRef)
                              .get();

                      for (var item in checklistQuery.docs) {
                        await item.reference.delete();
                      }

                      // Finally delete the category itself
                      await categoryRef.delete();

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Category and associated items deleted',
                            ),
                          ),
                        );
                        // Navigate to home page
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MainScaffold(),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error deleting category: $e'),
                          ),
                        );
                      }
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: AppStyles.smallPadding),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                        Navigator.pop(context, categories[index]);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(
                            AppStyles.borderRadius,
                          ),
                          border:
                              selectedIndex == index
                                  ? Border.all(
                                    color: AppColors.primary,
                                    width: 2,
                                  )
                                  : Border.all(
                                    color: Colors.transparent,
                                    width: 2,
                                  ),
                        ),
                        child: Row(
                          children: [
                            _buildCategoryIcon(categories[index]),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                categories[index].name,
                                style: AppStyles.menuLabelStyle.copyWith(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (selectedIndex == index)
                              Icon(
                                Icons.check,
                                color: AppColors.primary,
                                size: AppStyles.iconSize - 2,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: AppColors.white),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCategoryPage()),
          );
          if (result != null && result is Map) {
            setState(() {});
          }
        },
      ),
    );
  }
}
