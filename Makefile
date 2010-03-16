
# if you are eager to use: change SMSW_VAR && make && ./smsw
# TOFIX test install make target
# otherwise goto #VARS: && clear this-is-beta-soft && make install && smsw

NAME		:= smsw
VERSION		:= $(shell cat VERSION)
FULLNAME	:= ${NAME}-${VERSION}

SRC		:= $(shell pwd)
DESTDIR		:=
PREFIX		:= /usr/local

#VARS: rehash if you want to install

# as it is it's suited to be run from within the source dir
SMSW_ETC	:= ${SRC}/etc
#SMSW_ETC	:= ${PREFIX}/etc

SMSW_LIB	:= ${SRC}
#SMSW_LIB	:= ${PREFIX}/lib/${NAME}

SMSW_VAR	:= /mnt/hd/eh/sla/${NAME}
#SMSW_VAR	:= ${PREFIX}/var/${NAME}

SMSW_DOC	:= ${PREFIX}/doc/${FULLNAME}

### shouldn't need to tinker beyond this point ###

EXTERNAL	:= scheme/globals/external.scm

top_files	:= Makefile VERSION
doc_files	:= README
DOC_FILES	:= TRIVIA DESIGN
IN_FILES	:= external.scm load.scm ${NAME}
ETC_FILES	:= main mirrors

# perhaps this way it would be more error prone but...
#scheme_dirs	:= access config globals help mirror pkg utils
#scheme_srcs	:= scheme/packages.scm\
#		   $(wildcard $(scheme_dirs:%=scheme/%/*.scm))
# this way makes us depend on find...

scheme_srcs	:= $(shell find scheme -name "*.scm")
SCM_FILES	:= $(filter-out ${EXTERNAL},${scheme_srcs})

FILES		:= ${top_files} ${doc_files} $(DOC_FILES:%=doc/%)\
		   $(IN_FILES:%=in/%) $(ETC_FILES:%=etc/%) $(SCM_FILES)

GEN_FILES	:= ${NAME} load.scm ${EXTERNAL}

### make
all: ${GEN_FILES}

${NAME}: in/${NAME}
	sed -s 's|@SMSW_LIB@|${SMSW_LIB}|' $< > $@
	chmod +x $@

load.scm: in/load.scm
	sed -s 's|@SMSW_LIB@|${SMSW_LIB}|' $< > $@

${EXTERNAL}: in/external.scm
	sed -s 's|@SMSW_ETC@|${SMSW_ETC}|;\
		s|@SMSW_VAR@|${SMSW_VAR}|' $< > $@

this-is-beta-soft: use-the-force-luke-read-the-source

### (un)install for now blocked because we r a freid of nuking ${SRC}
install: all this-is-beta-soft
# binwrapper
	mkdir -p ${DESTDIR}${PREFIX}/bin
	cp ${NAME} ${DESTDIR}${PREFIX}/bin
# example config files
	mkdir -p ${DESTDIR}${SMSW_ETC}
	for f in ${ETC_FILES} ; do\
	  cp etc/$$f ${DESTDIR}${SMSW_ETC}/$$f.example ;\
	done
# libraries
	mkdir -p ${DESTDIR}${SMSW_LIB}
	cp load.scm ${DESTDIR}${SMSW_LIB}
# TODO lazy mofo
	cp -r scheme ${DESTDIR}${SMSW_LIB}
# docs
	mkdir -p ${DESTDIR}${SMSW_DOC}
	cp ${DOC_FILES} ${DESTDIR}${SMSW_DOC}
# TODO SMSW_VAR should have some special perms...
	mkdir -p ${DESTDIR}${SMSW_VAR}
# perhaps only accessible to installers group? for now
	chmod 770 ${DESTDIR}${SMSW_VAR}

uninstall: this-is-beta-soft
	rm ${PREFIX}/bin/${NAME}
# but preserve configs?
	rm -f ${SMSW_ETC}/*.example
	rm -rf ${SMSW_LIB}
	rm -rf ${SMSW_DOC}
	@echo "To be complete rm -rf ${SMSW_ETC} ${SMSW_VAR}"

### archive
pack: ../${FULLNAME}.tar.bz2

../${FULLNAME}.tar.bz2: ${FILES}
	rm -f $@
	mkdir ${FULLNAME}
	for f in ${FILES} ; do\
	  d=$$(dirname $$f) ;\
	  mkdir -p ${FULLNAME}/$$d &&\
	  cp -a $$f ${FULLNAME}/$$d ;\
	done
	tar vcjf $@ ${FULLNAME} && rm -rf ${FULLNAME}

### clean up
clean: clean-baks
	rm -f ${GEN_FILES}
	rm -rf ${FULLNAME}

clean-baks:
	find -name "*~" | xargs rm -f

test:
	@echo ${scheme_srcs} | wc
	@echo ${FILES} | wc
