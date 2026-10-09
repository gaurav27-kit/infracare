/**
 * @file validation.constants.js
 * @description Centralized validation bounds used across Zod request schemas.
 */

export const VALIDATION_LIMITS = Object.freeze({
  CAMPUS: {
    NAME_MIN: 2,
    NAME_MAX: 150,
    CODE_MIN: 2,
    CODE_MAX: 20,
    PHONE_MAX: 50,
    EMAIL_MAX: 255,
  },
  BUILDING: {
    NAME_MIN: 2,
    NAME_MAX: 150,
    CODE_MIN: 2,
    CODE_MAX: 30,
  },
  FLOOR: {
    NAME_MIN: 1,
    NAME_MAX: 100,
    LEVEL_MIN: -5,
    LEVEL_MAX: 150,
  },
  SPACE: {
    NAME_MIN: 2,
    NAME_MAX: 150,
    CODE_MIN: 2,
    CODE_MAX: 30,
    CAPACITY_MIN: 0,
    CAPACITY_MAX: 5000,
  },
  ASSET_CATEGORY: {
    NAME_MIN: 2,
    NAME_MAX: 100,
  },
  ASSET: {
    NAME_MIN: 2,
    NAME_MAX: 150,
    SERIAL_NUMBER_MIN: 2,
    SERIAL_NUMBER_MAX: 100,
  },
  ISSUE: {
    TITLE_MIN: 3,
    TITLE_MAX: 200,
    DESCRIPTION_MIN: 5,
    DESCRIPTION_MAX: 5000,
  },
  WORK_ORDER: {
    COST_MIN: 0,
    COST_MAX: 1000000,
    RESOLUTION_NOTES_MAX: 5000,
  },
});
