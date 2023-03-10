// ignore_for_file: avoid_print

class Printer {
  const Printer._();

  static void printNormal(String message) =>
      print('š \x1B[36m$message\x1B[0m š');

  static void printWarning(String message) =>
      print('\nš \x1B[33m$message\x1B[0m š\n');

  static void printSuccess(String message) =>
      print('\nš \x1B[32m$message\x1B[0m š\n');
  static void printError(String message) =>
      print('\nš \x1B[31m$message\x1B[0m š\n');
}
