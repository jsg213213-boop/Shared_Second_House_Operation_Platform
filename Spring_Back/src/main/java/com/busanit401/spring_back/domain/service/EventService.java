package com.busanit401.spring_back.domain.service;

import com.busanit401.spring_back.domain.entity.Event;
import com.busanit401.spring_back.domain.entity.User;
import com.busanit401.spring_back.domain.repository.EventRepository;
import com.busanit401.spring_back.domain.repository.UserRepository; // 유저 리포지토리 필요
import com.busanit401.spring_back.dto.EventDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true) // 읽기 전용으로 설정하여 성능 최적화
public class EventService {

    private final EventRepository eventRepository;
    private final UserRepository userRepository; // 유저 정보를 찾기 위해 추가

    // 특정 사용자의 행사 목록 조회
    public List<EventDTO> getList(String email) {
        // 1. 이메일로 유저 객체 찾기
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));

        // 2. 해당 유저가 작성한 행사 목록 조회
        List<Event> eventList = eventRepository.findByWriterOrderByRegDateDesc(user);

        // 3. 엔티티를 DTO로 변환
        return eventList.stream().map(event -> EventDTO.builder()
                .id(event.getId())
                .title(event.getTitle())
                .content(event.getContent())
                .location(event.getLocation())
                .writerName(event.getWriter().getNickName()) // 작성자 닉네임
                .startDate(event.getStartDate())
                .endDate(event.getEndDate())
                .maxParticipants(event.getMaxParticipants())
                .regDate(event.getRegDate())
                .build()).collect(Collectors.toList());
    }

    // 행사 등록 로직 (추가 예정)
    @Transactional
    public Event register(EventDTO eventDTO, String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));

        Event event = Event.builder()
                .title(eventDTO.getTitle())
                .content(eventDTO.getContent())
                .location(eventDTO.getLocation())
                .writer(user) // 유저 객체 연결
                .startDate(eventDTO.getStartDate())
                .endDate(eventDTO.getEndDate())
                .maxParticipants(eventDTO.getMaxParticipants())
                .build();

        return eventRepository.save(event);
    }
}