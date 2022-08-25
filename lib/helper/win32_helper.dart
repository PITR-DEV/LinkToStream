import 'package:win32/win32.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';

void initWin32() {
  print('initializing win32');
  enumerateWindows();
}

void makeWindowDark(int hwnd) {
  const attr = DWMWINDOWATTRIBUTE.DWMWA_USE_IMMERSIVE_DARK_MODE;
  final pref = calloc<BOOL>();
  pref.value = 1;

  DwmSetWindowAttribute(hwnd, attr, pref, sizeOf<BOOL>());
}

void enumerateWindows() {
  final wndProc = Pointer.fromFunction<EnumWindowsProc>(enumWindowsProc, 0);

  EnumWindows(wndProc, 0);
}

int enumWindowsProc(int hWnd, int lParam) {
  final length = GetWindowTextLength(hWnd);
  if (length == 0) {
    return TRUE;
  }

  final buffer = wsalloc(length + 1);
  GetWindowText(hWnd, buffer, length + 1);
  if (buffer.toDartString() == 'LinkToStream') {
    makeWindowDark(hWnd);
  }

  free(buffer);

  return TRUE;
}
