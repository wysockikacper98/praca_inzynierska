import 'package:praca_inzynierska/models/users.dart';

enum UserType{
  Firm,
  PrivateUser,
}

Users currentUser;
// UserType userType;

Users getCurrentUser(){
  return currentUser;
}

setCurrentUser(Users givenUser){
  currentUser = givenUser;
}
//
// UserType getCurrentUserType(){
//   return userType;
// }
//
// setCurrentUserType(UserType type){
//   userType = type;
// }