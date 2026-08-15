class Validator {
  static String? validateEMail(String? value){
    if(value==null|| value.trim().isEmpty){
      return "Email is required";
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if(!emailRegex.hasMatch(value.trim())){
      return "Enter a valid email";
    }
    return null;
  }
  static String? validateConfirmPassword(String? value, String password){
    if(value==null || value.isEmpty){
      return "Please confirm your password";
    }
    if (value!=password){
      return "Password do not match";
    }
    return null;
  }
  static String? validateName(String? value){
    if(value==null|| value.trim().isEmpty){
      return "Name is required";
    }
    if(value.trim().length<2){
      return "Name is too short";
    }
    return null;
  }
  static String? validateRequired(String? value, String fieldName){
    if(value==null || value.trim().isEmpty){
      return "$fieldName is required";
    }
    return null;
  }
}