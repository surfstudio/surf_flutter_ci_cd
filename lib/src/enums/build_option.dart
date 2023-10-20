/// Аргументы для команды сборки.
enum BuildOption {
  flavor(
    name: 'flavor',
    abbr: 'f',
    help: 'Application flavor',
    valueHelp: 'flavor',
    mandatory: true,
  ),
  androidPublishingFormat(
    name: 'publishing_format',
    abbr: 'p',
    help: 'Artifact publishing format',
    valueHelp: 'publishing_format',
  ),
  buildType(
    name: 'build_type',
    abbr: 'b',
    help: 'Application build type',
    valueHelp: 'build_type',
    mandatory: true,
  );

  /// Название аргумента.
  final String name;

  /// Сокращённое азвание аргумента.
  final String abbr;

  /// Подсказка.
  final String help;

  /// Пример аргумента.
  final String valueHelp;

  /// Обязательность аргумента.
  final bool mandatory;

  /// Конструктор.
  const BuildOption({
    required this.name,
    required this.abbr,
    required this.help,
    required this.valueHelp,
    this.mandatory = false,
  });
}
