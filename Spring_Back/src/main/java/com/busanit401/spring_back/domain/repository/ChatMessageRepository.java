package com.busanit401.spring_back.domain.repository;

// 수정 전: import com.busanit401.spring_back.domain.ChatMessage;
// 수정 후:
import com.busanit401.spring_back.domain.entity.ChatMessage;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {
    List<ChatMessage> findByChatRoomIdOrderByIdAsc(Long chatRoomId);
}