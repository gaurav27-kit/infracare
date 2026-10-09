/**
 * @file apiResponse.js
 * @description Standardized API response structure.
 */

export class ApiResponse {
  constructor(statusCode, success, message, data = null, meta = null) {
    this.statusCode = statusCode;
    this.success = success;
    this.message = message;
    if (data !== null) this.data = data;
    if (meta !== null) this.meta = meta;
  }

  static success(res, message = "Success", data = null, statusCode = 200, meta = null) {
    const response = new ApiResponse(statusCode, true, message, data, meta);
    return res.status(statusCode).json({
      success: response.success,
      message: response.message,
      ...(data !== null && { data }),
      ...(meta !== null && { meta }),
    });
  }

  static error(res, message = "Error occurred", errors = [], statusCode = 500) {
    return res.status(statusCode).json({
      success: false,
      message,
      ...(errors && errors.length > 0 && { errors }),
    });
  }
}
