void sendFirstScreenReady() {}

void sendAppStarted() {}

bool pageBeganFromSplash() => false;

void afterSplashGone(void Function() action) => action();
