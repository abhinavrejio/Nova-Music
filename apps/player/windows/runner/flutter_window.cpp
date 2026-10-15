#include "flutter_window.h"

#include <flutter/encodable_value.h>

#include <optional>
#include <variant>

namespace {
bool SaveHardwareAccelerationPreference(bool enabled) {
  HKEY key = nullptr;
  const LSTATUS create_status = RegCreateKeyExW(
      HKEY_CURRENT_USER, L"Software\\NovaMusic\\Player", 0, nullptr, 0,
      KEY_SET_VALUE, nullptr, &key, nullptr);
  if (create_status != ERROR_SUCCESS) return false;

  const DWORD value = enabled ? 1 : 0;
  const LSTATUS write_status = RegSetValueExW(
      key, L"HardwareAcceleration", 0, REG_DWORD,
      reinterpret_cast<const BYTE*>(&value), sizeof(value));
  RegCloseKey(key);
  return write_status == ERROR_SUCCESS;
}
}  // namespace

#include "flutter/generated_plugin_registrant.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  window_channel_ = std::make_unique<flutter::MethodChannel<>>(
      flutter_controller_->engine()->messenger(), "nova/window",
      &flutter::StandardMethodCodec::GetInstance());
  window_channel_->SetMethodCallHandler(
      [this](const flutter::MethodCall<>& call,
             std::unique_ptr<flutter::MethodResult<>> result) {
        if (call.method_name() == "setHardwareAcceleration") {
          const auto* requested = std::get_if<bool>(call.arguments());
          if (requested == nullptr) {
            result->Error("invalid_argument", "Expected a boolean value.");
          } else if (!SaveHardwareAccelerationPreference(*requested)) {
            result->Error("registry_error",
                          "Could not save the Windows GPU preference.");
          } else {
            result->Success();
          }
          return;
        }

        if (call.method_name() != "setFullscreen") {
          result->NotImplemented();
          return;
        }
        const auto* requested = std::get_if<bool>(call.arguments());
        if (requested == nullptr) {
          result->Error("invalid_argument", "Expected a boolean value.");
          return;
        }

        const HWND window = GetHandle();
        if (*requested && !is_fullscreen_) {
          GetWindowRect(window, &windowed_bounds_);
          windowed_style_ = GetWindowLongPtr(window, GWL_STYLE);
          MONITORINFO monitor_info{sizeof(MONITORINFO)};
          const HMONITOR monitor =
              MonitorFromWindow(window, MONITOR_DEFAULTTONEAREST);
          GetMonitorInfo(monitor, &monitor_info);
          SetWindowLongPtr(window, GWL_STYLE,
                           WS_POPUP | WS_VISIBLE | WS_CLIPCHILDREN |
                               WS_CLIPSIBLINGS);
          SetWindowPos(window, HWND_TOP, monitor_info.rcMonitor.left,
                       monitor_info.rcMonitor.top,
                       monitor_info.rcMonitor.right -
                           monitor_info.rcMonitor.left,
                       monitor_info.rcMonitor.bottom -
                           monitor_info.rcMonitor.top,
                       SWP_FRAMECHANGED | SWP_NOOWNERZORDER);
          is_fullscreen_ = true;
        } else if (!*requested && is_fullscreen_) {
          SetWindowLongPtr(window, GWL_STYLE, windowed_style_);
          SetWindowPos(window, nullptr, windowed_bounds_.left,
                       windowed_bounds_.top,
                       windowed_bounds_.right - windowed_bounds_.left,
                       windowed_bounds_.bottom - windowed_bounds_.top,
                       SWP_FRAMECHANGED | SWP_NOZORDER | SWP_NOOWNERZORDER);
          is_fullscreen_ = false;
        }
        result->Success();
      });

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  window_channel_.reset();
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
