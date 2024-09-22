import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../model/BMIModel.dart';

class BMIController extends GetxController {
  RxDouble bmiValue = 22.8.obs; // Giá trị BMI ban đầu, bạn có thể thay đổi
  RxString bmiCategory = 'Bình thường'.obs;
  Rx<Color> bmiColor = Colors.green.obs;

  void updateBMI(double height, double weight) {
    double bmi = weight / (height * height);
    bmiValue.value = bmi;
    updateCategory(bmi);
  }

  void updateCategory(double bmi) {
    if (bmi < 18.5) {
      bmiCategory.value = 'Thiếu cân';
      bmiColor.value = Colors.blue;
    } else if (bmi < 25) {
      bmiCategory.value = 'Bình thường';
      bmiColor.value = Colors.green;
    } else if (bmi < 30) {
      bmiCategory.value = 'Thừa cân';
      bmiColor.value = Colors.orange;
    } else {
      bmiCategory.value = 'Béo phì';
      bmiColor.value = Colors.red;
    }
  }
}
