// ignore_for_file: avoid_print

class Printer {
  const Printer._();

  static void printNormal(String message) =>
      print('📘 \x1B[36m$message\x1B[0m 📘');

  static void printWarning(String message) =>
      print('\n📙 \x1B[33m$message\x1B[0m 📙\n');

  static void printSuccess(String message) =>
      print('\n📗 \x1B[32m$message\x1B[0m 📗\n');
  static void printError(String message) =>
      print('\n📕 \x1B[31m$message\x1B[0m 📕\n');
}
