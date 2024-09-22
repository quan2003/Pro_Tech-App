import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import '../model/HealthData.dart';  // Import your model

class HealthDataController {
  // Step 1: Fetch Health Data
  Future<List<HealthData>> fetchHealthData() async {
    // Example data, you can fetch from a database or API
    return [
      HealthData(date: '2024-09-20', status: 'Good'),
      HealthData(date: '2024-09-21', status: 'Moderate'),
    ];
  }

  // Step 2: Generate CSV
  Future<File> generateCsvFile(List<HealthData> data) async {
    List<List<String>> csvData = [
      ['Date', 'Health Status'],
      ...data.map((healthData) => healthData.toCsvRow())
    ];

    String csv = const ListToCsvConverter().convert(csvData);

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/health_data.csv';
    final file = File(path);

    return file.writeAsString(csv);
  }

  // Step 3: Upload CSV to Firebase Storage
  Future<String> uploadCsvToFirebase(File csvFile) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child('csv_files/${csvFile.uri.pathSegments.last}');
    UploadTask uploadTask = ref.putFile(csvFile);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Step 4: Send Email with CSV Download Link
  Future<void> sendEmail(String downloadUrl, String recipientEmail) async {
    String apiKey = 'your-sendgrid-api-key';  // Use your SendGrid API key

    final response = await http.post(
      Uri.parse('https://api.sendgrid.com/v3/mail/send'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'personalizations': [
          {
            'to': [{'email': recipientEmail}]
          }
        ],
        'from': {'email': 'your-email@example.com'},
        'subject': 'Your Health Data CSV',
        'content': [
          {
            'type': 'text/html',
            'value': 'Click <a href="$downloadUrl">here</a> to download your health data CSV file. The link is valid for 24 hours.'
          }
        ]
      }),
    );

    if (response.statusCode != 202) {
      throw Exception('Failed to send email: ${response.body}');
    }
  }
}
