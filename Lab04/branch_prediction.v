module branch_prediction_unit (
    input wire clk,
    input wire reset,

    // Actual outcome resolved in MEM stage
    input wire branch_resolved,           // 1 when a branch instruction is resolved
    input wire branch_taken_actual,       // 1 if branch was actually taken

    // Prediction needed in IF stage
    output reg branch_predict             // 1 if predictor predicts taken, 0 otherwise
);

    // 2-bit FSM States
    typedef enum logic [1:0] {
        STRONGLY_NOT_TAKEN = 2'b00,
        WEAKLY_NOT_TAKEN   = 2'b01,
        WEAKLY_TAKEN       = 2'b10,
        STRONGLY_TAKEN     = 2'b11
    } predictor_state_t;

    predictor_state_t state, next_state;

    // Combinational logic to compute next state and prediction
    always @(*) begin
        // Default to current state
        next_state = state;

        // Predict based on current state
        case (state)
            STRONGLY_NOT_TAKEN,
            WEAKLY_NOT_TAKEN: branch_predict = 1'b0;
            WEAKLY_TAKEN,
            STRONGLY_TAKEN:   branch_predict = 1'b1;
        endcase

        // State transition on branch resolution
        if (branch_resolved) begin
            case (state)
                STRONGLY_NOT_TAKEN:
                    next_state = branch_taken_actual ? WEAKLY_NOT_TAKEN : STRONGLY_NOT_TAKEN;
                WEAKLY_NOT_TAKEN:
                    next_state = branch_taken_actual ? WEAKLY_TAKEN     : STRONGLY_NOT_TAKEN;
                WEAKLY_TAKEN:
                    next_state = branch_taken_actual ? STRONGLY_TAKEN   : WEAKLY_NOT_TAKEN;
                STRONGLY_TAKEN:
                    next_state = branch_taken_actual ? STRONGLY_TAKEN   : WEAKLY_TAKEN;
            endcase
        end
    end

    // Sequential state update
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= WEAKLY_NOT_TAKEN; // Initialize to neutral state
        else
            state <= next_state;
    end

endmodule
