class SensorData {
  double acc;
  double bvp;
  double eda;
  double temp;

  SensorData(this.acc, this.bvp, this.eda, this.temp);

  SensorData.fromMap(Map<String, double> map) {
    acc = map['ACC'];
    bvp = map['BVP'];
    eda = map['GSR'];
    temp = map['TEMP'];
  }

  List<double> get toList => [acc, bvp, eda, temp];

  @override
  String toString() {
    return "ACC: $acc\nBVP: $bvp\nEDA: $eda\nTEMP: $temp";
  }
}
