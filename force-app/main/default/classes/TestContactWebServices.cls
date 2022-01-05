@isTest
private class TestContactWebServices {
    //Test to create contact who doesn't exist in SF from AXG
    @isTest static void testCreateContactDoesntExist() {
        //Call the method to test
        Id thisContactId = ContactWebService.createContactFromAXG('Test', 'Contact', 'exple@exple.com', '0102030405');

        //Verify the test
        System.assert(thisContactId != null);
        Contact thisContact = [SELECT Id, Email FROM Contact WHERE Id=:thisContactId];
        System.assert(thisContact != null);
        System.assertEquals('exple@exple.com', thisContact.Email);
    }
    //Test to try to create contact who already exist in SF from AXG
    @isTest static void testCreateContactAlreadyExist()  {
        //Call the method to test
        Id thisContactId1 = ContactWebService.createContactFromAXG('Test', 'Contact', 'exple@exple.com', '0102030405');
        //Recall the method to test with same param
        Id thisContactId2 = ContactWebService.createContactFromAXG('Test', 'Contact', 'exple@exple.com', '0102030405');

        //Verify the test
        System.assert(thisContactId1 != null);
        System.assert(thisContactId2 != null);
        System.assert(thisContactId1 == thisContactId2);
        List<Contact> thisContacts = [SELECT Id, Email, Email_Heroku__c FROM Contact WHERE Email='exple@exple.com'];
        System.assert(thisContacts != null);
        System.assertEquals('exple@exple.com', thisContacts[0].Email);
        System.assertEquals(1, thisContacts.size());
    }
    //Test to update contact with info from AXG
    @isTest static void testUpdateContact() {
        //Create a record of contact to test
        Id thisContactId = createTestContact();
        //Instantiate request
        RestRequest request = new RestRequest();
        request.requestURI = 'https://legarant6-dev-ed.my.salesforce.com/services/apexrest/Contacts/'+thisContactId;
        request.httpMethod = 'PATCH';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"email": "email.update@exemple.com"}');
        RestContext.request = request;
        //Update contact of existing contact
        Contact contactUpdate = ContactWebService.updateContactFromAXG();

        //Verify contact was update
        System.assert(contactUpdate != null);
        Contact thisContact = [SELECT Email, Email_Heroku__c FROM Contact WHERE Id=:thisContactId];
        System.assert(thisContact != null);
        System.assertEquals('email.update@exemple.com', thisContact.Email);
        System.assertEquals('email.update@exemple.com', thisContact.Email_Heroku__c);
    }
    //Test to unactive contact after delete from AXG
    @isTest static void testDisableContact() {
        //Create a record of contact to test
        Id thisContactId = createTestContact();
        //Instantiate request
        RestRequest request = new RestRequest();
        request.requestURI = 'https://legarant6-dev-ed.my.salesforce.com/services/apexrest/Contacts/'+thisContactId;
        request.httpMethod = 'GET';
        RestContext.request = request;
        //Disable contact
        ContactWebService.disableContactSF();

        //Verify the contact is disable and NOT delete
        Contact thisContact = [SELECT Active__c FROM Contact WHERE Id=:thisContactId];
        System.assert(thisContact != null);
        System.assertEquals(false, thisContact.Active__c);
    }
    //Helper method
    static Id createTestContact() {
        Contact contact = new Contact(
            LastName = 'Test',
            FirstName = 'Contact',
            Email = 'exple@exple.com',
            Phone = '0102030405'
        );
        insert contact;
        return contact.Id;
    }
}
