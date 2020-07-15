`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/22/2015 11:30:46 PM
// Design Name: 
// Module Name: camera_read_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module camera_read_2_tb();

// inputs 
reg p_clock;
reg vsync;
reg href;
reg [7:0] p_data;

//outputs 
wire [15:0] pixel_data;
wire pixel_valid;
wire frame_done;
wire [18:0] wraddr;
 camera_read camera_read_1 (
        .p_clock(p_clock), 
        .vsync(vsync), 
        .href(href),
        .p_data(p_data), 
        .pixel_data(pixel_data), 
        .pixel_valid(pixel_valid),
        .frame_done (frame_done),
        .wraddr(wraddr)
    );
    
    always #5 p_clock = ~p_clock;
    integer i,j,k;
    initial begin 
    
    p_clock = 0;
    vsync = 0;
    href = 0;
    p_data = 0;
    #5;
    #100;
    
    vsync = 1;
    #200;
    vsync = 0;
    
    
    #340;
    for(k=0;k<480;k=k+1)begin
       href = 1; 
        p_data = 8'hFF;
        #10; 
        p_data = 8'h88;
        for(i=0;i<1279;i=i+1)begin
            for(j=0;j<1;j = j+1)begin
                #10;
                p_data = p_data +1;
            end
         end
        href =0;
        #280;
    end
    
    
    
    
    #200;
    vsync = 1; 
    #20
    vsync = 0;
    #5000;
    
    end
    
    
endmodule
