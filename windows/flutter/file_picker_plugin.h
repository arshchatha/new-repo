// file_picker_plugin.h

#ifndef FLUTTER_PLUGIN_FILE_PICKER_PLUGIN_H_
#define FLUTTER_PLUGIN_FILE_PICKER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>

namespace file_picker {

class FilePickerPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FilePickerPlugin();

  virtual ~FilePickerPlugin();

  // Disallow copy and assign.
  FilePickerPlugin(const FilePickerPlugin&) = delete;
  FilePickerPlugin& operator=(const FilePickerPlugin&) = delete;

 private:
  // Called when a method is called on plugin channel.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace file_picker

#endif  // FLUTTER_PLUGIN_FILE_PICKER_PLUGIN_H_
