/**
 * Copyright Alex Santos
 * The MIT License (MIT)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */
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