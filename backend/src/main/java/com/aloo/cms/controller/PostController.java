package com.aloo.cms.controller;

import com.aloo.cms.dto.PostRequest;
import com.aloo.cms.dto.PostResponse;
import com.aloo.cms.security.AdminScopeChecker;
import com.aloo.cms.service.PostService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/posts")
@RequiredArgsConstructor
public class PostController {

    private final PostService postService;
    private final AdminScopeChecker adminScopeChecker;

    @GetMapping
    public List<PostResponse> findAll() {
        if (adminScopeChecker.has("content")) {
            return postService.findAll();
        }
        return postService.findPublished();
    }

    @GetMapping("/{id}")
    public PostResponse findById(@PathVariable Long id) {
        if (adminScopeChecker.has("content")) {
            return postService.findById(id);
        }
        return postService.findPublishedById(id);
    }

    @GetMapping("/slug/{slug}")
    public PostResponse findBySlug(@PathVariable String slug) {
        if (adminScopeChecker.has("content")) {
            return postService.findBySlug(slug);
        }
        return postService.findPublishedBySlug(slug);
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN') and @adminScope.has('content')")
    public ResponseEntity<PostResponse> create(@Valid @RequestBody PostRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(postService.create(request));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN') and @adminScope.has('content')")
    public PostResponse update(@PathVariable Long id, @Valid @RequestBody PostRequest request) {
        return postService.update(id, request);
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN') and @adminScope.has('content')")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        postService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
