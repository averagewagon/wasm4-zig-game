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
    // Define the three control points (x, y)
    const P0 = [2]f64{ 15, 80 }; // Left lane
    const P1 = [2]f64{ 25, 125 }; // Control point (mid-lane, arc shape)
    const P2 = [2]f64{ 95, 140 }; // Right lane

    // Compute position on the Bézier curve
    const t = motorcycle.position; // Normalized parameter (0 to 1)
    const oneMinusT = 1.0 - t;

    const x = oneMinusT * oneMinusT * P0[0] +
        2.0 * oneMinusT * t * P1[0] +
        t * t * P2[0];

    const y = oneMinusT * oneMinusT * P0[1] +
        2.0 * oneMinusT * t * P1[1] +
        t * t * P2[1];

    // Draw the motorcycle
    w4.DRAW_COLORS.* = 3;
    w4.rect(@intFromFloat(x), @intFromFloat(y - 5), 5, 5); // Positioned at (x, y)
}
