class Profile {
  final String userName;
  final String phoneNumber;
  Profile({required this.phoneNumber, required this.userName});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      userName: json['user']['name'],
      phoneNumber: json['user']['phone'],
    );
  }
}
