#!/bin/sh
# 魔改固件: CPU 频率管理 (M29 cpupower 深度内核联动)
# 从 NVRAM 读取配置，直接操作 sysfs 内核接口

ACTION="$1"

apply_cpupower_settings() {
	local enable=$(nvram get cpupower_enable)
	local governor=$(nvram get cpupower_governor)
	local min_freq=$(nvram get cpupower_min_freq)
	local max_freq=$(nvram get cpupower_max_freq)
	local ondemand_rate=$(nvram get cpupower_ondemand_rate)
	local ondemand_up=$(nvram get cpupower_ondemand_up)
	local ondemand_down=$(nvram get cpupower_ondemand_down)

	if [ "$enable" != "1" ]; then
		echo "cpupower: disabled (cpupower_enable!=1)"
		return 0
	fi

	# 设置所有 CPU 核心的调速器
	for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
		[ -f "$cpu/cpufreq/scaling_governor" ] || continue

		# 设置调速器
		if [ -n "$governor" ] && [ "$governor" != "ondemand" ]; then
			echo "$governor" > "$cpu/cpufreq/scaling_governor" 2>/dev/null
		elif [ "$governor" = "ondemand" ] || [ -z "$governor" ]; then
			echo "ondemand" > "$cpu/cpufreq/scaling_governor" 2>/dev/null
		fi

		# 设置最小频率
		if [ -n "$min_freq" ]; then
			echo "$min_freq" > "$cpu/cpufreq/scaling_min_freq" 2>/dev/null
		fi

		# 设置最大频率
		if [ -n "$max_freq" ]; then
			echo "$max_freq" > "$cpu/cpufreq/scaling_max_freq" 2>/dev/null
		fi
	done

	# ondemand 调速器参数
	if [ "$governor" = "ondemand" ] || [ -z "$governor" ]; then
		for path in /sys/devices/system/cpu/cpufreq/ondemand; do
			[ -d "$path" ] || continue
			[ -n "$ondemand_rate" ] && echo "$ondemand_rate" > "$path/sampling_rate" 2>/dev/null
			[ -n "$ondemand_up" ] && echo "$ondemand_up" > "$path/up_threshold" 2>/dev/null
			[ -n "$ondemand_down" ] && echo "$ondemand_down" > "$path/sampling_down_factor" 2>/dev/null
		done
	fi

	# Broadcom clkfreq (需要重启生效)
	local clkfreq=$(nvram get cpupower_clkfreq)
	if [ -n "$clkfreq" ]; then
		nvram set clkfreq="$clkfreq"
	fi

	echo "cpupower: applied governor=$governor min=$min_freq max=$max_freq"
}

stop_cpupower() {
	# 恢复默认 performance 调速器
	for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
		[ -f "$cpu/cpufreq/scaling_governor" ] && echo "performance" > "$cpu/cpufreq/scaling_governor" 2>/dev/null
	done
	echo "cpupower: stopped, restored performance governor"
}

case "$ACTION" in
	start|load)
		apply_cpupower_settings
		;;
	stop)
		stop_cpupower
		;;
	restart)
		stop_cpupower
		apply_cpupower_settings
		;;
	status)
		echo "=== CPU Power Status ==="
		echo "Enable: $(nvram get cpupower_enable)"
		echo "Governor: $(nvram get cpupower_governor)"
		for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
			[ -f "$cpu/cpufreq/scaling_cur_freq" ] || continue
			name=$(basename $cpu)
			cur=$(cat "$cpu/cpufreq/scaling_cur_freq" 2>/dev/null)
			gov=$(cat "$cpu/cpufreq/scaling_governor" 2>/dev/null)
			echo "  $name: ${cur}kHz ($gov)"
		done
		;;
	*)
		echo "Usage: $0 {start|stop|restart|status}"
		;;
esac
