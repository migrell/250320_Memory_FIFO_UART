`timescale 1ns / 1ps

module uart_fifo_top (
    // 시스템 신호
    input wire clk,      // 시스템 클록
    input wire rst,      // 리셋 신호
    
    // UART 인터페이스
    input wire rx,       // UART RX 입력
    output wire tx       // UART TX 출력
);
    // 내부 연결 신호
    wire w_rx_done;      // RX 완료 신호
    wire [7:0] w_rx_data; // RX 데이터
    wire w_tick;         // 보드레이트 틱 신호
    wire w_tx_done;      // TX 완료 신호
    
    // 테스트벤치용 추가 신호
    reg btn_start = 1'b1;  // 시작 버튼 신호, 항상 활성화
    wire [7:0] rdata;      // 데이터 읽기 값
    wire rd;               // 읽기 신호
    
    // 내부 FIFO 신호
    wire [7:0] tx_fifo_rdata;    // TX FIFO 출력 데이터
    wire       tx_fifo_empty;    // TX FIFO 엠티 신호
    wire       tx_rd;            // TX FIFO 읽기 신호
    wire       tx_fifo_full;     // TX FIFO 풀 신호
    wire [7:0] rx_fifo_wdata;    // RX FIFO 입력 데이터
    wire       rx_fifo_full;     // RX FIFO 풀 신호
    wire       rx_wr;            // RX FIFO 쓰기 신호
    wire       rx_fifo_empty;    // RX FIFO 엠티 신호
    wire [7:0] rx_fifo_rdata;    // RX FIFO 읽기 데이터
    wire       w_rx_rd;          // RX FIFO 읽기 신호
    wire [7:0] tx_wdata;         // TX FIFO 입력 데이터
    wire       tx_wr;            // TX FIFO 쓰기 신호
    wire       tx_start;         // TX 시작 신호
    
    // 수정: UART RX에서 받은 데이터를 직접 rx_fifo_wdata에 연결
    assign rx_fifo_wdata = w_rx_data;
    
    // 테스트벤치용 신호 연결
    assign rdata = rx_fifo_rdata;
    assign rd = w_rx_rd;
    
    // 루프백 구현 - RX FIFO에서 읽은 데이터를 TX FIFO로 전달
    assign tx_wdata = rx_fifo_rdata;
    
    // 제어 로직 - 회로도에 맞게 수정
    // TX 부분
    assign tx_start = ~tx_fifo_empty;  // TX FIFO가 비어있지 않으면 전송 시작
    assign tx_rd = w_tx_done & ~tx_fifo_empty;  // TX 완료되고 FIFO가 비어있지 않으면 다음 데이터 읽기
    
    // RX 부분
    assign rx_wr = w_rx_done & ~rx_fifo_full;  // RX 완료되고 FIFO가 가득 차지 않았으면 데이터 쓰기
    
    // 수정: tx_wr 로직 - RX FIFO가 비어있지 않을 때만 TX FIFO에 쓰기
    assign tx_wr = ~rx_fifo_empty;
    
    // 수정: w_rx_rd 로직 - TX FIFO가 가득 차지 않았고 TX 쓰기가 활성화되었을 때만 RX FIFO에서 읽기
    assign w_rx_rd = tx_wr & ~tx_fifo_full;
    
    // FIFO TX 인스턴스
    FIFO u_fifo_tx (
        .clk(clk),
        .reset(rst),
        .wdata(tx_wdata),
        .wr(tx_wr),
        .rd(tx_rd),
        .rdata(tx_fifo_rdata),
        .full(tx_fifo_full),
        .empty(tx_fifo_empty)
    );
    
    // UART TX 모듈
    uart_tx U_uart_tx (
        .clk(clk),
        .rst(rst),
        .tick(w_tick),
        .start_trigger(tx_start),
        .data_in(tx_fifo_rdata),
        .o_tx_done(w_tx_done),
        .o_tx(tx)
    );
    
    // 보드레이트 생성기
    baud_tick_gen U_tick_gen (
        .clk(clk),
        .rst(rst),
        .baud_tick(w_tick)
    );
    
    // UART RX 모듈
    uart_rx u_UART_Rx (
        .clk(clk),
        .rst(rst),
        .tick(w_tick),
        .rx(rx),
        .rx_done(w_rx_done),
        .rx_data(w_rx_data)
    );
    
    // FIFO RX 인스턴스
    FIFO u_fifo_rx (
        .clk(clk),
        .reset(rst),
        .wdata(rx_fifo_wdata),
        .wr(rx_wr),
        .rd(w_rx_rd),
        .rdata(rx_fifo_rdata),
        .full(rx_fifo_full),
        .empty(rx_fifo_empty)
    );
endmodule


// `timescale 1ns / 1ps

