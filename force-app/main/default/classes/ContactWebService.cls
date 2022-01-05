@RestResource(urlMapping='/Contacts/*')
global with sharing class ContactWebService {
    //Method to create contact from AXG
    @HttpPost
    global static ID createContactFromAXG(String lastName, String firstName, String email, String phone) {
        List<Contact> contactsSF = [SELECT Id FROM Contact WHERE Email=:email];
        if (contactsSF.size() != 0) {
            return contactsSF[0].Id;
        } else {
            Contact thisContact = new Contact();
            thisContact.LastName = lastName;
            thisContact.FirstName = firstName;
            thisContact.Email = email;
            thisContact.Phone = phone;
            
            insert thisContact;
            return thisContact.Id;
        }
    }
    //Method to update contact from AXG
    @HttpPatch
    global static Contact updateContactFromAXG() {
        RestRequest request = RestContext.request;
        String contactId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        Contact thisContact = [SELECT Id FROM Contact WHERE Id = :contactId];
        // Deserialize the JSON string into name-value pairs
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(request.requestbody.tostring());
        // Iterate through each parameter field and value
        for(String fieldName : params.keySet()) {
            // Set the field and value on the Case sObject
            thisContact.put(fieldName, params.get(fieldName));
            if(fieldName == 'Email') {
                thisContact.put('Email_Heroku__c', params.get(fieldName));
            }
        }
        update thisContact;
        return thisContact;
    }
    //Method to unactive contact from AXG
    @HttpDelete
    global static void disableContactSF() {
        RestRequest request = RestContext.request;
        String contactId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        Contact thisContact = [SELECT Id, Active__c FROM Contact WHERE Id = :contactId];
        thisContact.Active__c = false;
        update thisContact;
    }
}
