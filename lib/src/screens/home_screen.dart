import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventhub/src/models/events_model.dart';
import 'package:eventhub/src/screens/view_details_screen.dart';
import 'package:eventhub/src/services/event_service.dart';
import 'package:eventhub/src/widgets/event_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<EventModel> eventsList = [];

  final User? user = FirebaseAuth.instance.currentUser;

  Stream<QuerySnapshot> getMyEvents() {
    return _firestore
        .collection('public_events')
        .orderBy('eventId')
        .snapshots();
  }

  Widget _buildFeedTab() {
    return Expanded(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            decoration: BoxDecoration(gradient: AppColors.primaryGradient),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Nearby Eventsss',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 63.5),
              child: StreamBuilder<QuerySnapshot>(
                stream: getMyEvents(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No events found'));
                  }
                  final events =
                      snapshot.data!.docs
                          .map(
                            (doc) => EventModel.fromMap(
                              doc.data() as Map<String, dynamic>,
                              id: doc.id,
                            ),
                          )
                          .toList();
                  EventService().events = events;
                  return ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      kFloatingActionButtonMargin + 55,
                    ),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return EventCard(
                        event: event,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => EventDetailsScreen(
                                    event: event,
                                    user: user!,
                                  ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [_buildFeedTab()]);
  }
}
