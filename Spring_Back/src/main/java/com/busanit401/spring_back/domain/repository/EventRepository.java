package com.busanit401.spring_back.domain.repository;

import com.busanit401.spring_back.domain.entity.Event;
import com.busanit401.spring_back.domain.User; // User 엔티티 import
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface EventRepository extends JpaRepository<Event, Long> {

    // 💡 변경점: findByMid 대신 연관관계 객체인 writer를 사용하여 조회
    // 이제 특정 유저(User 객체)가 작성한 행사 목록을 최신순으로 가져옵니다.
    List<Event> findByWriterOrderByRegDateDesc(User writer);
}