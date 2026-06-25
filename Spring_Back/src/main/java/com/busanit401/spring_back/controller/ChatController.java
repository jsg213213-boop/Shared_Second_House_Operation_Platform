package com.busanit401.spring_back.controller;

import com.busanit401.spring_back.domain.entity.ChatMessage;
import com.busanit401.spring_back.domain.entity.ChatRoom;
import com.busanit401.spring_back.domain.User;
import com.busanit401.spring_back.domain.repository.ChatMessageRepository;
import com.busanit401.spring_back.domain.repository.ChatRoomRepository;
import com.busanit401.spring_back.domain.repository.UserRepository;
import lombok.*;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;

@Controller
@RequiredArgsConstructor
public class ChatController {

    private final SimpMessagingTemplate messagingTemplate;
    private final ChatMessageRepository chatMessageRepository;
    private final ChatRoomRepository chatRoomRepository;
    private final UserRepository userRepository;

    /**
     * 클라이언트가 /app/dm/chat/send 주소로 메시지를 보냈을 때 실행됩니다.
     */
    @MessageMapping("/dm/chat/send")
    @Transactional
    public void sendMessage(MessageInboundDto messageDto) {

        ChatRoom room = chatRoomRepository.findById(messageDto.getChatRoomId())
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 채팅방입니다."));

        User sender = userRepository.findById(messageDto.getSenderId())
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 유저입니다."));

        // 1. 메시지 객체 생성 후 DB 저장
        ChatMessage chatMessage = ChatMessage.builder()
                .chatRoom(room)
                .sender(sender)
                .message(messageDto.getMessage())
                .build();
        chatMessageRepository.save(chatMessage);

        // 2. 채팅방의 최신 메시지 정보 스냅샷 업데이트 (목록 최신화용)
        room.updateLastMessage(messageDto.getMessage(), LocalDateTime.now());

        // 3. 팀원 설정에 맞춰 /topic/dm/room/{방번호}를 구독 중인 유저들에게 실시간 전송
        messagingTemplate.convertAndSend("/topic/dm/room/" + messageDto.getChatRoomId(), messageDto);
    }

    // 컨트롤러 내부에서 임시로 사용할 메시지 수신용 DTO
    @Getter
    @Setter
    public static class MessageInboundDto {
        private Long chatRoomId;
        private Long senderId;
        private String message;
    }
}