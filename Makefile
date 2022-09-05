#
# Top-level Makefile for the CUPS commands.
#
# Copyright © 2022 by OpenPrinting.
#
# Licensed under Apache License v2.0.  See the file "LICENSE" for more
# information.
#

include Makedefs


# Source directories...
DIRS	=	\
		commands \
		locale \
		man


#
# Make all targets...
#

all:
	for dir in $(DIRS); do \
		echo "======== all in $$dir ========"; \
		(cd $$dir; $(MAKE) $(MFLAGS) all) || exit 1; \
	done


#
# Remove object and target files...
#

clean:
	for dir in $(DIRS); do \
		echo "======== clean in $$dir ========"; \
		(cd $$dir; $(MAKE) $(MFLAGS) clean) || exit 1; \
	done


#
# Remove all non-distribution files...
#

distclean:	clean
	echo "Cleaning generated files."
	$(RM) Makedefs config.h config.log config.status
	-$(RM) -r autom4te*.cache


#
# Make dependencies
#

depend:
	for dir in $(DIRS); do \
		echo "======== depend in $$dir ========"; \
		(cd $$dir; $(MAKE) $(MFLAGS) depend) || exit 1; \
	done


#
# Install everything...
#

install:
	for dir in $(DIRS); do \
		echo "======== install in $$dir ========"; \
		(cd $$dir; $(MAKE) $(MFLAGS) install) || exit 1; \
	done


#
# Test everything...
#

.PHONY: test

test:
	for dir in $(DIRS); do \
		echo "======== test in $$dir ========"; \
		(cd $$dir; $(MAKE) $(MFLAGS) test) || exit 1; \
	done


#
# Don't run top-level build targets in parallel...
#

.NOTPARALLEL:
