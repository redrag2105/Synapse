export default () => ({
  nodeEnv: process.env.NODE_ENV ?? 'development',
  port: Number(process.env.PORT ?? 4000),
  apiPrefix: process.env.API_PREFIX ?? 'api',
  corsOrigins: (process.env.CORS_ORIGINS ?? 'http://localhost:3000')
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean),
  firebase: {
    projectId: process.env.FIREBASE_PROJECT_ID,
    storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
    serviceAccountBase64: process.env.FIREBASE_SERVICE_ACCOUNT_BASE64,
    usersCollection: process.env.FIREBASE_USERS_COLLECTION ?? 'users',
    notificationCollection:
      process.env.FIREBASE_NOTIFICATION_COLLECTION ?? 'notificationCampaigns',
    auditLogCollection:
      process.env.FIREBASE_AUDIT_LOG_COLLECTION ?? 'adminAuditLogs',
    reportsPrefix: process.env.FIREBASE_REPORTS_PREFIX ?? 'reports',
    defaultTopic: process.env.FCM_DEFAULT_TOPIC ?? 'all-users'
  },
  analytics: {
    propertyId: process.env.GOOGLE_ANALYTICS_PROPERTY_ID
  },
  crashlytics: {
    googleCloudProjectId: process.env.GOOGLE_CLOUD_PROJECT_ID,
    bigQueryLocation: process.env.BIGQUERY_LOCATION,
    dataset: process.env.BIGQUERY_CRASHLYTICS_DATASET
  },
  throttle: {
    ttl: Number(process.env.THROTTLE_TTL_MS ?? 60000),
    limit: Number(process.env.THROTTLE_LIMIT ?? 100)
  }
});
