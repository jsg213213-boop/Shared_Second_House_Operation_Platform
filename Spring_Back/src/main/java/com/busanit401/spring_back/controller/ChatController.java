package com.busanit401.spring_back.controller;

import com.busanit401.spring_back.domain.User;
import com.busanit401.spring_back.domain.entity.ChatMessage;
import com.busanit401.spring_back.domain.entity.ChatRoom;
import com.busanit401.spring_back.domain.repository.ChatMessageRepository;
import com.busanit401.spring_back.domain.repository.ChatRoomRepository;
import com.busanit401.spring_back.domain.repository.UserRepository;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;
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

    @MessageMapping("/dm/chat/send")
    @Transactional
    public void sendMessage(MessageInboundDto messageDto) {

        ChatRoom room = chatRoomRepository.findById(messageDto.getChatRoomId())
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 채팅방입니다."));

        User sender = userRepository.findById(messageDto.getSenderId())
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 유저입니다."));

        ChatMessage chatMessage = ChatMessage.builder()
                .chatRoom(room)
                .sender(sender)
                .message(messageDto.getMessage())
                .build();
        chatMessageRepository.save(chatMessage);

        room.updateLastMessage(messageDto.getMessage(), LocalDateTime.now());

        messagingTemplate.convertAndSend("/topic/dm/room/" + messageDto.getChatRoomId(), messageDto);
    }

    @Getter
    @Setter
    public static class MessageInboundDto {
        private Long chatRoomId;
        private Long senderId;
        private String message;
    }
}