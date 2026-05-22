package com.aloo.cms.dto;

public record UploadResponse(
        String url,
        String fileName,
        long size
) {
}
