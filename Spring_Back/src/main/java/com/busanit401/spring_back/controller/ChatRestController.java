package com.busanit401.spring_back.controller;

import com.busanit401.spring_back.domain.service.ChatService;
import com.busanit401.spring_back.dto.ChatRoomCreateRequestDto;
import com.busanit401.spring_back.dto.ChatRoomResponseDto;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/dm")
public class ChatRestController {

    private final ChatService chatService;

    /**
     * 1. 인스타 DM 스타일 채팅방 개설 API
     * POST http://localhost:8080/api/dm/room
     */
    @PostMapping("/room")
    public ResponseEntity<Long> createRoom(@RequestBody ChatRoomCreateRequestDto dto) {
        Long roomId = chatService.createChatRoom(dto);
        return ResponseEntity.ok(roomId);
    }

    /**
     * 2. 로그인한 유저의 채팅방 목록 조회 API (최신 메시지 순)
     * GET http://localhost:8080/api/dm/rooms/{userId}
     */
    @GetMapping("/rooms/{userId}")
    public ResponseEntity<List<ChatRoomResponseDto>> getMyRooms(@PathVariable("userId") Long userId) {
        List<ChatRoomResponseDto> rooms = chatService.getMyChatRooms(userId);
        return ResponseEntity.ok(rooms);
    }
}