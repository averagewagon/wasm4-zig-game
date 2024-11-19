const w4 = @import("wasm4.zig");
const s = @import("sprites.zig");

pub const Obstacle = struct {
    pub const Kind = enum {
        Car,
        Barrel,
        Cone,
    };

    position: [2]f64, // x and y position in screen space
    velocity: [2]f64, // dx and dy for movement
    hitbox: [4]i32, // {x, y, width, height}
    state: bool, // Active or inactive
    kind: Kind, // Kind of the obstacle

    /// Initialize the obstacle with default values
    pub fn init(self: *Obstacle, kind: Kind, x: f64, y: f64, dx: f64, dy: f64) void {
        self.position = [2]f64{ x, y };
        self.velocity = [2]f64{ dx, dy };
        self.hitbox = [4]i32{ 0, 0, 16, 16 }; // Placeholder hitbox size
        self.state = true;
        self.kind = kind;
    }

    /// Update the position of the obstacle
    pub fn update(self: *Obstacle, deltaTime: f64) void {
        if (!self.state) return; // Skip inactive obstacles

        // Move the obstacle
        self.position[0] += self.velocity[0] * deltaTime;
        self.position[1] += self.velocity[1] * deltaTime;

        // Deactivate if off-screen
        if (self.position[0] + @as(f64, @floatFromInt(self.hitbox[2])) < 0 or self.position[1] > 160) {
            self.state = false;
        }
    }
};

pub const ObstacleManager = struct {
    obstacles: [16]?Obstacle, // Fixed-size array of optional obstacles

    pub fn init() ObstacleManager {
        return ObstacleManager{
            .obstacles = [_]?Obstacle{null} ** 16,
        };
    }

    /// Spawn a new obstacle in the first available slot
    pub fn spawn(self: *ObstacleManager, kind: Obstacle.Kind, x: f64, y: f64, dx: f64, dy: f64) void {
        for (&self.obstacles) |*obstacle| {
            if (obstacle.* == null) {
                obstacle.* = Obstacle{
                    .position = .{ x, y },
                    .velocity = .{ dx, dy },
                    .hitbox = .{ 0, 0, 16, 16 }, // Default hitbox size
                    .state = true,
                    .kind = kind,
                };
                return;
            }
        }
    }

    /// Update all active obstacles
    pub fn update(self: *ObstacleManager, deltaTime: f64) void {
        for (&self.obstacles) |*obstacle| {
            if (obstacle.*) |*activeObstacle| {
                activeObstacle.update(deltaTime);

                // Deactivate obstacle if it moves off-screen
                if (activeObstacle.position[0] + @as(f64, @floatFromInt(activeObstacle.hitbox[2])) < 0 or
                    activeObstacle.position[1] > 160)
                {
                    obstacle.* = null;
                }
            }
        }
    }
};
