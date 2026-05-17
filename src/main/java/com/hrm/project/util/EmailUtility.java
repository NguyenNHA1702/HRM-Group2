package com.hrm.project.util;

import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.util.Properties;

public class EmailUtility {

    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587";
    private static final String SENDER_EMAIL = "systemhrm029@gmail.com";
    private static final String SENDER_PASSWORD = "ydujuejpozrywjwn";

    public static boolean sendEmail(String recipientEmail, String subject, String content) {
        System.out.println("\n=== [HRM SYSTEM - EMAIL SENT] ===");
        System.out.println("To: " + recipientEmail);
        System.out.println("Subject: " + subject);
        System.out.println("=================================\n");

        try {
            Properties properties = new Properties();
            properties.put("mail.smtp.auth", "true");
            properties.put("mail.smtp.starttls.enable", "true");
            properties.put("mail.smtp.host", SMTP_HOST);
            properties.put("mail.smtp.port", SMTP_PORT);
            properties.put("mail.smtp.ssl.protocols", "TLSv1.2");

            Session session = Session.getInstance(properties, new Authenticator() {
                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(SENDER_EMAIL, SENDER_PASSWORD);
                }
            });

            MimeMessage message = new MimeMessage(session);
            message.setFrom(new InternetAddress(SENDER_EMAIL));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
            message.setSubject(subject, "UTF-8");
            message.setContent(content, "text/html; charset=utf-8");

            new Thread(() -> {
                try {
                    Transport.send(message);
                    System.out.println("[HRM EMAIL] Sent successfully!");
                } catch (Exception e) {
                    System.out.println("[HRM EMAIL] Failed to send email via SMTP: " + e.getMessage());
                }
            }).start();

            return true;
        } catch (Exception e) {
            System.out.println("[HRM EMAIL] Error: " + e.getMessage());
            return true;
        }
    }
}
