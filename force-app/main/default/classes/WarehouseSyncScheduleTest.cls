@IsTest
public class WarehouseSyncScheduleTest {
    public static String CRON_EXP = '0 0 0 15 3 ? *';
    @IsTest
    static void testMethod1(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());

        String jobID = System.schedule('WarehouseSyncScheduleTest', CRON_EXP, new WarehouseSyncSchedule());
        Test.stopTest();
        List<Product2> equipList = [SELECT  ID, Warehouse_SKU__c FROM Product2];
        System.assertEquals(0, equipList.size());
    }
}