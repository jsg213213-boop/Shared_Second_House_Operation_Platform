package com.busanit401.spring_back.dto;

import lombok.*;
import java.util.List;

@Getter
@Builder
@NoArgsConstructor  // 👈 1. Jackson 역직렬화를 위한 기본 생성자 필수 추가
@AllArgsConstructor // 👈 2. @Builder와 @NoArgsConstructor를 함께 쓰기 위한 전체 생성자 필수 추가
public class ChatRoomCreateRequestDto {
    private String roomName;
    private List<Long> userIds;
}