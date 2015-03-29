trigger SetStudentEmail on Time_Card__c (after insert) {
    List<Time_Card__c> newTimeCards = [select id, student__c, student__r.student_email__c from time_card__c where id IN : Trigger.newMap.keySet()];
 
    for(Time_Card__c tCard: newTimeCards)
    {
        tCard.Student_Email__c = tCard.Student__r.Student_Email__c;
    }
    
    update newTimeCards;
}