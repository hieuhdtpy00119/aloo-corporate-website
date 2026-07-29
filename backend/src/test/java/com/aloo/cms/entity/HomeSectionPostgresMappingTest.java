package com.aloo.cms.entity;

import static org.assertj.core.api.Assertions.assertThat;

import jakarta.persistence.Column;
import jakarta.persistence.Lob;
import java.lang.reflect.Field;
import org.junit.jupiter.api.Test;

class HomeSectionPostgresMappingTest {

    @Test
    void descriptionUsesPostgresTextInsteadOfLargeObjectOid() throws NoSuchFieldException {
        Field description = HomeSection.class.getDeclaredField("description");
        Column column = description.getAnnotation(Column.class);

        assertThat(column).isNotNull();
        assertThat(column.columnDefinition()).isEqualTo("text");
        assertThat(description.getAnnotation(Lob.class)).isNull();
    }
}
