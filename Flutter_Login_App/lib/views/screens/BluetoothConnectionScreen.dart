import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BluetoothConnectionScreen extends StatefulWidget {
  const BluetoothConnectionScreen({super.key});

  @override
  _BluetoothConnectionScreenState createState() => _BluetoothConnectionScreenState();
}

class _BluetoothConnectionScreenState extends State<BluetoothConnectionScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> connectedDevices = [];
  List<ScanResult> scanResults = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _initializeBluetooth();
  }

  void _initializeBluetooth() async {
    // Get connected devices
    connectedDevices = await flutterBlue.connectedDevices;
    setState(() {});
  }

  void _startScan() {
    setState(() {
      _isScanning = true;
      scanResults.clear();
    });
    
    // Start scanning and listen to the stream
    flutterBlue.scan(timeout: Duration(seconds: 4)).listen((scanResult) {
      setState(() {
        bool isNewDevice = scanResults.indexWhere((result) => result.device.id == scanResult.device.id) == -1;
        if (isNewDevice) {
          scanResults.add(scanResult);
        }
      });
    }).onDone(() {
      setState(() {
        _isScanning = false;
      });
    });
  }

  void _stopScan() {
    flutterBlue.stopScan();
    setState(() {
      _isScanning = false;
    });
  }

  void _connectToDevice(BluetoothDevice device) async {
    await device.connect();
    setState(() {
      connectedDevices.add(device);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thiết bị Bluetooth'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Đồng bộ dữ liệu sức khoẻ qua các thiết bị kết nối Bluetooth',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có thiết bị được kết nối',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isScanning ? _stopScan : _startScan,
              child: Text(_isScanning ? 'Dừng quét' : 'Kết nối thiết bị mới'),
            ),
            const SizedBox(height: 16),
            if (_isScanning) ...[
              Center(child: CircularProgressIndicator()),
            ],
            const SizedBox(height: 16),
            Text('Các thiết bị có sẵn:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: scanResults.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(scanResults[index].device.name.isNotEmpty
                        ? scanResults[index].device.name
                        : 'Thiết bị không tên'),
                    subtitle: Text(scanResults[index].device.id.toString()),
                    onTap: () => _connectToDevice(scanResults[index].device),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}