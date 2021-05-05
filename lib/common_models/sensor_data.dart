class SensorData {
  double temp;
  double accx;
  double accy;
  double accz;  
  double eda;
  double bvp;

  SensorData(this.temp,this.accx,this.accy, this.accz, this.eda, this.bvp);

  SensorData.fromMap(Map<String, double> map) {
    temp = map['TEMP'];
    accx = map['ACCX'];
    accy = map['ACCY'];
    accz = map['ACCZ'];
    eda = map['GSR'];
    bvp = map['BVP'];
  }

  List<double> get toList => [temp,accx,accy,accz, eda, bvp];

  @override
  String toString() {
    return "ACCX: $accx\nACCY: $accy\nACCZ: $accz\nBVP: $bvp\nEDA: $eda\nTEMP: $temp";
  }
}
