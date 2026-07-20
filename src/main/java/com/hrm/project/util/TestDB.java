package com.hrm.project.util;

import com.hrm.project.dao.impl.DBConnection;
import java.sql.Connection;
import java.sql.Statement;

public class TestDB {
    public static void main(String[] args) {
        System.out.println("=== CLEANING OLD NOTIFICATION TABLES ===");
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            
            System.out.println("Dropping user_notifications if exists...");
            stmt.executeUpdate("DROP TABLE IF EXISTS user_notifications");
            
            System.out.println("Dropping notifications if exists...");
            stmt.executeUpdate("DROP TABLE IF EXISTS notifications");

            System.out.println("Removing failed flyway migration V28...");
            stmt.executeUpdate("DELETE FROM flyway_schema_history WHERE version = '28'");
            
            System.out.println("Cleaned up old tables and flyway history successfully!");
            System.out.println("Please restart your application so Flyway can recreate the tables properly.");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
