import 'package:apartment_manager/features/setup/data/turkey_locations_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parseTurkeyProvincesResponse maps nested districts', () {
    final parsed = parseTurkeyProvincesResponse(<String, dynamic>{
      'status': 'OK',
      'data': [
        {
          'id': 34,
          'name': 'İstanbul',
          'districts': [
            {'id': 1421, 'name': 'Kadıköy'},
            {'id': 1183, 'name': 'Beşiktaş'},
          ],
        },
        {
          'id': 6,
          'name': 'Ankara',
          'districts': [
            {'id': 1231, 'name': 'Çankaya'},
          ],
        },
      ],
    });

    expect(parsed, hasLength(2));
    expect(parsed.first.name, 'Ankara');
    expect(parsed.last.name, 'İstanbul');
    expect(parsed.last.districts.first.name, 'Beşiktaş');
    expect(
      parsed.last.districts.map((d) => d.name),
      contains('Kadıköy'),
    );
  });
}
