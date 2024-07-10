module fake_rx (
    input           rst_n       ,
    input           clk         ,
    input   [7:0]   key         ,
    output  [6:0]   rx          
);
    reg    [3:0]   key_code    ;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)begin
            key_code <= 4'd0000;
        end
        else begin
            case(key)
            8'b11111110: key_code <= 4'b0001; // Key 1
            8'b11111101: key_code <= 4'b0010; // Key 2
            8'b11111011: key_code <= 4'b0011; // Key 3
            8'b11110111: key_code <= 4'b0100; // Key 4
            8'b11101111: key_code <= 4'b0101; // Key 5 (repeated to illustrate, should be 0011 but showing error handling scenario)
            8'b11011111: key_code <= 4'b0110; // Key 6
            8'b10111111: key_code <= 4'b0111; // Key 7
            8'b01111111: key_code <= 4'b1000; // Key 8
            default: key_code <= key_code;      // No key pressed or invalid input
        endcase
        end
    end 
    assign rx = {1'b1,2'b0,key_code};
    

endmodule