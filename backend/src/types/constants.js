/**
 * @file constants.js
 * @description Master data system constants shared across backend services.
 */

export const SYSTEM_CONSTANTS = Object.freeze({
  APP_NAME: "Smart Campus Management System",
  API_VERSION: "v1",
  DEFAULT_TIMEZONE: "UTC",
  DEFAULT_DATE_FORMAT: "YYYY-MM-DDTHH:mm:ss.SSSZ",

  // Image Upload Configurations
  MAX_IMAGE_UPLOAD_SIZE: 10 * 1024 * 1024, // 10 MB in bytes
  ALLOWED_IMAGE_EXTENSIONS: [".jpg", ".jpeg", ".png", ".webp"],
  ALLOWED_IMAGE_MIME_TYPES: ["image/jpeg", "image/png", "image/webp"],

  // Pagination Defaults
  DEFAULT_PAGE: 1,
  DEFAULT_PAGE_SIZE: 10,
  MAX_PAGE_SIZE: 100,

  // Hardware & Code Prefixes
  QR_CODE_PREFIX: "QR-",
});
