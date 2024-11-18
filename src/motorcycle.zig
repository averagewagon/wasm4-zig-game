const w4 = @import("wasm4.zig");

pub const Motorcycle = struct {
    pub const State = enum {
        Normal,
        Crashed,
    };

    position: f64 = 0.0, // Lane position: -1.2 to 1.2
    state: State = .Normal,

    /// Updates the position based on steering direction.
    /// Crashes if the position exceeds boundaries.
    pub fn steer(self: *Motorcycle, direction: f64) void {
        if (self.state == .Crashed) return; // Ignore input if crashed

        // Update position
        self.position += direction;

        // Check boundaries for a crash
        if (self.position < -1.2 or self.position > 1.2) {
            self.state = .Crashed;
            w4.trace("Game Over: Crashed!"); // Log the crash
        }
    }

    /// Resets the motorcycle to its initial state.
    pub fn reset(self: *Motorcycle) void {
        self.position = 0.0;
        self.state = .Normal;
    }
};

/// Handles input for steering the motorcycle.
/// Calls the motorcycle's `steer` method with appropriate direction.
pub fn handleInput(motorcycle: *Motorcycle) void {
    const gamepad = w4.GAMEPAD1.*;

    if (gamepad & w4.BUTTON_LEFT != 0) {
        motorcycle.steer(-0.1); // Steer left
    } else if (gamepad & w4.BUTTON_RIGHT != 0) {
        motorcycle.steer(0.1); // Steer right
    }
}

pub fn drawMotorcycle(motorcycle: *Motorcycle) void {
    // Map position (-1.2 to 1.2) to screen X coordinates
    const centerLaneX = 80; // X position for center lane
    const laneWidth = 40.0; // Width between lanes
    const x = centerLaneX + @as(i32, @intFromFloat(motorcycle.position * laneWidth));

    // Draw the motorcycle as a rectangle (temporary)
    w4.DRAW_COLORS.* = 3;
    w4.rect(x, 140, 10, 10); // Positioned near the bottom of the screen
}
