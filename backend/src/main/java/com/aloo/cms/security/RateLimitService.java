package com.aloo.cms.security;

import com.aloo.cms.exception.RateLimitExceededException;
import java.time.Duration;
import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class RateLimitService {

    private final Map<String, Bucket> buckets = new ConcurrentHashMap<>();
    private final StringRedisTemplate redisTemplate;

    @Value("${app.rate-limit.backend:memory}")
    private String backend;

    public void check(String action, String key, int maxAttempts, Duration window) {
        String bucketKey = action + ":" + normalize(key);
        if ("redis".equalsIgnoreCase(backend)) {
            checkRedis(bucketKey, maxAttempts, window);
            return;
        }

        checkMemory(bucketKey, maxAttempts, window);
    }

    private void checkRedis(String bucketKey, int maxAttempts, Duration window) {
        String redisKey = "aloo:rate-limit:" + bucketKey;
        try {
            Long count = redisTemplate.opsForValue().increment(redisKey);
            if (count != null && count == 1) {
                redisTemplate.expire(redisKey, window);
            }

            if (count != null && count > maxAttempts) {
                throw new RateLimitExceededException("Too many requests. Please try again later.");
            }
        } catch (RateLimitExceededException ex) {
            throw ex;
        } catch (RuntimeException ex) {
            log.warn("Redis rate limit failed, falling back to in-memory bucket for {}", bucketKey, ex);
            checkMemory(bucketKey, maxAttempts, window);
        }
    }

    private void checkMemory(String bucketKey, int maxAttempts, Duration window) {
        Instant now = Instant.now();
        Bucket bucket = buckets.compute(bucketKey, (ignored, current) -> {
            if (current == null || now.isAfter(current.resetAt())) {
                return new Bucket(1, now.plus(window));
            }
            return new Bucket(current.count() + 1, current.resetAt());
        });

        if (bucket.count() > maxAttempts) {
            throw new RateLimitExceededException("Too many requests. Please try again later.");
        }
    }

    private String normalize(String value) {
        if (value == null || value.isBlank()) {
            return "unknown";
        }
        return value.trim().toLowerCase();
    }

    private record Bucket(int count, Instant resetAt) {
    }
}
