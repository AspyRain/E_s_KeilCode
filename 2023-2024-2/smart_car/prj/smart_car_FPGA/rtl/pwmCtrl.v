module pwmCtrl (
    input wire clk,         // System clock
    input wire rst_n,       // Active-low synchronous reset
    input wire [6:0] duty_percent, // Duty cycle percentage, 0-100% represented as 0-0 to 0-127
    output reg pwm_out ,     // PWM output signal
    output      pwm_en
);
    parameter PERIOD_COUNT = 65535; // Adjusted PWM period counter max value for approx. 1.22kHz

    reg [19:0] counter = 0;      // PWM period counter with increased width for higher precision
    reg [19:0] compare_value;   // Counter value for PWM high period with matching width

    // Calculate compare value based on duty percent, ensuring duty_percent does not exceed its valid range.
    always @* begin
        compare_value = (duty_percent >= 7'd100) ? PERIOD_COUNT : PERIOD_COUNT * duty_percent[6:0]/100 ;
    end

    // PWM logic with clear specification of reset edge sensitivity
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 20'b0;
            pwm_out <= 1'b0;
        end else begin
            if (pwm_en) begin
                    if (counter == compare_value) begin // Time to switch PWM state
                         pwm_out <= ~pwm_out; // Toggle PWM output
                    end
                    if (counter == PERIOD_COUNT) begin // End of PWM period
                        counter <= 21'b0; // Reset counter
                    end else begin
                        counter <= counter + 1'b1; // Increment counter
                    end
            end
            else begin
                pwm_out = 1'b1;
            end
        end
    end
    assign pwm_en = (duty_percent != 7'b0);
endmodule