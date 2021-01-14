// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/blocs/core/tab/tab_bloc.dart';
import 'package:smart_home/models/app_tab.dart';

void main() {
  group('TabBloc', () {
    // ignore: close_sinks
    TabBloc tabBloc;

    setUp(() {
      tabBloc = TabBloc();
    });

    test('initial state is null', () {
      expect(tabBloc.state, null);
    });

    blocTest<TabBloc, AppTab>(
      'should update the AppTab',
      build: () => tabBloc,
      act: (TabBloc bloc) async {
        bloc.add(TabChanged(AppTab.board));
        bloc.add(TabChanged(AppTab.iot));
      },
      expect: <AppTab>[
        AppTab.board,
        AppTab.iot,
      ],
    );
  });
  group('TabBlocToString', () {
    test('TabEvent', () {
      expect(TabChanged(AppTab.board).toString(),
          'TabChanged(tab: ${AppTab.board})');
    });
  });
}
