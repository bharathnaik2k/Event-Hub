import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventhub/src/models/events_model.dart' show EventModel;
import 'package:eventhub/src/utils/constants.dart' show AppColors;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventDetailsScreen extends StatelessWidget {
  final EventModel event;
  final User user;
  const EventDetailsScreen({
    super.key,
    required this.event,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final dateTime = DateTime(
      event.dateTime!.year,
      event.dateTime!.month,
      event.dateTime!.day,
      event.dateTime!.hour,
      event.dateTime!.minute,
    );

    Future<void> joinEvent(String eventId, String userId) async {
      await firestore.collection('public_events').doc(eventId).update({
        'attendeeList': FieldValue.arrayUnion([userId]),
      });
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/routerPath');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Joined successfully!')));
      }
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            flexibleSpace: FlexibleSpaceBar(
              background:
                  event.coverImageUrl == null
                      ? Image.asset(
                        'assets/images/noImg.png',
                        fit: BoxFit.cover,
                      )
                      : Image.network(
                        event.coverImageUrl.toString(),
                        fit: BoxFit.cover,
                      ),
            ),
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: const Color.fromARGB(104, 0, 0, 0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            // actions: [
            //   Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: CircleAvatar(
            //       backgroundColor: const Color.fromARGB(104, 0, 0, 0),
            //       child: IconButton(
            //         icon: const Icon(Icons.ios_share, color: Colors.white),
            //         onPressed: () {},
            //       ),
            //     ),
            //   ),
            // ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title ?? '',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1a1a1a),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Color(0xFF7c3aed),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE, MMMM d').format(dateTime),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1a1a1a),
                              ),
                            ),
                            Text(
                              '${DateFormat('h:mm a').format(dateTime)} - ${DateFormat('h:mm a').format(dateTime.add(Duration(hours: 4)))}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Color(0xFF7c3aed),
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Text(
                          event.location ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1a1a1a),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.category_rounded,
                          color: Color(0xFF7c3aed),
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Text(
                          event.category ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1a1a1a),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Color(0xFFe0e0e0),
                          child: Icon(Icons.person, color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hosted by',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF666666),
                              ),
                            ),
                            Text(
                              event.creatorName ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF7c3aed),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        SizedBox(
                          width: 80,
                          height: 32,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    255,
                                    153,
                                    0,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: Color.fromARGB(255, 255, 223, 176),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 20,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    233,
                                    30,
                                    99,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: Color.fromARGB(255, 233, 159, 184),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 40,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    33,
                                    150,
                                    243,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: Color.fromARGB(255, 151, 201, 242),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${event.attendeeList!.length} people attending',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color:
                                  user.uid == event.creatorId
                                      ? AppColors.grey
                                      : event.attendeeList!.contains(user.uid)
                                      ? AppColors.grey
                                      : null,
                              gradient:
                                  user.uid == event.creatorId
                                      ? null
                                      : event.attendeeList!.contains(user.uid)
                                      ? null
                                      : AppColors.primaryGradient,
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                if (user.uid != event.creatorId) {
                                  if (event.attendeeList!.contains(user.uid)) {
                                    return;
                                  } else {
                                    joinEvent(event.id!, user.uid);
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  0,
                                  0,
                                  0,
                                  0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                user.uid == event.creatorId
                                    ? 'Hosted by you'
                                    : event.attendeeList!.contains(user.uid)
                                    ? 'Alredy joined'
                                    : 'Join Event',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // const SizedBox(width: 12),
                        // Container(
                        //   decoration: BoxDecoration(
                        //     border: Border.all(color: Color(0xFFe0e0e0)),
                        //     borderRadius: BorderRadius.circular(12),
                        //   ),
                        //   child: IconButton(
                        //     style: IconButton.styleFrom(
                        //         shape: RoundedRectangleBorder()),
                        //     icon: Icon(
                        //       Icons.chat_bubble_outline_sharp,
                        //       color: Color(0xFF7c3aed),
                        //     ),
                        //     onPressed: () {},
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'About this event',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1a1a1a),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      event.description ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
