#!/bin/sh
# 魔改固件: VLAN 管理 (M29 vlan 深度内核联动)
# 从 NVRAM 读取配置，直接操作内核 VLAN 和网桥

ACTION="$1"

detect_vlan_method() {
	if command -v ip >/dev/null 2>&1; then
		VLAN_METHOD="ip"
	elif command -v vconfig >/dev/null 2>&1; then
		VLAN_METHOD="vconfig"
	else
		VLAN_METHOD="none"
	fi
	echo "vlan_mgr: method=$VLAN_METHOD"
}

reset_vlans() {
	# 删除所有自定义 VLAN 接口
	for iface in $(ip -o link show | grep "eth0\." | awk -F': ' '{print $2}' | cut -d'@' -f1); do
		ip link set "$iface" down 2>/dev/null
		ip link delete "$iface" 2>/dev/null
	done

	# 删除所有自定义网桥
	for br in $(brctl show | awk 'NR>1{print $1}' | grep "^br[0-9]"); do
		[ "$br" = "br0" ] && continue
		ip link set "$br" down 2>/dev/null
		brctl delbr "$br" 2>/dev/null
	done

	nvram set vlan_status="已停止"
	echo "vlan_mgr: reset all VLANs"
}

apply_vlan_rules() {
	local enable=$(nvram get vlan_enable)
	if [ "$enable" != "1" ]; then
		echo "vlan_mgr: disabled"
		return 0
	fi

	detect_vlan_method
	[ "$VLAN_METHOD" = "none" ] && { echo "vlan_mgr: no VLAN tool available"; return 1; }

	reset_vlans

	local rules=$(nvram get vlan_rules)
	[ -z "$rules" ] && { echo "vlan_mgr: no rules"; return 0; }

	nvram set vlan_status="运行中"

	# 解析 VLAN 规则
	# 格式: <enable><VID><port_mask><tagged_mask><wl_mask><role><subnet><0
	echo "$rules" | tr '<' '\n' | while read rule; do
		[ -z "$rule" ] && continue

		local r_enable=$(echo "$rule" | cut -d'>' -f1)
		local vid=$(echo "$rule" | cut -d'>' -f2)
		local port_mask=$(echo "$rule" | cut -d'>' -f3)
		local tagged_mask=$(echo "$rule" | cut -d'>' -f4)
		local wl_mask=$(echo "$rule" | cut -d'>' -f5)
		local role=$(echo "$rule" | cut -d'>' -f6)
		local subnet=$(echo "$rule" | cut -d'>' -f7)

		[ "$r_enable" != "1" ] && continue
		[ -z "$vid" ] && continue

		# 创建 VLAN 子接口
		if [ "$VLAN_METHOD" = "ip" ]; then
			ip link add link eth0 name "eth0.v${vid}" type vlan id "$vid" 2>/dev/null
			ip link set "eth0.v${vid}" up 2>/dev/null
		else
			vconfig add eth0 "$vid" 2>/dev/null
			ifconfig "eth0.${vid}" up 2>/dev/null
		fi

		if [ "$role" = "wan" ]; then
			# WAN VLAN: 设置 WAN 接口
			nvram set wan0_ifname="eth0.v${vid}"
			nvram set wan0_vid="$vid"
			nvram set switch_wantag="vlan"
			echo "vlan_mgr: WAN VLAN $vid created"
		elif [ "$role" = "lan" ]; then
			# LAN VLAN: 创建网桥并添加接口
			local brname="br${vid}"
			brctl addbr "$brname" 2>/dev/null
			brctl addif "$brname" "eth0.v${vid}" 2>/dev/null
			ip link set "$brname" up 2>/dev/null

			if [ -n "$subnet" ]; then
				local ip_addr=$(echo "$subnet" | cut -d'/' -f1)
				local cidr=$(echo "$subnet" | cut -d'/' -f2)
				ip addr add "${ip_addr}/${cidr}" dev "$brname" 2>/dev/null
			fi
			echo "vlan_mgr: LAN VLAN $vid created on $brname"
		fi
	done

	# 添加 rc_support 标志
	local current_support=$(nvram get rc_support)
	for flag in tagged_based_vlan vlan; do
		echo "$current_support" | grep -qw "$flag" || {
			nvram set rc_support="$current_support $flag"
			current_support=$(nvram get rc_support)
		}
	done

	echo "vlan_mgr: all rules applied"
}

stop_vlan() {
	reset_vlans
	nvram unset wan0_ifname
	nvram unset wan0_vid
	nvram unset switch_wantag
	echo "vlan_mgr: stopped"
}

case "$ACTION" in
	start)
		apply_vlan_rules
		;;
	stop)
		stop_vlan
		;;
	restart)
		stop_vlan
		apply_vlan_rules
		;;
	status)
		echo "=== VLAN Status ==="
		echo "Enable: $(nvram get vlan_enable)"
		echo "Status: $(nvram get vlan_status)"
		echo "Rules: $(nvram get vlan_rules)"
		echo "Method: ${VLAN_METHOD:-unknown}"
		ip -o link show | grep -E "eth0\.|bond" 2>/dev/null
		brctl show 2>/dev/null
		;;
	*)
		echo "Usage: $0 {start|stop|restart|status}"
		;;
esac
