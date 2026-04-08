import 'package:rapid_app/core/models/issue.dart';

class IssueDatabase {
  static final Map<String, DiagnosticIssue> issues = {
    'C0074': const DiagnosticIssue(
      code: 'C0074',
      title: 'ABS Brake Pressure Sensor Circuit',
      severity: DiagnosticSeverity.critical,
      description:
          'This code indicates a problem in the electrical system that monitors how hard you press the brake pedal.',
      recommendedAction:
          'Drive carefully and keep your speed moderate (preferably below 50 km/h). Avoid sudden braking and have the vehicle checked as soon as possible.',
      estimatedCost: '₦4,000 - ₦10,000',
      possibleCauses: [
        'Faulty Brake Pressure Sensor',
        'Damaged or Corroded Wiring',
        'Blown Fuse',
        'ABS Control Module Issue',
        'Low Brake Fluid',
        'Short Circuit / Ground Fault',
      ],
      unsafeToDrive: true,
    ),
    'P0A01': const DiagnosticIssue(
      code: 'P0A01',
      title: 'Drive Motor A Inverter Performance',
      severity: DiagnosticSeverity.warning,
      description:
          'The engine control module has detected a performance issue with the inverter that controls the electric drive motor A.',
      recommendedAction:
          'Maintain a steady speed and avoid rapid acceleration. Monitor the vehicle\'s hybrid system indicators and schedule a diagnostic check.',
      estimatedCost: '₦45,000 - ₦90,000',
      possibleCauses: [
        'Inverter Coolant Pump Failure',
        'Internal Inverter Damage',
        'Hybrid Battery Voltage Issues',
        'Sensor Calibration Error',
      ],
      unsafeToDrive: false,
    ),
    'P0001': const DiagnosticIssue(
      code: 'P0001',
      title: 'Fuel Volume Regulator Control Circuit/Open',
      severity: DiagnosticSeverity.critical,
      description:
          'The powertrain control module (PCM) has detected an open circuit in the fuel volume regulator control circuit.',
      recommendedAction:
          'Do not drive the vehicle if you notice severe performance loss or stalling. Have the fuel system inspected immediately.',
      estimatedCost: '₦12,000 - ₦25,000',
      possibleCauses: [
        'Fuel Volume Regulator Solenoid Failure',
        'Corroded Electrical Connectors',
        'Damaged Wiring Harness',
        'PCM Software Error',
      ],
      unsafeToDrive: true,
    ),
    'B1365': const DiagnosticIssue(
      code: 'B1365',
      title: 'Ignition Start Circuit Failure',
      severity: DiagnosticSeverity.info,
      description:
          'The vehicle body control module has identified an issue with the ignition start circuit, likely a momentary interruption.',
      recommendedAction:
          'If the vehicle starts normally, monitor for recurrence. If it fails to start, check the battery and ignition switch.',
      estimatedCost: '₦2,500 - ₦6,000',
      possibleCauses: [
        'Weak Battery',
        'Loose Ignition Switch Terminal',
        'Faulty Starter Relay',
      ],
      unsafeToDrive: false,
    ),
    'P0420': const DiagnosticIssue(
      code: 'P0420',
      title: 'Catalyst System Efficiency Below Threshold',
      severity: DiagnosticSeverity.critical,
      description:
          'The oxygen sensor has detected that the catalytic converter is not performing at minimum efficiency.',
      recommendedAction:
          'Avoid heavy acceleration and high speeds. Have the exhaust system and oxygen sensors inspected immediately.',
      estimatedCost: '₦60,000 - ₦150,000',
      possibleCauses: [
        'Damaged Catalytic Converter',
        'Faulty Oxygen Sensor',
        'Exhaust Leak',
        'Engine Misfire',
      ],
      unsafeToDrive: true,
    ),
    'P0171': const DiagnosticIssue(
      code: 'P0171',
      title: 'System Too Lean (Bank 1)',
      severity: DiagnosticSeverity.warning,
      description:
          'The engine control module has detected that the air-fuel mixture is too lean (too much air, not enough fuel).',
      recommendedAction:
          'Check for vacuum leaks or a dirty mass airflow sensor. Avoid driving at high speeds until fixed.',
      estimatedCost: '₦15,000 - ₦35,000',
      possibleCauses: [
        'Vacuum Leak',
        'Dirty Mass Airflow (MAF) Sensor',
        'Clogged Fuel Injectors',
        'Faulty Fuel Pump',
      ],
      unsafeToDrive: false,
    ),
    'P0456': const DiagnosticIssue(
      code: 'P0456',
      title: 'EVAP System Very Small Leak Detected',
      severity: DiagnosticSeverity.info,
      description:
          'A very small leak has been detected in the evaporative emission control system.',
      recommendedAction:
          'Check that your gas cap is tightened properly. If the light stays on, have a professional check for tiny cracks in EVAP hoses.',
      estimatedCost: '₦5,000 - ₦15,000',
      possibleCauses: [
        'Loose or Faulty Gas Cap',
        'Cracked EVAP Hose',
        'Faulty Purge Valve',
        'Leaky Charcoal Canister',
      ],
      unsafeToDrive: false,
    ),
  };

  static DiagnosticIssue? getIssue(String code) => issues[code];
}
