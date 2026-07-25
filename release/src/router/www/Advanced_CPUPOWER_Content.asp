<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta http-equiv="Pragma" content="no-cache">
<title>CPU 调度控制</title>
<link rel="stylesheet" type="text/css" href="/form_style.css">
<link rel="stylesheet" type="text/css" href="/index_style.css">
<script language="JavaScript" type="text/javascript" src="/state.js"></script>
<script language="JavaScript" type="text/javascript" src="/general.js"></script>
<script language="JavaScript" type="text/javascript" src="/popup.js"></script>
<script>
function applySettings() {
	var f = document.forms["cpupower_form"];
	var params = {
		"cpupower_enable": f.cpupower_enable.checked ? "1" : "0",
		"cpupower_governor": f.cpupower_governor.value,
		"cpupower_min_freq": f.cpupower_min_freq.value,
		"cpupower_max_freq": f.cpupower_max_freq.value,
		"cpupower_ondemand_rate": f.cpupower_ondemand_rate.value,
		"cpupower_ondemand_up": f.cpupower_ondemand_up.value,
		"cpupower_ondemand_down": f.cpupower_ondemand_down.value
	};
	httpApi.nvramSet(params, function() {
		httpApi.exec("cpupower.sh restart", function() {
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
			<div class="formfonttitle">CPU 调度控制 (cpupower)</div>
			<div class="formfontdesc">BCM6764 四核 Cortex-A7 CPU 调度器、频率管理与温度监控。</div>

			<table width="100%" border="1" cellpadding="4" cellspacing="0" class="FormTable">
			<tr><th colspan="2">当前状态</th></tr>
			<tr><td>当前频率</td><td><% get_cpupower_status(); %> MHz</td></tr>
			<tr><td>功能状态</td><td><% nvram_match("cpupower_enable", "1", "已启用"); %><% nvram_match("cpupower_enable", "0", "已禁用"); %></td></tr>
			<tr><td>当前温度</td><td><% get_cpu_temperature(); %> &deg;C</td></tr>
			</table>

			<form name="cpupower_form" method="post">
			<table width="100%" border="1" cellpadding="4" cellspacing="0" class="FormTable">
			<tr><th colspan="2">调度设置</th></tr>
			<tr><td>启用 CPU 调度管理</td><td><input type="checkbox" name="cpupower_enable" <% nvram_match("cpupower_enable", "1", "checked"); %>></td></tr>
			<tr><td>CPU 调速器</td><td>
				<select name="cpupower_governor" class="input_option">
					<option value="ondemand" <% nvram_match("cpupower_governor", "ondemand", "selected"); %>>ondemand</option>
					<option value="performance" <% nvram_match("cpupower_governor", "performance", "selected"); %>>performance</option>
					<option value="powersave" <% nvram_match("cpupower_governor", "powersave", "selected"); %>>powersave</option>
					<option value="conservative" <% nvram_match("cpupower_governor", "conservative", "selected"); %>>conservative</option>
					<option value="schedutil" <% nvram_match("cpupower_governor", "schedutil", "selected"); %>>schedutil</option>
				</select></td></tr>
			<tr><td>最小频率 (KHz)</td><td><input type="text" name="cpupower_min_freq" class="input_32_table" value="<% nvram_get("cpupower_min_freq"); %>" maxlength="10"></td></tr>
			<tr><td>最大频率 (KHz)</td><td><input type="text" name="cpupower_max_freq" class="input_32_table" value="<% nvram_get("cpupower_max_freq"); %>" maxlength="10"></td></tr>
			<tr><th colspan="2">Ondemand 参数</th></tr>
			<tr><td>采样率 (μs)</td><td><input type="text" name="cpupower_ondemand_rate" class="input_32_table" value="<% nvram_get("cpupower_ondemand_rate"); %>" maxlength="10"></td></tr>
			<tr><td>升频阈值 (%)</td><td><input type="text" name="cpupower_ondemand_up" class="input_32_table" value="<% nvram_get("cpupower_ondemand_up"); %>" maxlength="5"></td></tr>
			<tr><td>降频因子</td><td><input type="text" name="cpupower_ondemand_down" class="input_32_table" value="<% nvram_get("cpupower_ondemand_down"); %>" maxlength="5"></td></tr>
			</table>
			</form>
			<div class="apply_gen"><input class="button_gen" onclick="applySettings();" type="button" value="应用设置"></div>
		</td></tr></table>
	</td></tr>
</table>
<div id="footer"></div>
</body></html>
