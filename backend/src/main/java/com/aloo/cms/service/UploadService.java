package com.aloo.cms.service;

import com.aloo.cms.dto.UploadResponse;
import com.aloo.cms.exception.BadRequestException;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

@Service
public class UploadService {

    private static final Set<String> ALLOWED_EXTENSIONS = Set.of("jpg", "jpeg", "png", "webp", "gif");
    private static final Map<String, Set<String>> ALLOWED_CONTENT_TYPES = Map.of(
            "jpg", Set.of("image/jpeg"),
            "jpeg", Set.of("image/jpeg"),
            "png", Set.of("image/png"),
            "webp", Set.of("image/webp"),
            "gif", Set.of("image/gif")
    );

    @Value("${app.upload.dir:uploads}")
    private String uploadDir;

    @Value("${app.upload.max-size-bytes:5242880}")
    private long maxUploadSizeBytes;

    public UploadResponse uploadImage(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BadRequestException("Image file is required");
        }
        if (file.getSize() > maxUploadSizeBytes) {
            throw new BadRequestException("Image file is too large");
        }

        String originalName = StringUtils.cleanPath(file.getOriginalFilename() == null ? "image" : file.getOriginalFilename());
        String extension = extensionOf(originalName);
        if (!ALLOWED_EXTENSIONS.contains(extension)) {
            throw new BadRequestException("Only jpg, jpeg, png, webp and gif images are allowed");
        }
        validateContentType(file, extension);
        validateMagicBytes(file, extension);

        String fileName = UUID.randomUUID() + "." + extension;
        Path targetDir = Path.of(uploadDir).toAbsolutePath().normalize();
        Path targetFile = targetDir.resolve(fileName).normalize();

        if (!targetFile.startsWith(targetDir)) {
            throw new BadRequestException("Invalid file name");
        }

        try {
            Files.createDirectories(targetDir);
            Files.copy(file.getInputStream(), targetFile, StandardCopyOption.REPLACE_EXISTING);
        } catch (IOException ex) {
            throw new BadRequestException("Could not upload image");
        }

        return new UploadResponse("/uploads/" + fileName, fileName, file.getSize());
    }

    private void validateContentType(MultipartFile file, String extension) {
        String contentType = file.getContentType();
        if (contentType == null || !ALLOWED_CONTENT_TYPES.get(extension).contains(contentType.toLowerCase())) {
            throw new BadRequestException("Image content type does not match file extension");
        }
    }

    private void validateMagicBytes(MultipartFile file, String extension) {
        byte[] header = new byte[12];
        int read;
        try (InputStream inputStream = file.getInputStream()) {
            read = inputStream.read(header);
        } catch (IOException ex) {
            throw new BadRequestException("Could not read image file");
        }

        boolean valid = switch (extension) {
            case "jpg", "jpeg" -> read >= 3
                    && (header[0] & 0xff) == 0xff
                    && (header[1] & 0xff) == 0xd8
                    && (header[2] & 0xff) == 0xff;
            case "png" -> read >= 8
                    && (header[0] & 0xff) == 0x89
                    && header[1] == 'P'
                    && header[2] == 'N'
                    && header[3] == 'G'
                    && header[4] == 0x0d
                    && header[5] == 0x0a
                    && header[6] == 0x1a
                    && header[7] == 0x0a;
            case "gif" -> read >= 6
                    && header[0] == 'G'
                    && header[1] == 'I'
                    && header[2] == 'F'
                    && header[3] == '8'
                    && (header[4] == '7' || header[4] == '9')
                    && header[5] == 'a';
            case "webp" -> read >= 12
                    && header[0] == 'R'
                    && header[1] == 'I'
                    && header[2] == 'F'
                    && header[3] == 'F'
                    && header[8] == 'W'
                    && header[9] == 'E'
                    && header[10] == 'B'
                    && header[11] == 'P';
            default -> false;
        };

        if (!valid) {
            throw new BadRequestException("Image file content is invalid");
        }
    }

    private String extensionOf(String fileName) {
        int dotIndex = fileName.lastIndexOf('.');
        if (dotIndex < 0 || dotIndex == fileName.length() - 1) {
            throw new BadRequestException("Image file extension is required");
        }
        return fileName.substring(dotIndex + 1).toLowerCase();
    }
}
