import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MongoDB Connection Test', () {
    test('Should connect and insert a document', () async {
      // 1. Load connection string manually from .env
      final envFile = File('.env');
      String? connectionString;
      
      if (await envFile.exists()) {
        final lines = await envFile.readAsLines();
        for (var line in lines) {
          if (line.startsWith('MONGO_CONN_URL=')) {
            connectionString = line.split('=')[1].trim();
            break;
          }
        }
      }

      if (connectionString == null) {
        // Fallback or fail
        // connectionString = 'mongodb+srv://mendozadiazjuandavid:NIRBvYlJsLPJ605v@cluster0.i4bvy.mongodb.net/caracterizacion_cens';
         fail('MONGO_CONN_URL not found in .env');
      }

      print('Connecting to: $connectionString');

      final db = await Db.create(connectionString);
      await db.open();
      print('✅ Connected to MongoDB');

      final collection = db.collection('test_connection');
      final testData = {
        'test_id': DateTime.now().millisecondsSinceEpoch,
        'message': 'Hello from VS Code Agent',
        'timestamp': DateTime.now().toIso8601String()
      };

      await collection.insert(testData);
      print('✅ Inserted test document');

      final retrieved = await collection.findOne(where.eq('test_id', testData['test_id']));
      expect(retrieved, isNotNull);
      expect(retrieved!['message'], equals('Hello from VS Code Agent'));
      print('✅ Retrieved test document: $retrieved');

      await db.close();
      print('✅ Connection closed');
    });
  });
}
