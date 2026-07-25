include ${TOP}/common.mak

CFLAGS += -O2 -Wall $(EXTRACFLAGS) -fPIC
LDFLAGS += -lcrypt

CFLAGS += -I$(TOP)/openssl/include
LDFLAGS += -L$(TOP)/openssl -lcrypto

#rtconfig.h
CFLAGS += -I$(TOP)/shared

OBJS = ateed.o utility.o

ifeq ($(RTCONFIG_HND_ROUTER_AX_6756),y)
CFLAGS += -D_GNU_SOURCE
CFLAGS += -I$(BCM_FSBUILD_DIR)/public/include/
LDFLAGS += -L$(BCM_FSBUILD_DIR)/public/lib/ -lteec
OBJS += sec_key_lib.o
OBJS += bcm.o
endif

INSTALL = install

ifneq ($(wildcard ./prebuild),)
all:
	@-cp -f ./prebuild/* .
else
all: ateed libatee.so
endif

ateed: $(OBJS)
	@$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

libatee.so: libatee.o
	@$(CC) -shared $(LDFLAGS) -o $@ $^

install: all
	$(INSTALL) -d $(INSTALLDIR)/usr/sbin/
	$(INSTALL) ateed $(INSTALLDIR)/usr/sbin/ateed
	$(STRIP) $(INSTALLDIR)/usr/sbin/ateed
	$(INSTALL) -d $(INSTALLDIR)/usr/lib/
	$(INSTALL) libatee.so $(INSTALLDIR)/usr/lib
	$(STRIP) $(INSTALLDIR)/usr/lib/libatee.so

clean:
	rm -f ateed *.o .*.depend

%.o: %.c .%.depend
	@echo " [ateed] CC $@"
	@$(CC) $(CFLAGS) -o $@ -c $<

.%.depend: %.c
	@$(CC) $(CFLAGS) -M $< > $@

-include $(OBJS:%.o=.%.depend)
