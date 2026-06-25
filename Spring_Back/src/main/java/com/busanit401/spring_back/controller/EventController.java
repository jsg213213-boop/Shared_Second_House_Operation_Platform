package com.busanit401.spring_back.controller;

import com.busanit401.spring_back.domain.entity.Event; // Event 클래스는 대문자 시작 권장
import com.busanit401.spring_back.domain.service.EventService;
import com.busanit401.spring_back.dto.EventDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping("/api/events") // 경로 변경
@RequiredArgsConstructor
public class EventController {

    private final EventService eventService; // 서비스만 사용하세요

    // 1. 전체 행사 목록 조회 (또는 유저별 신청 목록)
    @GetMapping
    public ResponseEntity<List<EventDTO>> getEventList(Principal principal) {
        if (principal == null) {
            return ResponseEntity.status(401).build();
        }

        // 서비스 내부에서 로직을 처리하도록 변경
        List<EventDTO> list = eventService.getList(principal.getName());
        return ResponseEntity.ok(list);
    }

    // 2. 행사 등록 (관리자용 로직으로 확장 가능)
    @PostMapping
    public ResponseEntity<?> register(@RequestBody EventDTO eventDTO, Principal principal) {
        if (principal == null) {
            return ResponseEntity.status(401).body("로그인이 필요합니다.");
        }

        // DTO를 서비스로 넘겨서 처리 (컨트롤러는 가볍게 유지)
        Event savedEvent = eventService.register(eventDTO, principal.getName());
        return ResponseEntity.ok(savedEvent);
    }
}