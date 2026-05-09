import 'package:apartment_manager/features/auth/domain/user_role.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'code_preview.freezed.dart';

@freezed
abstract class CodePreview with _$CodePreview {
  const factory CodePreview({
    required InviteCodeType codeType,
    String? buildingName,
    String? unitLabel,
    String? address,
  }) = _CodePreview;
}
