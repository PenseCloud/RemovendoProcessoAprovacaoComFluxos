@isTest
public class CustomApprovalProcessRequestTest {
    
    @TestSetup
    static void makeData(){
        Opportunity opp = new Opportunity(
            StageName = 'Needs Analysis',
            Name = 'Opportunity test',
            CloseDate = Date.today() + 10
        );        
        insert opp;
    }

    @IsTest
    static void approveOpportunityTest(){
        
        Opportunity opp = [ SELECT Id, StageName FROM Opportunity LIMIT 1 ];
        Integer totalApprovalProcessPending;
        List< CustomApprovalProcessRequest.ApprovalParam > params = new List< CustomApprovalProcessRequest.ApprovalParam >();

        Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
        request.setObjectId(opp.id);
        Approval.ProcessResult result = Approval.process(request);

        totalApprovalProcessPending = obtainAmountApprovalProcessPending( opp.Id );
        System.assert( totalApprovalProcessPending > 0 );

        Test.startTest();

        CustomApprovalProcessRequest.ApprovalParam param = new CustomApprovalProcessRequest.ApprovalParam();
        param.recordId = opp.Id;
        param.action = 'Approve';
        param.comments = 'Approved by custom method';
        params.add( param );
        
        CustomApprovalProcessRequest.request( params );

        Test.stopTest();
        
        totalApprovalProcessPending = obtainAmountApprovalProcessPending( opp.Id );
        System.assertEquals( 0, totalApprovalProcessPending );
    }

    @IsTest
    static void rejectOpportunityTest(){
        
        Opportunity opp = [ SELECT Id, StageName FROM Opportunity LIMIT 1 ];
        Integer totalApprovalProcessPending;
        List< CustomApprovalProcessRequest.ApprovalParam > params = new List< CustomApprovalProcessRequest.ApprovalParam >();

        Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
        request.setObjectId(opp.id);
        Approval.ProcessResult result = Approval.process(request);

        totalApprovalProcessPending = obtainAmountApprovalProcessPending( opp.Id );
        System.assert( totalApprovalProcessPending > 0 );

        Test.startTest();

        CustomApprovalProcessRequest.ApprovalParam param = new CustomApprovalProcessRequest.ApprovalParam();
        param.recordId = opp.Id;
        param.action = 'Reject';
        param.comments = 'Rejected by custom method';
        params.add( param );
        
        CustomApprovalProcessRequest.request( params );

        Test.stopTest();
        
        totalApprovalProcessPending = obtainAmountApprovalProcessPending( opp.Id );
        System.assertEquals( 0, totalApprovalProcessPending );
    }

    @IsTest
    static void removeApprovalProcessOpportunityTest(){
        
        Opportunity opp = [ SELECT Id, StageName FROM Opportunity LIMIT 1 ];
        Integer totalApprovalProcessPending;
        List< CustomApprovalProcessRequest.ApprovalParam > params = new List< CustomApprovalProcessRequest.ApprovalParam >();

        Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
        request.setObjectId(opp.id);
        Approval.ProcessResult result = Approval.process(request);

        totalApprovalProcessPending = obtainAmountApprovalProcessPending( opp.Id );
        System.assert( totalApprovalProcessPending > 0 );

        Test.startTest();

        CustomApprovalProcessRequest.ApprovalParam param = new CustomApprovalProcessRequest.ApprovalParam();
        param.recordId = opp.Id;
        param.action = 'Removed';
        param.comments = 'Removed by custom method';
        params.add( param );
        
        CustomApprovalProcessRequest.request( params );

        Test.stopTest();
        
        totalApprovalProcessPending = obtainAmountApprovalProcessPending( opp.Id );
        System.assertEquals( 0, totalApprovalProcessPending );
    }

    @IsTest
    static void opportunityWithoutApprovalProcessTest(){
        
        Opportunity opp = [ SELECT Id, StageName FROM Opportunity LIMIT 1 ];
        Integer totalApprovalProcessPending;
        List< CustomApprovalProcessRequest.ApprovalParam > params = new List< CustomApprovalProcessRequest.ApprovalParam >();
        List< CustomApprovalProcessRequest.ApprovalRequestResult > results;
        totalApprovalProcessPending = obtainAmountApprovalProcessPending( opp.Id );
        System.assertEquals( 0, totalApprovalProcessPending );

        Test.startTest();

        CustomApprovalProcessRequest.ApprovalParam param = new CustomApprovalProcessRequest.ApprovalParam();
        param.recordId = opp.Id;
        param.action = 'Approve';
        param.comments = 'Approved by custom method';
        params.add( param );
        
        results = CustomApprovalProcessRequest.request( params );

        Test.stopTest();
        
        System.assertEquals( 'Approval process not found for this record!', results[0].message );
    }

    private static Integer obtainAmountApprovalProcessPending( Id recordId ){
        return [ SELECT COUNT()
            FROM ProcessInstanceWorkitem
            WHERE ProcessInstance.TargetObjectId =: recordId
            AND ProcessInstance.Status = 'Pending'
        ];
    }
}