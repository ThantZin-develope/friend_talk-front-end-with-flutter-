import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_app/commons/SkeletonContainer.dart';

class FakePosts extends StatelessWidget{
  final int fakePostsLemgth;
  bool enableScroll;
  FakePosts({Key key  , this.fakePostsLemgth = 1 , @required this.enableScroll});
  @override 
  Widget build(BuildContext context){
    return  ListView.separated(
                  itemBuilder: (context, index) {
                    return Card(
                      child: Container(
                        width: double.infinity,
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding:
                                  EdgeInsets.only(left: 7, top: 5, bottom: 5),
                              child: Row(
                                children: <Widget>[
                                  SkeletonContainer(
                                    width: 50,
                                    height: 50,
                                    radius: 25,
                                  ),
                                  SizedBox(
                                    width: 7,
                                  ),
                                  SkeletonContainer(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    height: 18,
                                  )
                                ],
                              ),
                            ),
                            SkeletonContainer(
                              width: double.infinity,
                              height: 210,
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(
                      height: 10,
                    );
                  },
                  itemCount: this.fakePostsLemgth,
                  shrinkWrap: true,
                  physics: this.enableScroll ? ClampingScrollPhysics() : NeverScrollableScrollPhysics(),
                ); 
  }

}