@isTest 
private class TimeCardSponsorControllerTest{
    static testMethod void validateSponsorTimeCard() {        
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
                Contact_URL__c,
                Supervisor__r.Name,
                Contact_Submitted__c
            FROM Time_Card__c WHERE Id =:t.Id];
        
        PageReference pageRef = Page.SupervisorTimeCardEntry;
        Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getParameters().put('c', expected.Hash__c);
        
        // Act
        TimeCardSponsorController controller = new TimeCardSponsorController();
        Time_Card__c actual =  controller.getTimeCard();
        string actualSupervisorName = controller.getSupervisorName();
        Boolean actualCanEdit = controller.GetCanEdit();
        string actualStatusMessage = controller.getStatusMessage();
        
        // Assert
        System.assertEquals(expected.Hash__c, actual.Hash__c);
        System.assertEquals(expected.Supervisor__r.Name, actualSupervisorName);
        System.assertEquals(!expected.Contact_Submitted__c, actualCanEdit);
        
        controller.save();
        PageReference actualRef = controller.reload();
        System.assertEquals(expected.Contact_URL__c, actualRef.getUrl());
    }   
}