import * as Joi from 'joi';

export const envValidationSchema = Joi.object({
  NODE_ENV: Joi.string().valid('development', 'test', 'production').default('development'),
  PORT: Joi.number().default(4000),
  API_PREFIX: Joi.string().default('api'),
  CORS_ORIGINS: Joi.string().default('http://localhost:3000'),
  FIREBASE_PROJECT_ID: Joi.string().required(),
  FIREBASE_STORAGE_BUCKET: Joi.string().allow('', null),
  FIREBASE_SERVICE_ACCOUNT_BASE64: Joi.string().allow('', null),
  FIREBASE_USERS_COLLECTION: Joi.string().default('users'),
  FIREBASE_NOTIFICATION_COLLECTION: Joi.string().default('notificationCampaigns'),
  FIREBASE_AUDIT_LOG_COLLECTION: Joi.string().default('adminAuditLogs'),
  FIREBASE_REPORTS_PREFIX: Joi.string().default('reports'),
  FCM_DEFAULT_TOPIC: Joi.string().default('all-users'),
  GOOGLE_ANALYTICS_PROPERTY_ID: Joi.string().allow('', null),
  FIREBASE_ANDROID_APP_ID: Joi.string().allow('', null),
  FIREBASE_IOS_APP_ID: Joi.string().allow('', null),
  FIREBASE_WEB_APP_ID: Joi.string().allow('', null),
  GOOGLE_CLOUD_PROJECT_ID: Joi.string().allow('', null),
  BIGQUERY_LOCATION: Joi.string().allow('', null),
  BIGQUERY_ANALYTICS_DATASET: Joi.string().allow('', null),
  BIGQUERY_CRASHLYTICS_DATASET: Joi.string().allow('', null),
  THROTTLE_TTL_MS: Joi.number().default(60000),
  THROTTLE_LIMIT: Joi.number().default(100)
});
