class IconMap {
  static final Map<String, String> iconPaths = {
    '01d': 'assets/weather/01d.png',
    '01n': 'assets/weather/01n.png',
    '02d': 'assets/weather/02d.png',
    '02n': 'assets/weather/02n.png',
    '03d': 'assets/weather/03d.png',
    '03n': 'assets/weather/03n.png',
    '04d': 'assets/weather/04d.png',
    '04n': 'assets/weather/04n.png',
    '09d': 'assets/weather/09d.png',
    '09n': 'assets/weather/09n.png',
    '10d': 'assets/weather/10d.png',
    '10n': 'assets/weather/10n.png',
    '11d': 'assets/weather/11d.png',
    '11n': 'assets/weather/11n.png',
    '13d': 'assets/weather/13d.png',
    '13n': 'assets/weather/13n.png',
    '50d': 'assets/weather/50d.png',
    '50n': 'assets/weather/50n.png',
  };

  static String getPath(String icon) {
    var path = iconPaths[icon];
    if (path == null) return "";
    return path;
  }
}
