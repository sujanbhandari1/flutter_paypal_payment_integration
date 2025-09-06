import 'dart:developer';

import 'package:dio/dio.dart';

import 'file.dart';

class BaseFormData {
  BaseFormData({this.formFields, this.files});

  Map<String?, dynamic>? formFields;
  List<FilesToBeUploaded>? files;

  Map<String, dynamic> get nonNullFormFields {
    Map<String, dynamic> temp = {};

    if (formFields == null) return temp;

    for (var key in formFields!.keys) {
      if (key != null && formFields![key] != null) {
        temp[key] = formFields![key];
      }
    }

    return temp;
  }

  /// Getter for form data
  Future<FormData> get toFormData async {
    final temp = <String, dynamic>{};

    temp.addAll(nonNullFormFields);

    if (files != null && files!.isNotEmpty) {
      for (final file in files!) {
        if (file.key != null && file.path != null) {
          temp[file.key!] = await MultipartFile.fromFile(file.path!);
        }
      }
    }

    final formData = FormData.fromMap(temp);

    return formData;
  }

  /// Static method to convert formFields to string map
  static Map<String, String> convertDynamicToStringMap(
      Map<String, dynamic> formFields) {
    Map<String, String> stringMap = {};

    for (var key in formFields.keys) {
      if (formFields[key] != null) {
        stringMap[key] = formFields[key].toString();
      }
    }

    log('⨝⨹⨹⨹⨝ BaseFormData To String Map $stringMap');
    return stringMap;
  }
}
