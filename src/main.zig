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

var prev_state: u8 = 0; // Previous gamepad state

// https://lospec.com/palette-list/coral-4
export fn start() void {
    w4.PALETTE.* = .{
        0x68518a,
        0xf4949c,
        0xffd0a4,
        0x7c9aac,
    };
}

// Global variables to track the rectangle's position
var rectX: i32 = 160; // Initial X position
var rectY: i32 = -40; // Initial Y position

var motorcycle = m.Motorcycle{};

export fn update() void {
    drawBackground();

    drawMovingRectangle();

    drawForeground();

    // Delta time (assuming fixed time step for simplicity)
    const deltaTime = 1.0 / 60.0;

    // Handle input and update the motorcycle
    const input = m.handleInput();
    motorcycle.update(input, deltaTime);

    // Draw the motorcycle
    m.drawMotorcycle(&motorcycle);
}

/// Draws and updates the position of the moving rectangle (skyscraper).
fn drawMovingRectangle() void {
    // Draw the rectangle
    w4.DRAW_COLORS.* = 3; // Color for the skyscraper
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
    w4.DRAW_COLORS.* = 1;
    for (0..297) |i| {
        drawSlope(58.4, @intCast(i));
    }
}

fn drawForeground() void {
    // Set the road color
    w4.DRAW_COLORS.* = 4;
    for (80..300) |i| {
        drawSlope(26.6, @intCast(i));
    }

    // Draw the foreground color
    w4.DRAW_COLORS.* = 1;
    for (298..600) |i| {
        drawSlope(58.4, @intCast(i));
    }

    // Set the draw color
    w4.DRAW_COLORS.* = 2; // Use color 2 for the slope

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
