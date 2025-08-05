public class FieldPopulationCalculator{

@InvocableMethod

public static void calculateFieldPopulation(List<String> input) {

if (input == null || input.isEmpty()) {

throw new IllegalArgumentException('Object API name must be provided as input.');

}

String objectApiName = input[0];

// Describe the object dynamically

Schema.SObjectType objectType;

try {

objectType = (Schema.SObjectType)Schema.getGlobalDescribe().get(objectApiName);

} catch (Exception e) {

throw new IllegalArgumentException('Invalid Object API name: ' + objectApiName);

}

// Get all fields for the object

Map<String, Schema.SObjectField> objectFields = objectType.getDescribe().fields.getMap();

// Query all records for the given object dynamically including specific fields

List<String> fieldNames = new List<String>(objectFields.keySet());

String query = 'SELECT ' + String.join(fieldNames, ', ') + ' FROM ' + objectApiName;

List<SObject> records = Database.query(query);

// Count the total number of records

Integer totalRecordCount = records.size();

if (totalRecordCount == 0) {

// If no records exist, log and exit

System.debug('No records found for object ' + objectApiName + '. Exiting population calculation.');

return;

}

// Map to store field population counts

Map<String, Integer> fieldPopulationCounts = new Map<String, Integer>();

// Initialize the map with field names and zero counts

for (String fieldName : fieldNames) {

fieldPopulationCounts.put(fieldName, 0);

}

// Iterate through records to count populated fields dynamically

for (SObject record : records) {

for (String fieldName : fieldNames) {

Object fieldValue = record.get(fieldName);

if (fieldValue != null) {

fieldPopulationCounts.put(fieldName, fieldPopulationCounts.get(fieldName) + 1);

}

}

}

// Prepare Field_Population__c records for insert or update

List<Field_Population__c> fieldPopulationRecords = new List<Field_Population__c>();

List<Field_Population__c> existingRecords = [SELECT Id, Field_Name__c, ExternalId__c FROM Field_Population__c WHERE Object__c = :objectApiName];

Map<String, Field_Population__c> existingRecordsMap = new Map<String, Field_Population__c>();

for (Field_Population__c record : existingRecords) {

existingRecordsMap.put(record.ExternalId__c, record);

}

for (String fieldName : fieldPopulationCounts.keySet()) {

Integer populatedCount = fieldPopulationCounts.get(fieldName);

Decimal populationPercentage = ((Decimal) populatedCount / totalRecordCount) * 100;

String externalId = objectApiName + '-' + fieldName;

if (existingRecordsMap.containsKey(externalId)) {

// Update existing record

Field_Population__c existingRecord = existingRecordsMap.get(externalId);

existingRecord.Population_Percentage__c = populationPercentage;

fieldPopulationRecords.add(existingRecord);

} else {

// Create new record

Field_Population__c newRecord = new Field_Population__c(

Object__c = objectApiName,

Field_Name__c = fieldName,

Population_Percentage__c = populationPercentage,

ExternalId__c = externalId

);

fieldPopulationRecords.add(newRecord);

}

}

// Upsert Field_Population__c records using ExternalId__c

if (!fieldPopulationRecords.isEmpty()) {

upsert fieldPopulationRecords ExternalId__c;

}

System.debug('Field population calculation complete for object ' + objectApiName + ' and records inserted or updated.');

}

}