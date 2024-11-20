const w4 = @import("wasm4.zig");
const s = @import("sprites.zig");
const std = @import("std");

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

        const acceleration = 6.0; // Acceleration rate for input
        const maxVelocity = 2.5; // Maximum velocity
        const deceleration = 5.0; // Deceleration rate when no input

        if (input != 0.0) {
            self.velocity += input * acceleration * deltaTime;
        } else {
            if (self.velocity > 0.0) {
                self.velocity -= deceleration * deltaTime;
                if (self.velocity < 0.0) self.velocity = 0.0;
            } else if (self.velocity < 0.0) {
                self.velocity += deceleration * deltaTime;
                if (self.velocity > 0.0) self.velocity = 0.0;
            }
        }

        if (self.velocity > maxVelocity) self.velocity = maxVelocity;
        if (self.velocity < -maxVelocity) self.velocity = -maxVelocity;

        self.position += self.velocity * deltaTime;

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

    /// Computes the position of the motorcycle on the Bézier curve.
    pub fn getPosition(self: *Motorcycle) [2]f64 {
        const P0 = [2]f64{ 18, 80 }; // Left lane
        const P1 = [2]f64{ 25, 125 }; // Control point (mid-lane, arc shape)
        const P2 = [2]f64{ 90, 150 }; // Right lane

        const t = self.position; // Normalized parameter (0 to 1)
        const oneMinusT = 1.0 - t;

        const x = oneMinusT * oneMinusT * P0[0] +
            2.0 * oneMinusT * t * P1[0] +
            t * t * P2[0];

        const y = oneMinusT * oneMinusT * P0[1] +
            2.0 * oneMinusT * t * P1[1] +
            t * t * P2[1];

        return .{ x, y };
    }

    /// Returns the current hitbox of the motorcycle
    pub fn getHitbox(self: *Motorcycle) [4]i32 {
        const position = self.getPosition();
        const x: i32 = @intFromFloat(position[0]);
        const y: i32 = @intFromFloat(position[1]);

        // Centered 16x16 hitbox
        return .{
            x - 8, // Top-left X
            y - 8, // Top-left Y
            16, // Width
            16, // Height
        };
    }

    /// Checks if the motorcycle is in a crashed state
    pub fn isCrashed(self: *Motorcycle) bool {
        return self.state == .Crashed;
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
    const position = motorcycle.getPosition();
    const x: i32 = @intFromFloat(position[0]);
    const y: i32 = @intFromFloat(position[1]);

    // Determine lane based on position
    const laneIndex: usize = if (motorcycle.position < 0.3) 0 else if (motorcycle.position < 0.75) 1 else 2;

    // Determine turning state based on velocity
    const turningIndex: usize = if (motorcycle.velocity < -0.5) 0 else if (motorcycle.velocity > 0.5) 2 else 1;

    // Compute sprite index
    const spriteIndex = laneIndex * 3 + turningIndex;

    // Retrieve the appropriate sprite
    const sprite = &s.motorcycleSprites[spriteIndex];

    // Render the sprite using the anchor-based helper function
    s.drawSpriteAtAnchor(sprite, x, y);
}
