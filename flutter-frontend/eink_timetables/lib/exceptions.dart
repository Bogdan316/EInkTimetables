class UnfulfilledRequestException implements Exception {
  String msg;
  UnfulfilledRequestException(this.msg);
}

class RaspPiAlreadyRegisteredException implements Exception {
  String msg;
  RaspPiAlreadyRegisteredException(this.msg);
}