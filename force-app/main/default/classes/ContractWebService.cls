@RestResource(urlMapping='/Contracts/*')
global with sharing class ContractWebService {
    //Method to create contract from AXG
    @httpPost
    global static Id createContractFromAXG(String account, String status, Integer contractTerm) {
        Contract thisContract = new Contract(
            AccountId = account,
            Status = status,
            ContractTerm = contractTerm
        );
        insert thisContract;
        return thisContract.Id;
    }
    //Method to update contract from AXG
    @HttpPatch
    global static void updateContractFromAXG() {
        RestRequest request = RestContext.request;
        String contractId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        Contract thisContract = [SELECT Id FROM Contract WHERE Id = :contractId];
        // Deserialize the JSON string into name-value pairs
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(request.requestbody.tostring());
        // Iterate through each parameter field and value
        for(String fieldName : params.keySet()) {
            // Set the field and value on the Case sObject
            thisContract.put(fieldName, params.get(fieldName));
        }
        update thisContract;
    }
}