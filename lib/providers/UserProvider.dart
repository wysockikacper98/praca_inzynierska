import 'package:praca_inzynierska/models/users.dart';

class UserProvider {
  Users currentUser;
}
Users currentUser;
Users getCurrentUser(){
  return currentUser;
}

setCurrentUser(Users givenUser){
  currentUser = givenUser;
}