import 'package:flutter/material.dart';
import 'package:expense_tracker/settings/currency_preferences.dart';
import 'package:expense_tracker/theme/app_theme.dart';
import 'package:expense_tracker/models/expense.dart';

class NewExpense extends StatefulWidget {
  const NewExpense({super.key, required this.onSave, this.expense});

  final void Function(Expense expense) onSave;
  final Expense? expense; // null = adding, not null = editing

  @override
  State<NewExpense> createState() => _NewExpenseState();
}

class _NewExpenseState extends State<NewExpense> {
  final _formKey = GlobalKey<FormState>();
  final _dateFieldKey = GlobalKey<FormFieldState<DateTime>>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  DateTime? _selectedDate;
  bool _hasSubmitted = false;
  Category _selectedCategory = Category.Food;

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _titleController = TextEditingController(text: e?.title ?? '');
    _amountController = TextEditingController(text: e?.amount.toString() ?? '');
    _noteController = TextEditingController(text: e?.note ?? '');
    _selectedDate = e?.date;
    _selectedCategory = e?.category ?? Category.Food;
  }

  void _presentDatePicker() async {
    final now = DateUtils.dateOnly(DateTime.now());
    final oldestDate = DateTime(now.year - 5, now.month, now.day);
    final initialDate = DateUtils.dateOnly(_selectedDate ?? now);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: initialDate.isBefore(oldestDate) ? initialDate : oldestDate,
      lastDate: initialDate.isAfter(now) ? initialDate : now,
    );
    if (!mounted || pickedDate == null) return;
    setState(() {
      _selectedDate = pickedDate;
      _dateFieldKey.currentState?.didChange(pickedDate);
    });
  }

  Future<void> _submitExpenseData() async {
    if (_hasSubmitted || !_formKey.currentState!.validate()) return;
    setState(() => _hasSubmitted = true);
    FocusScope.of(context).unfocus();
    final enteredAmount = double.parse(_amountController.text.trim());

    final note = _noteController.text.trim();

    widget.onSave(
      Expense(
        id: widget.expense?.id, // keeps the same id when editing
        title: _titleController.text.trim(),
        amount: enteredAmount,
        date: _selectedDate!,
        category: _selectedCategory,
        note: note.isEmpty ? null : note,
      ),
    );
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text(_isEditing ? 'Expense updated' : 'Expense saved'),
          content: Text(
            _isEditing
                ? 'Your changes have been saved.'
                : 'Your expense has been saved.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: SizedBox(
        height: double.infinity,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppTheme.pagePadding,
              AppTheme.pagePadding,
              AppTheme.pagePadding,
              AppTheme.pagePadding + keyboardSpace,
            ),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Please enter a title.'
                        : null,
                    keyboardType: TextInputType.text,
                    maxLength: 50,
                    decoration: const InputDecoration(label: Text('Title')),
                  ),
                  const SizedBox(height: AppTheme.smallSpacing),
                  ValueListenableBuilder<ExpenseCurrency>(
                    valueListenable: CurrencyPreferences.current,
                    builder: (context, currency, _) => TextFormField(
                      controller: _amountController,
                      validator: (value) {
                        final amount = double.tryParse(value?.trim() ?? '');
                        return amount == null || !amount.isFinite || amount <= 0
                            ? 'Enter a valid amount greater than zero.'
                            : null;
                      },
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      maxLength: 50,
                      decoration: InputDecoration(
                        prefixText: '${currency.code} ',
                        labelText: 'Amount',
                        errorMaxLines: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.smallSpacing),
                  FormField<DateTime>(
                    key: _dateFieldKey,
                    initialValue: _selectedDate,
                    validator: (value) =>
                        value == null ? 'Please select a date.' : null,
                    builder: (field) => InkWell(
                      onTap: _presentDatePicker,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date',
                          errorText: field.errorText,
                          errorMaxLines: 3,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedDate == null
                                    ? 'No date selected'
                                    : formatter.format(_selectedDate!),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Select date',
                              onPressed: _presentDatePicker,
                              icon: const Icon(Icons.calendar_month),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.pagePadding),
                  TextFormField(
                    controller: _noteController,
                    keyboardType: TextInputType.text,
                    maxLength: 100,
                    decoration: const InputDecoration(
                      label: Text('Note (optional)'),
                    ),
                  ),
                  const SizedBox(height: AppTheme.pagePadding),
                  DropdownButtonFormField<Category>(
                    initialValue: _selectedCategory,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: Category.values
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category.name.toUpperCase()),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _selectedCategory = value);
                    },
                  ),
                  const SizedBox(height: AppTheme.sectionSpacing),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      TextButton(
                        onPressed: _hasSubmitted
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: _hasSubmitted ? null : _submitExpenseData,
                        child: Text(
                          _isEditing ? 'Update Expense' : 'Save Expense',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
