class IDStudent {
  String? email;

  IDStudent(this.email);

  String getID() {
    // Check if the email is not null and has at least 10 characters
    if (email != null && email!.length >= 10) {
      // Extract the first 10 characters
      String extracted = email!.substring(0, 10);
      // Convert to uppercase
      String uppercaseExtracted = extracted.toUpperCase();
      return uppercaseExtracted;
    } else {
      // Handle case where email is null or has less than 10 characters
      return "Invalid Email";
    }
  }
}