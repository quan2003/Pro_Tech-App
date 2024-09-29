import 'package:flutter/material.dart';

class DrugDetailScreen extends StatefulWidget {
  final String drugName;
  final String manufacturerName;
  String form;

  DrugDetailScreen({
    Key? key,
    required this.drugName,
    required this.manufacturerName,
    required this.form,
    required String dosage,
  }) : super(key: key);

  @override
  _DrugDetailScreenState createState() => _DrugDetailScreenState();
}

class _DrugDetailScreenState extends State<DrugDetailScreen> {
  String dosage = '';
  bool isUnitSelected = false;
  String _selectedUnit = 'mg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Column(
                  children: [
                    Text(
                      'Thêm thuốc',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Detail Section
              _buildSectionHeader('Chi tiết'),
              _buildDetailCard(Icons.local_hospital, 'Tên', widget.drugName, null),
              _buildDetailCard(Icons.business, 'Nhà sản xuất', widget.manufacturerName, null),
              _buildDetailCard(
                Icons.opacity,
                'Hàm lượng',
                dosage.isNotEmpty ? dosage : '-',
                null,
                onTap: () {
                  _showDosageForm(context);
                },
              ),
              _buildDetailCard(
                Icons.bubble_chart, 
                'Dạng', 
                widget.form, 
                const Icon(Icons.more_horiz),
                onTap: () {
                  _showMedicationFormSelector(context);
                },
              ),
              _buildDetailCard(Icons.inventory, 'Trong hộp', 'còn 30', null),

              const SizedBox(height: 20),

              // Reminder Section
              _buildSectionHeader('Nhắc nhở'),
              _buildDetailCard(Icons.repeat, 'Tần suất', 'Mỗi ngày', null),
              _buildDetailCard(Icons.access_time, 'Đặt lịch', '08:00 - Uống 1 viên', null),

              const SizedBox(height: 40),

              // Save Button
              Center(
                child: ElevatedButton(
                  onPressed: (dosage.isNotEmpty && isUnitSelected)
                      ? () {
                          // Action for saving or confirming medication
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getButtonColor(),
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Lưu', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  Widget _buildDetailCard(IconData icon, String label, String value, Widget? trailing, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.pinkAccent),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                '$label: $value',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  // Function to show the dosage entry form
  void _showDosageForm(BuildContext context) {
    TextEditingController dosageController = TextEditingController();

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Wrap(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Thêm hàm lượng', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Dosage input field
                        TextField(
                          controller: dosageController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Hàm lượng',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                          ),
                          onChanged: (value) {
                            setState(() {
                              dosage = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),

                        // Unit selection
                        const Text('Đơn vị', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          children: _buildUnitButtons(_selectedUnit, (String unit) {
                            setModalState(() {
                              _selectedUnit = unit;
                              isUnitSelected = true;
                            });
                            setState(() {
                              isUnitSelected = true;
                            });
                          }),
                        ),
                        const SizedBox(height: 20),

                        // Save button
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, '${dosageController.text} $_selectedUnit');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 100),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                             child: const Text('Lưu', style: TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          dosage = value;
        });
      }
    });
  }

  Color _getButtonColor() {
    if (dosage.isEmpty) {
      return Colors.grey; // Màu bạc khi chưa nhập hàm lượng
    } else if (dosage.isNotEmpty && !isUnitSelected) {
      return Colors.black; // Màu đen sau khi nhập hàm lượng
    } else {
      return Colors.black; // Giữ màu đen sau khi chọn đơn vị
    }
  }

  List<Widget> _buildUnitButtons(String selectedUnit, Function(String) onSelected) {
    final units = ['mL', 'IU', '%', 'mcg', 'mg', 'g'];
    return units.map((unit) {
      return ChoiceChip(
        label: Text(unit),
        selected: selectedUnit == unit,
        onSelected: (bool selected) {
          onSelected(unit);
        },
        selectedColor: Colors.purple[100],
        labelStyle: TextStyle(
          color: selectedUnit == unit ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.grey[300],
      );
    }).toList();
  }
  void _showMedicationFormSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, controller) {
            return MedicationFormSelector(
              onSelect: (selectedForm) {
                setState(() {
                  widget.form = selectedForm;
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}

class MedicationFormSelector extends StatelessWidget {
  final Function(String) onSelect;

  const MedicationFormSelector({Key? key, required this.onSelect}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Thay đổi dạng thuốc',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Dạng thuốc phổ biến',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildMedicationFormItem('Viên', 'assets/icons/pill.png', onSelect),
          _buildMedicationFormItem('Viên nhộng', 'assets/icons/capsule.png', onSelect),
          _buildMedicationFormItem('Viên', 'assets/icons/tablet.svg', onSelect),
          _buildMedicationFormItem('Mũi', 'assets/icons/injection.svg', onSelect),
          const SizedBox(height: 20),
          const Text(
            'Khác',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildMedicationFormItem('Ống', 'assets/icons/liquid.svg', onSelect),
          _buildMedicationFormItem('Xịt', 'assets/icons/cream.svg', onSelect),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Tiếp theo', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationFormItem(String name, String iconPath, Function(String) onSelect) {
    return GestureDetector(
      onTap: () => onSelect(name),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Image.asset(iconPath, width: 24, height: 24),
            ),
            const SizedBox(width: 16),
            Text(name, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}