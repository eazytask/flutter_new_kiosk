class Token {
  final String? access;
  final String? refresh;

  Token({this.access, this.refresh});

  Token.fromJson(Map<String, dynamic> map)
      : access = map["access"],
        refresh = map["refresh"];

  Map<String, dynamic> toMap() => {
    "access": access,
    "refresh": refresh,
  };
}