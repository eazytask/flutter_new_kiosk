import 'package:kiosk/src/core/provider/view.state.dart';
import 'package:flutter/widgets.dart';

class BaseProvider extends ChangeNotifier {
  ViewState _state = ViewState.Idle;
  ViewState get state => _state;

  void setState(ViewState viewState) {
    _state = viewState;
  }

  bool _isBusy = false;

  // ignore: unnecessary_getters_setters
  bool get isBusy => _isBusy;

  set loading(bool value) {
    _isBusy = value;
    notifyListeners();
  }
  // ignore: unnecessary_getters_setters
  set isBusy(bool value) => _isBusy = value;

  bool _isPaginating = false;
  bool get isPaginating => _isPaginating;
  set isPaginating(bool value) {
    _isPaginating = value;
    notifyListeners();
  }

}