// SPDX-License-Identifier: Apache-2.0
module counter(
  input wire clk,
  input wire reset,
  output [127:0] out
);
  reg [127:0] counter_tmp;
  always @ (posedge clk or posedge reset) begin
    if (reset) begin
      counter_tmp <= 0;
    end else begin
      counter_tmp <= counter_tmp + 1;
    end
  end

  assign out = counter_tmp;

endmodule
