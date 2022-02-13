extension VolumeKMBGenerator on String {
  String toKBMFormat() {
    if (double.tryParse(this)! > 999 && double.tryParse(this)! < 99999) {
      return "\$""${(double.tryParse(this)! / 1000).toStringAsFixed(2)}K";
    } else if (double.tryParse(this)! > 99999 &&
        double.tryParse(this)! < 999999) {
      return  "\$""${(double.tryParse(this)! / 1000).toStringAsFixed(2)}K";
    } else if (double.tryParse(this)! > 999999 &&
        double.tryParse(this)! < 999999999) {
      return  "\$""${(double.tryParse(this)! / 1000000).toStringAsFixed(2)}M";
    } else if (double.tryParse(this)! > 999999999) {
      return  "\$""${(double.tryParse(this)! / 1000000000).toStringAsFixed(2)}B";
    } else {
      return  "\$"+double.tryParse(this).toString();
    }
  }
}
