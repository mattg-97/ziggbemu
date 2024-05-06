const rl = @import("raylib");
const std = @import("std");
const cpu = @import("cpu.zig");

pub fn main() !void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 640;
    const screenHeight = 480;

    rl.initWindow(screenWidth, screenHeight, "Space rocks");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.white);

        //----------------------------------------------------------------------------------
    }
}
