class SystemException implements Exception{
  String cause;
  SystemException(this.cause);
}


class UnauthorizedException implements Exception{
  String cause;
  UnauthorizedException(this.cause);
}

class InternalServerErrorException implements Exception{
  String cause;
  InternalServerErrorException(this.cause);
}


class NotFoundException implements Exception{
  String cause;
  NotFoundException(this.cause);
}

class NotAllowedException implements Exception{
  String cause;
  NotAllowedException(this.cause);
}