import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/exceptions.dart';
import 'package:number_trivia/core/error/failures.dart';
import 'package:number_trivia/core/network/network_info.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:number_trivia/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';

class MockRemoteDataSource extends Mock implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  NumberTriviaRepositoryImpl repository;
  MockRemoteDataSource mockRemoteDataSource;
  MockLocalDataSource mockLocalDataSource;
  MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  group('get_concrete_number_trivia', () {
    final tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel(number: tNumber, text: 'Test Text');
    final tNumberTrivia = tNumberTriviaModel;

    void runTestsOnline(Function body) {
      group('device is online', () {
        setUp(() {
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        });
        body();
      });
    }

    void runTestsOffline(Function body) {
      group('device is offline', () {
        setUp(() {
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        });
        body();
      });
    }

    test('should check if device is online', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

      repository.getConcreteNumberTrivia(tNumber);
      verify(mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {
      test('should return remote data when the call to remoteDataSource is successful', () async {
        when(mockRemoteDataSource.getConcreteNumberTrivia(any)).thenAnswer((_) async => tNumberTriviaModel);
        final result = await repository.getConcreteNumberTrivia(tNumber);
        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        expect(result, Right(tNumberTrivia));
      });

      test('should cache the data locally when the call to remoteDataSource is successful', () async {
        when(mockRemoteDataSource.getConcreteNumberTrivia(any)).thenAnswer((_) async => tNumberTriviaModel);
        await repository.getConcreteNumberTrivia(tNumber);
        verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
      });

      test('should return server failure when the call to remoteDataSource is unsuccessful', () async {
        when(mockRemoteDataSource.getConcreteNumberTrivia(any)).thenThrow(ServerException());
        final result = await repository.getConcreteNumberTrivia(tNumber);
        expect(result, Left(ServerFailure()));
      });
    });

    runTestsOffline(() {
      test('should return locally cached data when it is present', () async {
        when(mockLocalDataSource.getCachedNumberTrivia()).thenAnswer((_) async => tNumberTriviaModel);
        final result = await repository.getConcreteNumberTrivia(tNumber);
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource.getCachedNumberTrivia());
        expect(result, Right(tNumberTrivia));
      });

      test('should return CacheFailure when there is no cached data present for number', () async {
        when(mockLocalDataSource.getCachedNumberTrivia()).thenThrow(CacheException());
        final result = await repository.getConcreteNumberTrivia(tNumber);
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource.getCachedNumberTrivia());
        expect(result, Left(CacheFailure()));
      });
    });
  });

  group('get_random_number_trivia', () {
    final tNumberTriviaModel = NumberTriviaModel(number: 1, text: 'Test Text');
    final tNumberTrivia = tNumberTriviaModel;

    void runTestsOnline(Function body) {
      group('device is online', () {
        setUp(() {
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        });
        body();
      });
    }

    void runTestsOffline(Function body) {
      group('device is offline', () {
        setUp(() {
          when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        });
        body();
      });
    }

    test('should check if device is online', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

      repository.getRandomNumberTrivia();
      verify(mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {
      test('should return remote data when the call to remoteDataSource is successful', () async {
        when(mockRemoteDataSource.getRandomNumberTrivia()).thenAnswer((_) async => tNumberTriviaModel);
        final result = await repository.getRandomNumberTrivia();
        verify(mockRemoteDataSource.getRandomNumberTrivia());
        expect(result, Right(tNumberTrivia));
      });

      test('should cache the data locally when the call to remoteDataSource is successful', () async {
        when(mockRemoteDataSource.getRandomNumberTrivia()).thenAnswer((_) async => tNumberTriviaModel);
        await repository.getRandomNumberTrivia();
        verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
      });

      test('should return server failure when the call to remoteDataSource is unsuccessful', () async {
        when(mockRemoteDataSource.getRandomNumberTrivia()).thenThrow(ServerException());
        final result = await repository.getRandomNumberTrivia();
        expect(result, Left(ServerFailure()));
      });
    });

    runTestsOffline(() {
      test('should return locally cached data when it is present', () async {
        when(mockLocalDataSource.getCachedNumberTrivia()).thenAnswer((_) async => tNumberTriviaModel);
        final result = await repository.getRandomNumberTrivia();
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource.getCachedNumberTrivia());
        expect(result, Right(tNumberTrivia));
      });

      test('should return CacheFailure when there is no cached data present for number', () async {
        when(mockLocalDataSource.getCachedNumberTrivia()).thenThrow(CacheException());
        final result = await repository.getRandomNumberTrivia();
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource.getCachedNumberTrivia());
        expect(result, Left(CacheFailure()));
      });
    });
  });
}
