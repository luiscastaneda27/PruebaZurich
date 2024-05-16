trigger ZRH_ContentDocumentLinkTrigger on ContentDocumentLink (before insert, after insert, before update, after update, before delete, after delete) {
    fflib_SObjectDomain.triggerHandler(ZRH_ContentDocumentLinks.class);
}