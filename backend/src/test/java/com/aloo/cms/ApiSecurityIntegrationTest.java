package com.aloo.cms;

import static org.hamcrest.Matchers.notNullValue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.options;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class ApiSecurityIntegrationTest {

    private static final String TEST_SECRET = "ALOO_Franchise_CMS_Test_Secret_Key_At_Least_32_Chars";

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void adminLoginReturnsJwtAndDoesNotLeakPasswordHash() throws Exception {
        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "email": "admin@aloo.vn",
                                  "password": "123456"
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token", notNullValue()))
                .andExpect(jsonPath("$.tokenType").value("Bearer"))
                .andExpect(jsonPath("$.user.email").value("admin@aloo.vn"))
                .andExpect(jsonPath("$.user.passwordHash").doesNotExist());
    }

    @Test
    void publicEndpointsAllowAnonymousRequests() throws Exception {
        mockMvc.perform(get("/api/products"))
                .andExpect(status().isOk());

        mockMvc.perform(post("/api/franchise-registrations")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "fullName": "Nguyen Van A",
                                  "phone": "0900123456",
                                  "email": "lead@example.com",
                                  "province": "TP.HCM",
                                  "expectedBudget": 300000000,
                                  "note": "Muon mo cua hang quan 1"
                                }
                                """))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id", notNullValue()))
                .andExpect(jsonPath("$.fullName").value("Nguyen Van A"))
                .andExpect(jsonPath("$.status").value("NEW"));
    }

    @Test
    void validationErrorsReturnFieldDetails() throws Exception {
        mockMvc.perform(post("/api/franchise-registrations")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "fullName": "",
                                  "phone": "abc",
                                  "province": ""
                                }
                                """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Validation failed"))
                .andExpect(jsonPath("$.details.fullName", notNullValue()))
                .andExpect(jsonPath("$.details.phone", notNullValue()))
                .andExpect(jsonPath("$.details.province", notNullValue()));
    }

    @Test
    void protectedAdminCrudRejectsMissingAndExpiredJwt() throws Exception {
        String productBody = productBody("jwt-required-" + System.nanoTime());

        mockMvc.perform(post("/api/products")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(productBody))
                .andExpect(status().isUnauthorized());

        mockMvc.perform(post("/api/products")
                        .header("Authorization", "Bearer " + expiredToken())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(productBody))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void validJwtAllowsAdminCrudAndMeEndpoint() throws Exception {
        String token = loginToken();
        String slug = "jwt-product-" + System.nanoTime();

        mockMvc.perform(get("/api/auth/me")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.email").value("admin@aloo.vn"));

        mockMvc.perform(post("/api/products")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(productBody(slug)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.slug").value(slug))
                .andExpect(jsonPath("$.name").value("Kem bo JWT test"));
    }

    @Test
    void adminRegistrationListAndStatusNeedJwt() throws Exception {
        mockMvc.perform(get("/api/franchise-registrations"))
                .andExpect(status().isUnauthorized());

        String token = loginToken();
        String createResponse = mockMvc.perform(post("/api/franchise-registrations")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "fullName": "Tran Thi B",
                                  "phone": "0900111222",
                                  "province": "Da Nang",
                                  "expectedBudget": 250000000
                                }
                                """))
                .andExpect(status().isCreated())
                .andReturn()
                .getResponse()
                .getContentAsString();

        long id = objectMapper.readTree(createResponse).get("id").asLong();

        mockMvc.perform(get("/api/franchise-registrations")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk());

        mockMvc.perform(patch("/api/franchise-registrations/{id}/status", id)
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"status\":\"CONTACTED\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("CONTACTED"));
    }

    @Test
    void missingResourceReturns404WithoutStackTrace() throws Exception {
        mockMvc.perform(get("/api/products/999999"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("Product not found"))
                .andExpect(jsonPath("$.trace").doesNotExist());
    }

    @Test
    void corsAllowsViteOrigin() throws Exception {
        mockMvc.perform(options("/api/products")
                        .header("Origin", "http://localhost:5173")
                        .header("Access-Control-Request-Method", "POST")
                        .header("Access-Control-Request-Headers", "Authorization,Content-Type"))
                .andExpect(status().isOk())
                .andExpect(header().string("Access-Control-Allow-Origin", "http://localhost:5173"));
    }

    private String loginToken() throws Exception {
        String response = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "email": "admin@aloo.vn",
                                  "password": "123456"
                                }
                                """))
                .andExpect(status().isOk())
                .andReturn()
                .getResponse()
                .getContentAsString();

        JsonNode json = objectMapper.readTree(response);
        return json.get("token").asText();
    }

    private String expiredToken() {
        Date now = new Date();
        return Jwts.builder()
                .subject("admin@aloo.vn")
                .claim("role", "ADMIN")
                .issuedAt(new Date(now.getTime() - 7_200_000))
                .expiration(new Date(now.getTime() - 3_600_000))
                .signWith(Keys.hmacShaKeyFor(TEST_SECRET.getBytes(StandardCharsets.UTF_8)))
                .compact();
    }

    private String productBody(String slug) {
        return """
                {
                  "name": "Kem bo JWT test",
                  "slug": "%s",
                  "description": "San pham tao tu integration test",
                  "price": 0,
                  "category": "Kem bo",
                  "status": "ACTIVE"
                }
                """.formatted(slug);
    }
}
