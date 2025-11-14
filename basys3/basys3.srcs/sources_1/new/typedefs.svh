`ifndef TYPEDEFS_SVH
`define TYPEDEFS_SVH
typedef enum logic [1:0] {
    STATE_IDLE,
    STATE_START,
    STATE_PROCESSING,
    STATE_DONE
} uart_state_t;


typedef struct packed {
    logic [13:0] in_a;
    logic [13:0] in_b;
    logic [3:0]  alu_sel;
} alu_packet_t;

`endif 