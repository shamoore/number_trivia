import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/failures.dart';
import 'package:number_trivia/core/usecases/usecase.dart';
import 'package:number_trivia/core/util/input_converter.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/bloc.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

class MockGetConcreteNumberTrivia extends Mock implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  NumberTriviaBloc bloc;
  MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(concrete: mockGetConcreteNumberTrivia, random: mockGetRandomNumberTrivia, converter: mockInputConverter);
  });

  test('initialState should be Empty ', () {
    expect(bloc.initialState, Empty());
  });

  group('GetTriviaForConcreteNumber', () {
    final tNumberString = '1';
    final tNumberParsed = 1;
    final tNumberTrivia = NumberTrivia(number: 1, text: 'Test Text');
    void setUpMockInputConverterSucess() => when(mockInputConverter.stringToUnsignedInteger(any)).thenReturn(Right(tNumberParsed));

    test('should call InputConverter to valid and convert the string to an int', () async {
      //arrange
      setUpMockInputConverterSucess();
      //act
      bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockInputConverter.stringToUnsignedInteger(any));
      //assert
      verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
    });

    test('should emit [Error] when the input is invalid', () {
      //arrange
      when(mockInputConverter.stringToUnsignedInteger(any)).thenReturn(Left(InvalidInputFailure()));
      //assert Later

      final expected = [
        Empty(),
        Error(message: INVALID_INPUT_MESSAGE),
      ];

      expectLater(bloc.state, emitsInOrder(expected));
      //act
      bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
    });

    test('should get data from the Concrete use case', () async {
      //arrange
      setUpMockInputConverterSucess();
      //act
      bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockGetConcreteNumberTrivia(any));

      //assert
      verify(mockGetConcreteNumberTrivia(Params(number: tNumberParsed)));
    });

    test('should should emit [loading, loaded] when data is gotten successfully', () async* {
      //arrange
      setUpMockInputConverterSucess();
      when(mockGetConcreteNumberTrivia(any)).thenAnswer((_) async => Right(tNumberTrivia));

      //assert later
      final expected = [
        Empty(),
        Loading(),
        Loaded(numberTrivia: tNumberTrivia),
      ];
      expectLater(bloc.state, emits(expected));

      //act
      bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
    });

    test('should should emit [loading, error] when getting data fails', () async* {
      //arrange
      setUpMockInputConverterSucess();
      when(mockGetConcreteNumberTrivia(any)).thenAnswer((_) async => Left(ServerFailure()));

      //assert later
      final expected = [
        Empty(),
        Loading(),
        Error(message: SERVER_FAILURE_MESSAGE),
      ];
      expectLater(bloc.state, emits(expected));

      //act
      bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
    });

    test('should should emit [loading, error] with a proper message when getting data fails', () async* {
      //arrange
      setUpMockInputConverterSucess();
      when(mockGetConcreteNumberTrivia(any)).thenAnswer((_) async => Left(CacheFailure()));

      //assert later
      final expected = [
        Empty(),
        Loading(),
        Error(message: CACHE_FAILURE_MESSAGE),
      ];
      expectLater(bloc.state, emits(expected));

      //act
      bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
    });
  });

  group('GetTriviaForRandomNumber', () {
    final tNumberTrivia = NumberTrivia(number: 1, text: 'Test Text');

    test('should get data from the Random use case', () async {
      //arrange

      //act
      bloc.dispatch(GetTriviaForRandomNumber());
      await untilCalled(mockGetRandomNumberTrivia(NoParams()));

      //assert
      verify(mockGetRandomNumberTrivia(NoParams()));
    });

    test('should should emit [loading, loaded] when data is gotten successfully', () async* {
      //arrange
      when(mockGetRandomNumberTrivia(NoParams())).thenAnswer((_) async => Right(tNumberTrivia));

      //assert later
      final expected = [
        Empty(),
        Loading(),
        Loaded(numberTrivia: tNumberTrivia),
      ];
      expectLater(bloc.state, emits(expected));

      //act
      bloc.dispatch(GetTriviaForRandomNumber());
    });

    test('should should emit [loading, error] when getting data fails', () async* {
      //arrange
      when(mockGetRandomNumberTrivia(NoParams())).thenAnswer((_) async => Left(ServerFailure()));

      //assert later
      final expected = [
        Empty(),
        Loading(),
        Error(message: SERVER_FAILURE_MESSAGE),
      ];
      expectLater(bloc.state, emits(expected));

      //act
      bloc.dispatch(GetTriviaForRandomNumber());
    });

    test('should should emit [loading, error] with a proper message when getting data fails', () async* {
      //arrange
      when(mockGetRandomNumberTrivia(NoParams())).thenAnswer((_) async => Left(CacheFailure()));

      //assert later
      final expected = [
        Empty(),
        Loading(),
        Error(message: CACHE_FAILURE_MESSAGE),
      ];
      expectLater(bloc.state, emits(expected));

      //act
      bloc.dispatch(GetTriviaForRandomNumber());
    });
  });
}
