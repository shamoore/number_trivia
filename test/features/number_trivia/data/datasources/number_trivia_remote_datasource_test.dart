import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/exceptions.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  NumberTriviaRemoteDataSourceImpl dataSource;
  MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });

  void setUpMockHttp404() {
    when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  void setUpMockHttp200() {
    when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test('should perform a GET request on a URL with the number being the endpoint and with application/json header ', () {
      //arrange
      setUpMockHttp200();
      //act
      dataSource.getConcreteNumberTrivia((tNumber));
      //assert
      verify(mockHttpClient.get('http://numbersapi.com/$tNumber', headers: {'Content-Type': 'application/json'}));
    });

    test('should return NumberTrivia when the response is 200 (success)', () async {
      //arrange
      setUpMockHttp200();
      //act
      final result = await dataSource.getConcreteNumberTrivia(tNumber);
      //assert
      expect(result, tNumberTriviaModel);
    });

    test('should throw a ServerException when the response is not 200', () async {
      //arrange
      setUpMockHttp404();
      //act
      final call = dataSource.getConcreteNumberTrivia;
      //assert
      expect(() => call(tNumber), throwsA(isInstanceOf<ServerException>()));
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test('should perform a GET request on a URL with the number being the endpoint and with application/json header ', () {
      //arrange
      setUpMockHttp200();
      //act
      dataSource.getRandomNumberTrivia();
      //assert
      verify(mockHttpClient.get('http://numbersapi.com/random', headers: {'Content-Type': 'application/json'}));
    });

    test('should return NumberTrivia when the response is 200 (success)', () async {
      //arrange
      setUpMockHttp200();
      //act
      final result = await dataSource.getRandomNumberTrivia();
      //assert
      expect(result, tNumberTriviaModel);
    });

    test('should throw a ServerException when the response is not 200', () async {
      //arrange
      setUpMockHttp404();
      //act
      final call = dataSource.getRandomNumberTrivia;
      //assert
      expect(() => call(), throwsA(isInstanceOf<ServerException>()));
    });
  });
}
