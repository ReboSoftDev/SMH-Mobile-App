class Compliance {
  String? productcode;
  int? color;
  int? position;
  int? sizeratio;
  int? product;
  int? quantity;
  String? fileContents;
  int? signage;
  int? status;
  int? detectedQuantity;
  int? mannequin_signage ;

  Compliance({this.productcode, this.color, this.position , this.sizeratio, this.product,this.quantity,this.fileContents,this.signage,this.mannequin_signage,
  this.detectedQuantity,this.status});

  Compliance.fromJson(Map<String, dynamic> json) {
    productcode = json['product_code'];
    color = json['color'];
    position = json['position'];
    sizeratio = json["size_ratio"];
    product = json["product"];
    quantity = json["quantity"];
    fileContents = json["file_contents"];
    signage = json["signage_compliance"];
    mannequin_signage = json['signage'];
    detectedQuantity= json['detected_quantity'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['product_code'] = productcode;
    data['color'] = color;
    data['position'] = position;
    data['size_ratio'] = sizeratio;
    data['product'] = product;
    data['quantity'] = quantity;
    data['file_contents'] = fileContents;
    data['signage_compliance'] = signage;
    data['signage'] = mannequin_signage;
    data['status'] = status;
    data['detected_quantity'] = detectedQuantity;
    return data;
  }
}

///qr code table data

class QRdata {
  String? storecode;
  String? equipmentid;
  String? componentid;
  String? filename;
  String? filecontent;
  QRdata({this.storecode, this.equipmentid, this.componentid, this.filename,this.filecontent});

  QRdata.fromJson(Map<String, dynamic> json) {
    storecode = json['storecode'];
    equipmentid = json['equipment_name'];
    componentid = json['equipment_component'];
    filename = json["file_name"];
    filecontent = json["file_contents"];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['storecode'] = storecode;
    data['equipment_name'] = equipmentid;
    data['equipment_component'] = componentid;
    data['file_name'] = filename;
    data['file_contents'] = filecontent;

    return data;
  }
}
//////////////////////////////////////////////////////////////
////////////////////////////////////////
// compliance popup data
class Comp {
  String? d_color;
  String? v_color;
  int? d_position;
  int? v_position;
  String? v_product;
  String? d_product;
  int? d_quantity;
  int? v_quantity;
  String? v_sizeratio;
  String? d_sizeratio;
  int? vm_signage;
  int? signage;
  String? sap;
  String? pos;
  int? detected_product;
  String? size;
  int? quantity;
  String? sizeCount;
  int? detected_values_id;




  Comp({this.v_color,this.d_color,this.d_position,this.v_position,this.d_product,this.v_product,
  this.d_quantity,this.v_quantity,this.d_sizeratio,this.v_sizeratio,this.signage,this.vm_signage,this.sap,this.pos,this.detected_product,
  this.size,this.quantity,this.sizeCount,this.detected_values_id});

  Comp.fromJson(Map<String, dynamic> json) {
    v_color = json['vm_colour'];
    d_color = json['detected_colour'];
    v_position = json['vm_position'];
    d_position = json['detected_position'];
    v_quantity = json['vm_quantity'];
    d_quantity = json['detected_quantity'];
    v_sizeratio = json['v_sizeratio'];
    d_sizeratio = json['d_sizeratio'];
    v_product = json['product_code'];
    d_product = json['d_product'];
    vm_signage = json['vm_signage'];
    signage = json['signage'];
    sap = json['sap'];
    pos = json['pos'];
    detected_product =json['detect_product'];
    size =json['size'];
    quantity =json['quantity'];
    sizeCount =json['sizeCount'];
    detected_values_id = json['id'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> popupData = Map<String, dynamic>();
    popupData['vm_colour'] = v_color;
    popupData['detected_colour'] = d_color;
    popupData['vm_position'] = v_position;
    popupData['detected_position'] = d_position;
    popupData['product_code'] = v_product;
    popupData['d_product'] = d_product;
    popupData['v_sizeratio'] = v_sizeratio;
    popupData['d_sizeratio'] = d_sizeratio;
    popupData['vm_quantity'] = v_quantity;
    popupData['detected_quantity'] = d_quantity;
    popupData['vm_signage'] = vm_signage;
    popupData['signage'] = signage;
    popupData['sap'] = sap;
    popupData['pos'] = pos;
    popupData['detect_product'] = detected_product;
    popupData['size'] = size;
    popupData['quantity'] = quantity;
    popupData['sizeCount'] = sizeCount;
    popupData['id'] = detected_product;

    return popupData;
  }
}



class CheatSheet {

  String? size;
  String? sizeCount;

  CheatSheet({this.size,this.sizeCount});

  CheatSheet.fromJson(Map<String, dynamic> json) {
    size =json['Size'];
    sizeCount =json['SizeCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> popupData = Map<String, dynamic>();

    popupData['Size'] = size;
    popupData['SizeCount'] = sizeCount;


    return popupData;
  }
}




class PopupCompliance {
  String? v_code;
  String? d_code;

  PopupCompliance({this.v_code, this.d_code,});
  PopupCompliance.fromJson(Map<String, dynamic> json) {
    v_code = json['v_code'];
    d_code = json['d_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> popupData = Map<String, dynamic>();
    popupData['v_code'] = v_code;
    popupData['d_code'] = d_code;
    return popupData;
  }
}

// vmguidline list
class VMGuidelineMenu {
  int? id;
  int? eqpt_id;
  String? guidelineName;
  String? date;
  String? createdBy;

  VMGuidelineMenu({this.id,this.eqpt_id,this.guidelineName, this.date, this.createdBy});

  VMGuidelineMenu.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    eqpt_id =json['equipment_id'];
    guidelineName = json['equipment_name'];
    date = json['entry_date'];
    createdBy = json['created_by'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['equipment_id'] = eqpt_id;
    data['equipment_name'] = guidelineName;
    data['entry_date'] = date;
    data['created_by'] = createdBy;
    return data;
  }
}
// generalguidline list
class GeneralGuidelineMenu {
  String? GDguidelineName;
  String? GDdate;
  String? GDcreatedBy;
  int? id;

  GeneralGuidelineMenu({this.GDguidelineName, this.GDdate, this.GDcreatedBy,this.id});

  GeneralGuidelineMenu.fromJson(Map<String, dynamic> json) {
    GDguidelineName = json['category_name'];
    GDdate = json['entry_date'];
    GDcreatedBy = json['created_by'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['category_name'] = GDguidelineName;
    data['entry_date'] = GDdate;
    data['created_by'] = GDcreatedBy;
    data['id'] = id;
    return data;
  }
}

// login
class login {
  int? id;
  String? role;


  login({this.role,this.id,});

  login.fromJson(Map<String, dynamic> json) {
    role = json['role'];
    id =json['id'];


    Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = <String, dynamic>{};

      data['role'] = role;
      data['id']= id;

      return data;
    }
  }
}




class UserModel {

  final int id;
  final String code;

  UserModel(
      {required this.id, required this.code});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        id: json["id"],
        code:json["code"]
    );
  }

  static List<UserModel> fromJsonList(List list) {
    return list.map((item) => UserModel.fromJson(item)).toList();
  }

  ///this method will prevent the override of toString
  String userAsString() {
    return '#$id $code';
  }


  ///custom comparing function to check if two users are equal
  bool isEqual(UserModel model) {
    return id == model.id;
  }

  @override
  String toString() => code;



}

/// city manager////


class StoreManager {

  int? first_amber;
  int? first_red;
  int? second_amber;
  int? second_red;
  int? store_id;
  String? store_code;
  String? inserted_date;
  String? s_address;
  int? total_image_first;
  int? total_image_second;
  StoreManager({this.inserted_date,this.first_amber, this.first_red, this.second_amber , this.second_red, this.store_id,this.store_code,this.s_address,
    this.total_image_first,this.total_image_second});

  StoreManager.fromJson(Map<String, dynamic> json) {
    first_amber = json["FIRST_AMBER"];
    first_red = json["FIRST_RED"];
    second_amber = json["SECOND_AMBER"];
    second_red = json["SECOND_RED"];
    store_id = json["store_id"];
    store_code = json["store_code"];
    s_address = json["address"];
    total_image_first = json["TOTAL_IMAGES_FIRST"];
    total_image_second = json["TOTAL_IMAGES_SECOND"];
    inserted_date = json["inserted_date"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['FIRST_AMBER'] = first_amber;
    data['FIRST_RED'] = first_red;
    data['SECOND_AMBER'] = second_amber;
    data['SECOND_RED'] = second_red;
    data['store_id'] = store_id;
    data["store_code"] = store_code;
    data['address'] = s_address;
    data['TOTAL_IMAGES_FIRST'] = total_image_first;
    data['TOTAL_IMAGES_SECOND'] = total_image_second;
    data['inserted_date'] = inserted_date;
    return data;
  }

}







/// city manager////


class CityManager {

  int? first_amber;
  int? first_red;
  int? second_amber;
  int? second_red;
  int? store_id;
  String? store_code;
  String? s_address;
  String? total_image_first;
  String? total_image_second;
  CityManager({this.first_amber, this.first_red, this.second_amber , this.second_red, this.store_id,this.store_code,this.s_address,
    this.total_image_first,this.total_image_second});

  CityManager.fromJson(Map<String, dynamic> json) {
    first_amber = json["FIRST_AMBER"];
    first_red = json["FIRST_RED"];
    second_amber = json["SECOND_AMBER"];
    second_red = json["SECOND_RED"];
    store_id = json["store_id"];
    store_code = json["store_code"];
    s_address = json["address"];
    total_image_first = json["TOTAL_IMAGES_FIRST"];
    total_image_second = json["TOTAL_IMAGES_SECOND"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['FIRST_AMBER'] = first_amber;
    data['FIRST_RED'] = first_red;
    data['SECOND_AMBER'] = second_amber;
    data['SECOND_RED'] = second_red;
    data['store_id'] = store_id;
    data["store_code"] = store_code;
    data['address'] = s_address;
    data['TOTAL_IMAGES_FIRST'] = total_image_first;
    data['TOTAL_IMAGES_SECOND'] = total_image_second;
    return data;
  }

}
class CityManagerEquipmentWise {

  int? equipment_id;
  int? detected_table_id;
  int? count;
  String? equipment_name;
  String? inserted_on;
  String? location;
  String? store_code;


  CityManagerEquipmentWise({this.equipment_id,this.detected_table_id,this.count,this.equipment_name,this.inserted_on,this.location,this.store_code });

  CityManagerEquipmentWise.fromJson(Map<String, dynamic> json) {
    equipment_id = json["equipment_id"];
    detected_table_id = json["detected_table_id"];
    equipment_name = json["equipment_name"];
    inserted_on = json["inserted_on"];
    location = json["location"];
    store_code = json["storeCode"];
    count = json["count"];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['equipment_id'] = equipment_id;
    data['detected_table_id'] = detected_table_id;
    data['equipment_name'] = equipment_name;
    data['inserted_on'] = inserted_on;
    data['location'] = location;
    data['count'] = count;
    data["storeCode"] = store_code;

    return data;
  }

}
class CityManagerProductWise {

  String? productcode;
  int? color;
  int? position;
  int? sizeratio;
  int? product;
  int? quantity;
  String? fileContents;
  int? signage;
  String? imageContent;
  CityManagerProductWise({this.productcode,this.imageContent, this.color, this.position , this.sizeratio, this.product,this.quantity,this.fileContents,this.signage,});

  CityManagerProductWise.fromJson(Map<String, dynamic> json) {
    productcode = json['product_code'];
    color = json['color'];
    position = json['position'];
    sizeratio = json["size_ratio"];
    product = json["product"];
    quantity = json["quantity"];
    fileContents = json["file_contents"];
    signage = json["signage_compliance"];
    imageContent = json["returned_image_file"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['product_code'] = productcode;
    data['color'] = color;
    data['position'] = position;
    data['size_ratio'] = sizeratio;
    data['product'] = product;
    data['quantity'] = quantity;
    data['file_contents'] = fileContents;
    data['signage_compliance'] = signage;
    data['returned_image_file'] = imageContent;
    return data;
  }
  }

/// cluster manger ////////////////////////////////////////////////////////////////////////////////////////////////////////

  class ClusterManager {

  int? first_amber;
  int? first_red;
  int? second_amber;
  int? second_red;
  int? store_id;

  String? s_address;
  String? storeCode;
  String? city;
  String? total_image_first;
  String? total_image_second;
  int? total_stores;
  int? total_images;
  ClusterManager({this.first_amber, this.first_red, this.second_amber , this.second_red, this.store_id,this.s_address,this.city,
    this.total_image_first,this.total_image_second,this.total_stores,this.total_images,this.storeCode});

  ClusterManager.fromJson(Map<String, dynamic> json) {
    first_amber = json["FIRST_AMBER"];
    first_red = json["FIRST_RED"];
    second_amber = json["SECOND_AMBER"];
    second_red = json["SECOND_RED"];
    store_id = json["store_id"];
    storeCode = json["store_code"];

    s_address = json["address"];
    city = json['store_city'];
    total_image_first = json["TOTAL_IMAGES_FIRST"];
    total_image_second = json["TOTAL_IMAGES_SECOND"];
    total_stores = json['Total_stores'];
    total_images = json['Total_Images'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['FIRST_AMBER'] = first_amber;
    data['FIRST_RED'] = first_red;
    data['SECOND_AMBER'] = second_amber;
    data['SECOND_RED'] = second_red;
    data['store_id'] = store_id;
    data['store_code'] = storeCode;
    data['address'] = s_address;
    data['store_city'] = city;
    data['TOTAL_IMAGES_FIRST'] = total_image_first;
    data['TOTAL_IMAGES_SECOND'] = total_image_second;
    data['Total_stores'] = total_stores;
    data['Total_Images'] = total_images;
    return data;
  }

}




class ClusterManagerEquipmentWise {

  int? equipment_id;
  int? detected_table_id;
  String? equipment_name;
  String? inserted_on;
  String? location;
  String? store_code;
  String? city;
  int? store_id;

  ClusterManagerEquipmentWise({this.equipment_id,this.detected_table_id,this.equipment_name,this.inserted_on,this.location,this.store_code,this.city,this.store_id });

  ClusterManagerEquipmentWise.fromJson(Map<String, dynamic> json) {
    equipment_id = json["equipment_id"];
    equipment_name = json["equipment_name"];
    inserted_on = json["inserted_on"];
    location = json["location"];
    store_code = json["storeCode"];
    city = json["city"];
    store_id = json["store_id"];
    detected_table_id = json["detected_table_id"];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['equipment_id'] = equipment_id;
    data['equipment_name'] = equipment_name;
    data['inserted_on'] = inserted_on;
    data['location'] = location;
    data["storeCode"] = store_code;
    data["city"] = city;
    data["store_id"] = store_id;
    data["detected_table_id"] = detected_table_id;

    return data;
  }

}

///seniorManager//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


class SeniorManager {

  int? first_amber;
  int? first_red;
  int? second_amber;
  int? second_red;
  int? red;
  int? amber;
  int? store_id;
  int? detected_table_id;
  int? equipment_id;
  String? store_code;
  String? s_address;
  String? city;
  String? total_image_first;
  String? total_image_second;
  int? total_stores;
  int? total_images;
  SeniorManager({this.first_amber, this.first_red, this.second_amber , this.second_red, this.store_id,this.store_code,this.s_address,this.city,
    this.total_image_first,this.total_image_second,this.total_stores,this.total_images,this.red,this.amber,this.detected_table_id,this.equipment_id});

  SeniorManager.fromJson(Map<String, dynamic> json) {
    first_amber = json["FIRST_AMBER"];
    first_red = json["FIRST_RED"];
    second_amber = json["SECOND_AMBER"];
    second_red = json["SECOND_RED"];
    store_id = json["store_id"];
    store_code = json["store_code"];
    s_address = json["address"];
    city = json['store_city'];
    total_image_first = json["TOTAL_IMAGES_FIRST"];
    total_image_second = json["TOTAL_IMAGES_SECOND"];
    total_stores = json['Total_stores'];
    total_images = json['Total_Images'];
    red = json['RED'];
    amber = json['AMBER'];
    detected_table_id = json['detected_table_id'];
    equipment_id = json['equipment_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['FIRST_AMBER'] = first_amber;
    data['FIRST_RED'] = first_red;
    data['SECOND_AMBER'] = second_amber;
    data['SECOND_RED'] = second_red;
    data['store_id'] = store_id;
    data["store_code"] = store_code;
    data['address'] = s_address;
    data['store_city'] = city;
    data['TOTAL_IMAGES_FIRST'] = total_image_first;
    data['TOTAL_IMAGES_SECOND'] = total_image_second;
    data['Total_stores'] = total_stores;
    data['Total_Images'] = total_images;
    data['RED'] = red;
    data['AMBER'] = amber;
    data['detected_table_id'] = detected_table_id;
    data['equipment_id'] = equipment_id;
    return data;
  }

}



class stockQuery {

  int? id;
  String? colour;
  String? generic_code;
  String? material_code;
  double? pos_qty;
  String? size;
  double? sap;
  double? trans_qty;
  String? prodh;
  String? storeCode;
  String? season;
  String? materialGroup;

  stockQuery({this.id,this.colour,this.generic_code,this.material_code,this.pos_qty,this.size,this.sap,this.trans_qty,this.prodh,
    this.storeCode,this.season,this.materialGroup });
  stockQuery.fromJson(Map<String, dynamic> json) {
    colour = json["color"];
    generic_code = json["genericCode"];
    material_code = json["materialCode"];
    pos_qty = json["posQty"];
    size = json["size"];
    sap = json["systemQty"];
    trans_qty = json["transitQty"];
    prodh = json["productionHouse"];
    storeCode = json["storeCode"];
    season = json["season"];
    materialGroup = json["materialGroup"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['color'] = colour;
    data['genericCode'] = generic_code;
    data['materialCode'] = material_code;
    data['posQty'] = pos_qty;
    data["size"] = size;
    data["systemQty"] = sap;
    data["transitQty"] = trans_qty;
    data["productionHouse"] = prodh;
    data["storeCode"] = storeCode;
    data["season"] = season;
    data["materialGroup"] = materialGroup;

    return data;
  }

}
class stockNearby {

  String? store_code;
  String? sys_qty;
  String? material_code;


  stockNearby({this.store_code,this.sys_qty,this.material_code});

  stockNearby.fromJson(Map<String, dynamic> json) {
    store_code = json["storeCode"];
    sys_qty = json["systemQty"];
    material_code = json["materialCode"];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['storeCode'] = store_code;
    data['systemQty'] = sys_qty;
    data['materialCode'] = material_code;
    return data;
  }

}


class alternateProduct {

  String? material_no;
  String? colour;
  String? size;
  double? sap;
  String? storeCode;
  double? transQty;

  alternateProduct({this.material_no,this.colour,this.size,this.sap,this.storeCode,this.transQty });

  alternateProduct.fromJson(Map<String, dynamic> json) {
    colour = json["color"];
    size = json["size"];
    sap = json["systemQty"];
    transQty = json["transitQty"];
    storeCode = json["storeCode"];
    material_no = json["materialNumber"];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['color'] = colour;
    data['materialNumber'] = material_no;
    data["size"] = size;
    data["sap"] = sap;
    data["transitQty"] = transQty;
    data["storeCode"] = storeCode;

    return data;
  }

}
// class whichEquipment {
//   String? equipment;
//   whichEquipment({this.equipment });
//   whichEquipment.fromJson(Map<String, dynamic> json) {
//     equipment = json["code"];
//   }
//
// }
class whichEquipment{
   String? equipment;
   whichEquipment({
    required this.equipment,

  });

  factory whichEquipment.fromJson(Map<String, dynamic> json) {
    return whichEquipment(
      equipment: json['code'],

    );
  }
}

class ComplianceImage {


  String? file_content;
  String? file_name;

  ComplianceImage({this.file_content,this.file_name, });
  ComplianceImage.fromJson(Map<String, dynamic> json) {
    file_content = json["equipment_id"];
    file_name = json["equipment_name"];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['file_content'] = file_content;
    data['file_name'] = file_name;


    return data;
  }

}


class googleReviews {
  String? badReviews;
  String? feedbackBuckets;
  googleReviews({this.badReviews,this.feedbackBuckets, });
  googleReviews.fromJson(Map<String, dynamic> json) {
    badReviews = json["bad_reviews"];
    feedbackBuckets = json["feedback_bucket"];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['bad_reviews'] = badReviews;
    data['feedback_bucket'] = feedbackBuckets;
    return data;
  }
}



class beautyCompliance {
  String? product_code ;
  int? detected_quantity;
  int? missing_quantity;
  int? tester_not_present;
  int? tester_present_empty;
  int? tester_present_not_empty;
  String? vm_colour;
  int? vm_position;
  int? vm_quantity ;
  beautyCompliance({this.product_code, this.vm_colour, this.vm_position ,this.vm_quantity,this.detected_quantity,this.missing_quantity,
  this.tester_not_present,this.tester_present_empty,this.tester_present_not_empty});

  beautyCompliance.fromJson(Map<String, dynamic> json) {
    product_code = json['product_code'];
    vm_colour = json['vm_colour'];
    vm_position = json['vm_position'];
    vm_quantity = json["vm_quantity"];
    missing_quantity = json["missing_quantity"];
    detected_quantity = json["detected_quantity"];
    tester_present_not_empty = json["tester_present_not_empty"];
    tester_present_empty = json["tester_present_empty"];
    tester_not_present = json['tester_not_present'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['product_code'] = product_code;
    data['vm_colour'] = vm_colour;
    data['vm_position'] = vm_position;
    data['vm_quantity'] = vm_quantity;
    data['missing_quantity'] = missing_quantity;
    data['detected_quantity'] = detected_quantity;
    data['tester_npt_present'] = tester_not_present;
    data['tester_present_empty'] = tester_present_empty;
    data['tester_present_not_empty'] = tester_present_not_empty;
    return data;
  }
}