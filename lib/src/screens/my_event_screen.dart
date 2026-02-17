import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventhub/src/models/events_model.dart' show EventModel;
import 'package:eventhub/src/screens/view_details_screen.dart'
    show EventDetailsScreen;
import 'package:eventhub/src/services/event_service.dart' show EventService;
import 'package:eventhub/src/utils/constants.dart' show AppColors;
import 'package:eventhub/src/widgets/event_card.dart' show EventCard;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyEventScreen extends StatefulWidget {
  const MyEventScreen({super.key});

  @override
  State<MyEventScreen> createState() => _MyEventScreenState();
}

class _MyEventScreenState extends State<MyEventScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;
  bool _isLoading = true;
  List<EventModel> allEvents = [];
  List<EventModel> myEvents = [];

  @override
  void initState() {
    _getMyEvents();
    super.initState();
  }

  void _getMyEvents() async {
    allEvents = EventService().events;
    final userId = user?.uid ?? '';
    myEvents = allEvents.where((e) => e.creatorId == userId).toList();
    allEvents = EventService().events;
    log(allEvents.toString());
    _isLoading = !_isLoading;
    setState(() {});
  }

  void _deleteEvent(String id) async {
    try {
      await _firestore.collection('public_events').doc(id).delete();
      Navigator.of(context).pop();
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> _showDeleteConfirmDialog(String id) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Item'),
            content: const Text('Are you sure you want to delete this item?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // Cancel
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _deleteEvent(id);
                }, // Confirm
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      // perform delete action here
      print('Item deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        foregroundColor: Colors.white,
        title: Text('My Events'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : myEvents.isEmpty
                ? Center(child: Text("Not Published any Event!"))
                : ListView.builder(
                  itemCount: myEvents.length,
                  itemBuilder: (context, index) {
                    return EventCard(
                      event: myEvents[index],
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => EventDetailsScreen(
                                  event: myEvents[index],
                                  user: user!,
                                ),
                          ),
                        );
                      },
                      delete: Align(
                        alignment: Alignment.topLeft,
                        child: CircleAvatar(
                          backgroundColor: const Color.fromARGB(
                            255,
                            255,
                            220,
                            220,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Color.fromARGB(255, 255, 0, 0),
                            ),
                            onPressed: () {
                              // deleteEvent(myEvents[index].id.toString());
                              _showDeleteConfirmDialog(
                                myEvents[index].id.toString(),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
