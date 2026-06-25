package com.busanit401.spring_back.domain.repository;

import com.busanit401.spring_back.domain.entity.ChatRoom ;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ChatRoomRepository extends JpaRepository<ChatRoom, Long> {
}