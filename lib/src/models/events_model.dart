import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String? id;
  final String? title;
  final String? description;
  final String? location;
  final List<String>? attendeeList;
  final String? category;
  final String? creatorId;
  final String? creatorName;
  final String? coverImageUrl;
  final int attendeeCount;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? dateTime;
  final DateTime? timestamp;

  EventModel({
    this.id,
    this.title,
    this.description,
    this.location,
    this.attendeeList,
    this.category,
    this.creatorId,
    this.creatorName,
    this.coverImageUrl,
    this.attendeeCount = 0,
    this.isActive = true,
    this.createdAt,
    this.dateTime,
    this.timestamp,
  });

  factory EventModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return EventModel(
      id: id,
      title: map['title'] as String?,
      description: map['description'] as String?,
      location: map['location'] as String?,
      attendeeList:
          map['attendeeList'] != null
              ? List<String>.from(map['attendeeList'] as List)
              : null,
      category: map['category'] as String?,
      creatorId: map['creatorId'] as String?,
      creatorName: map['creatorName'] as String?,
      coverImageUrl: map['coverImageUrl'] as String?,
      attendeeCount: (map['attendeeCount'] as int?) ?? 0,
      isActive: (map['isActive'] as bool?) ?? true,
      createdAt: _parseTimestamp(map['createdAt']),
      dateTime: _parseTimestamp(map['dateTime']),
      timestamp: _parseTimestamp(map['timestamp']),
    );
  }

  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is DateTime) {
      return timestamp;
    }
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'attendeeList': attendeeList,
      'category': category,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'coverImageUrl': coverImageUrl,
      'attendeeCount': attendeeCount,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'dateTime': dateTime != null ? Timestamp.fromDate(dateTime!) : null,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : null,
    };
  }

  EventModel copyWithAddedAttendee(String attendee) {
    final updatedList = List<String>.from(attendeeList ?? [])..add(attendee);
    return EventModel(
      id: id,
      title: title,
      description: description,
      location: location,
      attendeeList: updatedList,
      category: category,
      creatorId: creatorId,
      creatorName: creatorName,
      coverImageUrl: coverImageUrl,
      attendeeCount: updatedList.length,
      isActive: isActive,
      createdAt: createdAt,
      dateTime: dateTime,
      timestamp: timestamp,
    );
  }
}
