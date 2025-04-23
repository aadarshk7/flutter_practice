class ShareToken {
  final int id;
  final String deviceId;
  bool disabled;
  final String token;
  final String expiresAt;
  final String createdAt;

  ShareToken({
    required this.id,
    required this.deviceId,
    required this.disabled,
    required this.token,
    required this.expiresAt,
    required this.createdAt,
  });

  factory ShareToken.fromJson(Map<String, dynamic> json) {
    return ShareToken(
      id: json['id'],
      deviceId: json['deviceId'],
      disabled: json['disabled'],
      token: json['token'],
      expiresAt: json['expiresAt'],
      createdAt: json['createdAt'],
    );
  }
}
