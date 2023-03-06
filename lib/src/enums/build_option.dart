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

  final String name;
  final String abbr;
  final String help;
  final String valueHelp;
  final bool mandatory;

  const BuildOption({
    required this.name,
    required this.abbr,
    required this.help,
    required this.valueHelp,
    this.mandatory = false,
  });
}
