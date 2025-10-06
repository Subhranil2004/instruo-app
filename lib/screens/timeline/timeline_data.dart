// timeline_data.dart
class TimelineEvent {
  final String time;
  final String title;
  final String venue;

  TimelineEvent({required this.time, required this.title, required this.venue});
}

final timelineData = {
  0: [ // Day 1
    TimelineEvent(time: "10:00 AM", title: "Opening Ceremony", venue: "Main Hall"),
    TimelineEvent(time: "11:00 AM", title: "Coding Contest", venue: "Lab 1"),
  ],
  1: [ // Day 2
    TimelineEvent(time: "09:00 AM", title: "Robotics Challenge", venue: "Ground"),
  ],
  2: [ // Day 3
    TimelineEvent(time: "02:00 PM", title: "Gaming Finals", venue: "Auditorium"),
  ],
};
