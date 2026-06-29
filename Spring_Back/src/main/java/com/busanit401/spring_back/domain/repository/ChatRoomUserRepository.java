package com.busanit401.spring_back.domain.repository;

import com.busanit401.spring_back.domain.entity.ChatRoomUser;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ChatRoomUserRepository extends JpaRepository<ChatRoomUser, Long> {
    List<ChatRoomUser> findByUserId(Long userId);
    boolean existsByChatRoomIdAndUserId(Long chatRoomId, Long userId);
}
