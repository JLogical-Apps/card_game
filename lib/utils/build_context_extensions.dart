import 'package:flutter/material.dart';

extension FindAncestorContext on BuildContext {
  BuildContext? findAncestorContextOfType<T extends Widget>() {
    BuildContext? result;
    visitAncestorElements((element) {
      if (element.widget is T) {
        result = element;
        return false;
      }
      return true;
    });
    return result;
  }
}