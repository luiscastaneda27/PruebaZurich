@isTest
public class ZRH_Product2Selector_TEST {
    @isTest
    private static void selectByProductCodeTest() {
        Product2 testHealthProduct = ZRH_DataFactory.createHealthProduct(false);
        testHealthProduct.ProductCode = '601';
        insert testHealthProduct;

        Test.startTest();
        List<Product2> prods = new ZRH_Product2Selector().selectByProductCode(testHealthProduct.ProductCode);
        Test.stopTest();

        System.assertEquals(1, prods.size());
    }
}