'use client';

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';

interface CartItem {
  id: number;
  name: string;
  price: number;
  quantity: number;
}

export default function CartPage() {
  const [, setRefresh] = useState(0);
  const router = useRouter();

  const getCartItems = (): CartItem[] => {
    if (typeof window === 'undefined') return [];
    const savedCart = localStorage.getItem('cart');
    try {
      const parsed = savedCart ? JSON.parse(savedCart) : [];
      return Array.isArray(parsed) ? parsed.map(item => ({
        ...item,
        price: Number(item.price) || 0,
        quantity: Number(item.quantity) || 1
      })) : [];
    } catch (e) {
      return [];
    }
  };

  const cartItems = getCartItems();
  
  const totalAmount = cartItems.reduce((sum, item) => sum + (Number(item.price) * Number(item.quantity)), 0);

  const handleQuantity = (id: number, delta: number) => {
    const currentCart = getCartItems();
    const updated = currentCart.map((item) =>
      item.id === id ? { ...item, quantity: Math.max(1, item.quantity + delta) } : item
    );
    localStorage.setItem('cart', JSON.stringify(updated));
    setRefresh((prev) => prev + 1);
  };

  const handleDelete = (id: number) => {
    const currentCart = getCartItems();
    const updated = currentCart.filter((item) => item.id !== id);
    localStorage.setItem('cart', JSON.stringify(updated));
    setRefresh((prev) => prev + 1);
  };

  // [수정된 주문하기 로직] 버튼이 먹통이 되지 않도록 비동기 처리 보강
  const handleOrder = async (e: React.MouseEvent) => {
  e.preventDefault();

  // 장바구니 데이터를 백엔드의 OrderItemDto 구조에 맞게 변환
  const orderItems = cartItems.map(item => ({
    product_id: item.id,
    price: item.price,
    quantity: item.quantity
    // name: item.name <- 이 줄을 지우세요!
}));
  
  const orderData = {
    user_id: 1004,
    delivery_address: "부산광역시 해운대구 센텀시티",
    total_amount: totalAmount,
    items: orderItems // 수정된 배열 전달
  };

    try {
      const response = await fetch('http://localhost:8080/api/orders', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(orderData),
      });

      if (response.ok) {
        alert("주문이 완료되었습니다!");
        localStorage.removeItem('cart');
        router.push('/delivery');
      } else {
        const errorText = await response.text();
        console.error("서버 응답 에러:", errorText);
        alert(`주문 실패: ${errorText || "서버 오류 발생"}`);
      }
    } catch (error) {
      console.error("주문 통신 에러:", error);
      alert("서버 연결에 실패했습니다. 서버가 실행 중인지 확인하세요.");
    }
  };

  return (
    <div style={{ padding: '24px' }}>
      <h1>🛒 장바구니</h1>
      {cartItems.length === 0 ? (
        <p>장바구니가 비어 있습니다.</p>
      ) : (
        <>
          {cartItems.map((item) => (
            <div key={item.id} style={{ borderBottom: '1px solid #ccc', padding: '15px 0', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div>
                <div style={{ fontWeight: 'bold' }}>{item.name}</div>
                <div style={{ fontSize: '14px', color: '#666' }}>가격: {Number(item.price).toLocaleString()}원</div>
              </div>
              <div>
                <button onClick={() => handleQuantity(item.id, -1)}>-</button>
                <span style={{ margin: '0 10px' }}>{item.quantity}</span>
                <button onClick={() => handleQuantity(item.id, 1)}>+</button>
                <button onClick={() => handleDelete(item.id)} style={{ marginLeft: '15px', color: 'red' }}>삭제</button>
              </div>
            </div>
          ))}
          <div style={{ marginTop: '20px', fontSize: '20px', fontWeight: 'bold' }}>
            총 결제 금액: {totalAmount.toLocaleString()}원
          </div>
          <button 
            onClick={handleOrder} 
            style={{ marginTop: '20px', padding: '12px 24px', backgroundColor: '#2E6F40', color: 'white', border: 'none', borderRadius: '8px', cursor: 'pointer', fontSize: '16px' }}
          >
            주문하기
          </button>
        </>
      )}
    </div>
  );
}