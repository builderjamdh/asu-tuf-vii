<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta http-equiv="Pragma" content="no-cache">
<title>自定义防火墙</title>
<link rel="stylesheet" type="text/css" href="/form_style.css">
<link rel="stylesheet" type="text/css" href="/index_style.css">
<script language="JavaScript" type="text/javascript" src="/state.js"></script>
<script language="JavaScript" type="text/javascript" src="/general.js"></script>
<script language="JavaScript" type="text/javascript" src="/popup.js"></script>
<script>
function applySettings() {
	var params = {
		"fb_custom_enable": document.forms["fb_form"].fb_custom_enable.checked ? "1" : "0",
		"fb_ipv4_rules": document.forms["fb_form"].fb_ipv4_rules.value,
		"fb_ipv6_rules": document.forms["fb_form"].fb_ipv6_rules.value
	};
	httpApi.nvramSet(params, function() {
		httpApi.exec("fb_custom.sh restart", function() {
			alert("Firewall rules applied");
			location.reload();
		});
	});
}
function init() {
	show_menu();
	var enable = "<% nvram_match("fb_custom_enable", "1", "1"); %>";
	document.getElementById("fb_custom_enable").checked = (enable == "1");
}
</script>
</head>
<body onload="init();">
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
			<div class="formfonttitle">自定义防火墙规则 (Firewall Custom)</div>
			<div class="formfontdesc">添加自定义 iptables/ip6tables 规则，支持 INPUT、FORWARD、OUTPUT 链。<br>每行一条规则，以 # 开头的行为注释。</div>

			<table width="100%" border="1" cellpadding="4" cellspacing="0" class="FormTable">
			<tr><th colspan="2">当前状态</th></tr>
			<tr><td>BBR TCP 加速</td><td><% get_bbr_status(); %></td></tr>
			<tr><td>防火墙规则已启用</td><td><% nvram_match("fb_custom_enable", "1", "是"); %><% nvram_match("fb_custom_enable", "0", "否"); %></td></tr>
			</table>

			<form name="fb_form" method="post">
			<table width="100%" border="1" cellpadding="4" cellspacing="0" class="FormTable">
			<tr><th colspan="2">防火墙规则启用</th></tr>
			<tr><td>启用自定义防火墙</td><td><input type="checkbox" id="fb_custom_enable" name="fb_custom_enable" <% nvram_match("fb_custom_enable", "1", "checked"); %>></td></tr>
			<tr><th colspan="2">IPv4 规则 (iptables)</th></tr>
			<tr><td colspan="2">
				<textarea name="fb_ipv4_rules" class="input_textarea" rows="15" style="width:98%;font-family:monospace;font-size:12px;"><% nvram_get("fb_ipv4_rules"); %></textarea>
			</td></tr>
			<tr><th colspan="2">IPv6 规则 (ip6tables)</th></tr>
			<tr><td colspan="2">
				<textarea name="fb_ipv6_rules" class="input_textarea" rows="15" style="width:98%;font-family:monospace;font-size:12px;"><% nvram_get("fb_ipv6_rules"); %></textarea>
			</td></tr>
			</table>

			<div class="apply_gen" style="margin-top:10px;">
				<input type="button" class="button_gen" value="应用" onclick="applySettings();">
			</div>
			</form>
		</td></tr>
		</table>
	</td>
</tr>
</table>
</body>
</html>
