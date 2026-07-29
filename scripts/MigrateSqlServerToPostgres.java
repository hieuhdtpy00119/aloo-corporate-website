import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.StringJoiner;

/**
 * One-time, transactional migration from the legacy SQL Server database to PostgreSQL.
 *
 * Required environment variables:
 *   SOURCE_DB_URL, SOURCE_DB_USERNAME, SOURCE_DB_PASSWORD
 *   TARGET_DB_URL, TARGET_DB_USERNAME, TARGET_DB_PASSWORD
 */
public final class MigrateSqlServerToPostgres {
    private static final List<String> TABLES = List.of(
            "users",
            "categories",
            "products",
            "posts",
            "franchise_registrations",
            "contact_messages",
            "stores",
            "testimonials",
            "franchise_contents",
            "hero_banners",
            "home_sections",
            "menu_posters",
            "brand_timelines",
            "audit_logs",
            "chat_sessions",
            "chat_messages",
            "product_reviews",
            "account_role_history",
            "post_images",
            "post_related_posts",
            "store_gallery",
            "store_business_hours",
            "store_menu_posters"
    );

    private MigrateSqlServerToPostgres() {
    }

    public static void main(String[] args) throws Exception {
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        Class.forName("org.postgresql.Driver");

        try (
                Connection source = DriverManager.getConnection(
                        required("SOURCE_DB_URL"),
                        required("SOURCE_DB_USERNAME"),
                        required("SOURCE_DB_PASSWORD")
                );
                Connection target = DriverManager.getConnection(
                        required("TARGET_DB_URL"),
                        required("TARGET_DB_USERNAME"),
                        required("TARGET_DB_PASSWORD")
                )
        ) {
            source.setReadOnly(true);
            target.setAutoCommit(false);

            try {
                truncateTarget(target);
                int totalRows = 0;
                for (String table : TABLES) {
                    int copied = copyTable(source, target, table);
                    totalRows += copied;
                    System.out.printf("%s: %d row(s)%n", table, copied);
                }
                resetIdentitySequences(target);
                target.commit();
                System.out.printf("Migration committed: %d total row(s).%n", totalRows);
            } catch (Exception exception) {
                target.rollback();
                throw exception;
            }
        }
    }

    private static void truncateTarget(Connection target) throws SQLException {
        StringJoiner tables = new StringJoiner(", ");
        TABLES.forEach(table -> tables.add(quote(table)));
        try (Statement statement = target.createStatement()) {
            statement.execute("TRUNCATE TABLE " + tables + " RESTART IDENTITY CASCADE");
        }
    }

    private static int copyTable(Connection source, Connection target, String table) throws SQLException {
        Set<String> targetColumns = targetColumns(target, table);

        try (
                Statement select = source.createStatement();
                ResultSet rows = select.executeQuery("SELECT * FROM dbo." + quoteSqlServer(table))
        ) {
            ResultSetMetaData metadata = rows.getMetaData();
            List<Integer> sourceIndexes = new ArrayList<>();
            List<String> columns = new ArrayList<>();

            for (int index = 1; index <= metadata.getColumnCount(); index++) {
                String column = metadata.getColumnLabel(index).toLowerCase(Locale.ROOT);
                if (targetColumns.contains(column)) {
                    sourceIndexes.add(index);
                    columns.add(column);
                }
            }

            if (columns.isEmpty()) {
                throw new SQLException("No shared columns found for table " + table);
            }

            String columnSql = columns.stream().map(MigrateSqlServerToPostgres::quote)
                    .reduce((left, right) -> left + ", " + right)
                    .orElseThrow();
            String placeholders = String.join(", ", java.util.Collections.nCopies(columns.size(), "?"));
            String insertSql = "INSERT INTO " + quote(table) + " (" + columnSql + ") VALUES (" + placeholders + ")";

            int count = 0;
            try (PreparedStatement insert = target.prepareStatement(insertSql)) {
                while (rows.next()) {
                    for (int parameter = 0; parameter < sourceIndexes.size(); parameter++) {
                        insert.setObject(parameter + 1, rows.getObject(sourceIndexes.get(parameter)));
                    }
                    insert.addBatch();
                    count++;
                    if (count % 250 == 0) {
                        insert.executeBatch();
                    }
                }
                insert.executeBatch();
            }
            return count;
        }
    }

    private static Set<String> targetColumns(Connection target, String table) throws SQLException {
        Set<String> columns = new HashSet<>();
        DatabaseMetaData metadata = target.getMetaData();
        try (ResultSet result = metadata.getColumns(null, "public", table, null)) {
            while (result.next()) {
                columns.add(result.getString("COLUMN_NAME").toLowerCase(Locale.ROOT));
            }
        }
        return columns;
    }

    private static void resetIdentitySequences(Connection target) throws SQLException {
        for (String table : TABLES) {
            if (!targetColumns(target, table).contains("id")) {
                continue;
            }
            String sql = """
                    SELECT setval(
                        pg_get_serial_sequence(?, 'id'),
                        COALESCE((SELECT MAX(id) FROM %s), 1),
                        EXISTS (SELECT 1 FROM %s)
                    )
                    """.formatted(quote(table), quote(table));
            try (PreparedStatement statement = target.prepareStatement(sql)) {
                statement.setString(1, "public." + table);
                statement.executeQuery().close();
            }
        }
    }

    private static String quote(String identifier) {
        return "\"" + identifier.replace("\"", "\"\"") + "\"";
    }

    private static String quoteSqlServer(String identifier) {
        return "[" + identifier.replace("]", "]]") + "]";
    }

    private static String required(String name) {
        String value = System.getenv(name);
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Missing environment variable: " + name);
        }
        return value;
    }
}
