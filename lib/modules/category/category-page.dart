import '../../exports.dart';

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
                Container(
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
                                ? Border.all(color: AppColors.primary, width: 2)
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
