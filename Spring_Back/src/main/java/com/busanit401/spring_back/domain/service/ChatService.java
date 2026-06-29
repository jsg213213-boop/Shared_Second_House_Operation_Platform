package com.busanit401.spring_back.domain.service;

import com.busanit401.spring_back.domain.User;
import com.busanit401.spring_back.domain.entity.ChatMessage;
import com.busanit401.spring_back.domain.entity.ChatRoom;
import com.busanit401.spring_back.domain.entity.ChatRoomUser;
import com.busanit401.spring_back.domain.repository.ChatMessageRepository;
import com.busanit401.spring_back.domain.repository.ChatRoomRepository;
import com.busanit401.spring_back.domain.repository.ChatRoomUserRepository;
import com.busanit401.spring_back.domain.repository.UserRepository;
import com.busanit401.spring_back.dto.ChatRoomCreateRequestDto;
import com.busanit401.spring_back.dto.ChatRoomResponseDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ChatService {

    private final ChatRoomRepository chatRoomRepository;
    private final ChatRoomUserRepository chatRoomUserRepository;
    private final UserRepository userRepository;
    private final ChatMessageRepository chatMessageRepository;

    @Transactional
    public Long createChatRoom(ChatRoomCreateRequestDto dto) {
        ChatRoom chatRoom = ChatRoom.builder()
                .roomName(dto.getRoomName())
                .build();
        ChatRoom savedRoom = chatRoomRepository.save(chatRoom);

        for (Long userId : dto.getUserIds()) {
            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 유저입니다. ID: " + userId));

            ChatRoomUser chatRoomUser = ChatRoomUser.builder()
                    .chatRoom(savedRoom)
                    .user(user)
                    .build();
            chatRoomUserRepository.save(chatRoomUser);
        }

        return savedRoom.getId();
    }

    public List<ChatRoomResponseDto> getMyChatRooms(Long userId) {
        List<ChatRoomUser> myRooms = chatRoomUserRepository.findByUserId(userId);

        return myRooms.stream()
                .map(cru -> {
                    ChatRoom room = cru.getChatRoom();
                    return ChatRoomResponseDto.builder()
                            .chatRoomId(room.getId())
                            .roomName(room.getRoomName() != null ? room.getRoomName() : "1:1 대화방")
                            .lastMessage(room.getLastMessage())
                            .lastMessageAt(room.getLastMessageAt())
                            .build();
                })
                .sorted((o1, o2) -> {
                    if (o1.getLastMessageAt() == null) return 1;
                    if (o2.getLastMessageAt() == null) return -1;
                    return o2.getLastMessageAt().compareTo(o1.getLastMessageAt());
                })
                .collect(Collectors.toList());
    }

    public List<ChatMessage> getMessages(Long roomId) {
        return chatMessageRepository.findByChatRoomIdOrderByCreatedDateAsc(roomId);
    }
}