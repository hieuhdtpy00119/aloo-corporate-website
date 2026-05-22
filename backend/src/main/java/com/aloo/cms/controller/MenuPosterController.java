package com.aloo.cms.controller;

import com.aloo.cms.dto.MenuPosterRequest;
import com.aloo.cms.dto.MenuPosterResponse;
import com.aloo.cms.service.MenuPosterService;
import jakarta.validation.Valid;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/menu-posters")
@RequiredArgsConstructor
public class MenuPosterController {

    private final MenuPosterService menuPosterService;

    @GetMapping
    public List<MenuPosterResponse> findAll() {
        return menuPosterService.findAll();
    }

    @GetMapping("/{id}")
    public MenuPosterResponse findById(@PathVariable Long id) {
        return menuPosterService.findById(id);
    }

    @PostMapping
    public ResponseEntity<MenuPosterResponse> create(@Valid @RequestBody MenuPosterRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(menuPosterService.create(request));
    }

    @PutMapping("/{id}")
    public MenuPosterResponse update(@PathVariable Long id, @Valid @RequestBody MenuPosterRequest request) {
        return menuPosterService.update(id, request);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        menuPosterService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
