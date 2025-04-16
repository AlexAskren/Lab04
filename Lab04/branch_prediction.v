module branch_prediction_unit (
    input wire clk,
    input wire reset,

    input wire branch_resolved,           
    input wire branch_taken_actual,       

    output reg branch_predict             
);

    // FSM state encoding (Standard Verilog)
    parameter STRONGLY_NOT_TAKEN = 2'b00;
    parameter WEAKLY_NOT_TAKEN   = 2'b01;
    parameter WEAKLY_TAKEN       = 2'b10;
    parameter STRONGLY_TAKEN     = 2'b11;

    reg [1:0] state, next_state;

    // Combinational logic
    always @(*) begin
        next_state = state;

        // Prediction based on current state
        case (state)
            STRONGLY_NOT_TAKEN,
            WEAKLY_NOT_TAKEN: branch_predict = 1'b0;

            WEAKLY_TAKEN,
            STRONGLY_TAKEN: branch_predict = 1'b1;
        endcase

        // Update next state based on actual outcome
        if (branch_resolved) begin
            case (state)
                STRONGLY_NOT_TAKEN:
                    next_state = branch_taken_actual ? WEAKLY_NOT_TAKEN : STRONGLY_NOT_TAKEN;

                WEAKLY_NOT_TAKEN:
                    next_state = branch_taken_actual ? WEAKLY_TAKEN : STRONGLY_NOT_TAKEN;

                WEAKLY_TAKEN:
                    next_state = branch_taken_actual ? STRONGLY_TAKEN : WEAKLY_NOT_TAKEN;

                STRONGLY_TAKEN:
                    next_state = branch_taken_actual ? STRONGLY_TAKEN : WEAKLY_TAKEN;
            endcase
        end
    end

    // Sequential state update
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= WEAKLY_NOT_TAKEN; 
        else
            state <= next_state;
    end

endmodule
