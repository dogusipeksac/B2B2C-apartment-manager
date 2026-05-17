/// Read-only profile context from server (unit, code) plus editable name.
class ProfileDetails {
  const ProfileDetails({
    this.fullName,
    this.buildingName,
    this.unitLabel,
    this.inviteCode,
    this.profileId,
  });

  final String? fullName;
  final String? buildingName;
  final String? unitLabel;
  final String? inviteCode;
  final String? profileId;
}
