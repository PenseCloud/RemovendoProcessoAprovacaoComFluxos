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
public with sharing class CustomApprovalProcessRequest {

    @InvocableMethod
    public static List< ApprovalRequestResult > request( List< ApprovalParam > params ){
        List< ApprovalRequestResult > results = new List< ApprovalRequestResult >();
        List< Approval.ProcessResult > resultRequests;
        List< Approval.ProcessWorkitemRequest > approveRequests = new List< Approval.ProcessWorkitemRequest >();
        Map< Id, ApprovalParam > targetObjects = new Map< Id, ApprovalParam >();
        Set< Id > queuedObjects = new Set< id >();

        for( ApprovalParam param : params ){
            targetObjects.put( param.recordId, param );
        }

        List< ProcessInstanceWorkitem > workItens = [ SELECT Id,
            ProcessInstance.TargetObjectId
            FROM ProcessInstanceWorkitem
            WHERE ProcessInstance.TargetObjectId =: targetObjects.keySet()
            AND ProcessInstance.Status = 'Pending'
        ];

        for( ProcessInstanceWorkitem item : workItens ){
            if( !queuedObjects.contains( item.processInstance.TargetObjectId )){
                Approval.ProcessWorkitemRequest approveRequest = new Approval.ProcessWorkitemRequest();
    
                approveRequest.setWorkitemId( item.Id );
                approveRequest.setComments( 
                    targetObjects.get( item.ProcessInstance.TargetObjectId ).comments 
                );
                approveRequest.setAction( 
                    targetObjects.get( item.ProcessInstance.TargetObjectId ).action 
                );
                approveRequests.add( approveRequest );
                queuedObjects.add( item.ProcessInstance.TargetObjectId );
            }
            
        }

        resultRequests = Approval.process( approveRequests );

        for( Approval.ProcessResult resultRequest : resultRequests ){
            ApprovalRequestResult result = new ApprovalRequestResult();
            result.recordId = resultRequest.getEntityId();
            result.isSuccess = resultRequest.isSuccess();
            if( resultRequest.getErrors() != null ){
                List< String > errorMessages = new List< String >();
                for( Database.Error error : resultRequest.getErrors() ){
                    errorMessages.add( error.getMessage() );
                }
                result.errors = errorMessages;
            }
            results.add( result );
        }

        //create results for objects without a approval process pending
        for( ApprovalParam approval : targetObjects.values() ){
            if( !queuedObjects.contains(approval.recordId) ){
                ApprovalRequestResult result = new ApprovalRequestResult();
                result.recordId = approval.recordId;
                result.isSuccess = true;
                result.message = 'Approval process not found for this record!';

                results.add( result );
            }
        }

        return results;
    }

    public class ApprovalParam {
         
        @InvocableVariable( required = true )
        public String action;

        @InvocableVariable( required = true )
        public Id recordId;

        @InvocableVariable
        public String comments;
    }

    public class ApprovalRequestResult {
        
        @InvocableVariable
        public Id recordId;

        @InvocableVariable
        public Boolean isSuccess;

        @InvocableVariable
        public String message;

        @InvocableVariable
        public List< String > errors;
    }
}