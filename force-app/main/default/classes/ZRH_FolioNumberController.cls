/*********************************************************************************
Project      : Zurich Salesforce - Seguros Colectivos
Created By   : Deloitte
Created Date : 18/10/2023
Description  : Class responsible to the Folio Number Controller (Reserva de Folio)
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdon Tejos O			    ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            	Description
1.0      ATO            18/10/2023		   	Created Class
********************************************************************************/
public with sharing class ZRH_FolioNumberController {

   /**
   *  @Description: Initialization of static variables
   *  @Autor:       Andrés Deus, Deloitte, adeusme@deloitte.com
   *  @Date:        20/10/2023
   */
   private static final String INTEGRATION_BASE;
   private static final String INTEGRATION_ROUTE;
   private static final String INTEGRATION_ORIGEN;

   /**
   *  @Description: Initialization of static variables
   *  @Autor:       Andrés Deus, Deloitte, adeusme@deloitte.com
   *  @Date:        20/10/2023
   */
   static {
      INTEGRATION_BASE = 'ZRH_SegurosColectivos';
      INTEGRATION_ROUTE = 'ZRH_ConsultaFolio';
      INTEGRATION_ORIGEN = 'P002';
   }

   /**
   *  @Description: Constructor
   *  @Author:      Andrés Deus, Deloitte, adeusme@deloitte.com
   *  @Date:        20/10/2023         
   */
   public ZRH_FolioNumberController(){
   }

   /**
   *  @Description: FolioNumber json mapping
   *  @Author:      Andrés Deus, Deloitte, adeusme@deloitte.com
   *  @Date:        20/10/2023  
   */
   private ZRH_JSONFolioNumber.Request mapping(Integer range) {
      ZRH_JSONFolioNumber.Request request = new ZRH_JSONFolioNumber.Request();
      request.origen = INTEGRATION_ORIGEN;
      request.cantidad = range;
      return request;
   }

   /**
   *  @Description: Service Call
   *  @Author:      Andrés Deus, Deloitte, adeusme@deloitte.com
   *  @Date:        20/10/2023  
   */
   private HttpResponse call(Integer range) {
      ZRH_RestConnection objClass = new ZRH_RestConnection(INTEGRATION_BASE, INTEGRATION_ROUTE);
      return objClass.callService(JSON.serialize(mapping(range), true));
   }

   /**
   *  @Description: Response
   *  @Author:      Andrés Deus, Deloitte, adeusme@deloitte.com
   *  @Date:        20/10/2023  
   */
  public Map<String,Object> response(Integer range) {
   
   HttpResponse res = call(range);
   Integer statusCode = res.getStatusCode();
   List<String> folioNumbers = new List<String>();

   if (statusCode == 201) {
      
      ZRH_JSONFolioNumber.Response objRes = (ZRH_JSONFolioNumber.Response)ZRH_JSONFolioNumber.parseResponse(res.getBody());
   
      for(Integer i = objRes.folioInicial; i <= objRes.folioFinal; i++){
         String folioNumber = i + '-' + calculateVerificationDigit(String.valueOf(i));
         folioNumbers.add(folioNumber);
      }
   
      Map<String,Object> responseMap = new Map<String,Object>();
      responseMap.put('statusCode', statusCode);
      responseMap.put('folioNumbers', folioNumbers);
      return responseMap;
      
   } else {
      
      Map<String,Object> responseMap = new Map<String,Object>();
      responseMap.put('statusCode', statusCode);
      responseMap.put('folioNumbers', folioNumbers);
      return responseMap;
   }

}

   /**
   *  @Description: Method for calculating the verification digit based on modulus 10
   *  @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
   *  @Date:        19/10/2023
   */

   public Integer calculateVerificationDigit(String num) {
      Integer sum = 0;
      Boolean multiply = false;
      num += '0';

      for (Integer i = num.length() - 1; i >= 0; i--) {
         Integer dig = Integer.valueOf(num.substring(i, i + 1));

         if (multiply) {
            dig *= 2;
            if (dig > 9) {
                  dig = dig - 9;
            }
         }
         sum += dig;
         multiply = !multiply;
      }

      if (Math.mod(sum, 10) == 0) {
         return 0;
      } else {
         return 10 - Math.mod(sum, 10);
      }
   }

   /**
   *  @scription: Method to verify if the verification digit of the sent number is valid.
   *  @Autor:       Josue Aguilar, Deloitte, jaguilars@deloitte.com
   *  @Date:        19/10/2023
   */

   public Boolean verifyVerificationDigit(String num) {
      String dig = num.left(num.length() - 1);
      Integer verificationDigit = Integer.valueOf(num.right(1));
      Integer calculatedDigit = calculateVerificationDigit(dig);
      return calculatedDigit == verificationDigit;
   }

}