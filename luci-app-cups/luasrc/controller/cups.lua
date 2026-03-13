-- LuCI Controller for OpenPrinting CUPS 2.4.16
-- 服务菜单入口，状态查询，启动/停止/移除

module("luci.controller.cups", package.seeall)

function index()
    -- 仅在 cupsd 存在时显示（已安装 CUPS）
    if not nixio.fs.access("/usr/sbin/cupsd") and not nixio.fs.access("/etc/init.d/cupsd") then
        return
    end

    local page = entry({"admin", "services", "cups"}, alias("admin", "services", "cups", "status"), _("OpenPrinting CUPS 2.4.16"), 61)
    page.dependent = true
    page.acl_depends = { "luci-app-cups" }
    entry({"admin", "services", "cups", "status"}, cbi("cups/status"), _("状态"), 10).leaf = true
    entry({"admin", "services", "cups", "status_ajax"}, call("act_status")).leaf = true
    entry({"admin", "services", "cups", "start"}, post("act_start")).leaf = true
    entry({"admin", "services", "cups", "stop"}, post("act_stop")).leaf = true
    entry({"admin", "services", "cups", "disable"}, post("act_disable")).leaf = true
end

function act_status()
    local sys = require "luci.sys"
    local e = {}
    e.running = (sys.call("pidof cupsd > /dev/null") == 0)
    e.port = 631
    e.version = "2.4.16"
    luci.http.prepare_content("application/json")
    luci.http.write_json(e)
end

function act_start()
    luci.sys.call("/etc/init.d/cupsd start > /dev/null 2>&1")
    luci.sys.call("/etc/init.d/cupsd enable > /dev/null 2>&1")
    luci.http.redirect(luci.dispatcher.build_url("admin/services/cups"))
end

function act_stop()
    luci.sys.call("/etc/init.d/cupsd stop > /dev/null 2>&1")
    luci.http.redirect(luci.dispatcher.build_url("admin/services/cups"))
end

function act_disable()
    luci.sys.call("/etc/init.d/cupsd stop > /dev/null 2>&1")
    luci.sys.call("/etc/init.d/cupsd disable > /dev/null 2>&1")
    luci.http.redirect(luci.dispatcher.build_url("admin/services/cups"))
end
