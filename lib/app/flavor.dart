enum Flavor { dev, staging, prod }

extension FlavorX on Flavor {
  String get displayName => switch (this) {
        Flavor.dev => 'CSE/CET Reviewer Dev',
        Flavor.staging => 'CSE/CET Reviewer Staging',
        Flavor.prod => 'CSE/CET Reviewer',
      };
}
