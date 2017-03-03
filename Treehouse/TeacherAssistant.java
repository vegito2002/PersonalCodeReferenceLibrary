public class TeacherAssistant {

  public static String validatedFieldName(String fieldName) {
  	if (fieldName.charAt(0)!='m'){
  		throw new IllegalArgumentException("It can't start wth a(n)" + fieldName.charAt(0));
  	}
  	if (!Character.isUpperCase(fieldName.charAt(1))){
  		throw new IllegalArgumentException("This is not camel-casing");
  	}
  	return fieldName;


    // These things should be verified:
    // 1.  Member fields must start with an 'm'
    // 2.  The second letter in the field name must be uppercased to ensure camel-casing
    // NOTE:  To check if something is not equal use the != symbol. eg: 3 != 4
    // return fieldName;
  }

}

