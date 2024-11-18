const w4 = @import("wasm4.zig");

pub const Motorcycle = struct {
    pub const State = enum {
        Normal,
        Crashed,
    };

    position: f64 = 0.5, // Lane position: 0 to 1
    state: State = .Normal,

    /// Updates the position based on steering direction.
    /// Crashes if the position exceeds boundaries.
    pub fn steer(self: *Motorcycle, direction: f64) void {
        if (self.state == .Crashed) return; // Ignore input if crashed

        // Update position
        self.position += direction;

        // Check boundaries for a crash
        if (self.position < 0.0 or self.position > 1.0) {
            self.state = .Crashed;
            w4.trace("Game Over: Crashed!"); // Log the crash
        }
    }

    /// Resets the motorcycle to its initial state.
    pub fn reset(self: *Motorcycle) void {
        self.position = 0.5;
        self.state = .Normal;
    }
};

/// Handles input for steering the motorcycle.
/// Calls the motorcycle's `steer` method with appropriate direction.
pub fn handleInput(motorcycle: *Motorcycle) void {
    const gamepad = w4.GAMEPAD1.*;

    if (gamepad & w4.BUTTON_LEFT != 0) {
        motorcycle.steer(-0.05); // Steer left
    } else if (gamepad & w4.BUTTON_RIGHT != 0) {
        motorcycle.steer(0.05); // Steer right
    }
}

pub fn drawMotorcycle(motorcycle: *Motorcycle) void {
    // Define an array of 10 (x, y) positions
    const renderPositions = [_][2]i32{
        .{ 10, 80 },  .{ 48, 140 }, .{ 56, 140 }, .{ 64, 140 },  .{ 72, 140 },
        .{ 80, 140 }, .{ 88, 140 }, .{ 96, 140 }, .{ 104, 140 }, .{ 85, 130 },
    };

    // Calculate the array index based on the motorcycle's position
    const arrayLength = renderPositions.len;
    var index: usize = @intFromFloat(motorcycle.position * @as(f64, @floatFromInt(arrayLength)));
    if (index < 0) index = 0;
    if (index >= arrayLength) index = arrayLength - 1;

    // Get the x and y coordinates from the array
    const coords = renderPositions[index];

    // Draw the motorcycle
    w4.DRAW_COLORS.* = 3;
    // Positioned at (x, y) from the array
    w4.rect(coords[0], coords[1] - 10, 10, 10);
}
