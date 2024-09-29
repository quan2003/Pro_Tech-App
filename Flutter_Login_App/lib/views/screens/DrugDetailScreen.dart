import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DrugDetailScreen extends StatefulWidget {
  final String drugName;
  final String manufacturerName;
  String form;

  DrugDetailScreen({
    super.key,
    required this.drugName,
    required this.manufacturerName,
    required this.form,
    required String dosage,
  });

  @override
  // ignore: library_private_types_in_public_api
  _DrugDetailScreenState createState() => _DrugDetailScreenState();
}

class _DrugDetailScreenState extends State<DrugDetailScreen> {
  String dosage = '';
  bool isUnitSelected = false;
  final String _selectedUnit = 'mg';

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

              // ... (rest of the code remains the same)
            ],
          ),
        ),
      ),
    );
  }

  // ... (other methods remain the same)

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
                  widget.form = selectedForm.name;
                });
                Navigator.pop(context);
              },
              onClose: () {
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}

class MedicationForm {
  final String id;
  final String name;
  final String iconPath;
  final String category;

  MedicationForm({required this.id, required this.name, required this.iconPath, required this.category});
}

class MedicationFormSelector extends StatefulWidget {
  final Function(MedicationForm) onSelect;
  final VoidCallback onClose;

  const MedicationFormSelector({super.key, required this.onSelect, required this.onClose});

  @override
  // ignore: library_private_types_in_public_api
  _MedicationFormSelectorState createState() => _MedicationFormSelectorState();
}

class _MedicationFormSelectorState extends State<MedicationFormSelector> {
  MedicationForm? selectedForm;

  final List<MedicationForm> medicationForms = [
    MedicationForm(id: 'pill', name: 'Viên', iconPath: 'assets/icons/pill.svg', category: 'common'),
    MedicationForm(id: 'capsule', name: 'Viên nhộng', iconPath: 'assets/icons/capsule.svg', category: 'common'),
    MedicationForm(id: 'tablet', name: 'Viên', iconPath: 'assets/icons/tablet.svg', category: 'common'),
    MedicationForm(id: 'injection', name: 'Mũi', iconPath: 'assets/icons/injection.svg', category: 'common'),
    MedicationForm(id: 'liquid', name: 'Ống', iconPath: 'assets/icons/liquid.svg', category: 'other'),
    MedicationForm(id: 'cream', name: 'Lăn dùng', iconPath: 'assets/icons/cream.svg', category: 'other'),
    MedicationForm(id: 'spray', name: 'Xịt', iconPath: 'assets/icons/spray.svg', category: 'other'),
    MedicationForm(id: 'patch', name: 'Dán', iconPath: 'assets/icons/patch.svg', category: 'other'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildFormList('Dạng thuốc phổ biến', 'common'),
          const SizedBox(height: 16),
          _buildFormList('Khác', 'other'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (selectedForm != null) {
                widget.onSelect(selectedForm!);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Tiếp theo', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Thay đổi dạng thuốc',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onClose,
        ),
      ],
    );
  }

  Widget _buildFormList(String title, String category) {
    List<MedicationForm> forms = medicationForms.where((form) => form.category == category).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...forms.map((form) => _buildFormItem(form)),
      ],
    );
  }

  Widget _buildFormItem(MedicationForm form) {
    bool isSelected = selectedForm?.id == form.id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedForm = form;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple.shade100 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                form.iconPath,
                width: 24,
                height: 24,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              form.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}