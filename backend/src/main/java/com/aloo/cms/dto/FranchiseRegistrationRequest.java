package com.aloo.cms.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;

public record FranchiseRegistrationRequest(
        @NotBlank(message = "Full name is required")
        @Size(max = 180, message = "Full name must be at most 180 characters")
        String fullName,

        @NotBlank(message = "Phone is required")
        @Pattern(regexp = "^[0-9+() .-]{8,40}$", message = "Phone is invalid")
        String phone,

        @Email(message = "Email is invalid")
        @Size(max = 180, message = "Email must be at most 180 characters")
        String email,

        @NotBlank(message = "Province is required")
        @Size(max = 120, message = "Province must be at most 120 characters")
        String province,

        @DecimalMin(value = "0.0", inclusive = true, message = "Expected budget must be greater than or equal to 0")
        BigDecimal expectedBudget,

        String note
) {
}
