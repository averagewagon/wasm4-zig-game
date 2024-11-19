const w4 = @import("wasm4.zig");
const s = @import("sprites.zig");

pub const Motorcycle = struct {
    pub const State = enum {
        Normal,
        Crashed,
    };

    position: f64 = 0.5, // Lane position: 0 to 1
    velocity: f64 = 0.0, // Rate of change of position
    state: State = .Normal,

    /// Updates the velocity and position based on input.
    pub fn update(self: *Motorcycle, input: f64, deltaTime: f64) void {
        if (self.state == .Crashed) return;

        // Constants
        const acceleration = 6.0; // Acceleration rate for input
        const maxVelocity = 2.5; // Maximum velocity
        const deceleration = 5.0; // Deceleration rate when no input

        if (input != 0.0) {
            // Accelerate in the input direction
            self.velocity += input * acceleration * deltaTime;
        } else {
            // Decelerate smoothly when no input
            if (self.velocity > 0.0) {
                self.velocity -= deceleration * deltaTime;
                if (self.velocity < 0.0) self.velocity = 0.0;
            } else if (self.velocity < 0.0) {
                self.velocity += deceleration * deltaTime;
                if (self.velocity > 0.0) self.velocity = 0.0;
            }
        }

        // Clamp velocity to max limits
        if (self.velocity > maxVelocity) self.velocity = maxVelocity;
        if (self.velocity < -maxVelocity) self.velocity = -maxVelocity;

        // Update position based on velocity
        self.position += self.velocity * deltaTime;

        // Clamp position to valid range
        if (self.position < 0.0 or self.position > 1.0) {
            self.state = .Crashed;
            w4.trace("Game Over: Crashed!");
        }
    }

    /// Resets the motorcycle to its initial state.
    pub fn reset(self: *Motorcycle) void {
        self.position = 0.5;
        self.velocity = 0.0;
        self.state = .Normal;
    }
};

pub fn handleInput() f64 {
    const gamepad = w4.GAMEPAD1.*;
    if (gamepad & w4.BUTTON_LEFT != 0) {
        return -1.0; // Steer left
    } else if (gamepad & w4.BUTTON_RIGHT != 0) {
        return 1.0; // Steer right
    }
    return 0.0; // No input
}

pub fn renderMotorcycle(motorcycle: *Motorcycle) void {
    // Define the three control points (x, y)
    const P0 = [2]f64{ 15, 80 }; // Left lane
    const P1 = [2]f64{ 25, 125 }; // Control point (mid-lane, arc shape)
    const P2 = [2]f64{ 90, 150 }; // Right lane

    // Compute position on the Bézier curve
    const t = motorcycle.position; // Normalized parameter (0 to 1)
    const oneMinusT = 1.0 - t;

    const x = oneMinusT * oneMinusT * P0[0] +
        2.0 * oneMinusT * t * P1[0] +
        t * t * P2[0];

    const y = oneMinusT * oneMinusT * P0[1] +
        2.0 * oneMinusT * t * P1[1] +
        t * t * P2[1];

    // Determine lane based on position
    const laneIndex: usize = if (motorcycle.position < 0.3) 0 else if (motorcycle.position < 0.75) 1 else 2;

    // Determine turning state based on velocity
    const turningIndex: usize = if (motorcycle.velocity < -0.5) 0 else if (motorcycle.velocity > 0.5) 2 else 1;

    // Compute sprite index
    const spriteIndex = laneIndex * 3 + turningIndex;

    // Retrieve the appropriate sprite
    const sprite = &s.motorcycleSprites[spriteIndex];

    // Render the sprite using the anchor-based helper function
    s.drawSpriteAtAnchor(sprite, @intFromFloat(x), @intFromFloat(y));
}
