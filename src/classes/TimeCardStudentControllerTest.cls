@isTest 
private class TimeCardStudentControllerTest{
    static testMethod void validateStudentTimeCard() {        
        // Arrange
        Student__c s = new Student__c(First_Name__c = 'First', Last_Name__c = 'Last', Student_Email__c = 'student@test.com');
        insert s;
        Contact c = new Contact(LastName = 'Last');
        insert c;
        Time_Card__c t = new Time_Card__c (Student__c = s.id, Supervisor__c = c.id);
        insert t;
        Time_Card__c expected = [SELECT Name,
	        	Date__c,
				Hash__c,
				Student_URL__c,
				Student__r.Name,
				Student_Submitted__c
			FROM Time_Card__c WHERE Id =:t.Id];
        
        PageReference pageRef = Page.StudentTimeCardEntry;
        Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getParameters().put('s', expected.Hash__c);
        // Act
        TimeCardStudentController controller = new TimeCardStudentController();
        Time_Card__c actual =  controller.getTimeCard();
        
        // Assert
        System.assertEquals(expected.Hash__c, actual.Hash__c);
        System.assertEquals(!expected.Student_Submitted__c, controller.getCanEdit());
        System.assertEquals(c.Name, controller.getSupervisorName());
        
        controller.save();
        PageReference actualRef = controller.reload();
        System.assertEquals(expected.Student_URL__c, actualRef.getUrl());
    }
}