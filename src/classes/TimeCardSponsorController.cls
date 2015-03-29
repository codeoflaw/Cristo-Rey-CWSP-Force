// Controller used to get and update Time Card information provided by the sponsor.
public class TimeCardSponsorController
{

    public String getSupervisorName() {
        return supervisorName;
    }

    private final Time_Card__c timeCard;
    private string statusMessage;
    private string supervisorName;
    
    public TimeCardSponsorController()
    {
        timeCard = [SELECT 
        Id,
        Contact_Me__c, 
        Date__c,
        Contact_Submitted__c,
        Contact_URL__c,
        End_Time__c, 
        Hash__c,
        Hours_Worked__c, 
        Lunch_In__c, 
        Lunch_Out__c, 
        Lunch_Time__c, 
        Name,
        Start_Time__c, 
        Student__c,
        Supervisor__r.Name,
        Student__r.Name,
        Student_Description__c,
        Supervisor_Comments__c,
        Total_Hours__c,
        Contact_Submitted_Date__c
        FROM Time_Card__c
        WHERE Hash__c =:ApexPages.currentPage().getParameters().get('c')];
        
        supervisorName = timeCard.Supervisor__r.Name;
        
        if(timeCard.Contact_Submitted__c)
        {
            statusMessage = 'Thank you for submitting your time card for ' + timeCard.Student__r.Name + '!';
        }
        else
        {
            DateTime dT = timeCard.Date__c;
            statusMessage = 'Please confirm and comment on the ' + dT.format('MMMMM dd, yyyy', 'Etc./GMT') + ' time card for ' + timeCard.Student__r.Name + '.';
        }
    }
    
    public boolean getCanEdit()
    {
        return !timeCard.Contact_Submitted__c;
    }
    
    public string getStatusMessage()
    {
        return statusMessage;
    }
    
    public Time_Card__c getTimeCard()
    {
        return timeCard;
    }
    
    public void save()
    {
        boolean success = false;
        try{
            update timeCard;
            success = true;
        }catch(Exception e){
            ApexPages.addMessages(e);
            success = false;
        }
        
        if(success) {
            timeCard.Contact_Submitted_Date__c = Datetime.now();
            timeCard.Contact_Submitted__c = true;
            update timeCard;
            reload();
        }
    }
    
    public PageReference reload()
    {        
        statusMessage = 'Thank you for submitting your time card for ' + timeCard.Student__r.Name + '!';
        
        if(timeCard.Contact_URL__c != null){
            return new PageReference(timeCard.Contact_URL__c);
            } else {
            return null;
            }
    }     
}