class LockerTelemetry {
  final String compartmentId;
  final double temperature;
  final double targetTemperature;
  final double humidity;
  final bool isDoorLocked;
  final String powerSource; // "Solar Hybrid", "Grid 220V", "Backup Battery"
  final int batteryLevel; // percentage
  final double powerConsumptionWatts;
  final String networkStatus; // "Connected (4G/LTE)", "Online"
  final DateTime lastUpdated;

  const LockerTelemetry({
    required this.compartmentId,
    required this.temperature,
    required this.targetTemperature,
    required this.humidity,
    required this.isDoorLocked,
    required this.powerSource,
    required this.batteryLevel,
    required this.powerConsumptionWatts,
    required this.networkStatus,
    required this.lastUpdated,
  });

  bool get isTempNormal {
    // Within +- 3 degrees of target
    return (temperature - targetTemperature).abs() <= 3.5;
  }
}
