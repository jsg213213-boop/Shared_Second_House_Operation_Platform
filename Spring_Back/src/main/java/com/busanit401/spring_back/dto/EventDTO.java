package com.busanit401.spring_back.dto;

import lombok.*;
import java.time.LocalDateTime;

@Data // Getter, Setter, toString 등을 포함하는 Lombok 어노테이션
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class EventDTO {

    private Long id;
    private String title;
    private String content;
    private String location;        // 💡 문의사항의 카테고리 대신 장소 추가

    // 💡 작성자 정보 매핑용 필드
    private Long writerId;          // 작성자 ID (PK)
    private String writerName;      // 작성자 닉네임 (화면 표시용)

    // 💡 행사 관리용 필드 추가
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    private int maxParticipants;

    private LocalDateTime regDate;
}