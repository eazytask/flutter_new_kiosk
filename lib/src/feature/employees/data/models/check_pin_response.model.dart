import 'package:kiosk/src/core/domain/entities/shift.entity.dart';

class CheckPinResponseModel{
  final bool success;
  final Shift? shift;

  CheckPinResponseModel({
    required this.success,
    required this.shift,
});
}