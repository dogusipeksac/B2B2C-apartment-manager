import 'package:apartment_manager/features/setup/domain/setup_unit_spec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('multi-block generates units per block', () {
    final units = buildAutomaticSetupUnits(
      floors: 2,
      perFloor: 2,
      singleBlock: false,
      blockCount: 3,
    );

    expect(units, hasLength(12));
    expect(units.where((u) => u.block == 'A'), hasLength(4));
    expect(units.where((u) => u.block == 'B'), hasLength(4));
    expect(units.where((u) => u.block == 'C'), hasLength(4));
    expect(
      units.where((u) => u.block == 'A' && u.doorNumber == '1A'),
      hasLength(1),
    );
  });

  test('single-block uses empty block code', () {
    final units = buildAutomaticSetupUnits(
      floors: 3,
      perFloor: 1,
      singleBlock: true,
      blockCount: 1,
    );

    expect(units, hasLength(3));
    expect(units.every((u) => u.block.isEmpty), isTrue);
  });

  test('custom names merge preserves edits per slot', () {
    final merged = mergeCustomDoorNames(
      floors: 2,
      perFloor: 2,
      singleBlock: true,
      blockCount: 1,
      existing: {'1|0': 'Daire 1'},
    );

    expect(merged['1|0'], 'Daire 1');
    expect(merged['1|1'], '1B');
    expect(merged['2|0'], '2A');
  });

  test('validate rejects empty and duplicate custom names', () {
    final units = [
      const SetupUnitSpec(
        block: '',
        floor: 1,
        doorNumber: 'A',
        slotIndex: 0,
      ),
      const SetupUnitSpec(
        block: '',
        floor: 1,
        doorNumber: 'A',
        slotIndex: 1,
      ),
    ];

    expect(validateSetupUnitNames(units), SetupUnitNameValidation.duplicate);

    units[1] = const SetupUnitSpec(
      block: '',
      floor: 1,
      doorNumber: '',
      slotIndex: 1,
    );
    expect(validateSetupUnitNames(units), SetupUnitNameValidation.empty);
  });
}
