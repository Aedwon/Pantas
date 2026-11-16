// LOCAL EXPERIMENT ONLY (E-098). Never merged. Switches read from `?exp=a,b`.
final Set<String> scrollExp = <String>{};

void readScrollExp() {
  final raw = Uri.base.queryParameters['exp'];
  if (raw != null) scrollExp.addAll(raw.split(','));
}
