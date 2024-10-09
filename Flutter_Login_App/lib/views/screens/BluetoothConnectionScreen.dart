import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

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
  int _heartRate = 0;
  int _stepCount = 0;

  final String targetMacAddress = "D0:62:2C:0B:D6:73"; // MAC Address cho Xiaomi Band 8

  // UUIDs
  final String HEART_RATE_SERVICE_UUID = "0000180d-0000-1000-8000-00805f9b34fb";
  final String HEART_RATE_CHARACTERISTIC_UUID = "00002a37-0000-1000-8000-00805f9b34fb";
  final String STEP_COUNT_SERVICE_UUID = "0000fee0-0000-1000-8000-00805f9b34fb"; 
  final String STEP_COUNT_CHARACTERISTIC_UUID = "00000007-0000-3512-2118-0009af100700"; 

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    var statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
      Permission.locationAlways,
    ].request();

    if (statuses[Permission.bluetooth]?.isGranted == true &&
        statuses[Permission.bluetoothScan]?.isGranted == true &&
        statuses[Permission.bluetoothConnect]?.isGranted == true &&
        (statuses[Permission.locationWhenInUse]?.isGranted == true ||
            statuses[Permission.locationAlways]?.isGranted == true)) {
      _initializeBluetooth();
    } else {
      print("Bluetooth hoặc quyền vị trí chưa được cấp.");
    }
  }

  void _initializeBluetooth() async {
    try {
      connectedDevices = await flutterBlue.connectedDevices;
      setState(() {});
      _checkBluetoothState();
    } catch (e) {
      print("Lỗi khi khởi tạo Bluetooth: $e");
    }
  }

  Future<void> _checkBluetoothState() async {
    if (await flutterBlue.isOn) {
      _startScan();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Bluetooth chưa được bật'),
            content: const Text('Vui lòng bật Bluetooth để quét thiết bị.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }
  }

  void _startScan() {
    setState(() {
      _isScanning = true;
      scanResults.clear();
    });
    flutterBlue.startScan(timeout: const Duration(seconds: 10)).then((_) {
      flutterBlue.scanResults.listen((results) {
        setState(() {
          for (var result in results) {
            if (!scanResults.any((existing) => existing.device.id == result.device.id)) {
              scanResults.add(result);
              print("Found device: ${result.device.name} with ID: ${result.device.id}");

              if (result.device.id.toString().toUpperCase() == targetMacAddress) {
                _connectToDevice(result.device);
              }
            }
          }
        });
      });
    }).catchError((error) {
      print("Lỗi khi bắt đầu quét: $error");
    }).whenComplete(() {
      setState(() {
        _isScanning = false;
      });
    });
  }

  // Hàm dừng quét
  void _stopScan() {
    flutterBlue.stopScan();
    setState(() {
      _isScanning = false;
    });
  }

  void _connectToDevice(BluetoothDevice device) async {
    try {
      await device.disconnect();
      await device.connect(autoConnect: false).timeout(const Duration(seconds: 10));
      setState(() {
        connectedDevices.add(device);
      });
      print("Đã kết nối với thiết bị: ${device.name}");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kết nối thành công với ${device.name}')),
      );

      _discoverServices(device);
    } catch (e) {
      print("Không thể kết nối với thiết bị ${device.name}, lỗi: $e");
    }
  }

  void _discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (var service in services) {
      print('Service UUID: ${service.uuid}');
      for (var characteristic in service.characteristics) {
        print('  Characteristic UUID: ${characteristic.uuid}');
        
        if (service.uuid.toString() == HEART_RATE_SERVICE_UUID &&
            characteristic.uuid.toString() == HEART_RATE_CHARACTERISTIC_UUID) {
          _subscribeToHeartRate(characteristic);
        } else if (service.uuid.toString() == STEP_COUNT_SERVICE_UUID &&
                   characteristic.uuid.toString() == STEP_COUNT_CHARACTERISTIC_UUID) {
          _subscribeToStepCount(characteristic);
        }
      }
    }
  }

  void _subscribeToHeartRate(BluetoothCharacteristic characteristic) {
    characteristic.setNotifyValue(true);
    characteristic.value.listen((value) {
      if (value.isNotEmpty) {
        setState(() {
          _heartRate = value[1];
        });
        print('Nhịp tim: $_heartRate');
      }
    });
  }

  void _subscribeToStepCount(BluetoothCharacteristic characteristic) {
    characteristic.setNotifyValue(true);
    characteristic.value.listen((value) {
      if (value.isNotEmpty) {
        setState(() {
          _stepCount = _decodeStepCount(value);
        });
        print('Số bước chân: $_stepCount');
      }
    });
  }

  int _decodeStepCount(List<int> value) {
    return value[1] << 8 | value[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thiết bị Bluetooth'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nhịp tim: $_heartRate',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Số bước chân: $_stepCount',
              style: const TextStyle(fontSize: 18),
            ),
            ElevatedButton(
              onPressed: _isScanning ? _stopScan : _startScan,
              child: Text(_isScanning ? 'Dừng quét' : 'Quét thiết bị'),
            ),
          ],
        ),
      ),
    );
  }
}
