package com.hrm.project.listener;

import org.flywaydb.core.Flyway;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

@WebListener
public class FlywayConfig implements ServletContextListener {
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        String dbName = "HRM_Group2";
        String masterUrl = "jdbc:sqlserver://localhost:1433;databaseName=master;encrypt=true;trustServerCertificate=true;";
        String user = "sa";
        String pass = "123"; // Mật khẩu của bạn

        try (Connection conn = DriverManager.getConnection(masterUrl, user, pass);
             Statement stmt = conn.createStatement()) {

            // Lệnh kiểm tra và tạo Database nếu chưa tồn tại
            stmt.executeUpdate("IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = '" + dbName + "') " +
                    "CREATE DATABASE " + dbName);

            // Sau khi có DB rồi mới chạy Flyway
            String dbUrl = "jdbc:sqlserver://localhost:1433;databaseName=" + dbName + ";encrypt=true;trustServerCertificate=true;";
            Flyway flyway = Flyway.configure().dataSource(dbUrl, user, pass).load();
            flyway.migrate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}