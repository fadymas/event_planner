import '../../exports.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;

/// A page for creating new events with form validation and QR code generation.
///
/// This page allows users to:
/// - Enter event details (name, subtitle, date, time, budget)
/// - Generate a QR code for the event
/// - Save the event to Firebase
class CreateEventPage extends StatefulWidget {
  const CreateEventPage({Key? key}) : super(key: key);

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Controllers for text input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _subTitleController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  // Selected date and time
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  /// Validates the event name
  /// Returns null if valid, error message if invalid
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter event name';
    }
    return null;
  }

  /// Validates the budget amount
  /// Returns null if valid, error message if invalid
  String? _validateBudget(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter budget';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  /// Validates that both date and time are selected
  /// Returns null if valid, error message if invalid
  String? _validateDateTime() {
    if (_selectedDate == null) {
      return 'Please select a date';
    }
    if (_selectedTime == null) {
      return 'Please select a time';
    }
    return null;
  }

  /// Generates a QR code image from the given data
  /// Returns the QR code as a base64 encoded string
  Future<String> _generateQRCode(String data) async {
    final qrPainter = QrPainter(
      data: data,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
      gapless: true,
    );

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(2048, 2048);

    qrPainter.paint(canvas, size);

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return base64Encode(byteData!.buffer.asUint8List());
  }

  /// Handles form submission
  /// Creates event in Firebase and generates QR code
  void _submitForm() async {
    if (_formKey.currentState!.validate() && _validateDateTime() == null) {
      try {
        final now = DateTime.now();
        final eventId =
            FirebaseFirestore.instance.collection('events').doc().id;

        // Prepare event data
        final eventData = {
          'name': _nameController.text.trim(),
          'subTitle': _subTitleController.text.trim(),
          'date': _selectedDate!.toIso8601String().split('T').first,
          'time': _selectedTime!.format(context),
          'budget': double.parse(_budgetController.text),
          'isOwner': true,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
          'eventId': eventId,
        };

        // Generate QR code data
        final qrData = jsonEncode({
          'name': _nameController.text.trim(),
          'subTitle': _subTitleController.text.trim(),
          'date': _selectedDate!.toIso8601String().split('T').first,
          'time': _selectedTime!.format(context),
          'budget': double.parse(_budgetController.text),
          'eventId': eventId,
        });

        // Generate QR code image
        final qrBase64 = await _generateQRCode(qrData);
        eventData['qrCode'] = qrBase64;

        // Save to Firebase
        await FirebaseFirestore.instance
            .collection('events')
            .doc(eventId)
            .set(eventData);

        if (mounted) {
          // Navigate to events page
          Navigator.pop(context);
          MainScaffold.of(context)?.navigateToTab(2);
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating event: $e')));
      }
    }
  }

  /// Builds the date picker field
  Widget _buildDateField() {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (date != null) {
            setState(() => _selectedDate = date);
          }
        },
        child: AbsorbPointer(
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Date',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            controller: TextEditingController(
              text:
                  _selectedDate == null
                      ? ''
                      : '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}',
            ),
            validator: (_) => _validateDateTime(),
          ),
        ),
      ),
    );
  }

  /// Builds the time picker field
  Widget _buildTimeField() {
    return Expanded(
      child: GestureDetector(
        onTap: () async {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (time != null) {
            setState(() => _selectedTime = time);
          }
        },
        child: AbsorbPointer(
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Time',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.access_time),
            ),
            controller: TextEditingController(
              text: _selectedTime?.format(context) ?? '',
            ),
            validator: (_) => _validateDateTime(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'New Event',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppStyles.defaultPadding),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppStyles.borderRadius),
              ),
              padding: const EdgeInsets.all(AppStyles.defaultPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.asset("images/event-list.png", height: 120),
                    const SizedBox(height: 16),
                    const Text(
                      'Create a new event',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Set up an event and start planning it',
                      style: TextStyle(fontSize: 14, color: AppColors.grey),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: _validateName,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _subTitleController,
                      decoration: const InputDecoration(
                        labelText: 'Subtitle',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildDateField(),
                        const SizedBox(width: 8),
                        _buildTimeField(),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _budgetController,
                      decoration: const InputDecoration(
                        labelText: 'Budget',
                        border: OutlineInputBorder(),
                        prefixText: '\$',
                      ),
                      keyboardType: TextInputType.number,
                      validator: _validateBudget,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Create Event',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subTitleController.dispose();
    _budgetController.dispose();
    super.dispose();
  }
}
