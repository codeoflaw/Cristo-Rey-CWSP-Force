@isTest 
private class TimeCardCreatorControllerTest{
    static testMethod void validateTimeCardCreator() {
        // Arrange
        string dayOfWeek = 'Thursday';
        Student__c s = new Student__c(First_Name__c = 'First', Last_Name__c = 'Last', Student_Email__c = 'student@test.com', Work_Day__c = 'Monday');
        insert s;
        Contact c = new Contact(LastName = 'Last');
        insert c;
        
        // Act
        TimeCardCreatorController controller = new TimeCardCreatorController();
        controller.findStudents();
        controller.createTimeCards();
        controller.getCreateMessage();
        controller.getStatusMessage();
        controller.setSelectedDay();
        
        // Assert
        System.assertEquals(false, controller.isFriday);
        System.assertEquals(0, controller.getStudents().size());
    }

    static testMethod void validateTimeCardCreatorOnFriday() {
        // Arrange
        Student__c s = new Student__c(First_Name__c = 'First', Last_Name__c = 'Last', Student_Email__c = 'student@test.com', Work_Day__c = 'Thursday');
        insert s;
        Contact c = new Contact(LastName = 'Last');
        insert c;
        
        // Act
        TimeCardCreatorController controller = new TimeCardCreatorController();
        controller.selectedDay = 'Thursday';
        controller.setSelectedDay();
        controller.createTimeCards();
        
        // Assert
        System.assertEquals(DateTime.Now().format('EEEE') == 'Friday', controller.isFriday);
        System.assertEquals(1, controller.getStudents().size());
    }
}