package com.busanit401.spring_back.domain.service;

import com.busanit401.spring_back.domain.entity.Event;
import com.busanit401.spring_back.domain.User;
import com.busanit401.spring_back.domain.repository.EventRepository;
import com.busanit401.spring_back.domain.repository.UserRepository;
import com.busanit401.spring_back.dto.EventDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class EventService {

    private final EventRepository eventRepository;
    private final UserRepository userRepository;

    public List<EventDTO> getList(String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));

        List<Event> eventList = eventRepository.findByWriterOrderByRegDateDesc(user);

        return eventList.stream().map(event -> EventDTO.builder()
                .id(event.getId())
                .title(event.getTitle())
                .content(event.getContent())
                .location(event.getLocation())
                .writerName(event.getWriter().getNickname())
                .startDate(event.getStartDate())
                .endDate(event.getEndDate())
                .maxParticipants(event.getMaxParticipants())
                .regDate(event.getRegDate())
                .build()).collect(Collectors.toList());
    }

    @Transactional
    public Event register(EventDTO eventDTO, String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));

        Event event = Event.builder()
                .title(eventDTO.getTitle())
                .content(eventDTO.getContent())
                .location(eventDTO.getLocation())
                .writer(user)
                .startDate(eventDTO.getStartDate())
                .endDate(eventDTO.getEndDate())
                .maxParticipants(eventDTO.getMaxParticipants())
                .build();

        return eventRepository.save(event);
    }

    @Transactional
    public Event update(Long id, EventDTO eventDTO, String username) {
        Event event = eventRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("행사를 찾을 수 없습니다."));

        if (!event.getWriter().getUsername().equals(username)) {
            throw new IllegalArgumentException("수정 권한이 없습니다.");
        }

        event.updateEvent(
                eventDTO.getTitle(),
                eventDTO.getContent(),
                eventDTO.getLocation(),
                eventDTO.getStartDate(),
                eventDTO.getEndDate(),
                eventDTO.getMaxParticipants()
        );

        return event;
    }

    @Transactional
    public void delete(Long id, String username) {
        Event event = eventRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("행사를 찾을 수 없습니다."));

        if (!event.getWriter().getUsername().equals(username)) {
            throw new IllegalArgumentException("삭제 권한이 없습니다.");
        }

        eventRepository.delete(event);
    }
}