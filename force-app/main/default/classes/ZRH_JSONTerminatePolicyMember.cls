/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 03/01/2024
Description  : JSON Class to map request for policy termination
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Mateo Long.              ML
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ML			03/01/2024		initial version
********************************************************************************/
global class ZRH_JSONTerminatePolicyMember {

    global class PolicyMember{
        public List<String> polizas;
        public String rut;
        public String rutTitular;
        //La fecha no puede ser mayor a hoy ya que la poliza va a quedar en estado cancelada, y no deberia quedar cancelada antes de que ocurra la fecha terminacion
        public Date fechaTerminacion;
    }
        
    global class PolicyMemberResponse{
        public Boolean exito;
        public String error;
        public List<String> polizasIndividuales;
        public List<String> participantesPolizas;
    }
}