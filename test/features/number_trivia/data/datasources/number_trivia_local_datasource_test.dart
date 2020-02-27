import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/exceptions.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  NumberTriviaLocalDataSourceImpl dataSource;
  MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(sharedPreferences: mockSharedPreferences);
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia_cached.json')));
    test('should return NumberTrivia from SharedPreferences when it exists in cache', () async {
      //arrange
      when(mockSharedPreferences.getString(any)).thenReturn(fixture('trivia_cached.json'));
      //act
      final result = await dataSource.getCachedNumberTrivia();
      verify(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
      expect(result, tNumberTriviaModel);
      //assert
    });

    test('should throw a CacheException when there is not a cached value', () async {
      when(mockSharedPreferences.getString(any)).thenReturn(null);
      final call = dataSource.getCachedNumberTrivia;
      expect(() => call(), throwsA(isInstanceOf<CacheException>()));
    });
  });

  group('cacheNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel(number: 1, text: 'Test Text');

    test('should call SharedPreferences to cache the data', () async {
      dataSource.cacheNumberTrivia(tNumberTriviaModel);
      //act
      final expectedJsonString = json.encode(tNumberTriviaModel.toJson());
      verify(mockSharedPreferences.setString(CACHED_NUMBER_TRIVIA, expectedJsonString));
      //assert
    });
  });
}
