public class TestDouble {
    public static void main(String[] args) {
        try {
            System.out.println(Double.parseDouble("d"));
        } catch(Exception e) {
            System.out.println("Exception: " + e.getClass().getName());
        }
    }
}
