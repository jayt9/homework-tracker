import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const HomeworkTrackerApp());
}

class HomeworkTrackerApp extends StatelessWidget {
  const HomeworkTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Homework Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const HomeworkListScreen(),
    );
  }
}

class HomeworkAssignment {
  final String id;
  final String title;
  final String subject;
  final String description;
  final DateTime dueDate;
  bool isCompleted;

  HomeworkAssignment({
    required this.id,
    required this.title,
    required this.subject,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
  });
}

class HomeworkListScreen extends StatefulWidget {
  const HomeworkListScreen({Key? key}) : super(key: key);

  @override
  _HomeworkListScreenState createState() => _HomeworkListScreenState();
}

class _HomeworkListScreenState extends State<HomeworkListScreen> {
  final List<HomeworkAssignment> _assignments = [];

  @override
  Widget build(BuildContext context) {
    // Sort assignments by due date
    _assignments.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Homework'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filtering
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filtering coming soon!')),
              );
            },
          ),
        ],
      ),
      body: _assignments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No homework yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first assignment',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _assignments.length,
              itemBuilder: (context, index) {
                final assignment = _assignments[index];
                final bool isOverdue = 
                    assignment.dueDate.isBefore(DateTime.now()) && 
                    !assignment.isCompleted;
                
                return Dismissible(
                  key: Key(assignment.id),
                  background: Container(
                    color: Colors.green,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.check, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      // Delete assignment
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirm"),
                            content: const Text("Are you sure you want to delete this assignment?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text("CANCEL"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text("DELETE"),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      // Mark as completed
                      setState(() {
                        assignment.isCompleted = !assignment.isCompleted;
                      });
                      return false;
                    }
                  },
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      setState(() {
                        _assignments.removeAt(index);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Assignment deleted'),
                          action: SnackBarAction(
                            label: 'UNDO',
                            onPressed: () {
                              setState(() {
                                _assignments.insert(index, assignment);
                              });
                            },
                          ),
                        ),
                      );
                    }
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _subjectColor(assignment.subject),
                        child: Icon(
                          _subjectIcon(assignment.subject),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        assignment.title,
                        style: TextStyle(
                          decoration: assignment.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: assignment.isCompleted
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        '${assignment.subject} • Due ${DateFormat('MMM d').format(assignment.dueDate)}',
                        style: TextStyle(
                          color: isOverdue ? Colors.red : Colors.grey[600],
                        ),
                      ),
                      trailing: assignment.isCompleted
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : isOverdue
                              ? const Icon(Icons.warning, color: Colors.red)
                              : const Icon(Icons.circle_outlined),
                      onTap: () {
                        // Open edit assignment screen
                        _editAssignment(context, assignment);
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewAssignment(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _subjectColor(String subject) {
    // Return different colors based on subject
    switch (subject.toLowerCase()) {
      case 'math':
        return Colors.blue;
      case 'science':
        return Colors.green;
      case 'english':
        return Colors.purple;
      case 'history':
        return Colors.brown;
      case 'art':
        return Colors.pink;
      case 'computer science':
        return Colors.teal;
      default:
        return Colors.orange;
    }
  }

  IconData _subjectIcon(String subject) {
    // Return different icons based on subject
    switch (subject.toLowerCase()) {
      case 'math':
        return Icons.calculate;
      case 'science':
        return Icons.science;
      case 'english':
        return Icons.menu_book;
      case 'history':
        return Icons.history_edu;
      case 'art':
        return Icons.brush;
      case 'computer science':
        return Icons.computer;
      default:
        return Icons.assignment;
    }
  }

  void _addNewAssignment(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditAssignmentScreen(),
      ),
    );

    if (result != null && result is HomeworkAssignment) {
      setState(() {
        _assignments.add(result);
      });
    }
  }

  void _editAssignment(BuildContext context, HomeworkAssignment assignment) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditAssignmentScreen(assignment: assignment),
      ),
    );

    if (result != null && result is HomeworkAssignment) {
      setState(() {
        final index = _assignments.indexWhere((a) => a.id == assignment.id);
        if (index != -1) {
          _assignments[index] = result;
        }
      });
    }
  }
}

class AddEditAssignmentScreen extends StatefulWidget {
  final HomeworkAssignment? assignment;

  const AddEditAssignmentScreen({Key? key, this.assignment}) : super(key: key);

  @override
  _AddEditAssignmentScreenState createState() => _AddEditAssignmentScreenState();
}

class _AddEditAssignmentScreenState extends State<AddEditAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedSubject = 'Other';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _dueTime = TimeOfDay.now();
  bool _isCompleted = false;

  final List<String> _subjects = [
    'Math',
    'Science',
    'English',
    'History',
    'Art',
    'Computer Science',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.assignment != null) {
      _titleController.text = widget.assignment!.title;
      _descriptionController.text = widget.assignment!.description;
      _selectedSubject = widget.assignment!.subject;
      _dueDate = widget.assignment!.dueDate;
      _dueTime = TimeOfDay.fromDateTime(widget.assignment!.dueDate);
      _isCompleted = widget.assignment!.isCompleted;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.assignment != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Assignment' : 'New Assignment'),
        actions: [
          if (isEditing)
            IconButton(
              icon: Icon(
                _isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                color: _isCompleted ? Colors.green : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _isCompleted = !_isCompleted;
                });
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Assignment Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
                value: _selectedSubject,
                items: _subjects.map((subject) {
                  return DropdownMenuItem(
                    value: subject,
                    child: Text(subject),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSubject = value ?? 'Other';
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDueDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Due Date',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(DateFormat('MMM d, yyyy').format(_dueDate)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDueTime(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Due Time',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_dueTime.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveAssignment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  isEditing ? 'Update Assignment' : 'Add Assignment',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _selectDueTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dueTime,
    );
    if (picked != null && picked != _dueTime) {
      setState(() {
        _dueTime = picked;
      });
    }
  }

  void _saveAssignment() {
    if (_formKey.currentState!.validate()) {
      // Combine date and time
      final dueDateTime = DateTime(
        _dueDate.year,
        _dueDate.month,
        _dueDate.day,
        _dueTime.hour,
        _dueTime.minute,
      );

      final assignment = HomeworkAssignment(
        id: widget.assignment?.id ?? DateTime.now().toString(),
        title: _titleController.text,
        subject: _selectedSubject,
        description: _descriptionController.text,
        dueDate: dueDateTime,
        isCompleted: _isCompleted,
      );

      Navigator.pop(context, assignment);
    }
  }
}