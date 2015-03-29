trigger GenerateHash on Time_Card__c (after insert) {
    List<Time_Card__c> newTimeCards = [select id, hash__c, student__c, student__r.name, date__c from time_card__c where id IN : Trigger.newMap.keySet()];
    
    for(Time_Card__c tCard: newTimeCards)
    {
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(String.valueOf(tCard.Date__c)+String.valueOf(tCard.Student__r.Name)));
        String hashStr = EncodingUtil.base64Encode(hash);
        tCard.Hash__c = hashStr;
    }
    
    update newTimeCards;
}