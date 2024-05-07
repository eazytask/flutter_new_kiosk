class SignInAndOutRequest {
  final int? timekeeperId;
  final String authToken;
  final String image;
  final String? comment;

  SignInAndOutRequest({
    required this.timekeeperId,
    required this.authToken,
    required this.image,
    required this.comment,
  });

  Map<String, dynamic> toMap() => {
    "timekeeper_id": timekeeperId,
    "image": image,
    "comment": comment,
  };
}