// module uart_fifo_top (
//     // 시스템 신호
//     input wire clk,      // 시스템 클록
//     input wire rst,      // 리셋 신호
    
//     // UART 인터페이스
//     input wire rx,       // UART RX 입력
//     output wire tx       // UART TX 출력
// );
//     // 내부 연결 신호
//     wire w_rx_done;      // RX 완료 신호
//     wire [7:0] w_rx_data; // RX 데이터
//     wire w_tick;         // 보드레이트 틱 신호
//     wire w_tx_done;      // TX 완료 신호
    
//     // 테스트벤치에서 필요한 신호들
//     reg btn_start = 1'b1;  // 시작 버튼 신호, 항상 활성화
//     wire [7:0] rdata;      // FIFO 읽기 데이터 
//     wire rd;               // 읽기 신호
    
//     // 내부 FIFO 신호
//     wire [7:0] tx_fifo_rdata;    // TX FIFO 출력 데이터
//     wire       tx_fifo_empty;    // TX FIFO 엠티 신호
//     wire       tx_rd;            // TX FIFO 읽기 신호
//     wire       tx_fifo_full;     // TX FIFO 풀 신호
//     wire [7:0] rx_fifo_wdata;    // RX FIFO 입력 데이터
//     wire       rx_fifo_full;     // RX FIFO 풀 신호
//     wire       rx_wr;            // RX FIFO 쓰기 신호
//     wire       rx_fifo_empty;    // RX FIFO 엠티 신호
//     wire [7:0] rx_fifo_rdata;    // RX FIFO 읽기 데이터
//     wire       w_rx_rd;          // RX FIFO 읽기 신호
//     wire [7:0] tx_wdata;         // TX FIFO 입력 데이터
//     wire       tx_wr;            // TX FIFO 쓰기 신호
//     wire       tx_start;         // TX 시작 신호
    
//     // 이미지에서 보이는 추가 신호 연결
//     assign rdata = rx_fifo_rdata;  // RX FIFO 읽기 데이터
//     assign rd = w_rx_rd;           // RX FIFO 읽기 신호와 동일
    
//     // TOP_UART에서 사용했던 루프백 방식을 FIFO 기반으로 구현
//     // RX에서 수신한 데이터를 TX로 루프백
//     assign tx_wdata = rx_fifo_rdata;  // RX FIFO에서 읽은 데이터를 TX FIFO로 전달
//     assign tx_wr = ~rx_fifo_empty;    // RX FIFO가 비어있지 않으면 TX FIFO에 쓰기
//     assign w_rx_rd = tx_wr & ~tx_fifo_full; // TX FIFO가 가득 차지 않았을 때만 RX FIFO에서 읽기
    
//     // FIFO TX 인스턴스
//     FIFO u_fifo_tx (
//         .clk(clk),
//         .reset(rst),
//         .wdata(tx_wdata),
//         .wr(tx_wr),
//         .rd(tx_rd),
//         .rdata(tx_fifo_rdata),
//         .full(tx_fifo_full),
//         .empty(tx_fifo_empty)
//     );
    
