
# if you are eager to use change SMSW_VAR && make && ./smsw
# TOFIX wite install make target
# otherwise goto #VARS: && make install && smsw

NAME		:= smsw
VERSION		:= $(shell cat VERSION)
FULLNAME	:= ${NAME}-${VERSION}

SRC		:= $(shell pwd)
DESTDIR		:=

#VARS: change to suit

SMSW_ETC	:= ${SRC}/etc
SMSW_LIB	:= ${SRC}
SMSW_VAR	:= /mnt/hd/eh/sla/${NAME}

### shouldn't need to tinker beyond this point ###

EXTERNAL	:= scheme/globals/external.scm

TOP_FILES	:= Makefile VERSION
DOC_FILES	:= README
IN_FILES	:= external.scm load.scm ${NAME}
ETC_FILES	:= main mirrors

# perhaps this way it would be more error prone but...
#scheme_dirs	:= access config globals help mirror pkg utils
#scheme_srcs	:= scheme/packages.scm\
#		   $(wildcard $(scheme_dirs:%=scheme/%/*.scm))
# this way we depend on find...

scheme_srcs	:= $(shell find scheme -name "*.scm")
SCM_FILES	:= $(filter-out ${EXTERNAL},${scheme_srcs})

FILES		:= ${TOP_FILES} ${DOC_FILES} $(IN_FILES:%=in/%)\
		   $(ETC_FILES:%=etc/%) $(SCM_FILES)

GEN_FILES	:= ${NAME} load.scm ${EXTERNAL}

all: ${GEN_FILES}

${NAME}: in/${NAME}
	sed -s 's|@SMSW_LIB@|${SMSW_LIB}|' $< > $@
	chmod +x $@

load.scm: in/load.scm
	sed -s 's|@SMSW_LIB@|${SMSW_LIB}|' $< > $@

${EXTERNAL}: in/external.scm
	sed -s 's|@SMSW_ETC@|${SMSW_ETC}|;\
		s|@SMSW_VAR@|${SMSW_VAR}|' $< > $@

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
	tar cjf $@ ${FULLNAME} && rm -rf ${FULLNAME}

### clean up
clean: clean-baks
	rm -f ${GEN_FILES}
	rm -rf ${FULLNAME}

clean-baks:
	find -name "*~" | xargs rm -f

test:
	@echo ${scheme_srcs} | wc
	@echo ${FILES} | wc
