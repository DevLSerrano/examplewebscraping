import 'package:chaleno/chaleno.dart';

//Modelo de resultado para as funcoes do chaleno
class ModelChalenoResult {
  Result? resultById;

  List<Result>? resultsByClassName;

  ModelChalenoResult({
    required this.resultById,
    required this.resultsByClassName,
  });
}
