/// Validation result for custom unit names at setup.
enum SetupUnitNameValidation {
  ok,
  empty,
  duplicate,
  tooLong,
}

/// One generated unit label for setup wizard preview / server parity.
class SetupUnitSpec {
  const SetupUnitSpec({
    required this.block,
    required this.floor,
    required this.doorNumber,
    required this.slotIndex,
  });

  /// Empty when single-block site.
  final String block;
  final int floor;
  final String doorNumber;

  /// 0-based index within the floor (A=0, B=1, …).
  final int slotIndex;

  String get displayLabel => doorNumber;

  /// Stable key for custom-name map across renames.
  String get structuralKey => block.isEmpty
      ? '$floor|$slotIndex'
      : '$block|$floor|$slotIndex';
}

/// Builds automatic unit rows (must match Edge `generateUnits`).
List<SetupUnitSpec> buildAutomaticSetupUnits({
  required int floors,
  required int perFloor,
  required bool singleBlock,
  required int blockCount,
}) {
  final safeFloors = floors.clamp(1, 60);
  final safePerFloor = perFloor.clamp(1, 40);
  final blocks = singleBlock
      ? <String>['']
      : List<String>.generate(
          blockCount.clamp(2, 12),
          (i) => String.fromCharCode(65 + i),
        );

  final units = <SetupUnitSpec>[];
  for (final block in blocks) {
    for (var fi = 1; fi <= safeFloors; fi++) {
      for (var k = 0; k < safePerFloor; k++) {
        final letter = String.fromCharCode(65 + k);
        units.add(
          SetupUnitSpec(
            block: block,
            floor: fi,
            doorNumber: '$fi$letter',
            slotIndex: k,
          ),
        );
      }
    }
  }
  return units;
}

/// Applies user-edited door labels onto the structural template.
List<SetupUnitSpec> resolveSetupUnitsWithCustomNames({
  required int floors,
  required int perFloor,
  required bool singleBlock,
  required int blockCount,
  required Map<String, String> customNames,
}) {
  final template = buildAutomaticSetupUnits(
    floors: floors,
    perFloor: perFloor,
    singleBlock: singleBlock,
    blockCount: blockCount,
  );
  return [
    for (final u in template)
      SetupUnitSpec(
        block: u.block,
        floor: u.floor,
        slotIndex: u.slotIndex,
        doorNumber: (customNames[u.structuralKey] ?? u.doorNumber).trim(),
      ),
  ];
}

/// Ensures custom names are non-empty, unique per block, and length-bounded.
SetupUnitNameValidation validateSetupUnitNames(List<SetupUnitSpec> units) {
  const maxLen = 40;
  final seen = <String>{};
  for (final u in units) {
    final name = u.doorNumber.trim();
    if (name.isEmpty) {
      return SetupUnitNameValidation.empty;
    }
    if (name.length > maxLen) {
      return SetupUnitNameValidation.tooLong;
    }
    final uniq = '${u.block}::$name';
    if (seen.contains(uniq)) {
      return SetupUnitNameValidation.duplicate;
    }
    seen.add(uniq);
  }
  return SetupUnitNameValidation.ok;
}

/// Merges template slots with any previously entered custom labels.
Map<String, String> mergeCustomDoorNames({
  required int floors,
  required int perFloor,
  required bool singleBlock,
  required int blockCount,
  required Map<String, String> existing,
}) {
  final template = buildAutomaticSetupUnits(
    floors: floors,
    perFloor: perFloor,
    singleBlock: singleBlock,
    blockCount: blockCount,
  );
  final next = <String, String>{};
  for (final u in template) {
    final key = u.structuralKey;
    final prev = existing[key]?.trim();
    next[key] = (prev != null && prev.isNotEmpty) ? prev : u.doorNumber;
  }
  return next;
}
