import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:financial_app/blocs/reminder/reminder_bloc.dart';
import 'package:financial_app/components/clickble_textfield.dart';
import 'package:financial_app/components/input_field.dart';
import 'package:financial_app/components/simple_button.dart';
import 'package:financial_app/language/transalation.dart';
import 'package:financial_app/models/reminder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'custome_snackbar.dart';

class ReminderUpdatePopup extends StatefulWidget {
  final Reminder reminder;

  const ReminderUpdatePopup({super.key, required this.reminder});

  @override
  State<ReminderUpdatePopup> createState() => _ReminderUpdatePopupState();
}

class _ReminderUpdatePopupState extends State<ReminderUpdatePopup> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  String? errorMessage;
  late ReminderBloc _reminderBloc;
  Reminder? updatedReminder;

  void _showTimePicker(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              surface: Theme.of(context).colorScheme.surface,
              primary: const Color(0xFF456EFE),
              onSurface: Theme.of(context).colorScheme.secondaryFixed,
              secondary: const Color(0xFF456EFE),
              onSecondary: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF456EFE), // button text color
              ),
            ),
          ),
          child: Localizations.override(
            context: context,
            locale: const Locale('en'),
            child: child!,
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        timeController.text = picked.format(context);
      });
    }
  }

  String? _selectedItem;
  final List<String> repeatOptions = [
    'Never',
    'Everyday',
    'Every week',
    'Every month',
    'Every year',
  ];

  void _showDatePicker(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2099),
    );
    if (pickedDate != null) {
      setState(() {
        dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    titleController.text = widget.reminder.title;
    descriptionController.text = widget.reminder.description;
    dateController.text = widget.reminder.date;
    timeController.text = widget.reminder.time;
    _selectedItem = widget.reminder.frequancy;
    _reminderBloc = RepositoryProvider.of<ReminderBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReminderBloc, ReminderState>(
      listener: (context, state) {
        if (state is ReminderUpdateLoading) {
          showDialog(
            context: context,
            builder: (context) {
              return const Center(
                child: SpinKitThreeBounce(
                  color: Colors.white,
                  size: 50.0,
                ),
              );
            },
          );
        } else if (state is ReminderUpdateSuccess) {
          Navigator.pop(context);
          Navigator.pop(context, updatedReminder);
          showSuccessSnakBar();
        } else if (state is ReminderUpdateError) {
          Navigator.pop(context);
          Navigator.pop(context);
          showErrorSnackBar(state.message);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).translate('title_task'),
                style: const TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              InputField(
                isObsecure: false,
                controller: titleController,
                isReadOnly: false,
                label: AppLocalizations.of(context).translate('add_task_name'),
              ),
              const SizedBox(height: 16.0),
              Text(
                AppLocalizations.of(context).translate('description_optional'),
                style: const TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                      AppLocalizations.of(context).translate('add_description'),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  fillColor: Theme.of(context).colorScheme.surfaceDim,
                  filled: true,
                  hintStyle: const TextStyle(
                    color: Color(0xFF626262),
                    fontWeight: FontWeight.w400,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFF456EFE), width: 1.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).translate('date'),
                          style: const TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        ClickbleTextfield(
                          prefixIcon: Icons.calendar_month,
                          label: 'Select Date',
                          controller: dateController,
                          onTap: () => _showDatePicker(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).translate('time'),
                          style: const TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        ClickbleTextfield(
                          prefixIcon: Icons.access_time,
                          label: 'Select Time',
                          controller: timeController,
                          onTap: () => _showTimePicker(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Text(
                AppLocalizations.of(context).translate('repeat'),
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String>(
                  elevation: 2,
                  hint: Text(
                    AppLocalizations.of(context)
                        .translate('select_repeat_frequency'),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.secondaryFixed,
                    fontWeight: FontWeight.w400,
                  ),
                  value: _selectedItem,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedItem = newValue!;
                    });
                  },
                  items: repeatOptions
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(value),
                      ),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(
                        color: Color.fromARGB(255, 145, 145, 145)),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceDim,
                    prefixIcon: const Icon(
                      Icons.repeat,
                      color: Color(0xFF456EFE),
                    ),
                    labelText: "Repeat",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                  dropdownColor: Theme.of(context).colorScheme.surfaceDim,
                  menuMaxHeight: 200,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    '',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 40),
              SimpleButton(
                data: 'update',
                onPressed: () {
                  final title = titleController.text;
                  final date = dateController.text;
                  final time = timeController.text;
                  final description = descriptionController.text;
                  if (validateFields()) {
                    _reminderBloc.add(
                      ReminderUpdateEvent(
                        reminderID: widget.reminder.id,
                        reminder: updatedReminder = Reminder(
                          id: widget.reminder.id,
                          userID: widget.reminder.userID,
                          createdAt: widget.reminder.createdAt,
                          date: date,
                          description: description,
                          frequancy: _selectedItem!,
                          time: time,
                          title: title,
                        ),
                      ),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  bool validateFields() {
    setState(() {
      errorMessage = '';
    });
    if (titleController.text.isEmpty) {
      setState(() {
        String message =
            AppLocalizations.of(context).translate('task_name_missing');
        errorMessage = message;
      });
      return false;
    }
    if (dateController.text.isEmpty) {
      setState(() {
        String message = AppLocalizations.of(context).translate('date_missing');
        errorMessage = message;
      });
      return false;
    }
    if (timeController.text.isEmpty) {
      setState(() {
        String message = AppLocalizations.of(context).translate('time_missing');
        errorMessage = message;
      });
      return false;
    }
    if (_selectedItem == null) {
      setState(() {
        String message =
            AppLocalizations.of(context).translate('select_repeat_frequency');
        errorMessage = message;
      });
      return false;
    }
    return true;
  }

  void showSuccessSnakBar() {
    CustomSnackBar.show(
      context,
      title: AppLocalizations.of(context).translate('successfully'),
      message: AppLocalizations.of(context).translate('reminder_updated'),
      contentType: ContentType.success,
    );
  }

  void showErrorSnackBar(String error) {
    CustomSnackBar.show(
      context,
      title: 'On Snap!',
      message: error,
      contentType: ContentType.failure,
    );
  }
}
