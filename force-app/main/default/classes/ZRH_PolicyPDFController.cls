/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 1/12/2023
Description  : class to submit policy PDF
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                            ACRONYM
Luis Enrique Castañeda.             LEC
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			17/11/2023		initial version
********************************************************************************/
global without sharing class ZRH_PolicyPDFController implements vlocity_ins.VlocityOpenInterface2, System.Callable  {

    private static final String METHOD_NAME_PDF = 'executeGeneratePDF';
    private static final String METHOD_NAME_PROPOSAL = 'executeSubmitProposal';
    private static final String VARIABLE_NAME = 'ContractHoldingId';
    private static final String VAR_NAME_ELIGI_REQ = 'EligibilityRequirements';
    private static final String TITLE_ELIGI_REQ = 'Requisitos de Asegurabilidad';
    private static final String NAME_ELIGI_REQ = 'Tabla Requisitos Asegurabilidad';
    private static final String VAR_NAME_RATE = 'Rates';
    private static final String TITLE_RATE = 'Tabla Prima/Tarifas';
    private static final String NAME_RATE = 'Tarifa';
    private static final String PVR_STR_TYPE = 'Rates';
    private static final String PVR_STR_CVRNAME = 'Nombre Cobertura';
    private static final String MAP_INPUT = 'input';
    private static final String MAP_OUTPUT = 'output';
    private static final String MAP_OPTIONS = 'options';
    private static final String RECORD_ID = 'recordId';
    private static final String OBJECT_API_NAME = 'objectApiName';
    private static final String OBJECT_CONTRACT= 'Contract';
    private static final String OBJECT_CONTRACT_GROUP_PLAN = 'ContractGroupPlan';
    private static final String QUERY_CONDITION_PDF = 'ZRH_Estado__c in (\'8\',\'9\',\'10\') and ZRH_TipoDeProducto__c = \'Product\' and Contract.ZRH_ContratoHolding__c = \'recordId\'';
    private static final String QUERY_CONDITION_CONTRACT = 'ContractId = \'recordId\' and ZRH_MensajeRespuestaPropuestaPoliza__c != null and ZRH_TipoDeProducto__c = \'Product\'';
    private static final String PVR_STR_AGE = 'Edades';
    private static final String PVR_STR_HASHTAG = '###';
    private static final String PVR_STR_START_PARAGRAPH = '<p>';
    private static final String PVR_STR_END_PARAGRAPH = '</p>';
    private static final String PVR_STR_LINE_BREAK = ' \n';
    private static final String GLOSS_TYPE_ANEXO = 'Anexos';
    private static final String POLICY_TYPE = 'Colectiva';
    private static final String ORIGIN_POLICY = 'Salesforce';
    private static final String SYSTEM_CODE = 'P002';
    private static final String RAW_FREQUENCY = 'Mensual';
    private static final String SPLIT_TEXT = '-';
    private static final String NO_TEXT = 'N';
    private static final Integer BATCH_SIZE = 1;
    private static final Set<String> PVR_SET_IDS_COVERAGE_RATE = new Set<String>{'83.0', '84.0', '85.0', '86.0', '88.0', '46.0'}; //Set the gloss IDs for the coverage table
    private static final Set<String> PVR_SET_IDS_RATES = new Set<String>{'141.0'}; // Set the gloss IDs for the rate table
    private static final Set<String> PVR_SET_IDS_ELIGIBILITY_REQUIREMENTS = new Set<String>{'151.0','152.0','153.0','157.0'}; // Set the gloss IDs for the Eligibility requirements table
    private static final Set<String> PVR_SET_IDS_MEDICAL_REQUIREMENTS = new Set<String>{'158.0'}; // Set the gloss IDs for the medical requirements table
    private static final Set<String> PVR_SET_IDS_SURCHARGE = new Set<String>{'143.0'}; // Set the gloss IDs for the Surcharge table
    private static final Set<String> PVR_SET_IDS_DEDUCTIBLES = new Set<String>{'114.0','130.0','131.0','132.0','136.0','137.0','140.0'}; // Set the gloss IDs for the Deductibles table
    private static final Set<String> PVR_SET_IDS_DEDUCTIBLES_SECTION = new Set<String>{'120.0','123.0','124.0','127.0','134.0'}; // Set the gloss IDs for the Deductibles By Section table
    private static final Set<String> PVR_SET_IDS_LIFE = new Set<String>{'500'};
    private static final Set<String> PVR_SET_IDS_LIFESCHOOLING = new Set<String>{'501'};
    private static final Set<String> PVR_SET_IDS_FAMILYPROTECTION = new Set<String>{'502'};
    private static final Set<String> PVR_SET_IDS_HEALTH = new Set<String>{'600', '601', '602', '603', '604', '605', '606'};
    private static final Set<String>PVR_SET_IDS_PERSONALACCIDENTS = new Set<String>{'700'};
    private static final Map<String, ZRH_ConfiguracionTraduccion__mdt> PVR_MAP_TRANSLATIONS = setTranslations();
    private static final Set<String> PVR_SET_CURRENCY = new Set<String>{'CLP', 'CLF'};
    private static final String PVR_CURRENCY_UF = 'UF';

    private static final String LIFE_SCHOLARSHIP_RATE = 'TarifaEscolaridad';
    private static final String TEXT_LEVEL_SCHOLARSHIP = 'Niveles';
    private static final String CODE_COVERAGE = 'CodigoCobertura';
    private static final String TEXT_COVERAGE_NAME_SCHOLARSHIP = 'NombreCobEsc';
    
    
    global Object invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        String recordId;
        String query;
        if (methodName == METHOD_NAME_PDF) {
            recordId = (String) input.get(VARIABLE_NAME);
            query = QUERY_CONDITION_PDF.replace(RECORD_ID, recordId);
            Database.executeBatch(new ZRH_BatchSubmitPolicyPDFAS400(query), BATCH_SIZE);
        }else if(methodName == METHOD_NAME_PROPOSAL){
            System.debug(JSON.serialize(input));
            recordId = (String) input.get(RECORD_ID);
            String objectApiName = (String) input.get(OBJECT_API_NAME);
            if(objectApiName == OBJECT_CONTRACT){
                query = QUERY_CONDITION_CONTRACT.replace(RECORD_ID, recordId);
            }else if(objectApiName == OBJECT_CONTRACT_GROUP_PLAN){
                 query = 'Id = \''  + recordId + '\''; 
            }
            Database.executeBatch(new ZRH_BatchSubmitPolicyProposalAS400(query), BATCH_SIZE);
        }
        return true;
    }

    // Implementation of call method for System.Callable
    global Object call(String methodName, Map<String, Object> params) {
        Map<String, Object> input = (Map<String, Object>) params.get(MAP_INPUT);
        Map<String, Object> output = (Map<String, Object>) params.get(MAP_OUTPUT);
        Map<String, Object> options = (Map<String, Object>) params.get(MAP_OPTIONS);
        return invokeMethod(methodName, input, output, options);
    }
                                   
    /**
    *  @Description: mapping policy fields
    *  @Autor:       Luis Castañeda, lcastanedad@deloitte.com
    *  @Date:        27/11/2023
    */                              
    public static ZRH_JSONPolicyPDF.PolicyPDF mapping(ContractGroupPlan objPol){
        
        ZRH_JSONPolicyPDF.PolicyPDF poliza = new ZRH_JSONPolicyPDF.PolicyPDF();
        ZRH_BatchSubmitPolicyProposalAS400.AttributeSelectedValues attr = 
            (ZRH_BatchSubmitPolicyProposalAS400.AttributeSelectedValues) JSON.deserialize(objPol.vlocity_ins_fsc__AttributeSelectedValues__c, ZRH_BatchSubmitPolicyProposalAS400.AttributeSelectedValues.class); 
        List<String> listFolio = String.isNotBlank(objPol.ZRH_Folio__c) ? objPol.ZRH_Folio__c.split(SPLIT_TEXT) : new List<String>();
        
        poliza.contractId = objPol.ContractId;
        poliza.poliza = Integer.valueOf(listFolio?.get(0));
        poliza.dvPoliza = Integer.valueOf(listFolio?.get(1));
        poliza.tipoPoliza = POLICY_TYPE;
        poliza.periodo = Integer.valueOf(objPol.ZRH_Periodo__c); 
        poliza.vigenciaInicial = convertInt(objPol.Contract.StartDate);
        poliza.vigenciaFinal = convertInt(objPol.Contract.vlocity_ins__EnrollmentEndDate__c);
        poliza.carencia = NO_TEXT; 
        poliza.corredor = objPol.Contract.ZRH_NombreCorredor__c;
        poliza.comision = String.valueOf(objPol.Contract.ZRH_ComisionCorredor__c);
        poliza.ejecutivo = objPol.Contract.SourceQuote.ZRH_EjecutivoPropietario__c;
        poliza.numeroCotizacion = objPol.Contract.SourceQuote.QuoteNumber;
        poliza.origen = ORIGIN_POLICY; 
        poliza.codigoSistema = SYSTEM_CODE;
        poliza.concideracionesEspeciales = '';
        poliza.asegurados = '';
        poliza.beneficiarios = '';
        poliza.pol = attr.POL;
        poliza.cad = new List<String>();
        if(attr.Cad != null){
         	poliza.cad.add(attr.Cad);   
        }
        for(ContractGroupPlan  covPol: objPol.ChildContractGroupPlans){
            covPol.vlocity_ins_fsc__AttributeSelectedValues__c = covPol.vlocity_ins_fsc__AttributeSelectedValues__c.replace('""', '0');
            ZRH_BatchSubmitPolicyProposalAS400.AttributeSelectedValues attrC = (ZRH_BatchSubmitPolicyProposalAS400.AttributeSelectedValues) JSON.deserialize(covPol.vlocity_ins_fsc__AttributeSelectedValues__c, ZRH_BatchSubmitPolicyProposalAS400.AttributeSelectedValues.class);
            if(String.isNotBlank(attrC.Cad) || String.isNotBlank(attrC.VidaCad)){
                poliza.Cad.add(String.isNotBlank(attrC.Cad) ? attrC.Cad : attrC.VidaCad);
            }
        }
        String suc = objPol.Contract.Account.ZRH_SucursalRecepcion__c;
        poliza.contratante = new ZRH_JSONPolicyPDF.Contratante();
        poliza.contratante.nombreContratante = objPol.Contract.Account.Name;
        poliza.contratante.rutContratante = objPol.Contract.Account.ZRH_Rut__c;
        poliza.contratante.grupoNegocios = objPol.Contract.ZRH_Holding__r.ZRH_CodigoGrupoNegocio__c + ' - ' +objPol.Contract.ZRH_Holding__r.Name;
        poliza.contratante.sucursal = String.isNotBlank(suc) ? Integer.valueOf(suc) : 1;
        poliza.contratante.subGrupo = '';
        poliza.contratante.direccion = objPol.Contract.Account.ShippingAddress != null ? String.valueOf(objPol.Contract.Account.ShippingAddress) : 'Sin dirección' ;
        poliza.contratante.comunaCiudad = objPol.Contract.Account.ShippingCity != null ? objPol.Contract.Account.ShippingCity : 'Sin ciudad';
        
        poliza.plan = new ZRH_JSONPolicyPDF.Plan();
        poliza.plan.CodigoPlan = Integer.valueOf(objPol.ZRH_CodigoProducto__c);
        poliza.plan.NombrePlan = objPol.vlocity_ins_fsc__Product2Id__r.Name;
        poliza.plan.FrecuenciaPagoPrima = attr.FrecPago; 
        poliza.plan.Moneda = PVR_SET_CURRENCY.contains(objPol.Contract.CurrencyIsoCode) ? PVR_CURRENCY_UF : objPol.Contract.CurrencyIsoCode;
        for(ContractGroupPlanGroupClass item: new ZRH_ContractGroupPlanGroupClassSelector().selectByContractGroupPlan(objPol.Id)){
            poliza.plan.Rol = item.GroupClass.Name;  
        }
        
        poliza.tarifa = new ZRH_JSONPolicyPDF.Tarifa();
        if(String.isNotBlank(objPol.ZRH_Tarifa__c)){
            ZRH_JSONRates objRates = ZRH_JSONRates.parse(objPol.ZRH_Tarifa__c);
            poliza.tarifa.idTipoTarifa = objRates.IdTipoTarifa;
            poliza.tarifa.nombreTarifa = mapTarifas().get(objRates.IdTipoTarifa);
        }
        
        poliza.TablasAntecedentesGrls = new ZRH_JSONPolicyPDF.TablasAntecedentesGrls(); 
        poliza.TablasAntecedentesGrls.tablas = new List<ZRH_JSONPolicyPDF.Tablas>(); 
        
        poliza.condicionParticular = new ZRH_JSONPolicyPDF.CondicionParticular(); 
        poliza.condicionParticular.articulos = new List<ZRH_JSONPolicyPDF.Articulos>();
        poliza.condicionParticular.anexos = new List<ZRH_JSONPolicyPDF.Anexos>(); 
        return mapGloss(objPol, poliza);
    }
    
     /**
    *  @Description: mapping policy gloss
    *  @Autor:       Luis Castañeda, lcastanedad@deloitte.com
    *  @Date:        27/11/2023
    */  
    public static ZRH_JSONPolicyPDF.PolicyPDF mapGloss (ContractGroupPlan cgp, ZRH_JSONPolicyPDF.PolicyPDF poliza){
        Map<Id, List<ContractGroupPlan>> mapCvr = new  Map<Id, List<ContractGroupPlan>>();
        
        cgp = ZRH_BatchSubmitPolicyProposalAS400.convertAttrb(cgp);
        mapCvr.put(cgp.Id, orderAttribute(cgp.ChildContractGroupPlans));
        
        List<ZRH_Glosas__c> glossList = new ZRH_GlosasSelector().selectByContractGroupPlan(cgp.Id);
        Decimal ordenCondc = 0;
        for(ZRH_Glosas__c g: glossList){
            ordenCondc = g.ZRH_LocalizacionCondicionado__c > ordenCondc ? g.ZRH_LocalizacionCondicionado__c : ordenCondc;
        }
        ordenCondc = Decimal.valueOf((Integer)ordenCondc) + 1;
        for(ZRH_Glosas__c g: glossList){
            ZRH_JSONGlossTables.TablasCondicionado conditioned = new ZRH_JSONGlossTables.TablasCondicionado();
            conditioned.ordenTabla = 1;
            conditioned.columnas = new List<ZRH_JSONGlossTables.Columnas>();
            conditioned.filas = new List<ZRH_JSONGlossTables.Filas>();
            
            ZRH_JSONPolicyPDF.Articulos art = new ZRH_JSONPolicyPDF.Articulos();
            ZRH_JSONPolicyPDF.Anexos anx = new ZRH_JSONPolicyPDF.Anexos ();
            
            anx.titulo = g.ZRH_Titulo__c;
            anx.nombre = g.ZRH_NombreArticulo__c;
            art.titulo = g.ZRH_Titulo__c;
            art.nombre = g.ZRH_NombreArticulo__c;
            
            
            art.ordenCondc = g.ZRH_LocalizacionCondicionado__c != null ? g.ZRH_LocalizacionCondicionado__c  : ordenCondc++;
            art.subTitulos = new List<ZRH_JSONPolicyPDF.SubTitulosA>();
            
            ZRH_JSONPolicyPDF.SubTitulosA subt = new ZRH_JSONPolicyPDF.SubTitulosA();
            ZRH_JSONPolicyPDF.SubTitulosA subtA = new ZRH_JSONPolicyPDF.SubTitulosA();
            g.ZRH_ContenidoGlosa__c = String.isNotBlank(g.ZRH_ContenidoGlosa__c) ? g.ZRH_ContenidoGlosa__c : '';
            subt.contenido = ((g.ZRH_ContenidoGlosa__c.replaceAll(PVR_STR_START_PARAGRAPH, '').replaceAll(PVR_STR_END_PARAGRAPH, PVR_STR_HASHTAG)).stripHtmlTags()).replaceAll(PVR_STR_HASHTAG, PVR_STR_LINE_BREAK);
            subt.contenido = subt.contenido != null && subt.contenido.length() > 2 &&subt.contenido.subString(subt.contenido.length() - 2, subt.contenido.length()) == PVR_STR_LINE_BREAK ? subt.contenido.subString(0, subt.contenido.length() - 2) : subt.contenido;
            subt.tablas = new List<ZRH_JSONPolicyPDF.TablasA>();
            subt.nombre = g.ZRH_NombreArticulo__c;
            Boolean flagTable = false;
            if(g.ZRH_ContieneTabla__c == true){
                if (PVR_SET_IDS_COVERAGE_RATE.contains(String.valueOf(g.ZRH_IDGlosa__c)) ) {
                    conditioned = mapCoverageRate(conditioned, mapCvr, g);
                    flagTable = true;
                } else if (PVR_SET_IDS_RATES.contains(String.valueOf(g.ZRH_IDGlosa__c))) {
                    conditioned = mapRates(conditioned, cgp);
                    flagTable = true;
				} else if (PVR_SET_IDS_ELIGIBILITY_REQUIREMENTS.contains(String.valueOf(g.ZRH_IDGlosa__c))){
                    conditioned = mapEligibilityRequirements(conditioned, cgp);
                    flagTable = true;
                } else if (PVR_SET_IDS_MEDICAL_REQUIREMENTS.contains(String.valueOf(g.ZRH_IDGlosa__c)) && !PVR_SET_IDS_PERSONALACCIDENTS.contains(g.ZRH_PlanDelContrato__r.ZRH_CodigoProducto__c)) {
                    conditioned = mapMedicalRequirements(conditioned, cgp);
                    flagTable = true;
                } else if (PVR_SET_IDS_SURCHARGE.contains(String.valueOf(g.ZRH_IDGlosa__c))) {
                    conditioned = mapSurcharge(conditioned, cgp);
                    flagTable = true;
                }else if (PVR_SET_IDS_DEDUCTIBLES.contains(String.valueOf(g.ZRH_IDGlosa__c))) {
                    conditioned = mapDeductibles(cgp);
                    flagTable = true;
                }else if (PVR_SET_IDS_DEDUCTIBLES_SECTION.contains(String.valueOf(g.ZRH_IDGlosa__c))) {
                    conditioned = mapDeductiblesBySection(cgp);
                    flagTable = true;
                }
                if(flagTable){
                    ZRH_JSONPolicyPDF.TablasA tab = new ZRH_JSONPolicyPDF.TablasA();
                    tab.TituloTabla = g.ZRH_Titulo__c;
                    tab.NombreTabla = g.ZRH_NombreArticulo__c;
                    tab.columnas = new List<ZRH_JSONPolicyPDF.Columnas>();
                    tab.FilaTabla = new List<ZRH_JSONPolicyPDF.Filas>();
                    List<String> nombreColumnaList = new List<String>();
                    Integer count = 0;
                    for(ZRH_JSONGlossTables.Columnas c: conditioned.columnas){
                        ZRH_JSONPolicyPDF.Columnas col = new ZRH_JSONPolicyPDF.Columnas();
                        col.nombre = c.nombreColumna;
                        if(!nombreColumnaList.contains(c.nombreColumna) && !PVR_SET_IDS_MEDICAL_REQUIREMENTS.contains(String.valueOf(g.ZRH_IDGlosa__c))){
                            nombreColumnaList.add(c.nombreColumna);
                            tab.columnas.add(col);
                        }else if(PVR_SET_IDS_MEDICAL_REQUIREMENTS.contains(String.valueOf(g.ZRH_IDGlosa__c))){
                            col.nombre = c.nombreColumna + ' '+conditioned.filas[0].datos[count].dato; 
                            nombreColumnaList.add(c.nombreColumna);
                            tab.columnas.add(col);
                            count++;
                        }
                    }
                    if(PVR_SET_IDS_MEDICAL_REQUIREMENTS.contains(String.valueOf(g.ZRH_IDGlosa__c))){
                        conditioned.filas.remove(0);
                    }
                    count = 0;
                    for(ZRH_JSONGlossTables.Filas f: conditioned.filas){
                        ZRH_JSONPolicyPDF.Filas ft = new ZRH_JSONPolicyPDF.Filas();
                        ft.datos = new List<ZRH_JSONPolicyPDF.Datos>();
                        for(ZRH_JSONGlossTables.Datos d: f.datos){
                            ZRH_JSONPolicyPDF.Datos da = new ZRH_JSONPolicyPDF.Datos();
                            da.dato = d.dato;
                            ft.datos.add(da);
                        }
                        Integer difTable = tab.columnas.size() - ft.datos.size();
                        for(Integer i = 0; i < difTable; i++){
                            ZRH_JSONPolicyPDF.Datos da = new ZRH_JSONPolicyPDF.Datos();
                            da.dato = '';
                            ft.datos.add(da);
                        }
                        while(ft.datos.size() > tab.columnas.size()){
                            ft.datos.remove(ft.datos.size() - 1);
                        }
                        tab.FilaTabla.add(ft);
                    }
                    if(tab.FilaTabla.size() > 0){
                        subt.tablas.add(tab);
                    }
                }
            }
            art.subTitulos.add(subt);
            anx.subTitulos = (List<ZRH_JSONPolicyPDF.SubTitulosA>) JSON.deserialize(JSON.serialize(art.subTitulos), List<ZRH_JSONPolicyPDF.SubTitulosA>.class) ;
            if(g.ZRH_NombreArticulo__c == GLOSS_TYPE_ANEXO){
                poliza.condicionParticular.anexos.add(anx);
            }else{
                poliza.condicionParticular.articulos.add(art);
            }
        }
        ZRH_JSONPolicyPDF.Tablas t = new ZRH_JSONPolicyPDF.Tablas();
        if(cgp.ZRH_AtributosRequisitosAsegurabilidad__c != null){
            t.tituloTabla = TITLE_ELIGI_REQ;
            t.nombreTabla = NAME_ELIGI_REQ;
            poliza.TablasAntecedentesGrls.tablas.add(orderGrl(t, cgp, VAR_NAME_ELIGI_REQ));
        }
        if(cgp.ZRH_Tarifa__c != null){
            t = new ZRH_JSONPolicyPDF.Tablas();
            t.tituloTabla = TITLE_RATE;
            t.nombreTabla = NAME_RATE;
            poliza.TablasAntecedentesGrls.tablas.add(orderGrl(t, cgp, VAR_NAME_RATE));
        }
        return poliza;
    }
    
    /**
    *  @Description: Generate General Records
    *  @Autor:       Luis Castañeda, lcastanedad@deloitte.com
    *  @Date:        27/11/2023
    */  
    public static ZRH_JSONPolicyPDF.Tablas orderGrl(ZRH_JSONPolicyPDF.Tablas t, ContractgroupPlan cgp, String method){
        ZRH_JSONGlossTables.TablasCondicionado conditioned = new ZRH_JSONGlossTables.TablasCondicionado();
        conditioned.ordenTabla = 1;
        conditioned.columnas = new List<ZRH_JSONGlossTables.Columnas>();
        conditioned.filas = new List<ZRH_JSONGlossTables.Filas>();
        if(method == VAR_NAME_ELIGI_REQ){
            conditioned = mapEligibilityRequirements(conditioned, cgp);
        }else if(method == VAR_NAME_RATE){
            conditioned = mapRates(conditioned, cgp);
        }
        t.columnas = new List<ZRH_JSONPolicyPDF.Columnas>();
        t.filas = new List<ZRH_JSONPolicyPDF.Filas>();
        for(ZRH_JSONGlossTables.Columnas c: conditioned.columnas){
            ZRH_JSONPolicyPDF.Columnas col = new ZRH_JSONPolicyPDF.Columnas();
            col.nombre = c.nombreColumna;
            t.columnas.add(col);
        } 
        for(ZRH_JSONGlossTables.Filas f: conditioned.filas){
            ZRH_JSONPolicyPDF.Filas ft = new ZRH_JSONPolicyPDF.Filas();
            ft.datos = new List<ZRH_JSONPolicyPDF.Datos>();
            for(ZRH_JSONGlossTables.Datos d: f.datos){
                ZRH_JSONPolicyPDF.Datos da = new ZRH_JSONPolicyPDF.Datos();
                da.dato = d.dato;
                ft.datos.add(da);
            }
            t.filas.add(ft);
        }
        return t;
    }
    
    /**
    *  @Description: Generate the Coverage table
    *  @Autor:       Luis Castañeda, lcastanedad@deloitte.com
    *  @Date:        27/11/2023
    */
    public static ZRH_JSONGlossTables.TablasCondicionado mapCoverageRate(ZRH_JSONGlossTables.TablasCondicionado conditioned, Map<Id, List<ContractGroupPlan>> mapCvr, ZRH_Glosas__c g) {
        Integer countColumns = 0;
        Map<String, ZRH_ConfiguracionTraduccion__mdt> trlMap1 =  new Map<String, ZRH_ConfiguracionTraduccion__mdt>();
        for (ContractGroupPlan cvr : mapCvr.get(g.ZRH_PlanDelContrato__c)) {
            ZRH_JSONGlossTables.Filas rows = new ZRH_JSONGlossTables.Filas();
            if (cvr.vlocity_ins_fsc__AttributeSelectedValues__c != null && ZRH_BatchSubmitPolicyProposalAS400.convertInt(cvr.ZRH_CodigoProducto__c) != null) {
                Map<String, Object> attrMap = (Map<String, Object>) JSON.deserializeUntyped(cvr.vlocity_ins_fsc__AttributeSelectedValues__c);
                if (countColumns == 0) {
                    ZRH_JSONGlossTables.Columnas columns = new ZRH_JSONGlossTables.Columnas();
                    columns.nombreColumna = PVR_STR_CVRNAME;
                    conditioned.columnas.add(columns);
                }
                rows.datos = new List<ZRH_JSONGlossTables.Datos>();
                ZRH_JSONGlossTables.Datos firstData = new ZRH_JSONGlossTables.Datos();
                firstData.dato = cvr.vlocity_ins_fsc__Product2Id__r.Name;
                rows.datos.add(firstData);
                for (String attr : attrMap.keySet()) {
                    if(PVR_SET_IDS_LIFESCHOOLING.contains(g.ZRH_PlanDelContrato__r.ZRH_CodigoProducto__c) && attr != 'VidaCAD'){
                        continue;
                    }
                    String attrProd = cvr.vlocity_ins_fsc__Product2Id__r.vlocity_ins__AttributeDefaultValues__c;
                    countColumns++;
                    
                    String order = PVR_MAP_TRANSLATIONS.containsKey(attr) ? toString(PVR_MAP_TRANSLATIONS.get(attr).ZRH_Orden__c) : null;
                    if (countColumns <= attrMap.keySet().size()) {
                        ZRH_JSONGlossTables.Columnas columns = new ZRH_JSONGlossTables.Columnas();
                        columns.nombreColumna = PVR_MAP_TRANSLATIONS.containsKey(attr) ? PVR_MAP_TRANSLATIONS.get(attr).ZRH_TraduccionFuncional__c : attr;
                        columns.orden = order;
                        if(PVR_MAP_TRANSLATIONS.containsKey(attr)){
                            conditioned.columnas.add(columns);
                        }
                    }
                    ZRH_JSONGlossTables.Datos data = new ZRH_JSONGlossTables.Datos();
                    data.dato = attrMap.get(attr) != null ? String.valueOf(attrMap.get(attr)) : '';
                    data.orden = order;
                    if(PVR_MAP_TRANSLATIONS.containsKey(attr)){
                            rows.datos.add(data);
                        }
                }
                rows.datos.sort();
                conditioned.filas.add(rows);
            }
        }
        conditioned.columnas.sort();
        conditioned.cantidadcolumnas = conditioned.columnas.size();
        conditioned.cantidadFilas = conditioned.filas.size();
        return conditioned;
    }

    /**
    *  @Description: Generate the Rates table
    *  @Autor:       Luis Castañeda, lcastanedad@deloitte.com
    *  @Date:        27/11/2023
    */    
    public static ZRH_JSONGlossTables.TablasCondicionado mapRates(ZRH_JSONGlossTables.TablasCondicionado conditioned, ContractGroupPlan cgp) {
        if (cgp.ZRH_Tarifa__c  != null) {
            if(PVR_SET_IDS_LIFESCHOOLING.contains(cgp.ZRH_CodigoProducto__c)){
                conditioned = mapRatesScholarShip(cgp);
            }else{
                ZRH_JSONRates objRates = ZRH_JSONRates.parse(cgp.ZRH_Tarifa__c);
                List<Object> items = (List<Object>) JSON.deserializeUntyped(getRateType(cgp.ZRH_CodigoProducto__c, objRates));
                conditioned = conversionTotable(items, conditioned, PVR_STR_TYPE);
            }
        }
        return conditioned;
    }

    /**
    *  @Description: Generate the Eligibility Requirements table
    *  @Autor:       Luis Castañeda, lcastanedad@deloitte.com
    *  @Date:        27/11/2023
    */    
    public static ZRH_JSONGlossTables.TablasCondicionado mapEligibilityRequirements(ZRH_JSONGlossTables.TablasCondicionado conditioned, ContractGroupPlan cgp) {
        if (cgp.ZRH_AtributosRequisitosAsegurabilidad__c  != null) {
            List<Object> items;
            if (PVR_SET_IDS_LIFE.contains(cgp.ZRH_CodigoProducto__c)) {
                List<ZRH_JSONEligibilityRequirements.Life> objRqm = (List<ZRH_JSONEligibilityRequirements.Life>)ZRH_JSONEligibilityRequirements.parseLife(cgp.ZRH_AtributosRequisitosAsegurabilidad__c);
                items = (List<Object>) JSON.deserializeUntyped(JSON.serialize(objRqm, true));
            } else if (PVR_SET_IDS_LIFESCHOOLING.contains(cgp.ZRH_CodigoProducto__c)) {
                List<ZRH_JSONEligibilityRequirements.LifeSchooling> objRqm = (List<ZRH_JSONEligibilityRequirements.LifeSchooling>)ZRH_JSONEligibilityRequirements.parseLifeSchooling(cgp.ZRH_AtributosRequisitosAsegurabilidad__c);
                items = (List<Object>) JSON.deserializeUntyped(JSON.serialize(objRqm, true));
            } else if (PVR_SET_IDS_FAMILYPROTECTION.contains(cgp.ZRH_CodigoProducto__c)) {
                List<ZRH_JSONEligibilityRequirements.FamilyProtection> objRqm = (List<ZRH_JSONEligibilityRequirements.FamilyProtection>)ZRH_JSONEligibilityRequirements.parseFamilyProtection(cgp.ZRH_AtributosRequisitosAsegurabilidad__c);
                items = (List<Object>) JSON.deserializeUntyped(JSON.serialize(objRqm, true));
            } else if (PVR_SET_IDS_HEALTH.contains(cgp.ZRH_CodigoProducto__c)) {
                List<ZRH_JSONEligibilityRequirements.Health> objRqm = (List<ZRH_JSONEligibilityRequirements.Health>)ZRH_JSONEligibilityRequirements.parseHealth(cgp.ZRH_AtributosRequisitosAsegurabilidad__c);
                items = (List<Object>) JSON.deserializeUntyped(JSON.serialize(objRqm, true));
            } else if (PVR_SET_IDS_PERSONALACCIDENTS.contains(cgp.ZRH_CodigoProducto__c)) {
                List<ZRH_JSONEligibilityRequirements.PersonalAccidents> objRqm = (List<ZRH_JSONEligibilityRequirements.PersonalAccidents>)ZRH_JSONEligibilityRequirements.parsePersonalAccidents(cgp.ZRH_AtributosRequisitosAsegurabilidad__c);
                items = (List<Object>) JSON.deserializeUntyped(JSON.serialize(objRqm, true));
            }
            conditioned = conversionTotable(items, conditioned, null);
        }
        return conditioned;
    }

    /**
    *  @Description: Generate the Medical Requirements table
    *  @Autor:       Luis Castañeda, lcastanedad@deloitte.com
    *  @Date:        27/11/2023
    */    
    public static ZRH_JSONGlossTables.TablasCondicionado mapMedicalRequirements(ZRH_JSONGlossTables.TablasCondicionado conditioned, ContractGroupPlan cgp) {
        String str = cgp.ZRH_AtributosReqMedicosSeleccionado__c;
        String rango2 = 'RangoEntre2';
        String rango3 = 'RangoEntre3';
        String rangoS = 'RangoSobre';
        if (str  != null) {
            ZRH_JSONMedicalRequirements.columns objColumns = (ZRH_JSONMedicalRequirements.columns)ZRH_JSONMedicalRequirements.parseColumns(str);
            ZRH_JSONMedicalRequirements.FirstRow objFirstRow = (ZRH_JSONMedicalRequirements.FirstRow)ZRH_JSONMedicalRequirements.parseFirstRow(str);
            ZRH_JSONMedicalRequirements.SecondRow objSecondRow = (ZRH_JSONMedicalRequirements.SecondRow)ZRH_JSONMedicalRequirements.parseSecondRow(str);
            ZRH_JSONMedicalRequirements.ThirdRow objThirdRow = (ZRH_JSONMedicalRequirements.ThirdRow)ZRH_JSONMedicalRequirements.parseThirdRow(str);
            List<Object> items = new List<Object>();
            objColumns.Rango = PVR_STR_AGE;
            List<String> field = new List<String>();
            Map<String, Object> colum = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(objColumns, true));
            colum.put(rango2, colum.get(rango2) != null ? colum.get(rango2) : '');
            colum.put(rango3, colum.get(rango3) != null ? colum.get(rango3) : '');
            colum.put(rangoS, colum.get(rangoS) != null ? colum.get(rangoS) : '');
            items.add((Object) colum);
            items.add((Object) JSON.deserializeUntyped(JSON.serialize(objFirstRow, true)));
            items.add((Object) JSON.deserializeUntyped(JSON.serialize(objSecondRow, true)));
            items.add((Object) JSON.deserializeUntyped(JSON.serialize(objThirdRow, true)));
            conditioned = conversionTotable(items, conditioned, null);
        }
        return conditioned;
    }

    /**
    *  @Description: Generate the Surcharge table
    *  @Autor:       Luis Castañeda, lcastanedad@deloitte.com
    *  @Date:        27/11/2023
    */    
    public static ZRH_JSONGlossTables.TablasCondicionado mapSurcharge(ZRH_JSONGlossTables.TablasCondicionado conditioned, ContractGroupPlan cgp) {
        String str = cgp.Contract.ZRH_AtributosSobreprimasSeleccionados__c;
        if (str  != null) {
            List<ZRH_JSONSurcharge> objSurcharge = (List<ZRH_JSONSurcharge>)ZRH_JSONSurcharge.parse(str);
            List<Object> items = (List<Object>) JSON.deserializeUntyped(JSON.serialize(objSurcharge, true));
            conditioned = conversionTotable(items, conditioned, null);
        }
        return conditioned;
    }

    /**
    *  @Description: Convert a JSON to a table
    *  @Autor:       Luis Castañeda, lcastanedad@deloitte.com
    *  @Date:        27/11/2023
    */    
    public static ZRH_JSONGlossTables.TablasCondicionado conversionTotable(List<Object> items, ZRH_JSONGlossTables.TablasCondicionado conditioned, String type) {
        Map<Integer, Map<String, Object>> itemsMap = new Map<Integer, Map<String, Object>>();
        Integer countKey = 0;
        for (Object instance : items){
            itemsMap.put(countKey, (Map<String, Object>)instance);
            countKey++;
        }
        if (type == PVR_STR_TYPE) {
            itemsMap.remove(itemsMap.size() - 1);
        }
        countKey = 0;
        for (Integer ik : itemsMap.keySet()) {
            ZRH_JSONGlossTables.Filas rows = new ZRH_JSONGlossTables.Filas();
            rows.datos = new List<ZRH_JSONGlossTables.Datos>();
            Map<String, Object> valuesMap = itemsMap.get(ik);
            for (String vk : valuesMap.keySet()){
                countKey++;
                String order = PVR_MAP_TRANSLATIONS.containsKey(vk) ? toString(PVR_MAP_TRANSLATIONS.get(vk).ZRH_Orden__c) : null;
                if (countKey <= valuesMap.keySet().size()) {
                    ZRH_JSONGlossTables.Columnas columns = new ZRH_JSONGlossTables.Columnas();
                    columns.nombreColumna = PVR_MAP_TRANSLATIONS.containsKey(vk) ? PVR_MAP_TRANSLATIONS.get(vk).ZRH_TraduccionFuncional__c : vk;
                    columns.orden = order; 
                    if(PVR_MAP_TRANSLATIONS.containsKey(vk)){
                        conditioned.columnas.add(columns);
                    }
                }
                ZRH_JSONGlossTables.Datos data = new ZRH_JSONGlossTables.Datos();
                data.dato = String.valueOf(valuesMap.get(vk));
                data.orden = order;
                if (PVR_MAP_TRANSLATIONS.containsKey(vk)) {
                   rows.datos.add(data);
                }
            }
            rows.datos.sort();
            conditioned.filas.add(rows);
        }
        List<ZRH_JSONGlossTables.Filas> filasList = new  List<ZRH_JSONGlossTables.Filas>();
        for(ZRH_JSONGlossTables.Filas item: conditioned.filas){
            if(conditioned.columnas.size() == item.datos.size()){
                ZRH_JSONGlossTables.Filas f = new ZRH_JSONGlossTables.Filas();
                f.datos = item.datos;
                filasList.add(f);
            }
        }
        
        conditioned.columnas.sort();
        conditioned.filas = filasList;
        conditioned.cantidadcolumnas = conditioned.columnas.size();
        conditioned.cantidadFilas = conditioned.filas.size();
        return conditioned;
    }
    
    /**
    *  @Description: Set the map for the translation of the tables
    *  @Autor:       Luis Castañeda, lcastanedad@deloitte.com
    *  @Date:        27/11/2023
    */    
    public static Map<String, ZRH_ConfiguracionTraduccion__mdt> setTranslations() {
        Map<String, ZRH_ConfiguracionTraduccion__mdt> trlMap =  new Map<String, ZRH_ConfiguracionTraduccion__mdt>();
        List<ZRH_ConfiguracionTraduccion__mdt> listTrl = new ZRH_ConfiguracionTraduccionesSelector().selectAll();
        for (ZRH_ConfiguracionTraduccion__mdt ct : listTrl){
            trlMap.put(ct.ZRH_Tag__c, ct);
        }
        return trlMap;
    }
    
    /**
    *  @Description: Convert DateTime field to Integer
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        17/11/2023  
    */
    public static Integer convertInt(Date dateConvert){
        try{
            String valueCero = '0';
            String dateString = String.valueOf(dateConvert.year());
            dateString +=  String.valueOf(dateConvert.month()).leftPad(2, valueCero);
            dateString += String.valueOf(dateConvert.day()).leftPad(2, valueCero);
            return Integer.valueOf(dateString);
        }catch(exception ex){
            return null;
        }
    }
    
    /**
    *  @Description: Converts an object to a String
    *  @Autor:       Luis Castañeda, Deloitte, lcastanedad@deloitte.com
    *  @Date:        29/09/2021
    */
    private static String toString(Object str){
        String res = str != Null ? String.valueOf(str) : null;
        return res;
    }
    
    /**
    *  @Description: Gets the JSON of rates depending on the plan
    *  @Autor:       Luis Castañeda, lcastanedad@deloitte.com
    *  @Date:        27/11/2023
    */    
    public static String getRateType(String prodCode, ZRH_JSONRates objRates) {
        String obj = '';
        if (prodCode.isNumeric() && Integer.valueOf(prodCode) >= 500 && Integer.valueOf(prodCode) <= 502 || Integer.valueOf(prodCode) == 700) {
            obj = JSON.serialize(objRates.TarifaVida, true);
        } else if (prodCode.isNumeric() && Integer.valueOf(prodCode) >= 600 && Integer.valueOf(prodCode) <= 606 ) {
            obj = JSON.serialize(objRates.TarifaSalud, true);
        }
        return obj;
    }
    
    /**
    *  @Description: Generate the Rates SCHOLARSHIP  table
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        8/1/2024 
    */    
    public static ZRH_JSONGlossTables.TablasCondicionado mapRatesScholarShip(ContractGroupPlan cgp) {
        ZRH_JSONGlossTables.TablasCondicionado response = new ZRH_JSONGlossTables.TablasCondicionado();
        response.columnas = new List<ZRH_JSONGlossTables.Columnas>();
        response.filas = new List<ZRH_JSONGlossTables.Filas>();
        ZRH_JSONGlossTables.Columnas c = new ZRH_JSONGlossTables.Columnas();
        c.nombreColumna = 'Cobertura';
        response.columnas.add(c);
        
        c = new ZRH_JSONGlossTables.Columnas();
        c.nombreColumna = 'Nivel';
        response.columnas.add(c);
        
        c = new ZRH_JSONGlossTables.Columnas();
        c.nombreColumna = 'Nᵒ Asegurados';
        response.columnas.add(c);
        
        c = new ZRH_JSONGlossTables.Columnas();
        c.nombreColumna = 'Capital Asegurado o UF';
        response.columnas.add(c);
        
        c = new ZRH_JSONGlossTables.Columnas();
        c.nombreColumna = 'Tasa Anual Propuesta ‰';
        response.columnas.add(c);
        
        c = new ZRH_JSONGlossTables.Columnas();
        c.nombreColumna = 'Tasa Mensual Propuesta ‰';
        response.columnas.add(c);
        
        c = new ZRH_JSONGlossTables.Columnas();
        c.nombreColumna = 'Prima Anual Propuesta UF';
        response.columnas.add(c);
        
        c = new ZRH_JSONGlossTables.Columnas();
        c.nombreColumna = 'Prima Mensual Propuesta UF';
        response.columnas.add(c);
        
        c = new ZRH_JSONGlossTables.Columnas();
        c.nombreColumna = 'Tasa Anual Vigente ‰';
        response.columnas.add(c);
        
        c = new ZRH_JSONGlossTables.Columnas();
        c.nombreColumna = 'Tasa Mensual Vigente ‰';
        response.columnas.add(c);
        
        c = new ZRH_JSONGlossTables.Columnas();
        c.nombreColumna = 'Prima Anual Vigente UF';
        response.columnas.add(c);
        
        c = new ZRH_JSONGlossTables.Columnas();
        c.nombreColumna = 'Prima Mensual Vigente UF';
        response.columnas.add(c);
        Map<String,Object> obj = (Map<String,Object>)((Object)System.JSON.deserializeUntyped(cgp.ZRH_Tarifa__c));
        List<Object> ratesList = (List<Object>) obj.get(LIFE_SCHOLARSHIP_RATE);
        for(Object taf: ratesList){
            Map<String,Object> tafMap = (Map<String,Object>)taf;
            if(tafMap.get(CODE_COVERAGE) != null){
                List<Object> listLevel = (List<Object>)tafMap.get(TEXT_LEVEL_SCHOLARSHIP);
                listLevel.remove(listLevel.size() - 1);
                for (Object o : listLevel) {
                    ZRH_JSONPolicyProposal.Escolaridad objVida = new ZRH_JSONPolicyProposal.Escolaridad();
                    Map<String,Object> dataNivel = (Map<String,Object>)o;
                    Escolridad esc = (Escolridad)System.JSON.deserialize(JSON.serialize(dataNivel), Escolridad.class);
                    
                    List<ZRH_JSONGlossTables.Datos> listDatos = new  List<ZRH_JSONGlossTables.Datos>();
                    ZRH_JSONGlossTables.Datos d = new  ZRH_JSONGlossTables.Datos();
                    d.dato = (String)tafMap.get('NombreCobEsc');
                    listDatos.add(d);
                    
                    d = new  ZRH_JSONGlossTables.Datos();
                    d.dato = esc.DescripcionNivel;
                    listDatos.add(d);
                    
                    d = new  ZRH_JSONGlossTables.Datos();
                    d.dato = esc.NAseguradosEsc;
                    listDatos.add(d);
                    
                    d = new  ZRH_JSONGlossTables.Datos();
                    d.dato = esc.CapAsegEsc;
                    listDatos.add(d);
					
					
					d = new  ZRH_JSONGlossTables.Datos();
                    d.dato = esc.TasaAnualEsc;
                    listDatos.add(d);
                    
                    d = new  ZRH_JSONGlossTables.Datos();
                    d.dato = esc.TasaMensualEsc;
                    listDatos.add(d);

					d = new  ZRH_JSONGlossTables.Datos();
                    d.dato = esc.PrimaAnualEsc;
                    listDatos.add(d);
                    
                    d = new  ZRH_JSONGlossTables.Datos();
                    d.dato = esc.PrimaMensualEsc;
                    listDatos.add(d);
					
					
					d = new  ZRH_JSONGlossTables.Datos();
                    d.dato = esc.TasaAnualVigenteEsc;
                    listDatos.add(d);
                    
                    d = new  ZRH_JSONGlossTables.Datos();
                    d.dato = esc.TasaMensualVigenteEsc;
                    listDatos.add(d);

					d = new  ZRH_JSONGlossTables.Datos();
                    d.dato = esc.PrimaAnualVigenteEsc;
                    listDatos.add(d);
                    
                    d = new  ZRH_JSONGlossTables.Datos();
                    d.dato = esc.PrimaMensualVigenteEsc;
                    listDatos.add(d);
                    
                    ZRH_JSONGlossTables.Filas fila = new ZRH_JSONGlossTables.Filas();
                    fila.datos = listDatos;
                    
                    response.filas.add(fila);
                }
            }
        }
        return response;
    }
    
    
    /**
    *  @Description: Generate the Deductibles  table
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        8/1/2024 
    */    
    public static ZRH_JSONGlossTables.TablasCondicionado mapDeductibles(ContractGroupPlan cgp) {
        ZRH_JSONGlossTables.TablasCondicionado response = new ZRH_JSONGlossTables.TablasCondicionado();
        response.columnas = new List<ZRH_JSONGlossTables.Columnas>();
        response.filas = new List<ZRH_JSONGlossTables.Filas>();
        ZRH_JSONGlossTables.Columnas c = new ZRH_JSONGlossTables.Columnas();
        c.nombreColumna = 'Grupo de Cobertura';
        response.columnas.add(c);
        c = new ZRH_JSONGlossTables.Columnas();
        c.nombreColumna = 'Deducible (UF)';
        response.columnas.add(c);
        c = new ZRH_JSONGlossTables.Columnas();
        c.nombreColumna = 'Máximo Deducible por Grupo Familiar (UF)';
        response.columnas.add(c);
        String valueZero = '0';
        Map<String, String> mapValues = getValuesPicklist('Product2' , 'ZRH_GrupoDeCobertura__c');
        for(ContractGroupPlan item: cgp.ChildContractGroupPlans){
            if(ZRH_BatchSubmitPolicyProposalAS400.convertInt(item.ZRH_CodigoProducto__c) == null){
                ZRH_BatchSubmitPolicyProposalAS400.AttributeSelectedValues attrC = 
                (ZRH_BatchSubmitPolicyProposalAS400.AttributeSelectedValues) JSON.deserialize(item.vlocity_ins_fsc__AttributeSelectedValues__c, ZRH_BatchSubmitPolicyProposalAS400.AttributeSelectedValues.class);
                if(attrC.Asegurado != null || attrC.NumMaxDedGrpFam != null){
                    List<ZRH_JSONGlossTables.Datos> listDatos = new  List<ZRH_JSONGlossTables.Datos>();
                    ZRH_JSONGlossTables.Datos d = new  ZRH_JSONGlossTables.Datos();
                    
                    d.dato = mapValues.get(item.ZRH_GrupoDeCobertura__c) ;
                    listDatos.add(d);
                    
                    d = new  ZRH_JSONGlossTables.Datos();
                    d.dato = attrC.Asegurado != null ? String.valueOf(attrC.Asegurado) : valueZero;
                    listDatos.add(d);
                    
                    d = new  ZRH_JSONGlossTables.Datos();
                    d.dato = attrC.NumMaxDedGrpFam  != null ? String.valueOf(attrC.NumMaxDedGrpFam) : valueZero;
                    listDatos.add(d);
                    
                    ZRH_JSONGlossTables.Filas fila = new ZRH_JSONGlossTables.Filas();
                    fila.datos = listDatos;
                    
                    response.filas.add(fila);
                }
            }
        }
        
        return response;
    }
    
    /**
    *  @Description: Generate the Deductibles  table
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        8/1/2024 
    */    
    public static ZRH_JSONGlossTables.TablasCondicionado mapDeductiblesBySection(ContractGroupPlan cgp) {
        ZRH_JSONGlossTables.TablasCondicionado response = new ZRH_JSONGlossTables.TablasCondicionado();
        response.columnas = new List<ZRH_JSONGlossTables.Columnas>();
        response.filas = new List<ZRH_JSONGlossTables.Filas>();
        ZRH_JSONGlossTables.Columnas c = new ZRH_JSONGlossTables.Columnas();
        c.nombreColumna = 'Tramo';
        response.columnas.add(c);
        String valueZero = '0';
        for(ContractGroupPlan item: cgp.ChildContractGroupPlans){
            if(ZRH_BatchSubmitPolicyProposalAS400.convertInt(item.ZRH_CodigoProducto__c) == null){
                c = new ZRH_JSONGlossTables.Columnas();
                c.nombreColumna = item.Name.replace('Deducible', '').capitalize();
                response.columnas.add(c);
            }
        }
        
        Map<String, String> mapField = new Map<String, String>();
        mapField.put('Asegurado', 'Asegurado');
        mapField.put('Empleado con una carga', 'EmpUnaCrg');
        mapField.put('Empleado con dos cargas', 'EmpDosCrgs');
        mapField.put('Empleado con dos o más cargas', 'EmpDosMasCrgs');
        mapField.put('Empleado con tres o más cargas', 'EmpTresMasCrgs');
        mapField.put('Empleado con tres cargas', 'EmpTresCrgs');
        mapField.put('Empleado con cuatro o más cargas', 'EmpCuatroMasCrgs');
        mapField.put('Empleado con cuatro cargas', 'EmpCuatroCrgs');
        mapField.put('Empleado con cinco o más cargas', 'EmpCincoMasCrgs');
        mapField.put('Número Máximo Deducible Grupo Familiar', 'NumMaxDedGrpFam');
        
        for(String field : mapField.keySet()){
            List<ZRH_JSONGlossTables.Datos> listDatos = new  List<ZRH_JSONGlossTables.Datos>();
            ZRH_JSONGlossTables.Datos d = new  ZRH_JSONGlossTables.Datos();
            ZRH_JSONGlossTables.Filas fila = new ZRH_JSONGlossTables.Filas();
            
            d.dato = field ;
            listDatos.add(d);
            
            String att = mapField.get(field);
            for(ContractGroupPlan item: cgp.ChildContractGroupPlans){
                if(ZRH_BatchSubmitPolicyProposalAS400.convertInt(item.ZRH_CodigoProducto__c) == null){
                    Map<String, Object>  attrC = (map<String, Object>) JSON.deserializeUntyped(item.vlocity_ins_fsc__AttributeSelectedValues__c);
                    
                    fila = new ZRH_JSONGlossTables.Filas();
                    d = new  ZRH_JSONGlossTables.Datos();
                    try{
                        d.dato = attrC.get(att) != null ? String.valueOf(attrC.get(att)) : valueZero;
                    }catch(exception e){
                        d.dato = attrC.get(att) != null ? (String) attrC.get(att) : valueZero;
                    }
                    listDatos.add(d);
                }
            }
            fila.datos = listDatos;
            response.filas.add(fila);
        }
        return response;
    }
    
    /**
    *  @Description: Gets values of PickList.
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        4/3/2024
    */
    public static Map<String, String> getValuesPicklist(String objectName, String fieldApiName){
        Map<String, String> mapValues = new Map<String, String>();
        SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        List<Schema.PicklistEntry> ple = objectType.getDescribe().fields.getMap().get(fieldApiName).getDescribe().getPickListValues();
        for(Schema.PicklistEntry entry : ple)  {
            mapValues.put(entry.getValue(), entry.getLabel());
        }
        return mapValues;
    }
    
    /**
    *  @Description: Order Attribute Coverage
    *  @Autor:       LEC, Deloitte, lcastanedad@deloitte.com
    *  @Date:        4/3/2024
    */
    public static List<ContractGroupPlan> orderAttribute(List<ContractGroupPlan> cvrList){
        List<String> allAttribute = new List<String>();
        for (ContractGroupPlan cvr : cvrList) {
            if (cvr.vlocity_ins_fsc__AttributeSelectedValues__c != null && ZRH_BatchSubmitPolicyProposalAS400.convertInt(cvr.ZRH_CodigoProducto__c) != null) {
                Map<String, Object> attrMap = (Map<String, Object>) JSON.deserializeUntyped(cvr.vlocity_ins_fsc__AttributeSelectedValues__c);
                for (String attr : attrMap.keySet()) {
                    if(!allAttribute.contains(attr) && attrMap.get(attr) != null){
                        allAttribute.add(attr);
                    }
                }
            }
        }
        
        for (Integer i = 0; i < cvrList.size(); i++) {
            if (cvrList[i].vlocity_ins_fsc__AttributeSelectedValues__c != null && ZRH_BatchSubmitPolicyProposalAS400.convertInt(cvrList[i].ZRH_CodigoProducto__c) != null) {
                Map<String, Object> attrMap = (Map<String, Object>) JSON.deserializeUntyped(cvrList[i].vlocity_ins_fsc__AttributeSelectedValues__c);
                Map<String, Object> attrMapOrd = new Map<String, Object>();
                for(String attr : allAttribute){
                    attrMapOrd.put(attr, attrMap.get(attr));
                }
                
                cvrList[i].vlocity_ins_fsc__AttributeSelectedValues__c = JSON.serialize(attrMapOrd);
                System.debug(cvrList[i].vlocity_ins_fsc__AttributeSelectedValues__c);
            }
        }
        return cvrList;
    }
    
    public static Map<String, String> mapTarifas(){
        Map<String, String> mapRates = new Map<String, String>();
        mapRates.put('1','POR TIPO DE INTEGRANTES');
        mapRates.put('2','POR NUMERO DE INTEGRANTES');
        mapRates.put('3','TARIFA PROMEDIO');
        mapRates.put('4','TARIFA ESCOLARIDAD');
        mapRates.put('6','TARIFA VIDA STANDARD');
        mapRates.put('7','NUMERO DE INTEGRANTES POR EDAD');
        mapRates.put('9','POR TIPO DE INTEGRANTES POR EDAD');
        return mapRates;
    }
    
    public class Escolridad{
        public String CapAsegEsc;
        public String NAseguradosEsc;
        public String PrimaAnualEsc;
        public String PrimaMensualVigenteEsc;
        public String TasaMensualEsc;
        public String DescripcionNivel;
        public String TasaAnualEsc;
        public String CodigoNivel;
        public String TasaAnualVigenteEsc;
        public String PrimaAnualVigenteEsc;
        public String TasaMensualVigenteEsc;
        public String PrimaMensualEsc;
    }
}