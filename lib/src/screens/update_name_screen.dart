import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventhub/src/utils/constants.dart' show AppColors;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UpdateNameScreen extends StatefulWidget {
  const UpdateNameScreen({super.key});

  @override
  State<UpdateNameScreen> createState() => _UpdateNameScreenState();
}

class _UpdateNameScreenState extends State<UpdateNameScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _nameController = TextEditingController();
  bool _isLoading = false;

  void updateName() async {
    setState(() {
      _isLoading = !_isLoading;
    });
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await _firestore.collection('users').doc(uid).update({
        'displayName': _nameController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      log('Name updated successfully');
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      log('Error updating name: $e');
      setState(() {
        _isLoading = !_isLoading;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Name"),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.primaryGradient),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
              decoration: InputDecoration(
                labelText: 'Enter your new name',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: const Color.fromARGB(255, 217, 81, 255),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter name';
                if (v.isEmpty) return 'Enter valid email';
                return null;
              },
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: AppColors.buttonGradient,
              ),
              child: ElevatedButton(
                onPressed: () {
                  updateName();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isLoading
                        ? SizedBox(
                          height: 18,
                          width: 18,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        )
                        : Text(
                          'Update Name',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
