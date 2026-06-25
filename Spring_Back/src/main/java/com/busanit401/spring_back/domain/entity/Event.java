package com.busanit401.spring_back.domain.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "sh_Event") // 1. 요청하신 테이블명으로 변경
@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Event {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "event_id") // 2. PK 컬럼명을 명시
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String content;

    private String location; // 3. 행사 장소 필드 추가

    // 4. 작성자 정보 (User와 연관관계 설정)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User writer;

    private LocalDateTime startDate; // 행사 시작일
    private LocalDateTime endDate;   // 행사 종료일
    private int maxParticipants;    // 최대 모집 인원
    private LocalDateTime regDate;

    @PrePersist
    public void prePersist() {
        this.regDate = LocalDateTime.now();
    }

    // 행사 정보 수정용 비즈니스 메서드
    public void updateEvent(String title, String content, String location,
                            LocalDateTime startDate, LocalDateTime endDate, int maxParticipants) {
        this.title = title;
        this.content = content;
        this.location = location;
        this.startDate = startDate;
        this.endDate = endDate;
        this.maxParticipants = maxParticipants;
    }
}