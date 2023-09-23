import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';

class ExpenseAddModal extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final dateController = useTextEditingController();
    final titleController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final totalExpenseController = useTextEditingController();
    final uploadURL = useState('');
    final receiptPath = useState('');
    final uploading = useState(false);
    final saving = useState(false);

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Upload Image',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              height: 120,
              width: MediaQuery.of(context).size.width - 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blue[200]?.withOpacity(0.3),
                image: receiptPath.value.isNotEmpty
                    ? DecorationImage(
                        image: FileImage(File(receiptPath.value)),
                        fit: BoxFit.contain,
                      )
                    : null,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize:
                      Size((MediaQuery.of(context).size.width - 42) / 2, 48)),
              onPressed: () async {
                final picker = ImagePicker();
                final data = await picker.pickImage(source: ImageSource.camera);
                final upload = await uploadImage(data?.path);
                uploadURL.value = upload ?? '';
              },
              child: const Text('Take Photo'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: totalExpenseController,
              decoration: const InputDecoration(
                labelText: 'Total Expense',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                labelText: 'Date',
              ),
              onTap: () async {
                // Show date picker when the text field is tapped
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );

                if (pickedDate != null) {
                  dateController.text = pickedDate.toUtc().toIso8601String();
                }
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                saving.value = true;
                final title = titleController.text;
                final description = descriptionController.text;
                final selected = dateController.text;
                final total = totalExpenseController.text;
                final url = uploadURL.value;
                final data = <String, dynamic>{
                  'title': title,
                  'description': description,
                  'url': url,
                  'total': total,
                  'dateCreated': selected
                };
                final id = await saveExpense(data);
                saving.value = false;
              },
              child: saving.value
                  ? const SizedBox(
                      height: 25,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ))
                  : const Text(
                      'Save',
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> uploadImage(String? imagePath) async {
    if (imagePath == null) return null;
    final storageRef = FirebaseStorage.instance.ref();
    final receiptRef =
        storageRef.child(DateTime.now().millisecondsSinceEpoch.toString());
    final task = receiptRef.putFile(File(imagePath));
    if (task.snapshot.state == TaskState.success) {
      final completeRef = await task.snapshot.ref.getDownloadURL();
      return completeRef;
    } else {
      return null;
    }
  }

  Future<String> saveExpense(Map<String, dynamic> data) async {
    final collectionRef = FirebaseFirestore.instance;
    final expenses = collectionRef.collection('expenses/${data['date']}');
    final snapshot = await expenses.add(data);
    return snapshot.id;
  }
}
