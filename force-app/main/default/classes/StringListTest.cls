public class StringListTest {
    public static List<String> generateStringList(Integer numberOfStrings) {
        List<String> listOfStrings = new List<String>();
        
        for (Integer i = 0; i < numberOfStrings; i++) {
            listOfStrings.add('Test ' + i);
        }
        
        return listOfStrings;
    }
}