import 'package:flutter/material.dart';
import 'package:health/health.dart';

import '../controller/health_service.dart';

class HealthDashboardScreen extends StatefulWidget {
  const HealthDashboardScreen({super.key});

  @override
  _HealthDashboardScreenState createState() => _HealthDashboardScreenState();
}

class _HealthDashboardScreenState extends State<HealthDashboardScreen> {
  final HealthService _healthService = HealthService();
  List<HealthDataPoint> _healthData = [];
  int? _steps;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeHealthService();
  }

  Future<void> _initializeHealthService() async {
    setState(() => _isLoading = true);
    try {
      await _healthService.initialize();
      bool authorized = await _healthService.requestAuthorization();
      if (authorized) {
        await _fetchData();
      } else {
        setState(() {
          _error =
              'Health data access not authorized. Please grant permissions in Health Connect app.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Error initializing health service: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchData() async {
    try {
      final data = await _healthService.fetchHealthData();
      final steps = await _healthService.getTodaySteps();
      setState(() {
        _healthData = data;
        _steps = steps;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = "Error fetching health data: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _addHealthData(HealthDataType type, String title) async {
    TextEditingController controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $title'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: "Enter value"),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Add'),
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                double value = double.parse(controller.text);
                bool success =
                    await _healthService.writeHealthData(type, value);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$title added successfully')),
                  );
                  _fetchData(); // Refresh data
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add $title')),
                  );
                }
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Health Dashboard')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _fetchData,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Today\'s Steps: ${_steps ?? 'N/A'}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              bool authorized =
                                  await _healthService.requestAuthorization();
                              if (authorized) {
                                // Thực hiện các hành động khi được cấp quyền
                                print("Health Connect access granted");
                              } else {
                                // Hiển thị thông báo khi quyền bị từ chối
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Health Connect access denied. Please grant permissions in settings.')),
                                );
                              }
                            } catch (e) {
                              print(
                                  "Error requesting Health Connect authorization: $e");
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'An error occurred while requesting Health Connect access.')),
                              );
                            }
                          },
                          child: Text('Request Health Connect Access'),
                        ),
                        ..._healthData.map((data) => ListTile(
                              title: Text(data.typeString),
                              subtitle:
                                  Text('${data.value} ${data.unitString}'),
                              trailing:
                                  Text(data.dateFrom.toString().split(' ')[0]),
                            )),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showAddDataDialog(),
      ),
    );
  }

  void _showAddDataDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Add Health Data'),
        children: [
          SimpleDialogOption(
            child: Text('Add Steps'),
            onPressed: () {
              Navigator.pop(context);
              _addHealthData(HealthDataType.STEPS, 'Steps');
            },
          ),
          SimpleDialogOption(
            child: Text('Add Weight'),
            onPressed: () {
              Navigator.pop(context);
              _addHealthData(HealthDataType.WEIGHT, 'Weight');
            },
          ),
          // Add more options for other health data types
        ],
      ),
    );
  }
}
