<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta http-equiv="Pragma" content="no-cache">
<title>VLAN 管理</title>
<link rel="stylesheet" type="text/css" href="/form_style.css">
<link rel="stylesheet" type="text/css" href="/index_style.css">
<script language="JavaScript" type="text/javascript" src="/state.js"></script>
<script language="JavaScript" type="text/javascript" src="/general.js"></script>
<script>
var vlanRules = [];

function addRule() {
	var vid = document.getElementById("new_vid").value;
	var role = document.getElementById("new_role").value;
	var subnet = document.getElementById("new_subnet").value;
	if (!vid || vid < 1 || vid > 4094) { alert("VLAN ID 1-4094"); return; }
	vlanRules.push("1>" + vid + ">0>0>0>" + role + ">" + subnet + ">0");
	refreshTable();
}
function delRule(i) { vlanRules.splice(i, 1); refreshTable(); }
function refreshTable() {
	var h = "";
	for (var i = 0; i < vlanRules.length; i++) {
		var p = vlanRules[i].split(">");
		h += "<tr><td>" + p[1] + "</td><td>" + p[5] + "</td><td>" + p[6] + "</td>";
		h += "<td><input type='button' class='remove_btn' onclick='delRule(" + i + ")' value='删除'></td></tr>";
	}
	document.getElementById("rb").innerHTML = h;
}
function applySettings() {
	var params = {
		"vlan_enable": document.getElementById("vlan_en").checked ? "1" : "0",
		"vlan_rules": vlanRules.join("<")
	};
	httpApi.nvramSet(params, function() {
		httpApi.exec("vlan_mgr.sh restart", function() {
			alert("VLAN 设置已应用");
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
			<div class="formfonttitle">VLAN 管理 (vlan)</div>
			<div class="formfontdesc">802.1Q VLAN 配置、端口划分和网桥管理。RTL8372 交换机支持。</div>

			<table width="100%" border="1" cellpadding="4" cellspacing="0" class="FormTable">
			<tr><th colspan="2">当前状态</th></tr>
			<tr><td>功能状态</td><td><% nvram_match("vlan_enable", "1", "运行中"); %><% nvram_match("vlan_enable", "0", "已停止"); %></td></tr>
			</table>

			<table width="100%" border="1" cellpadding="4" cellspacing="0" class="FormTable">
			<tr><th colspan="2">VLAN 配置</th></tr>
			<tr><td>启用 VLAN</td><td><input type="checkbox" id="vlan_en" <% nvram_match("vlan_enable", "1", "checked"); %>></td></tr>
			<tr><td>添加规则</td><td>
				<input type="text" id="new_vid" class="input_6_table" placeholder="VID" maxlength="4" style="width:60px;">
				<select id="new_role" class="input_option"><option value="lan">LAN</option><option value="wan">WAN</option></select>
				<input type="text" id="new_subnet" class="input_32_table" placeholder="192.168.10.1/24" style="width:200px;">
				<input type="button" class="add_btn" onclick="addRule();" value="添加"></td></tr>
			</table>

			<table width="100%" border="1" cellpadding="4" cellspacing="0" class="FormTable">
			<tr><th>VLAN ID</th><th>角色</th><th>子网</th><th>操作</th></tr>
			<tbody id="rb"></tbody></table>

			<div class="apply_gen"><input class="button_gen" onclick="applySettings();" type="button" value="应用设置"></div>
		</td></tr></table>
	</td></tr>
</table>
<div id="footer"></div>
</body></html>
