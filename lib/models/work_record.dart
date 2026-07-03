class WorkRecord {
  final int? id;
  final String date;
  final String title;
  final double revenue;
  final double fuel;
  final double garage;
  final double maintenance;
  final double otherExpenses;
  final double totalExpenses;
  final double netProfit;
  final String notes;
  final String createdAt;
  final String updatedAt;

  WorkRecord({
    this.id,
    required this.date,
    required this.title,
    required this.revenue,
    required this.fuel,
    required this.garage,
    required this.maintenance,
    required this.otherExpenses,
    required this.totalExpenses,
    required this.netProfit,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkRecord.create({
    required String date,
    required String title,
    required double revenue,
    required double fuel,
    required double garage,
    required double maintenance,
    required double otherExpenses,
    required String notes,
  }) {
    final now = DateTime.now().toIso8601String();
    final total = fuel + garage + maintenance + otherExpenses;
    return WorkRecord(
      date: date,
      title: title,
      revenue: revenue,
      fuel: fuel,
      garage: garage,
      maintenance: maintenance,
      otherExpenses: otherExpenses,
      totalExpenses: total,
      netProfit: revenue - total,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  WorkRecord copyWith({
    int? id,
    String? date,
    String? title,
    double? revenue,
    double? fuel,
    double? garage,
    double? maintenance,
    double? otherExpenses,
    double? totalExpenses,
    double? netProfit,
    String? notes,
    String? createdAt,
    String? updatedAt,
  }) {
    return WorkRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      revenue: revenue ?? this.revenue,
      fuel: fuel ?? this.fuel,
      garage: garage ?? this.garage,
      maintenance: maintenance ?? this.maintenance,
      otherExpenses: otherExpenses ?? this.otherExpenses,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      netProfit: netProfit ?? this.netProfit,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'date': date,
      'title': title,
      'revenue': revenue,
      'fuel': fuel,
      'garage': garage,
      'maintenance': maintenance,
      'other_expenses': otherExpenses,
      'total_expenses': totalExpenses,
      'net_profit': netProfit,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory WorkRecord.fromMap(Map<String, Object?> map) {
    double d(String key) => ((map[key] as num?) ?? 0).toDouble();
    return WorkRecord(
      id: map['id'] as int?,
      date: map['date'] as String? ?? '',
      title: map['title'] as String? ?? '',
      revenue: d('revenue'),
      fuel: d('fuel'),
      garage: d('garage'),
      maintenance: d('maintenance'),
      otherExpenses: d('other_expenses'),
      totalExpenses: d('total_expenses'),
      netProfit: d('net_profit'),
      notes: map['notes'] as String? ?? '',
      createdAt: map['created_at'] as String? ?? '',
      updatedAt: map['updated_at'] as String? ?? '',
    );
  }
}
