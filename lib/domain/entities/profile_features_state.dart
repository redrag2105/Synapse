class ProfileNotification {
  final String id;
  final String title;
  final String body;
  final DateTime receivedAt;

  const ProfileNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
  });
}

class ProfileFeaturesState {
  final bool isLoadingRemoteConfig;
  final String? uploadedReportUrl;
  final bool isExportingReport;
  final String? statusMessage;

  const ProfileFeaturesState({
    this.isLoadingRemoteConfig = false,
    this.uploadedReportUrl,
    this.isExportingReport = false,
    this.statusMessage,
  });

  ProfileFeaturesState copyWith({
    bool? isLoadingRemoteConfig,
    String? uploadedReportUrl,
    bool? isExportingReport,
    String? statusMessage,
    bool clearStatusMessage = false,
    bool clearUploadedReportUrl = false,
  }) {
    return ProfileFeaturesState(
      isLoadingRemoteConfig:
          isLoadingRemoteConfig ?? this.isLoadingRemoteConfig,
      uploadedReportUrl: clearUploadedReportUrl
          ? null
          : (uploadedReportUrl ?? this.uploadedReportUrl),
      isExportingReport: isExportingReport ?? this.isExportingReport,
      statusMessage:
          clearStatusMessage ? null : (statusMessage ?? this.statusMessage),
    );
  }
}
