// Simple API result wrapper to avoid throwing in UI layers
abstract class ApiResult<T> {
  const ApiResult();
}

class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);
}

class ApiFailure<T> extends ApiResult<T> {
  final Exception error;
  final int? statusCode;
  final String message;
  const ApiFailure(this.error, {this.statusCode, this.message = ''});
}
