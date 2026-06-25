package com.busanit401.spring_back.dto;

import lombok.*;
import java.time.LocalDateTime;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatRoomResponseDto {
    private Long chatRoomId;
    private String roomName;
    private String lastMessage;
    private LocalDateTime lastMessageAt;
}