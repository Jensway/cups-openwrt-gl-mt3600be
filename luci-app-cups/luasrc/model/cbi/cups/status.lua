-- LuCI CBI 页面：OpenPrinting CUPS 2.4.16 状态与操作
-- 显示版本、运行状态、跳转链接、启动/停止/移除

local m, s

m = Map("cups", translate("OpenPrinting CUPS 2.4.16"))
m.title = translate("打印服务器")
m.description = translate("OpenPrinting CUPS 2.4.16 - 网络打印共享，支持 AirPrint / IPP Everywhere。")
m.pageaction = false

s = m:section(SimpleSection)
s.template = "cups/status"

return m
