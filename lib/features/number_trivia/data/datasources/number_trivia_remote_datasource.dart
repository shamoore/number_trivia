import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:number_trivia/core/error/exceptions.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';

abstract class NumberTriviaRemoteDataSource {
  ///Calls http://numbersapi.com/{number}
  ///Throws [ServerException] for all error codes
  Future<NumberTrivia> getConcreteNumberTrivia(int number);

  ///Calls http://numbersapi.com/{number}
  ///Throws [ServerException] for all error codes
  Future<NumberTrivia> getRandomNumberTrivia();
}

class NumberTriviaRemoteDataSourceImpl implements NumberTriviaRemoteDataSource {
  final http.Client client;

  NumberTriviaRemoteDataSourceImpl({@required this.client}) {}

  @override
  Future<NumberTrivia> getConcreteNumberTrivia(int number) => _getTriviaFromUrl('http://numbersapi.com/$number');

  @override
  Future<NumberTrivia> getRandomNumberTrivia() => _getTriviaFromUrl('http://numbersapi.com/random');

  Future<NumberTriviaModel> _getTriviaFromUrl(String url) async {
    final response = await client.get(url, headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      return NumberTriviaModel.fromJson(json.decode(response.body));
    } else
      throw ServerException();
  }
}
