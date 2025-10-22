// timeline_data.dart
class TimelineEvent {
  final String time;
  final String title;
  final String venue;

  TimelineEvent({required this.time, required this.title, required this.venue});
}

final timelineData = {
  0: [ // Day 1
    TimelineEvent(time: "11:00 AM - 1:00 PM", title: "Inaugration", venue: "I - Hall"),
    TimelineEvent(time: "48-Hour Pre-Event", title: "EO Fool", venue: "Online"),
    TimelineEvent(time: "All Day", title: "Real Cricket", venue: "Lords"),
    TimelineEvent(time: "2:00 PM - 6:00 PM", title: "Workshop (HACKATHON)", venue: "ASH or I-Hall"),
    TimelineEvent(time: "2:00 PM - 4:00 PM", title: "HydroBlast", venue: "Lords"),
    TimelineEvent(time: "4:00 PM - 5:30 PM", title: "RXB Flashmob", venue: "NB"),
    TimelineEvent(time: "6:00 PM - 9:00 PM", title: "ODE to Code", venue: "(CST Dept.) Software Lab"),
    TimelineEvent(time: "6:00 PM - 7:30 PM", title: "CAD Catalyst", venue: "Computer Centre UG 1"),
    TimelineEvent(time: "6:00 PM - 8:00 PM", title: "Craft 'n' Cut", venue: "Computer Center 2"),
    TimelineEvent(time: "6:00 PM - 7:30 PM", title: "Doped", venue: "Gallery 8 (ETC)"),
    TimelineEvent(time: "6:30 PM - 7:30 PM", title: "Hardness Hustle", venue: "4th Year Classroom MME Dept."),
    TimelineEvent(time: "7:30 PM - 8:30 PM", title: "Mathemania", venue: "U-413"),
    TimelineEvent(time: "5:00 PM - 9:00 PM", title: "FIFA", venue: "Library Computer Lab"),
    TimelineEvent(time: "7:00 PM onwards", title: "Robotics Event", venue: "Lords"),
    TimelineEvent(time: "9:00 PM onwards", title: "BGMI", venue: "Online"),
  ],
  1: [ // Day 2
    TimelineEvent(time: "9:00 AM - 6:00 PM", title: "Hackathon", venue: "Various Locations"),
    TimelineEvent(time: "9:30 AM - 11:00 AM", title: "Rise Above", venue: "Lords"),
    TimelineEvent(time: "All Day", title: "Real Cricket", venue: "Lords"),
    TimelineEvent(time: "10:00 AM - 11:00 AM", title: "Wired In", venue: "Gallery 4 (AE & AM)"),
    TimelineEvent(time: "11:00 AM", title: "Mathemania", venue: "Online"),
    TimelineEvent(time: "11:00 AM - 1:00 PM", title: "Founder's Goal", venue: "I Hall"),
    TimelineEvent(time: "11:00 AM - 2:00 PM", title: "BGMI Final Round", venue: "Computer Centre UG 2"),
    TimelineEvent(time: "10:00 AM - 1:00 PM", title: "FIFA Final Round", venue: "Amenities"),
    TimelineEvent(time: "10:00 AM - 3:00 PM", title: "King's Conquest", venue: "BIX2S Civil Dept."),
    TimelineEvent(time: "10:00 AM - 2:00 PM", title: "Battle of Bards", venue: "Gallery 3 (AE & AM)"),
    TimelineEvent(time: "11:00 AM - 1:00 PM", title: "CAD Catalyst", venue: "IT Classroom 2"),
    TimelineEvent(time: "11:00 AM - 1:00 PM", title: "Hydroblast", venue: "Lords"),
    TimelineEvent(time: "4:00 PM - 5:30 PM", title: "Doped", venue: "Gallery 8 (ETC)"),
    TimelineEvent(time: "11:00 AM - 12:00 PM", title: "Junkyard", venue: "U-413 & U-513"),
    TimelineEvent(time: "2:00 PM - 5:00 PM", title: "Valorant", venue: "Computer Centre UG 2"),
    TimelineEvent(time: "2:00 PM - 4:00 PM", title: "Ignite", venue: "U-613"),
    TimelineEvent(time: "3:00 PM - 4:00 PM", title: "War of Titans", venue: "U-413"),
    TimelineEvent(time: "4:00 PM - 6:00 PM", title: "MayDay Mystery", venue: "RD"),
    TimelineEvent(time: "6:00 PM onwards", title: "Robotics Event", venue: "Lords"),

  ],
  2: [ // Day 3
    TimelineEvent(time: "9:00 AM - 6:00 PM", title: "Hackathon", venue: "Various Locations"),
    TimelineEvent(time: "Before 12:00 PM", title: "Chitrakatha & Photowalk", venue: ""),
    TimelineEvent(time: "All Day", title: "Real Cricket", venue: "Lords"),
    TimelineEvent(time: "10:00 AM - 11:30 AM", title: "Rise Above", venue: "Lords"),
    TimelineEvent(time: "10:00 AM - 1:00 PM", title: "Truss It", venue: "B22N Civil Dept."),
    TimelineEvent(time: "11:30 AM - 1:00 PM", title: "Hardness Hustle", venue: "Heat Treatment Lab & Polishing Lab (MME)"),
    TimelineEvent(time: "2:00 PM - 3:00 PM", title: "War of Titans", venue: "Gallery 3 (AE & AM)"),
    TimelineEvent(time: "9:00 AM - 12:00 PM", title: "Ignite", venue: "I Hall"),
    TimelineEvent(time: "2:00 PM - 6:00 PM", title: "Vicharagni All Rounds", venue: "ASH"),
    TimelineEvent(time: "4:30 PM - 6:00 PM", title: "Junkyard", venue: "Amenities"),
    TimelineEvent(time: "4:00 PM - 6:00 PM", title: "Wired In", venue: "IT Classroom 2"),
    TimelineEvent(time: "6:00 PM onwards", title: "Robotics Event", venue: "Lords"),
    TimelineEvent(time: "8:30 PM - 9:30 PM", title: "Narrimate (pre-event) Judgement", venue: "IT Seminar Hall"),
  ],
};
