import 'package:flutter/cupertino.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class BottomSheetModel  {


 BottomSheetModel.showSystetmBottomModel(BuildContext context , Widget body){
showMaterialModalBottomSheet(
  duration: Duration(milliseconds: 300),
  context: context, builder: (context){return body;});
 }
  
}