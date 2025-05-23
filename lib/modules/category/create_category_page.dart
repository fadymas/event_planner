import '../../exports.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({Key? key}) : super(key: key);

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();

  final List<IconData> _icons = [
    Icons.checkroom,
    Icons.spa,
    Icons.music_note,
    Icons.local_florist,
    Icons.photo_camera,
    Icons.emoji_events,
    Icons.room_service,
    Icons.directions_car,
    Icons.home,
    Icons.church,
    Icons.ring_volume,
  ];
  int _selectedIconIndex = 0;

  @override
  Widget build(BuildContext context) {
    return EntryFormLayout(
      title: 'Add a new category',
      fields: [
        TextField(
          controller: _nameController,
          decoration: AppStyles.inputDecoration(label: 'Name'),
        ),
        SizedBox(height: AppStyles.smallPadding),
        TextField(
          controller: _noteController,
          decoration: AppStyles.inputDecoration(label: 'Note'),
        ),
        SizedBox(height: AppStyles.smallPadding),
        standardCard(
          margin: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5, bottom: 8),
                child: Text(
                  'Select Icon',
                  style: AppStyles.menuLabelStyle.copyWith(
                    fontSize: 14,
                    color: AppColors.grey,
                  ),
                ),
              ),
              scrollSelectorRow(
                items: _icons,
                selectedIndex: _selectedIconIndex,
                onSelected:
                    (index) => setState(() => _selectedIconIndex = index),
                isIconList: true,
                horizontalPadding: 4,
                verticalPadding: 3,
              ),
            ],
          ),
        ),
      ],
      buttonText: 'ADD',
      onSubmit: () async {
        if (_nameController.text.isNotEmpty) {
          try {
            // Create a new category document in Firestore
            final docRef = await FirebaseFirestore.instance
                .collection('categories')
                .add({
                  'name': _nameController.text,
                  'note': _noteController.text,
                  'icon': _icons[_selectedIconIndex].codePoint.toString(),
                });

            // Create the category model
            final category = CategoryModel(
              id: docRef.id,
              name: _nameController.text,
              note: _noteController.text,
              icon: _icons[_selectedIconIndex].codePoint.toString(),
            );

            Navigator.pop(context, category);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error creating category: $e')),
            );
          }
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Name is required')));
        }
      },
    );
  }
}