//     // uart 모듈 기반 UART 구현
//     uart_tx U_uart_tx (
//         .clk(clk),
//         .rst(rst),
//         .tick(w_tick),
//         .start_trigger(tx_start),
//         .data_in(tx_fifo_rdata),
//         .o_tx_done(w_tx_done),
//         .o_tx(tx)
//     );
    
//     baud_tick_gen U_tick_gen (
//         .clk(clk),
//         .rst(rst),
//         .baud_tick(w_tick)
//     );
    
//     uart_rx u_UART_Rx (
//         .clk(clk),
//         .rst(rst),
//         .tick(w_tick),
//         .rx(rx),
//         .rx_done(w_rx_done),
//         .rx_data(w_rx_data)
//     );
    
//     // w_rx_data를 rx_fifo_wdata에 연결
//     assign rx_fifo_wdata = w_rx_data;
    
//     // FIFO RX 인스턴스
//     FIFO u_fifo_rx (
//         .clk(clk),
//         .reset(rst),
//         .wdata(rx_fifo_wdata),
//         .wr(rx_wr),
//         .rd(w_rx_rd),
//         .rdata(rx_fifo_rdata),
//         .full(rx_fifo_full),
//         .empty(rx_fifo_empty)
//     );
    
//     // 제어 신호 연결 - 회로도의 빨간색 연결에 맞게 구현
//     // TX 제어 로직
//     assign tx_start = ~tx_fifo_empty;           // TX FIFO가 비어있지 않으면 전송 시작
//     assign tx_rd = w_tx_done & ~tx_fifo_empty;  // 전송 완료 및 FIFO가 비어있지 않으면 다음 데이터 읽기
    
//     // RX 제어 로직
//     assign rx_wr = w_rx_done & ~rx_fifo_full;   // 수신 완료 및 FIFO가 가득 차지 않았으면 데이터 쓰기
// endmodule

