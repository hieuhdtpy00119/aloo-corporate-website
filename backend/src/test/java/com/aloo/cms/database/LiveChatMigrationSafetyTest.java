package com.aloo.cms.database;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.regex.Pattern;
import org.junit.jupiter.api.Test;

class LiveChatMigrationSafetyTest {

    private static final Pattern DESTRUCTIVE_SQL = Pattern.compile(
            "(?i)\\b(?:DROP\\s+TABLE|TRUNCATE\\s+TABLE|DELETE\\s+FROM)\\b"
    );

    @Test
    void everyManagedMigrationRejectsDestructiveSql() throws IOException {
        Path migrationDirectory = Path.of("src/main/resources/db/migration");
        List<Path> migrations;
        try (var paths = Files.list(migrationDirectory)) {
            migrations = paths.filter(path -> path.getFileName().toString().endsWith(".sql")).toList();
        }

        assertFalse(migrations.isEmpty(), "At least one managed migration is required");
        for (Path migration : migrations) {
            String sql = read(migration);
            assertFalse(
                    DESTRUCTIVE_SQL.matcher(sql).find(),
                    () -> migration.getFileName() + " must not contain destructive SQL"
            );
        }
    }

    @Test
    void postgresLiveChatMigrationIsIdempotent() throws IOException {
        String sql = read(Path.of("src/main/resources/db/migration/V20260625__create_live_chat_tables.sql"));

        assertFalse(DESTRUCTIVE_SQL.matcher(sql).find(), "Live-chat migration must not contain destructive SQL");
        assertTrue(sql.contains("CREATE TABLE IF NOT EXISTS chat_sessions"));
        assertTrue(sql.contains("CREATE TABLE IF NOT EXISTS chat_messages"));
    }

    private static String read(Path path) throws IOException {
        return Files.readString(path);
    }
}
