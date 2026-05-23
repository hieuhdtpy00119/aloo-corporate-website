package com.aloo.cms;

import static org.assertj.core.api.Assertions.assertThat;

import com.aloo.cms.repository.AdminUserRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
@EnabledIfEnvironmentVariable(named = "RUN_SQLSERVER_IT", matches = "true")
class SqlServerJpaConnectionIT {

    @Autowired
    private AdminUserRepository adminUserRepository;

    @Test
    void connectsToConfiguredSqlServerThroughJpa() {
        assertThat(adminUserRepository.count()).isGreaterThanOrEqualTo(0);
    }
}
