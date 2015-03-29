@isTest 
private class GenerateHashTestClass{
    static testMethod void validateGenerateHash() {
        // Arrange
        Student__c s = new Student__c(First_Name__c = 'First', Last_Name__c = 'Last', Student_Email__c = 'student@test.com');
        insert s;
        Contact c = new Contact(LastName = 'Last');
        insert c;
        Time_Card__c t = new Time_Card__c (Student__c = s.id, Supervisor__c = c.id);
        
        // Act
        insert t;
        
        // Retrieve the new time card
        t = [SELECT Name, Date__c, Hash__c, Student__r.Name FROM Time_Card__c WHERE Id =:t.Id];
        
        // Determine what the expected hash should be based on the time card's name
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(String.valueOf(t.Date__c)+String.valueOf(t.Student__r.Name)));
        String expected = EncodingUtil.base64Encode(hash);
        
        // Assert
        System.assertEquals(expected, t.Hash__c);
    }
}