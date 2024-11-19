// game -- To be determined
// Copyright (C) 2024 Archit Gupta <archit@accelbread.com>
// Copyright (C) 2024 Jonathan Hendrickson <jonathan@jhendrickson.dev>
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU Affero General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option) any
// later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
// details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.
//
// SPDX-License-Identifier: AGPL-3.0-or-later

const w4 = @import("wasm4.zig");
const m = @import("motorcycle.zig");
const o = @import("obstacles.zig");

var prev_state: u8 = 0; // Previous gamepad state

const C_BLACK = 1;
const C_WHITE = 2;
const C_PINK = 3;
const C_GREEN = 4;

// Global variables to track the rectangle's position
var rectX: i32 = 160; // Initial X position
var rectY: i32 = -40; // Initial Y position

// Time accumulator for obstacle spawning
var obstacleSpawnTimer: f64 = 0.0;

var motorcycle = m.Motorcycle{};
var obstacleManager = o.ObstacleManager.init();

export fn start() void {
    w4.PALETTE.* = .{
        0x222323, // Black
        0xA0A6A0, // Temporary Gray
        0xff4adc, // Pink
        0x3dff98, // Green
    };

    // // Initialize the obstacle manager
    // obstacleManager.init();
}

export fn update() void {
    drawBackground();

    drawMovingRectangle();

    drawForeground();

    // Delta time (assuming fixed time step for simplicity)
    const deltaTime = 1.0 / 60.0;

    // Handle input and update the motorcycle
    const input = m.handleInput();
    motorcycle.update(input, deltaTime);

    // Spawn obstacles at regular intervals
    obstacleSpawnTimer += deltaTime;
    if (obstacleSpawnTimer >= 1.0) { // Spawn every 1 second
        obstacleSpawnTimer = 0.0;
        obstacleManager.spawn(.Car, // Obstacle type (e.g., Car)
            160.0, // Starting X position (off-screen)
            0.0, // Starting Y position (top-right)
            -30.0, // Velocity X (moving left)
            20.0 // Velocity Y (moving down)
        );
    }

    // Update obstacles
    obstacleManager.update(deltaTime);

    // Draw the motorcycle
    m.renderMotorcycle(&motorcycle);

    // Render obstacles
    renderObstacles();

    // Collision detection
    checkCollisions();
}

/// Render all active obstacles
fn renderObstacles() void {
    for (&obstacleManager.obstacles) |*obstacle| {
        if (obstacle.*) |activeObstacle| {
            // Placeholder: Draw obstacle as a rectangle for now
            w4.DRAW_COLORS.* = C_GREEN;
            w4.rect(@intFromFloat(activeObstacle.position[0]), @intFromFloat(activeObstacle.position[1]), 16, 16);
        }
    }
}

/// Check for collisions between the motorcycle and obstacles
fn checkCollisions() void {
    const motorcycleHitbox = [4]i32{
        // Example hitbox for motorcycle (adjust as needed)
        @as(i32, @intFromFloat(motorcycle.position * 160)) - 8,
        140 - 8,
        16,
        16,
    };

    for (&obstacleManager.obstacles) |*obstacle| {
        if (obstacle.*) |activeObstacle| {
            if (activeObstacle.state and rectsOverlap(activeObstacle.hitbox, motorcycleHitbox)) {
                motorcycle.state = .Crashed;
                w4.trace("Game Over: Collision detected!");
                return;
            }
        }
    }
}

/// Simple rectangle overlap check
fn rectsOverlap(a: [4]i32, b: [4]i32) bool {
    return a[0] < b[0] + b[2] and a[0] + a[2] > b[0] and a[1] < b[1] + b[3] and a[1] + a[3] > b[1];
}

/// Draws and updates the position of the moving rectangle (skyscraper).
fn drawMovingRectangle() void {
    // Draw the rectangle
    w4.DRAW_COLORS.* = C_PINK; // Color for the skyscraper
    w4.rect(rectX, rectY, 20, 50); // Rectangle of width 20 and height 50

    // Update the rectangle's position
    rectX -= 2; // Move left
    rectY += 1; // Move down

    // Reset position if it moves off-screen
    if (rectX + 20 < 0 or rectY > 160) { // 20 is the width of the rectangle
        rectX = 160;
        rectY = -40;
    }
}

fn drawBackground() void {
    // Draw the background color
    w4.DRAW_COLORS.* = C_BLACK;
    for (0..297) |i| {
        drawSlope(58.4, @intCast(i));
    }
}

fn drawForeground() void {
    // Set the road color
    w4.DRAW_COLORS.* = C_WHITE;
    for (80..300) |i| {
        drawSlope(26.6, @intCast(i));
    }

    // Draw the foreground color
    w4.DRAW_COLORS.* = C_BLACK;
    for (298..600) |i| {
        drawSlope(58.4, @intCast(i));
    }

    // Set the draw color
    w4.DRAW_COLORS.* = C_GREEN; // Use color 2 for the slope

    // Draw the slope line
    drawSlope(26.6, 80);

    drawSlope(36, 122);

    drawSlope(46.4, 184);

    drawSlope(58.4, 298);
}

/// Draws a slope starting at a given Y-coordinate with a specific angle.
/// The slope is drawn until it goes off the canvas.
fn drawSlope(angleDegrees: f64, startY: i32) void {
    const canvasWidth: i32 = 160;
    const canvasHeight: i32 = 160;

    // Convert angle to radians for slope calculation
    const angleRadians = (180 - angleDegrees) * 0.0174533; // pi/180
    const slope = @tan(angleRadians); // Rise over run

    // Calculate the end point based on the canvas boundaries
    var endX: i32 = canvasWidth;
    var endY: f64 = @as(f64, @floatFromInt(startY)) + slope * @as(f64, @floatFromInt(endX));

    if (endY > canvasHeight) {
        endX = @intFromFloat((@as(f64, @floatFromInt(canvasHeight)) - @as(f64, @floatFromInt(startY))) / slope);
        endY = @floatFromInt(canvasHeight);
    }

    // Draw the line using the w4.line function
    w4.line(0, startY, endX, @intFromFloat(endY));
}
