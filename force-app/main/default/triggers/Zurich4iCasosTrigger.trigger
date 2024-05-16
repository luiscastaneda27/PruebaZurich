trigger Zurich4iCasosTrigger on case (before insert, after insert) {

    if(Trigger.isInsert && Trigger.isBefore){

        //Zu4i_Cases.onBeforeInsert(trigger.new);

        // for(case c: trigger.new){
        //     if(Zurich4i_integraciones.existeContacto(c.ZU4i_rut__c )){
        //         Contact con = Zurich4i_integraciones.contacto(c.ZU4i_rut__c);
                
        //         c.ContactId = con.Id;
        //     }else{
        //         Contact co = new Contact();
        //         co.RecordTypeId = Zurich4i_integraciones.getRecord('Personal');
        //         co.LastName = c.SuppliedName;
        //         co.MobilePhone = c.SuppliedPhone;
        //         co.Email = c.SuppliedEmail;
        //         co.CC4i_RUT__c  = c.ZU4i_rut__c ;
        //         insert co;
                
        //         c.ContactId = co.Id;
        //         system.debug(Zurich4i_integraciones.existeUsuarioMensajeria(c.id));
        //     }
        // }
        // for(case c: trigger.new){
        //     if(Zurich4iIntegraciones.existeUsuarioMensajeria(c.AccountId)){
        //         MessagingEndUser um = [select id from MessagingEndUser where AccountId =: c.AccountId];
        //         c.Messaging_User__c = um.id;
        //     }
        //     else{
        //         c.Messaging_User__c = Zurich4iIntegraciones.creaUsuarioMensajeria(c.AccountId);
        //     }
        // }
    }

}