// Home feature — domain models.

class HomeKpi {
  const HomeKpi({
    required this.label,
    required this.value,
    required this.delta,
    required this.deltaPositive,
    this.spark = const [],
  });
  final String label;
  final String value;
  final String delta;
  final bool deltaPositive;
  final List<double> spark;
}

class LiveNow {
  const LiveNow({
    required this.cabin,
    required this.client,
    required this.presenter,
    required this.viewers,
    required this.gmv,
    required this.duration,
  });
  final int cabin;
  final String client;
  final String presenter;
  final int viewers;
  final double gmv;
  final String duration;
}

class UpcomingLive {
  const UpcomingLive({required this.time, required this.client, required this.cabin, required this.presenter, this.duration});
  final String time;
  final String client;
  final int cabin;
  final String presenter;
  final String? duration;
}

class RankingEntry {
  const RankingEntry({required this.position, required this.name, required this.lives, required this.orders, required this.gmv});
  final int position;
  final String name;
  final int lives;
  final int orders;
  final double gmv;
}

class HomeAlert {
  const HomeAlert({required this.title, required this.subtitle, required this.severity});
  final String title;
  final String subtitle;
  final HomeAlertSeverity severity;
}

enum HomeAlertSeverity { info, warning, danger }

class HomeData {
  const HomeData({required this.kpis, required this.lives, required this.upcoming, required this.ranking, required this.alerts});
  final List<HomeKpi> kpis;
  final List<LiveNow> lives;
  final List<UpcomingLive> upcoming;
  final List<RankingEntry> ranking;
  final List<HomeAlert> alerts;
}
