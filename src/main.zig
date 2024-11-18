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
const images = @import("images.zig");

// Menu items
const menuItems = [_][]const u8{
    "New Game",
    "Load Game",
    "Exit",
};

var selectedIndex: usize = 0;
var prev_state: u8 = 0; // Previous gamepad state

// https://lospec.com/palette-list/coral-4
export fn start() void {
    w4.PALETTE.* = .{
        0xffd0a4,
        0xf4949c,
        0x7c9aac,
        0x68518a,
    };
}

// Global variables to track the rectangle's position
var rectX: i32 = 160; // Initial X position
var rectY: i32 = -40; // Initial Y position

export fn update() void {
    drawMovingRectangle();

    drawBackground();

    // Handle input for menu navigation
    handleInput();

    if (selectedIndex == 0) {
        images.person.render(1, 5);
    } else if (selectedIndex == 1) {
        images.person.render(2, 7);
    } else {
        images.person.render(4, 8);
    }
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
    w4.DRAW_COLORS.* = 1;
    for (80..160) |i| {
        drawSlope(26.6, @intCast(i));
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

/// Handles input for menu navigation.
fn handleInput() void {
    const gamepad = w4.GAMEPAD1.*;
    const just_pressed = gamepad & (gamepad ^ prev_state);

    if (just_pressed & w4.BUTTON_UP != 0) {
        if (selectedIndex == 0) {
            selectedIndex = menuItems.len - 1;
        } else {
            selectedIndex -= 1;
        }
    }
    if (just_pressed & w4.BUTTON_DOWN != 0) {
        if (selectedIndex == menuItems.len - 1) {
            selectedIndex = 0;
        } else {
            selectedIndex += 1;
        }
    }

    prev_state = gamepad;
}

/// Draws a simple menu with selectable items.
fn drawMenu() void {
    const startX: i32 = 20;
    const startY: i32 = 30;
    const lineHeight: i32 = 12;

    w4.DRAW_COLORS.* = 2;

    for (menuItems, 0..) |item, index| {
        const yPos = startY + (@as(i32, @intCast(index)) * lineHeight);

        if (index == selectedIndex) {
            // Highlight with inverted colors
            w4.DRAW_COLORS.* = 3; // Invert foreground and background
            w4.rect(startX - 2, yPos - 2, 80, 12); // Background rectangle
            w4.DRAW_COLORS.* = 1; // Inverted text color
        } else {
            w4.DRAW_COLORS.* = 2; // Default color for text
        }

        // Draw the menu text
        w4.text(item, startX, yPos);
    }
}
