/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 27/09/2023
Description  : JSON Class to map request for policy creation
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Mateo Long                    ML
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ML			03/01/2024		initial version
********************************************************************************/
global class ZRH_JSONEnrollPolicyMember {
    
    global class PolicyMember{
        public String groupCensusId;
        public String groupClassId;
        public String relationshipToInsured;
        public String claveSincronizacion;
        public String firstName;
        public String lastName;
        public String name;
        public String rut;
        //null for primary members
        public String rutTitular;
        public String email;
        public String gender;
        public String street;
        public String city;
        public String state;
        public String postalCode;
        public String country;
        public Date birthdate;
        public String phoneNumber;
        public Decimal annualEligibleSalary;
        public String banco;
        public Decimal capital;
        public Decimal capitalVidaVoluntario;
        public String codigoMonedaRenta;
        public Date fechaConversionCapital;
        public String nivelEscolaridad;
        public Decimal numeroRentas;
        public Decimal valorRentaAsegurado;
        public String numeroTelefonoAlternativo;
        public Boolean omitirRequisitosAsegurabilidad;
        public String tipoCuentaBancaria;
        public String tipoMovimiento;
        public Decimal numeroCuentaBancaria;
        public Decimal valorMonedaConversion;
        public Date vigenciaHistorica;
        public Date policyStartDate;
        // policy numbers of policies member will be enrolled to
        public List<String> polizas;
    }
    
    global class PolicyMemberResponse{
        public Boolean exito;
        public String error;
        public List<String> cuentasPersonales;
        public List<String> miembrosNomina;
        public List<String> polizasIndividuales;
        public List<String> participantesPolizas;
    }
}