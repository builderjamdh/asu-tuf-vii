#!/bin/sh
# 魔改固件: 多 WAN 管理 (M29 multiwand 深度内核联动)
# 从 NVRAM 读取配置，直接操作网络接口和路由

ACTION="$1"

start_multiwand() {
	local enable=$(nvram get multiwand_enable)
	if [ "$enable" != "1" ]; then
		echo "multiwand: disabled"
		return 0
	fi

	# 启用 IP 转发
	echo 1 > /proc/sys/net/ipv4/ip_forward

	local wans=$(nvram get multiwand_wans)
	if [ -z "$wans" ]; then
		echo "multiwand: no WAN rules configured"
		return 0
	fi

	# 解析管道分隔的 WAN 配置
	# 格式: iface|type|user|pass|ip|gateway|mask|metric|enabled
	echo "$wans" | while IFS='|' read -r iface type user pass ip gateway mask metric enabled; do
		[ "$enabled" = "0" ] && continue

		case "$type" in
			pppoe)
				# 启动 PPPoE 拨号
				pppd plugin pppoe.so \
					"plugin rp-pppoe.so" \
					"nic-$iface" \
					"user $user" \
					"password $pass" \
					"mtu 1492" \
					"mru 1492" \
					"defaultroute" \
					"nodetach" \
					"metric $metric" \
					>/dev/null 2>&1 &
				echo "multiwand: started PPPoE on $iface (user=$user)"
				;;
			dhcp)
				# 启动 DHCP 客户端
				udhcpc -i "$iface" -b -q -s /usr/share/udhcpc/default.script \
					-m "$metric" >/dev/null 2>&1 &
				echo "multiwand: started DHCP on $iface"
				;;
			static)
				# 配置静态 IP
				ip addr add "$ip/$mask" dev "$iface" 2>/dev/null
				ip link set "$iface" up 2>/dev/null
				[ -n "$gateway" ] && ip route add default via "$gateway" dev "$iface" metric "$metric" 2>/dev/null
				echo "multiwand: configured static $ip/$mask on $iface gw=$gateway"
				;;
		esac
	done

	# 添加 NAT 规则
	local lan_if=$(nvram get lan_ifname)
	for iface in $(echo "$wans" | cut -d'|' -f1); do
		iptables -t nat -A POSTROUTING -o "$iface" -j MASQUERADE 2>/dev/null
	done

	# 加载静态路由
	local routes=$(nvram get multiwand_routes)
	if [ -n "$routes" ]; then
		echo "$routes" | while IFS='|' read -r dest r_iface comment; do
			[ -n "$dest" ] && [ -n "$r_iface" ] && \
				ip route add "$dest" dev "$r_iface" 2>/dev/null
		done
	fi

	echo "multiwand: started"
}

stop_multiwand() {
	# 杀死所有 pppd 进程
	killall -q pppd 2>/dev/null

	# 杀死 udhcpc 进程
	for pidfile in /var/run/udhcpc.*.pid; do
		[ -f "$pidfile" ] && kill $(cat "$pidfile") 2>/dev/null
	done

	# 移除 NAT 规则
	iptables -t nat -D POSTROUTING -j MASQUERADE 2>/dev/null

	# 移除自定义路由
	local routes=$(nvram get multiwand_routes)
	if [ -n "$routes" ]; then
		echo "$routes" | while IFS='|' read -r dest r_iface comment; do
			[ -n "$dest" ] && [ -n "$r_iface" ] && \
				ip route del "$dest" dev "$r_iface" 2>/dev/null
		done
	fi

	echo "multiwand: stopped"
}

case "$ACTION" in
	start)
		start_multiwand
		;;
	stop)
		stop_multiwand
		;;
	restart)
		stop_multiwand
		start_multiwand
		;;
	status)
		echo "=== Multi-WAN Status ==="
		echo "Enable: $(nvram get multiwand_enable)"
		echo "WANs: $(nvram get multiwand_wans)"
		echo "Routes: $(nvram get multiwand_routes)"
		ip -br addr show 2>/dev/null
		;;
	*)
		echo "Usage: $0 {start|stop|restart|status}"
		;;
esac
