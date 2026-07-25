<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta http-equiv="Pragma" content="no-cache">
<title>多 WAN 管理</title>
<link rel="stylesheet" type="text/css" href="/form_style.css">
<link rel="stylesheet" type="text/css" href="/index_style.css">
<script language="JavaScript" type="text/javascript" src="/state.js"></script>
<script language="JavaScript" type="text/javascript" src="/general.js"></script>
<script>
function applySettings() {
	var f = document.forms["multiwand_form"];
	var params = {
		"multiwand_enable": f.multiwand_enable.checked ? "1" : "0",
		"multiwand_wans": f.multiwand_wans.value,
		"multiwand_routes": f.multiwand_routes.value
	};
	httpApi.nvramSet(params, function() {
		httpApi.exec("multiwand.sh restart", function() {
			alert("设置已应用，页面将刷新");
			location.reload();
		});
	});
}
</script>
</head>
<body onload="show_menu();">
<div id="TopBanner"></div>
<table class="content" align="center" cellpadding="0" cellspacing="0">
<tr>
	<td width="17">&nbsp;</td>
	<td valign="top" width="202"><div id="mainMenu"></div><div id="subMenu"></div></td>
	<td valign="top">
		<div id="tabMenu" class="submenuBlock"></div>
		<table width="98%" border="0" cellpadding="5" cellspacing="0" class="FormTitle" id="FormTitle">
		<tr><td bgcolor="#4D595D" valign="top">
			<div>&nbsp;</div>
			<div class="formfonttitle">多 WAN 管理 (multiwand)</div>
			<div class="formfontdesc">配置多 WAN 拨号 (PPPoE/DHCP/静态IP) 和策略路由。</div>

			<table width="100%" border="1" cellpadding="4" cellspacing="0" class="FormTable">
			<tr><th colspan="2">当前状态</th></tr>
			<tr><td>功能状态</td><td><% nvram_match("multiwand_enable", "1", "已启用"); %><% nvram_match("multiwand_enable", "0", "已禁用"); %></td></tr>
			<tr><td>WAN 配置</td><td style="word-break:break-all;max-width:400px;"><% nvram_get("multiwand_wans"); %></td></tr>
			</table>

			<form name="multiwand_form" method="post">
			<table width="100%" border="1" cellpadding="4" cellspacing="0" class="FormTable">
			<tr><th colspan="2">WAN 配置</th></tr>
			<tr><td>启用多 WAN</td><td><input type="checkbox" name="multiwand_enable" <% nvram_match("multiwand_enable", "1", "checked"); %>></td></tr>
			<tr><td>WAN 规则<br><span style="font-weight:normal;font-size:11px;">格式: 接口|类型|用户名|密码|IP|网关|掩码|跃点|启用<br>类型: PPPoE/DHCP/静态</span></td>
			<td><textarea name="multiwand_wans" class="textarea_32_table" rows="6"><% nvram_get("multiwand_wans"); %></textarea></td></tr>
			<tr><td>静态路由<br><span style="font-weight:normal;font-size:11px;">格式: 目标网段|接口|备注</span></td>
			<td><textarea name="multiwand_routes" class="textarea_32_table" rows="4"><% nvram_get("multiwand_routes"); %></textarea></td></tr>
			</table>
			</form>
			<div class="apply_gen"><input class="button_gen" onclick="applySettings();" type="button" value="应用设置"></div>
		</td></tr></table>
	</td></tr>
</table>
<div id="footer"></div>
</body></html>
