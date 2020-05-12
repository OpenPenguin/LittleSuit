--[[
    static func DiskDriver.new()
    func DiskDriver.mount(mountPath: String, deviceProxy: DiskDriver) -> null;
    func DiskDriver.makeDirrectory(path: String) -> null;
    func DiskDriver.delete(path: String) -> null;
    func DiskDriver.listDirrectory(path: String) -> [String];
    func DiskDriver.openFile(path: String) -> Int;
]]