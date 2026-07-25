
include ../common.mak
CFLAGS	+= -Wall -fPIC -I. -s -O2
CFLAGS	+= -I$(TOP)/shared -I$(SRCBASE)/include -I$(SRCBASE)/common/include
CFLAGS	+= $(if $(WLAN_ComponentIncPath),$(WLAN_ComponentIncPath),$(addprefix -I,$(wildcard $(SRCBASE)/shared/bcmwifi/include)))

LDFLAGS += -L$(TOP_PLATFORM)/nvram$(BCMEX)${EX7} ${EXTRA_NV_LDFLAGS} -lnvram
LDFLAGS += -L$(TOP)/shared -L$(INSTALLDIR)/shared/usr/lib -lshared

ifeq ($(wildcard $(SRCBASE)/router/eth_monitor/*.c),)
all:
	-cp -f prebuild/eth_monitor ./
else
all: eth_monitor
endif

eth_monitor: eth_monitor.o
	@echo " [eth_monitor] CC $@"
	@$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)
	@$(STRIP) eth_monitor

install: all
	@echo "[eth_monitor] Installing..."
	@install -d $(INSTALLDIR)/usr/sbin
	@install -m 755 eth_monitor $(INSTALLDIR)/usr/sbin

%.o: %.c
	@echo " [eth_monitor] CC $@"
	$(CC) $(CFLAGS) -c $<

clean:
	rm -f *.o eth_monitor
