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

// Menu items
const menuItems = [_][]const u8{
    "New Game",
    "Load Game",
    "Exit",
};

var selectedIndex: usize = 0;
var prev_state: u8 = 0; // Previous gamepad state

export fn start() void {}

export fn update() void {
    w4.DRAW_COLORS.* = 2;

    // Handle input for menu navigation
    handleInput();

    // Draw the menu
    drawMenu();
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
