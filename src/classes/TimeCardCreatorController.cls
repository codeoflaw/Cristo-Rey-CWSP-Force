// Controller used to create time cards for students working on the current day
public class TimeCardCreatorController {

    public Boolean isFriday { get; set; }
    public Boolean hasFoundStudents { get; set; }
    public List<SelectOption> dayOptions { get; set; }
    public string selectedDay { get; set; }

    private List<StudentViewModel> students;
    private List<StudentViewModel> studentsWithCards;
    private List<Time_Card__c> timeCardsForToday;
    private List<string> studentIds;
    private string statusMessage;
    private string createMessage;
    private DateTime today;
    private String dayOfWeek;
        
    public TimeCardCreatorController()
    {
        today = DateTime.Now();
        dayOfWeek = today.format('EEEE');
        if(dayOfWeek == 'Friday')
        {     
            isFriday = true;
        } 
        else 
        {   
            isFriday = false;
        }
        dayOptions = new List<SelectOption>();
        dayOptions.add(new SelectOption('Choose Day', 'Choose Day'));
        dayOptions.add(new SelectOption('Monday', 'Monday'));
        dayOptions.add(new SelectOption('Tuesday', 'Tuesday'));
        dayOptions.add(new SelectOption('Wednesday', 'Wednesday'));
        dayOptions.add(new SelectOption('Thursday', 'Thursday'));
        students = new List<StudentViewModel>();
        studentsWithCards = new List<StudentViewModel>();
        studentIds = new List<string>();
        createMessage = '';
        
        timeCardsForToday = [SELECT Id,
            Student__r.Id,
            Date__c
            FROM Time_Card__c
            WHERE Date__c = TODAY];
        for (Time_Card__c timeCard : timeCardsForToday)
        {
            studentIds.Add(timeCard.Student__r.Id);
        }
    }
    
    // Find the students whose work day is set to the current day of the week
    public PageReference findStudents() {        
        
        students = new List<StudentViewModel>();
        studentsWithCards = new List<StudentViewModel>();
    
        List<Student__c> possibleStudents = [SELECT Id,
        Name,
        Student_Email__c,
        Sponsor__c,
        Sponsor__r.Id,
        Sponsor__r.Name,
        Sponsor_Contact__c,
        Sponsor_Contact__r.Id,
        Sponsor_Contact__r.Name,
        Split_Time_Sponsor__c,
        Split_Time_Sponsor__r.Id,
        Split_Time_Sponsor__r.Name,
        Split_Time_Sponsor_Contact__c,
        Split_Time_Sponsor_Contact__r.Id,
        Split_Time_Sponsor_Contact__r.Name,
        Split_time__c,
        Withdrawn__c,
        Graduate__c,
        IsWorking__c
        FROM Student__c
        WHERE Work_Day__c =: dayOfWeek AND Withdrawn__c =: false AND Graduate__c =: false AND Id NOT IN :studentIds];
        
        for(Student__c student : possibleStudents) {
            if(isFriday && student.Split_time__c) {
                students.add(new StudentViewModel(student, true));
            }
            else {
                students.add(new StudentViewModel(student, false));
            }
        }
        
        statusMessage = 'Students available today: ' + students.size();
        hasFoundStudents = TRUE;
        
        List<Student__c> allStudentsWithCards = [SELECT Id,
            Name,
            Student_Email__c,
            Sponsor__c,
            Sponsor__r.Id,
            Sponsor__r.Name,
            Sponsor_Contact__c,
            Sponsor_Contact__r.Id,
            Sponsor_Contact__r.Name,
            Split_Time_Sponsor__c,
            Split_Time_Sponsor__r.Id,
            Split_Time_Sponsor__r.Name,
            Split_Time_Sponsor_Contact__c,
            Split_Time_Sponsor_Contact__r.Id,
            Split_Time_Sponsor_Contact__r.Name,
            Split_time__c,
            IsWorking__c
            FROM Student__c
            WHERE Work_Day__c =: dayofWeek AND Id IN :studentIds ];
        
        for(Student__c student : allStudentsWithCards ) {
            if(isFriday && student.Split_time__c) {
                studentsWithCards.add(new StudentViewModel(student, true));
            }
            else {
                studentsWithCards.add(new StudentViewModel(student, false));
            }
        }
        
        return null;
    }

