/// The screen sizes the reviewer can lay a real screen out at.
enum Device {
  desktop(1440, 900, 'Desktop'),
  tablet(820, 1180, 'Tablet'),
  phone(390, 844, 'Phone');

  const Device(this.width, this.height, this.label);

  final double width;
  final double height;
  final String label;

  /// Reads a stored or deep-link size. Notes written before the three sizes
  /// stored `wide`, which meant the desktop layout. Anything else is Phone.
  static Device fromStored(Object? value) => switch (value) {
        'desktop' || 'wide' => Device.desktop,
        'tablet' => Device.tablet,
        _ => Device.phone,
      };
}
