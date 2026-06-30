package com.mycompany.tourism.utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;

public class DBConnection {
    private static final String DEFAULT_URL ="jdbc:mysql://localhost:3306/tour_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    private static final String DEFAULT_USER = "root";
    private static final String DEFAULT_PASS = "";
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new ExceptionInInitializerError("MySQL JDBC Driver not found");
        }
    }

    private static String lookupEnv(String name, String defaultValue) {
        try {
            Context env = (Context) new InitialContext().lookup("java:comp/env");
            String value = (String) env.lookup(name);
            if (value != null && !value.isBlank()) {
                return value;
            }
        } catch (NamingException ignored) {
        }
        return defaultValue;
    }

    public static Connection getConnection() throws SQLException {
        String url = lookupEnv("db/url", DEFAULT_URL);
        String user = lookupEnv("db/user", DEFAULT_USER);
        String pass = lookupEnv("db/password", DEFAULT_PASS);
        return DriverManager.getConnection(url, user, pass);
    }
}