module uart_tx (
    input clk,
    input rst,
    input tick,
    input start_trigger,
    input [7:0] data_in,
    output o_tx_done,
    output o_tx
);

    localparam IDLE = 3'h0, SEND = 3'h1, START = 3'h2, DATA = 3'h3, STOP = 3'h4;
    reg [3:0] state, next;
    reg tx_reg, tx_next;
    assign o_tx = tx_reg;
    reg [2:0] bit_count, bit_count_next;  // Added bit_count_next
    reg [3:0] tick_count_reg, tick_count_next;

    reg tx_done_reg, tx_done_next;
    assign o_tx_done = tx_done_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= IDLE;
            tx_reg <= 1'b1;
            tx_done_reg <= 0;
            bit_count <= 0;  
            tick_count_reg <= 0;
        end else begin
            state <= next;
            tx_reg <= tx_next;
            tx_done_reg <= tx_done_next;
            tick_count_reg <= tick_count_next;
            bit_count <= bit_count_next;  // Update bit_count using next value
        end
    end

    always @(*) begin
        next = state;
        tx_next = tx_reg;
        tx_done_next = tx_done_reg;
        tick_count_next = tick_count_reg;
        bit_count_next = bit_count;  // Default: keep current value

        case (state)
            IDLE: begin
                tx_done_next = 1'b0;
                tx_next = 1'b1;
                tick_count_next = 0;
                bit_count_next = 0;  // Reset bit counter in IDLE
                if (start_trigger) next = SEND;
            end

            SEND: begin
                if (tick) begin
                    tick_count_next = 0;
                    next = START;
                end
            end

            START: begin
                tx_next = 1'b0;  // Start bit is 0
                tx_done_next = 1'b1;

                if (tick) begin
                    if (tick_count_reg == 15) begin
                        next = DATA;
                        tick_count_next = 0;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end

            DATA: begin
                tx_next = data_in[bit_count];  // Set current bit

                if (tick) begin
                    if (tick_count_reg == 15) begin
                        tick_count_next = 0;
                        
                        if (bit_count == 3'h7) begin
                            next = STOP;
                        end else begin
                            bit_count_next = bit_count + 1;  // Move to next bit
                        end
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end

            STOP: begin
                tx_next = 1'b1;  // Stop bit is 1
                
                if (tick) begin
                    if (tick_count_reg == 15) begin
                        next = IDLE;
                        tx_done_next = 1'b1;  // Set tx_done at the end of transmission
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end

        endcase
    end
endmodule




`timescale 1ns / 1ps

module uart_rx (
    input clk,rst,tick,rx,
    output rx_done,
    output [7:0] rx_data
);

    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3 ;
    reg [1:0] state,next;
    reg rx_reg, rx_next;
    reg rx_done_reg, rx_done_next;
    reg [2:0] bit_count_reg, bit_count_next;
    reg [4:0] tick_count_reg, tick_count_next;
    reg [7:0] rx_data_reg, rx_data_next;

    //output
    assign rx_done = rx_done_reg;
    assign rx_data = rx_data_reg;

    //state
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= 0;
            rx_done_reg <=0;
            rx_data_reg <=0;
            bit_count_reg <=0;
            tick_count_reg <=0;
        end else begin
            state <= next;
            rx_done_reg <= rx_done_next;
            rx_data_reg <= rx_data_next;
            bit_count_reg <=bit_count_next;
            tick_count_reg <= tick_count_next;
        end
    end

    //next
    always @(*) begin
        next = state;
        tick_count_next = tick_count_reg;
        bit_count_next = bit_count_reg;
        rx_data_next = rx_data_reg;
        rx_done_next  = 0;
        case (state)
            IDLE:  begin
                rx_done_next = 1'b0;
                tick_count_next = 0;
                bit_count_next = 0;
                if (rx==0) begin
                    next = START;
                end
            end

            START : begin
                if (tick) begin
                     if (tick_count_reg==7) begin
                    next = DATA;
                    tick_count_next = 0;
                end else begin
                    tick_count_next = tick_count_reg+1;
                end
                end
            end

            DATA : begin
                if (tick) begin
                    if (tick_count_reg==15) begin
                    //read data
                    rx_data_next [bit_count_reg] = rx;
                    tick_count_next = 0;
                    if (bit_count_reg==7) begin
                        next = STOP;
                    end else begin
                        next = DATA;
                        bit_count_next = bit_count_reg+1;
                    end
                end else begin
                    tick_count_next = tick_count_reg+1;
                end 
                end
            end

            STOP : begin
                if (tick) begin
                    if (tick_count_reg==23) begin
                    next = IDLE;
                    rx_done_next = 1'b1;
                end else begin
                    tick_count_next = tick_count_reg+1;
                end
                end
            end 
        endcase
    end
endmodule



`timescale 1ns / 1ps

module baud_tick_gen (
    input clk,
    input rst,
    output baud_tick
);
    //parameter BAUD_RATE = 115200;
    parameter BAUD_RATE = 9600;
    localparam BAUD_COUNT = 100_000_000 / BAUD_RATE / 16; // 반올림 처리
    localparam COUNTER_WIDTH = $clog2(BAUD_COUNT);  // 정확한 비트 수 설정

    reg [COUNTER_WIDTH-1:0] count_reg, count_next;
    reg tick_reg, tick_next;

    assign baud_tick = tick_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count_reg <= 0;
            tick_reg <= 0;
        end else begin
            count_reg <= count_next;
            tick_reg <= tick_next;
        end
    end

    always @(*) begin
        count_next = count_reg + 1;
        tick_next = 1'b0;  // tick_next 초기화

        if (count_reg >= BAUD_COUNT-1) begin
            count_next = 0;
            tick_next = 1'b1;
        end
    end
endmodule