    // Set the selected day based on the day picker and get timecards/students for that day
    public PageReference setSelectedDay() {
    
        List<Student__c> possibleStudents;
        if(selectedDay != 'Choose Day')
        {
            students = new List<StudentViewModel>();
            studentsWithCards = new List<StudentViewModel>();
        
            possibleStudents= [SELECT Id,
                Name,
                Student_Email__c,
                Sponsor__c,
                Sponsor__r.Id,
                Sponsor__r.Name,
                Sponsor_Contact__c,
                Sponsor_Contact__r.Id,
                Sponsor_Contact__r.Name,
                Split_Time_Sponsor__c,
                Split_Time_Sponsor__r.Id,
                Split_Time_Sponsor__r.Name,
                Split_Time_Sponsor_Contact__c,
                Split_Time_Sponsor_Contact__r.Id,
                Split_Time_Sponsor_Contact__r.Name,
                Split_time__c,
                Withdrawn__c,
                Graduate__c,
                IsWorking__c
                FROM Student__c
                WHERE Work_Day__c =: selectedDay AND Withdrawn__c =: false AND Graduate__c =: false AND Id NOT IN :studentIds];
            
            // Show each student as working so users don't have to click a bunch of checkboxes
            for(Student__c s : possibleStudents) {
                s.IsWorking__c = false;
                if(isFriday && s.Split_time__c) {
                    students.add(new StudentViewModel(s, true));
                }
                else {
                    students.add(new StudentViewModel(s, false));
                }
            }
        
            statusMessage = 'Students available today: ' + students.size();
            hasFoundStudents = TRUE;
            
            List<Student__c> allStudentsWithCards = [SELECT Id,
                Name,
                Student_Email__c,
                Sponsor__c,
                Sponsor__r.Id,
                Sponsor__r.Name,
                Sponsor_Contact__c,
                Sponsor_Contact__r.Id,
                Sponsor_Contact__r.Name,
                Split_Time_Sponsor__c,
                Split_Time_Sponsor__r.Id,
                Split_Time_Sponsor__r.Name,
                Split_Time_Sponsor_Contact__c,
                Split_Time_Sponsor_Contact__r.Id,
                Split_Time_Sponsor_Contact__r.Name,
                Split_time__c,
                IsWorking__c
                FROM Student__c
                WHERE Work_Day__c =: selectedDay AND Id IN :studentIds ];
                
            for(Student__c student : allStudentsWithCards ) {
                if(isFriday && student.Split_time__c) {
                    studentsWithCards.add(new StudentViewModel(student, true));
                }
                else {
                    studentsWithCards.add(new StudentViewModel(student, false));
                }
            }
        }
        else
        {
            hasFoundStudents = FALSE;
            students = new List<StudentViewModel>();
            studentsWithCards = new List<StudentViewModel>();
        }
        
        return null;
    }
    
     // Create new time cards for the selected students
    public PageReference createTimeCards()
    {
        try
        {
            List<Time_Card__c> newCards = new List<Time_Card__c>();
            
            for(StudentViewModel student : students)
            {
                if(student.IsWorking)
                {
                    
                    Time_Card__c newTimeCard = new Time_Card__c
                    (
                        Student__c = student.StudentId,
                        Student_Email__c = student.Email,
                        Date__c = date.Today(),
                        Supervisor__c = student.ContactId
                    );
                    newCards.add(newTimeCard);
                }
            }
            insert newCards;
            createMessage = 'Time cards created successfully';
        }
        catch(Exception e)
        {
            createMessage = e.getMessage();
        }
        return null;
    }
    
    public string getStatusMessage()
    {
        return statusMessage;
    }
    public String getCreateMessage() 
    {
        return createMessage;
    }
    public List<StudentViewModel> getStudents()
    {
        return students;
    }
    public List<StudentViewModel> getStudentsWithCards()
    {
        return studentsWithCards ;
    }
    public string getDayOfWeek()
    {
        return dayOfWeek;
    }
    public List<SelectOption> getDayOptions() 
    {
        return dayOptions;
    }
    
    //Student View Model used to abstract away logic around split time students
    public class StudentViewModel {
        public Student__c StudentObject;
        public Id StudentId;
        public string Name { get; set;}
        public string Email;
        public boolean IsWorking { get; set;}
        public boolean IsSplitTime;
        
        public Id SponsorId;
        public string SponsorName { get; set;}
        public Id ContactId;
        public string ContactName { get; set;}
       
      // public boolean getIsWorking() { return IsWorking; }
        
        public StudentViewModel() { }
        public StudentViewModel(Student__c student, boolean isSplitTime) {
            this.studentObject = student;
            this.StudentId = student.Id;
            this.Name = student.Name;
            this.Email = student.Student_Email__c;
            this.IsWorking = student.IsWorking__c;
            this.IsSplitTime = isSplitTime;
            if(isSplitTime) {
                this.SponsorId = student.Split_Time_Sponsor__r.Id;
                this.SponsorName = student.Split_Time_Sponsor__r.Name;
                this.ContactId = student.Split_Time_Sponsor_Contact__r.Id;
                this.ContactName = student.Split_Time_Sponsor_Contact__r.Name;
            }
            else {
                this.SponsorId = student.Sponsor__r.Id;
                this.SponsorName = student.Sponsor__r.Name;
                this.ContactId = student.Sponsor_Contact__r.Id;
                this.ContactName = student.Sponsor_Contact__r.Name;
            }
        }
    }

}