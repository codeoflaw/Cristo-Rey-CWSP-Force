// Controller used to get and update Time Card information provided by the student.
public class TimeCardStudentController
{
    private final Time_Card__c timeCard;
    private Student__c student;
    private string supervisorName;
    private string statusMessage;
    private final string queryHash;
    
    public TimeCardStudentController()
    {
        if(ApexPages.currentPage().getParameters().containsKey('s')){
            queryHash = ApexPages.currentPage().getParameters().get('s');   
        }
        
        timeCard = [SELECT Id, Date__c,
        End_Time__c, 
        Hash__c,
        Hours_Worked__c, 
        Lunch_In__c, 
        Lunch_Out__c, 
        Lunch_Time__c, 
        Name,
        Start_Time__c, 
        Student_Submitted__c,
        Student__r.Id,
        Student__r.Name,
        Student__r.Student_Cell_Phone__c,
        Student__r.Sponsor__c,
        Student__r.Sponsor__r.Name,
        Student__r.Split_Time_Sponsor__r.Name,
        Student_Description__c,
        Student_URL__c,
        Supervisor__r.Name,
        Supervisor__r.Account.Name,
        Total_Hours__c,
        Student_Submitted_Date__c
        FROM Time_Card__c
        WHERE Hash__c =:queryHash];
        
        DateTime dateDateTime = timeCard.Date__c;
        String dateString = dateDateTime.format('MMMMM dd, yyyy', 'Etc./GMT');

        if(timeCard.Student_Submitted__c)
        {
            statusMessage = 'Thank you for submitting your time card for ' + dateString + '!';
        }
        else
        {
            statusMessage = 'Please fill out your timesheet for ' + dateString + '.';
        }
    }
    
    public Time_Card__c getTimeCard()
    {
        return timeCard;
    }
    
    public string getStatusMessage()
    {
        return statusMessage;
    }
    
    public string getSupervisorName()
    {
        return supervisorName;
    }
    
    public PageReference reload()
    {        
        // Set success message
        DateTime dT = timeCard.Date__c;
        statusMessage = 'Thank you for submitting your time card for ' + dT.format('MMMMM dd, yyyy', 'Etc./GMT') + '!';
        
        if(timeCard.Student_URL__c != null) {
            return new PageReference(timeCard.Student_URL__c);
        } else {
            return null;
        }
    }
    
    public void save()
    {
        boolean success = false;
        try {
        // Attempt to update the time card
            update timeCard;
            
        // Attempt to update the student's phone number
            student = [SELECT Id,
            Student_Cell_Phone__c
            FROM Student__c 
            WHERE Student__c.Id =: timeCard.Student__r.Id];
            student.Student_Cell_Phone__c = timeCard.Student__r.Student_Cell_Phone__c;
            update student;
            
            success = true;
        } catch (Exception e) {
        // If there are errors, present them on the page
            ApexPages.addMessages(e);
            success = false;
        }        
        
        if (success) {
        // If the time card can be updated, do so and reload the page
            timeCard.Student_Submitted_Date__c = Datetime.now();
            timeCard.Student_Submitted__c = true;
            update timeCard;
            reload();
        }
    }
    
    public boolean getCanEdit()
    {
        return !timeCard.Student_Submitted__c;
    }
}