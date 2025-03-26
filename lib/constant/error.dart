import 'package:wiretap_webclient/component/error_base.dart';

const settingNotFoundError = ErrorBase(
  statusCode: 500,
  message: 'Setting not found',
  code: 'UNEXPECTED_CLIENT_ERROR',
);

const settingIsNotInTheOptionsError = ErrorBase(
  statusCode: 400,
  message: 'Setting is not in the options',
  code: 'BAD_CALL',
);
