const std = @import("std");
const jetzig = @import("../../jetzig.zig");

/// Job name and run function, used when generating an array of job definitions at build time.
pub const JobDefinition = struct {
    name: []const u8,
    runFn: *const fn (std.mem.Allocator, *jetzig.data.Value, JobEnv) anyerror!void,
};

pub const JobEnv = struct {
    logger: jetzig.loggers.Logger,
    environment: jetzig.Environment.EnvironmentName,
    routes: []*const jetzig.Route,
    mailers: []const jetzig.MailerDefinition,
    jobs: []const jetzig.JobDefinition,
};

allocator: std.mem.Allocator,
jet_kv: *jetzig.jetkv.JetKV,
logger: jetzig.loggers.Logger,
name: []const u8,
definition: ?JobDefinition,
data: *jetzig.data.Data,
params: *jetzig.data.Value,

const Job = @This();

/// Initialize a new Job
pub fn init(
    allocator: std.mem.Allocator,
    jet_kv: *jetzig.jetkv.JetKV,
    logger: jetzig.loggers.Logger,
    jobs: []const JobDefinition,
    name: []const u8,
) Job {
    var definition: ?JobDefinition = null;

    for (jobs) |job_definition| {
        if (std.mem.eql(u8, job_definition.name, name)) {
            definition = job_definition;
            break;
        }
    }

    const data = allocator.create(jetzig.data.Data) catch @panic("OOM");
    data.* = jetzig.data.Data.init(allocator);

    return .{
        .allocator = allocator,
        .jet_kv = jet_kv,
        .logger = logger,
        .name = name,
        .definition = definition,
        .data = data,
        .params = data.object() catch @panic("OOM"),
    };
}

/// Deinitialize the Job and frees memory
pub fn deinit(self: *Job) void {
    self.data.deinit();
    self.allocator.destroy(self.data);
}

/// Add a Job to the queue
pub fn schedule(self: *Job) !void {
    try self.params.put("__jetzig_job_name", self.data.string(self.name));
    const json = try self.data.toJson();
    try self.jet_kv.prepend("__jetzig_jobs", json);
    try self.logger.INFO("Scheduled job: {s}", .{self.name});
}
