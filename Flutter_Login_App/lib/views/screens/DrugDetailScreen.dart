import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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
  int _quantity = 30; // Số lượng mặc định
  String _treatmentCondition = '';

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
              _buildDetailCard(
                  Icons.local_hospital, 'Tên', widget.drugName, null),
              _buildDetailCard(Icons.business, 'Nhà sản xuất',
                  widget.manufacturerName, null),
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
                const Icon(Icons.chevron_right_sharp),
                onTap: () {
                  _showMedicationFormSelector(context);
                },
              ),
              _buildDetailCard(
                Icons.local_hospital,
                'Điều trị',
                _treatmentCondition.isNotEmpty ? _treatmentCondition : 'Chọn',
                const Icon(Icons.chevron_right_sharp),
                onTap: () {
                  _showTreatmentConditionSelector(context);
                },
              ),
              _buildDetailCard(
                Icons.inventory,
                'Trong hộp',
                '$_quantity viên',
                const Icon(Icons.chevron_right_sharp),
                onTap: () {
                  _showQuantitySelector(context);
                },
              ),

              const SizedBox(height: 20),

              // Reminder Section
              _buildSectionHeader('Nhắc nhở'),
              _buildDetailCard(Icons.repeat, 'Tần suất', 'Mỗi ngày', null),
              _buildDetailCard(
                  Icons.access_time, 'Đặt lịch', '08:00 - Uống 1 viên', null),

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
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Lưu',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
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

  Widget _buildDetailCard(
      IconData icon, String label, String value, Widget? trailing,
      {VoidCallback? onTap}) {
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
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

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
                            const Text('Thêm hàm lượng',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
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
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Hàm lượng',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0)),
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
                          children:
                              _buildUnitButtons(_selectedUnit, (String unit) {
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
                              Navigator.pop(context,
                                  '${dosageController.text} $_selectedUnit');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 0, 0, 0),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 100),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text('Lưu',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
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

  void _showQuantitySelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Trong hộp',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Bạn hiện còn bao nhiêu viên thuốc?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: CupertinoPickerWidget(
                  initialValue: _quantity,
                  onValueChanged: (newValue) {
                    setState(() {
                      _quantity = newValue;
                    });
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {}); // Cập nhật UI
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Tiếp theo',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
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

  List<Widget> _buildUnitButtons(
      String selectedUnit, Function(String) onSelected) {
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
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: MedicationFormSelector(
            onSelect: (selectedForm) {
              setState(() {
                widget.form = selectedForm;
              });
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  void _showTreatmentConditionSelector(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return FractionallySizedBox(
        heightFactor: 0.9,
        child: TreatmentConditionSelector(
          onSelect: (selectedCondition) {
            setState(() {
              _treatmentCondition = selectedCondition;
            });
          },
        ),
      );
    },
  );
}

}

class CupertinoPickerWidget extends StatelessWidget {
  final int initialValue;
  final ValueChanged<int> onValueChanged;

  const CupertinoPickerWidget({
    Key? key,
    required this.initialValue,
    required this.onValueChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker(
      itemExtent: 40,
      scrollController:
          FixedExtentScrollController(initialItem: initialValue - 1),
      onSelectedItemChanged: (int index) {
        onValueChanged(index + 1);
      },
      children: List<Widget>.generate(100, (int index) {
        return Center(
          child: Text(
            '${index + 1}',
            style: const TextStyle(fontSize: 20),
          ),
        );
      }),
    );
  }
}

class MedicationFormSelector extends StatelessWidget {
  final Function(String) onSelect;

  const MedicationFormSelector({Key? key, required this.onSelect})
      : super(key: key);

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
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Dạng thuốc phổ biến',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildMedicationFormItem(
                    'Viên', 'assets/icons/pill.png', onSelect),
                _buildMedicationFormItem(
                    'Viên nhộng', 'assets/icons/capsule.png', onSelect),
                _buildMedicationFormItem(
                    'Mũi', 'assets/icons/injection.png', onSelect),
                const SizedBox(height: 20),
                const Text(
                  'Khác',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildMedicationFormItem(
                    'Ống', 'assets/icons/liquid.png', onSelect),
                _buildMedicationFormItem(
                    'Giọt', 'assets/icons/drop.png', onSelect),
                _buildMedicationFormItem(
                    'Xịt', 'assets/icons/cream.png', onSelect),
                _buildMedicationFormItem(
                    'Miếng', 'assets/icons/personal.png', onSelect),
                _buildMedicationFormItem(
                    'Lọ', 'assets/icons/jar.png', onSelect),
                _buildMedicationFormItem(
                    'Khác', 'assets/icons/other.png', onSelect),
              ],
            ),
          ),
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
              child: const Text('Tiếp theo',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationFormItem(
      String name, String iconPath, Function(String) onSelect) {
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

class TreatmentConditionSelector extends StatefulWidget {
  final Function(String) onSelect;

  const TreatmentConditionSelector({Key? key, required this.onSelect}) : super(key: key);

  @override
  _TreatmentConditionSelectorState createState() => _TreatmentConditionSelectorState();
}

class _TreatmentConditionSelectorState extends State<TreatmentConditionSelector> {
  String? selectedCondition;
  TextEditingController customConditionController = TextEditingController();

  final List<Map<String, dynamic>> conditions = [
    {'name': 'Cao huyết áp', 'icon': 'assets/icons/blood_pressure.png', 'color': Colors.red},
    {'name': 'Tiểu đường', 'icon': 'assets/icons/diabetes.png', 'color': Colors.blue},
    {'name': 'Mỡ máu cao', 'icon': 'assets/icons/cholesterol.png', 'color': Colors.yellow},
    {'name': 'Đau thắt ngực', 'icon': 'assets/icons/heart_pain.png', 'color': Colors.red},
    {'name': 'Khác', 'icon': 'assets/icons/other.png', 'color': Colors.grey},
  ];

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin về chiều cao bàn phím nếu nó hiển thị
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      duration: const Duration(milliseconds: 300), // Thời gian chuyển đổi
      curve: Curves.easeOut, // Để làm chuyển động mượt hơn
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Điều trị cho',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: conditions.length,
                itemBuilder: (context, index) {
                  final condition = conditions[index];
                  return _buildConditionItem(
                    condition['name'],
                    condition['icon'],
                    condition['color'],
                    () {
                      setState(() {
                        selectedCondition = condition['name'];
                      });
                      if (condition['name'] != 'Khác') {
                        widget.onSelect(condition['name']);
                        Navigator.pop(context);
                      }
                    },
                  );
                },
              ),
            ),
            if (selectedCondition == 'Khác')
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: customConditionController,
                  decoration: InputDecoration(
                    hintText: 'Điều kiện sức khỏe. Ví dụ: Ho',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (selectedCondition == 'Khác') {
                    if (customConditionController.text.isNotEmpty) {
                      widget.onSelect('Khác: ${customConditionController.text}');
                      Navigator.pop(context);
                    } else {
                      // Hiển thị thông báo yêu cầu nhập điều kiện
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng nhập điều kiện sức khỏe')),
                      );
                    }
                  } else if (selectedCondition != null) {
                    widget.onSelect(selectedCondition!);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Lưu', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionItem(String name, String iconPath, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Image.asset(iconPath, width: 24, height: 24),
            ),
            const SizedBox(width: 16),
            Text(name, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            if (selectedCondition == name)
              const Icon(Icons.check, color: Colors.pink),
          ],
        ),
      ),
    );
  }
}
