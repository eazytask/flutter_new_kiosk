class AppStrings {
  const AppStrings._();

  static const String serverUnrecognisedError = "Processing failed, try again in few minutes!";
  static const String appUnrecognisedError = "Something went wrong, please try again!";

  static const String imageExtensions = r'.(jpeg|jpg|png|gif|heif|hevc|raw|heic)';
  static const String pdfExtensions = r'.(pdf)';
  static const String docExtensions = r'.(doc|docx)';
  static const String pptExtensions = r'.(ppt|pptx)';

  static const String loginBack = "LOGIN BACK";


  //datasource
  static const String apiException = "API_Exception";
  static const String serverExceptionError = "Something went wrong, please try again!";
  static const String unAuthorizedExceptionError = "Authorization failed, please login back!";
  static const String failureExceptionError = "Something went wrong, please try again later!";
  static const String networkFailureError = "Having trouble of connecting to internet";
}