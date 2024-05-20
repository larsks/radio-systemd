prefix=/usr
libexecdir=$(prefix)/libexec/radio
sysconfdir=/etc
unitdir=$(sysconfdir)/systemd/system
tmpfiledir=$(sysconfdir)/tmpfiles.d

INSTALL=install

HELPERS=\
				helpers/ax25ipd-start.sh \
				helpers/kissattach-start.sh

UNITS=\
			units/radio.target \
			units/ax25ports.target \
			units/kissattach@.service \
			units/ax25ipd@.service \
			units/ax25d.service \
			units/mheardd.service

TMPFILES=$(wildcard tmpfiles/*.conf)

all:

install: install-helpers install-units install-tmpfiles

install-helpers: $(HELPERS)
	$(INSTALL) -m 755 -d $(DESTDIR)$(libexecdir)
	$(INSTALL) -m 755 $(HELPERS) $(DESTDIR)$(libexecdir)/

install-units: $(UNITS)
	$(INSTALL) -m 755 -d $(DESTDIR)$(unitdir)
	$(INSTALL) -m 644 $(UNITS) $(DESTDIR)/$(unitdir)/

install-tmpfiles: $(TMPFILES)
	$(INSTALL) -m 755 -d $(DESTDIR)$(tmpfiledir)
	$(INSTALL) -m 644 $(TMPFILES) $(DESTDIR)/$(tmpfiledir)/
