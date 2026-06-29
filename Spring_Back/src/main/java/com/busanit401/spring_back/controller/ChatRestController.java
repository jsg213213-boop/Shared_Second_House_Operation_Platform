package com.busanit401.spring_back.controller;

import com.busanit401.spring_back.domain.entity.ChatMessage;
import com.busanit401.spring_back.domain.service.ChatService;
import com.busanit401.spring_back.dto.ChatRoomCreateRequestDto;
import com.busanit401.spring_back.dto.ChatRoomResponseDto;
import lombok.*;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/dm")
public class ChatRestController {

    private final ChatService chatService;

    @PostMapping("/room")
    public ResponseEntity<Long> createRoom(@RequestBody ChatRoomCreateRequestDto dto) {
        Long roomId = chatService.createChatRoom(dto);
        return ResponseEntity.ok(roomId);
    }

    @GetMapping("/rooms/{userId}")
    public ResponseEntity<List<ChatRoomResponseDto>> getMyRooms(@PathVariable("userId") Long userId) {
        List<ChatRoomResponseDto> rooms = chatService.getMyChatRooms(userId);
        return ResponseEntity.ok(rooms);
    }

    @GetMapping("/room/{roomId}/messages")
    public ResponseEntity<List<ChatMessageResponseDto>> getMessages(@PathVariable Long roomId) {
        List<ChatMessage> messages = chatService.getMessages(roomId);
        List<ChatMessageResponseDto> result = messages.stream()
                .map(m -> ChatMessageResponseDto.builder()
                        .id(m.getId())
                        .chatRoomId(m.getChatRoom().getId())
                        .senderId(m.getSender().getId())
                        .senderName(m.getSender().getNickname())
                        .message(m.getMessage())
                        .createdDate(m.getCreatedDate())
                        .build())
                .collect(Collectors.toList());
        return ResponseEntity.ok(result);
    }

    @Getter
    @Builder
    @AllArgsConstructor
    @NoArgsConstructor
    public static class ChatMessageResponseDto {
        private Long id;
        private Long chatRoomId;
        private Long senderId;
        private String senderName;
        private String message;
        private LocalDateTime createdDate;
    }
}