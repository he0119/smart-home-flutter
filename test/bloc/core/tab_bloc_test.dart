// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smarthome/core/core.dart';

void main() {
  group('TabBloc', () {
    late TabBloc tabBloc;

    setUp(() {
      tabBloc = TabBloc();
    });

    test('initial state is null', () {
      expect(tabBloc.state, null);
    });

    blocTest<TabBloc, AppTab?>(
      'should update the AppTab',
      build: () => tabBloc,
      act: (TabBloc bloc) async {
        bloc
          ..add(const TabChanged(AppTab.board))
          ..add(const TabChanged(AppTab.iot))
          ..add(const TabChanged(AppTab.iot));
      },
      expect: () => <AppTab>[
        AppTab.board,
        AppTab.iot,
      ],
    );
  });
  group('TabBlocToString', () {
    test('TabEvent', () {
      expect(const TabChanged(AppTab.board).toString(),
          'TabChanged(tab: ${AppTab.board})');
    });
  });
}
