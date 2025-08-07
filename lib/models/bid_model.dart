class BidModel {
  int? id;
  int loadId;
  double amount;
  String bidder;

  BidModel({
    this.id,
    required this.loadId,
    required this.amount,
    required this.bidder,
  
  });

  factory BidModel.fromMap(Map<String, dynamic> map) {
    return BidModel(
      id: map['id'],
      loadId: map['loadId'],
      amount: map['amount'],
      bidder: map['bidder'],
      
    );
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'loadId': loadId,
      'amount': amount,
      'bidder': bidder,
    };
    if (id != null) map['id'] = id;
    return map;
  }
}
