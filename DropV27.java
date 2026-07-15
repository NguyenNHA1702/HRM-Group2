import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

public class DropV27 {
    public static void main(String[] args) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://127.0.0.1:3306/hrm_db", "root", "123456");
            Statement stmt = conn.createStatement();
            stmt.executeUpdate("DROP TABLE IF EXISTS department_attendance_locks");
            stmt.executeUpdate("DELETE FROM flyway_schema_history WHERE version = '27'");
            System.out.println("V27 dropped successfully.");
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
