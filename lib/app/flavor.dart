enum Flavor { dev, staging, prod }

extension FlavorX on Flavor {
  String get displayName => switch (this) {
        Flavor.dev => 'Pantas Dev',
        Flavor.staging => 'Pantas Staging',
        Flavor.prod => 'Pantas',
      };
}
