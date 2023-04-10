
MACHINE     ?= x16
# also supported:
# * c64

CORE_SOURCE_BASE ?= CBM
SERIAL_SOURCE_BASE ?= CBM
# for both also supported
# * OPENROMS

ifdef RELEASE_VERSION
	VERSION_DEFINE="-DRELEASE_VERSION=$(RELEASE_VERSION)"
endif
ifdef PRERELEASE_VERSION
	VERSION_DEFINE="-DPRERELEASE_VERSION=$(PRERELEASE_VERSION)"
endif

CC           = cc65
AS           = ca65
LD           = ld65

# global includes
ASFLAGS     += -I inc
# for GEOS
ASFLAGS     += -D bsw=1 -D drv1541=1 -I geos/inc -I geos
# for monitor
ASFLAGS     += -D CPU_65C02=1
# KERNAL version number
ASFLAGS     +=  $(VERSION_DEFINE)
# put all symbols into .sym files
ASFLAGS     += -g

ifeq ($(MACHINE),x16)
ASFLAGS     += -D MACHINE_X16=1
# all files are allowed to use 65SC02 features
ASFLAGS     += --cpu 65SC02
else # c64
ASFLAGS     += -D MACHINE_C64=1
endif

BUILD_DIR=build/$(MACHINE)

CFG_DIR=$(BUILD_DIR)/cfg

KERNAL_CORE_CBM_SOURCES = \
	kernal/cbm/editor.s \
	kernal/cbm/channel/channel.s \
	kernal/cbm/init.s \
	kernal/cbm/memory.s \
	kernal/cbm/nmi.s \
	kernal/cbm/irq.s \
	kernal/cbm/util.s

KERNAL_SERIAL_CBM_SOURCES = \
	kernal/cbm/serial.s

KERNAL_SERIAL_OPENROMS_SOURCES = # TODO

KERNAL_CORE_OPENROMS_SOURCES = \
	kernal/open-roms/open-roms.s

KERNAL_CORE_SOURCES = \
	kernal/declare.s \
	kernal/vectors.s \
	kernal/kbdbuf.s \
	kernal/memory.s \
	kernal/lzsa.s \
	kernal/signature.s

ifeq ($(CORE_SOURCE_BASE),CBM)
	KERNAL_CORE_SOURCES += $(KERNAL_CORE_CBM_SOURCES)
else ifeq ($(CORE_SOURCE_BASE),OPENROMS)
	KERNAL_CORE_SOURCES += $(KERNAL_CORE_OPENROMS_SOURCES)
else
$(error Illegal value for CORE_SOURCE_BASE)
endif

ifeq ($(SERIAL_SOURCE_BASE),CBM)
	KERNAL_CORE_SOURCES += $(KERNAL_SERIAL_CBM_SOURCES)
else
	KERNAL_CORE_SOURCES += $(KERNAL_SERIAL_OPENROMS_SOURCES)
endif

KERNAL_GRAPH_SOURCES = \
	kernal/graph/graph.s \
	kernal/fonts/fonts.s \
	kernal/graph/console.s

ifeq ($(MACHINE),c64)
	KERNAL_DRIVER_SOURCES = \
		kernal/drivers/c64/c64.s \
		kernal/drivers/c64/clock.s \
		kernal/drivers/c64/entropy.s \
		kernal/drivers/c64/joystick.s \
		kernal/drivers/c64/kbd.s \
		kernal/drivers/c64/memory.s \
		kernal/drivers/c64/mouse.s \
		kernal/drivers/c64/rs232.s \
		kernal/drivers/c64/screen.s \
		kernal/drivers/c64/sprites.s \
		kernal/drivers/generic/softclock_timer.s \
		kernal/drivers/generic/softclock_time.s \
		kernal/drivers/generic/softclock_date.s
else ifeq ($(MACHINE),x16)
	KERNAL_DRIVER_SOURCES = \
		kernal/drivers/x16/x16.s \
		kernal/drivers/x16/memory.s \
		kernal/drivers/x16/screen.s \
		kernal/drivers/x16/ps2kbd.s \
		kernal/drivers/x16/ps2mouse.s \
		kernal/drivers/x16/joystick.s \
		kernal/drivers/x16/clock.s \
		kernal/drivers/x16/rs232.s \
		kernal/drivers/x16/framebuffer.s \
		kernal/drivers/x16/sprites.s \
		kernal/drivers/x16/entropy.s \
		kernal/drivers/x16/beep.s \
		kernal/drivers/x16/i2c.s \
		kernal/drivers/x16/smc.s \
		kernal/drivers/x16/rtc.s \
		kernal/drivers/generic/softclock_timer.s
else
$(error Illegal value for MACHINE)
endif

KERNAL_SOURCES = \
	$(KERNAL_CORE_SOURCES) \
	$(KERNAL_DRIVER_SOURCES)

ifneq ($(MACHINE),c64)
	KERNAL_SOURCES += \
		$(KERNAL_GRAPH_SOURCES) \
		kernal/ieee_switch.s
endif

KEYMAP_SOURCES = \
	keymap/keymap.s \
	keymap/vectors.s

DOS_SOURCES = \
	dos/fat32/fat32.s \
	dos/fat32/mkfs.s \
	dos/fat32/sdcard.s \
	dos/fat32/text_input.s \
	dos/zeropage.s \
	dos/jumptab.s \
	dos/main.s \
	dos/match.s \
	dos/file.s \
	dos/cmdch.s \
	dos/dir.s \
	dos/parser.s \
	dos/functions.s \
	dos/geos.s

GEOS_SOURCES= \
	geos/kernal/bitmask/bitmask2.s \
	geos/kernal/conio/conio1.s \
	geos/kernal/conio/conio2.s \
	geos/kernal/conio/conio3a.s \
	geos/kernal/conio/conio4.s \
	geos/kernal/conio/conio6.s \
	geos/kernal/dlgbox/dlgbox1a.s \
	geos/kernal/dlgbox/dlgbox1b.s \
	geos/kernal/dlgbox/dlgbox1c.s \
	geos/kernal/dlgbox/dlgbox1d.s \
	geos/kernal/dlgbox/dlgbox1e1.s \
	geos/kernal/dlgbox/dlgbox1e2.s \
	geos/kernal/dlgbox/dlgbox1f.s \
	geos/kernal/dlgbox/dlgbox1g.s \
	geos/kernal/dlgbox/dlgbox1h.s \
	geos/kernal/dlgbox/dlgbox1i.s \
	geos/kernal/dlgbox/dlgbox1j.s \
	geos/kernal/dlgbox/dlgbox1k.s \
	geos/kernal/dlgbox/dlgbox2.s \
	geos/kernal/files/files10.s \
	geos/kernal/files/files1a2a.s \
	geos/kernal/files/files1a2b.s \
	geos/kernal/files/files1b.s \
	geos/kernal/files/files2.s \
	geos/kernal/files/files3.s \
	geos/kernal/files/files6a.s \
	geos/kernal/files/files6b.s \
	geos/kernal/files/files6c.s \
	geos/kernal/files/files7.s \
	geos/kernal/files/files8.s \
	geos/kernal/graph/clrscr.s \
	geos/kernal/graph/inlinefunc.s \
	geos/kernal/graph/graphicsstring.s \
	geos/kernal/graph/graph2l1.s \
	geos/kernal/graph/pattern.s \
	geos/kernal/graph/inline.s \
	geos/kernal/header/header.s \
	geos/kernal/hw/hw1a.s \
	geos/kernal/hw/hw1b.s \
	geos/kernal/hw/hw2.s \
	geos/kernal/hw/hw3.s \
	geos/kernal/icon/icon1.s \
	geos/kernal/icon/icon2.s \
	geos/kernal/init/init1.s \
	geos/kernal/init/init2.s \
	geos/kernal/init/init3.s \
	geos/kernal/init/init4.s \
	geos/kernal/irq/irq.s \
	geos/kernal/jumptab/jumptab.s \
	geos/kernal/keyboard/keyboard1.s \
	geos/kernal/keyboard/keyboard2.s \
	geos/kernal/keyboard/keyboard3.s \
	geos/kernal/load/deskacc.s \
	geos/kernal/load/load1a.s \
	geos/kernal/load/load1b.s \
	geos/kernal/load/load1c.s \
	geos/kernal/load/load2.s \
	geos/kernal/load/load3.s \
	geos/kernal/load/load4b.s \
	geos/kernal/mainloop/mainloop.s \
	geos/kernal/math/shl.s \
	geos/kernal/math/shr.s \
	geos/kernal/math/muldiv.s \
	geos/kernal/math/neg.s \
	geos/kernal/math/dec.s \
	geos/kernal/math/random.s \
	geos/kernal/math/crc.s \
	geos/kernal/memory/memory1a.s \
	geos/kernal/memory/memory1b.s \
	geos/kernal/memory/memory2.s \
	geos/kernal/memory/memory3.s \
	geos/kernal/menu/menu1.s \
	geos/kernal/menu/menu2.s \
	geos/kernal/menu/menu3.s \
	geos/kernal/misc/misc.s \
	geos/kernal/mouse/mouse1.s \
	geos/kernal/mouse/mouse2.s \
	geos/kernal/mouse/mouse3.s \
	geos/kernal/mouse/mouse4.s \
	geos/kernal/mouse/mouseptr.s \
	geos/kernal/panic/panic.s \
	geos/kernal/patterns/patterns.s \
	geos/kernal/process/process.s \
	geos/kernal/reu/reu.s \
	geos/kernal/serial/serial1.s \
	geos/kernal/serial/serial2.s \
	geos/kernal/sprites/sprites.s \
	geos/kernal/time/time1.s \
	geos/kernal/time/time2.s \
	geos/kernal/tobasic/tobasic2.s \
	geos/kernal/vars/vars.s \
	geos/kernal/start/start64.s \
	geos/kernal/bitmask/bitmask1.s \
	geos/kernal/bitmask/bitmask3.s \
	geos/kernal/conio/conio5.s \
	geos/kernal/files/files9.s \
	geos/kernal/graph/bitmapclip.s \
	geos/kernal/graph/bitmapup.s \
	geos/kernal/graph/graph_bridge.s \
	geos/kernal/ramexp/ramexp1.s \
	geos/kernal/ramexp/ramexp2.s \
	geos/kernal/rename.s \
	geos/kernal/tobasic/tobasic1.s \
	geos/kernal/drvcbdos.s

BASIC_SOURCES= \
	kernsup/kernsup_basic.s \
	basic/basic.s \
	math/math.s

MONITOR_SOURCES= \
	kernsup/kernsup_monitor.s \
	monitor/monitor.s \
	monitor/io.s \
	monitor/asm.s

CHARSET_SOURCES= \
	charset/petscii.s \
	charset/iso-8859-15.s \
	charset/petscii2.s \
	charset/iso-8859-15_2.s \
	charset/vectors.s

GRAPH_SOURCES= \
	graphics/jmptbl.s \
	graphics/kernal.s \
	graphics/graph/graph.s \
	graphics/fonts/fonts.s \
	graphics/graph/console.s \
	graphics/drivers/framebuffer.s \
	graphics/drivers/fb_vectors.s

DEMO_SOURCES= \
	demo/test.s

AUDIO_SOURCES= \
	kernsup/kernsup_audio.s \
	audio/main.s \
	audio/memory.s \
	audio/basic.s \
	audio/fm.s \
	audio/psg.s \
	audio/fmpatchtables.s \
	audio/noteconvert.s \
	audio/audio_luts.s \
	audio/playstring.s

UTIL_SOURCES= \
	kernsup/kernsup_util.s \
	util/main.s \
	util/menu.s \
	util/control.s

BANNEX_SOURCES= \
	kernsup/kernsup_bannex.s \
	bannex/main.s \
	bannex/renumber.s

GENERIC_DEPS = \
	inc/kernal.inc \
	inc/mac.inc \
	inc/io.inc \
	inc/fb.inc \
	inc/banks.inc \
	inc/jsrfar.inc \
	inc/regs.inc \
	kernsup/kernsup.inc

KERNAL_DEPS = \
	$(GENERIC_DEPS) \
	$(GIT_SIGNATURE)

KEYMAP_DEPS = \
	$(GENERIC_DEPS)

DOS_DEPS = \
	$(GENERIC_DEPS) \
	dos/fat32/fat32.inc \
	dos/fat32/lib.inc \
	dos/fat32/regs.inc \
	dos/fat32/sdcard.inc \
	dos/fat32/text_input.inc \
	dos/functions.inc \
	dos/vera.inc

GEOS_DEPS= \
	$(GENERIC_DEPS) \
	geos/config.inc \
	geos/inc/printdrv.inc \
	geos/inc/gkernal.inc \
	geos/inc/inputdrv.inc \
	geos/inc/diskdrv.inc \
	geos/inc/const.inc \
	geos/inc/jumptab.inc \
	geos/inc/geosmac.inc \
	geos/inc/geossym.inc \
	geos/inc/c64.inc

BASIC_DEPS= \
	$(GENERIC_DEPS) \
	math/math.inc \
	$(GIT_SIGNATURE)

MONITOR_DEPS= \
	$(GENERIC_DEPS) \
	monitor/kernal.i

CHARSET_DEPS= \
	$(GENERIC_DEPS)

AUDIO_DEPS= \
	$(GENERIC_DEPS)

UTIL_DEPS= \
	$(GENERIC_DEPS)

BANNEX_DEPS= \
	$(GENERIC_DEPS)


KERNAL_OBJS  = $(addprefix $(BUILD_DIR)/, $(KERNAL_SOURCES:.s=.o))
KEYMAP_OBJS  = $(addprefix $(BUILD_DIR)/, $(KEYMAP_SOURCES:.s=.o))
DOS_OBJS     = $(addprefix $(BUILD_DIR)/, $(DOS_SOURCES:.s=.o))
GEOS_OBJS    = $(addprefix $(BUILD_DIR)/, $(GEOS_SOURCES:.s=.o))
BASIC_OBJS   = $(addprefix $(BUILD_DIR)/, $(BASIC_SOURCES:.s=.o))
MONITOR_OBJS = $(addprefix $(BUILD_DIR)/, $(MONITOR_SOURCES:.s=.o))
CHARSET_OBJS = $(addprefix $(BUILD_DIR)/, $(CHARSET_SOURCES:.s=.o))
GRAPH_OBJS   = $(addprefix $(BUILD_DIR)/, $(GRAPH_SOURCES:.s=.o))
DEMO_OBJS    = $(addprefix $(BUILD_DIR)/, $(DEMO_SOURCES:.s=.o))
AUDIO_OBJS   = $(addprefix $(BUILD_DIR)/, $(AUDIO_SOURCES:.s=.o))
UTIL_OBJS    = $(addprefix $(BUILD_DIR)/, $(UTIL_SOURCES:.s=.o))
BANNEX_OBJS  = $(addprefix $(BUILD_DIR)/, $(BANNEX_SOURCES:.s=.o))

ifeq ($(MACHINE),c64)
	BANK_BINS = $(BUILD_DIR)/kernal.bin
else
	BANK_BINS = \
		$(BUILD_DIR)/kernal.bin \
		$(BUILD_DIR)/keymap.bin \
		$(BUILD_DIR)/dos.bin \
		$(BUILD_DIR)/geos.bin \
		$(BUILD_DIR)/basic.bin \
		$(BUILD_DIR)/monitor.bin \
		$(BUILD_DIR)/charset.bin \
		$(BUILD_DIR)/codex.bin \
		$(BUILD_DIR)/graph.bin \
		$(BUILD_DIR)/demo.bin \
		$(BUILD_DIR)/audio.bin \
		$(BUILD_DIR)/util.bin \
		$(BUILD_DIR)/bannex.bin
endif

ifeq ($(MACHINE),x16)
	ROM_LABELS=$(BUILD_DIR)/rom_labels.h
	ROM_LST=$(BUILD_DIR)/rom_lst.h
	GIT_SIGNATURE=$(BUILD_DIR)/../signature.bin
else
	ROM_LABELS=
	ROM_LST=
	GIT_SIGNATURE=
endif

all: $(BUILD_DIR)/rom.bin $(ROM_LABELS) $(ROM_LST)

$(BUILD_DIR)/rom.bin: $(BANK_BINS)
	cat $(BANK_BINS) > $@

clean:
	rm -f $(GIT_SIGNATURE)
	rm -rf $(BUILD_DIR)
	(cd codex; make clean)

$(GIT_SIGNATURE): FORCE
	@mkdir -p $(BUILD_DIR)
	git diff --quiet && echo -n $$( (git rev-parse --short=8 HEAD || echo "00000000") | tr '[:lower:]' '[:upper:]') > $(GIT_SIGNATURE) \
	|| echo -n $$( echo -n $$(git rev-parse --short=7 HEAD || echo "0000000") | tr '[:lower:]' '[:upper:]'; echo -n '+') > $(GIT_SIGNATURE)

FORCE:

$(BUILD_DIR)/%.cfg: %.cfgtpl
	@mkdir -p $$(dirname $@)
	$(CC) -E $< -o $@

# TODO: Need a way to control lst file generation through a configuration variable.
$(BUILD_DIR)/%.o: %.s
	@mkdir -p $$(dirname $@)
	$(AS) $(ASFLAGS) -l $(BUILD_DIR)/$*.lst $< -o $@


# TODO: Need a way to control relist generation; don't try to do it if lst files haven't been generated!
# Bank 0 : KERNAL
$(BUILD_DIR)/kernal.bin: $(GIT_SIGNATURE) $(KERNAL_OBJS) $(KERNAL_DEPS) $(CFG_DIR)/kernal-$(MACHINE).cfg
	@mkdir -p $$(dirname $@)
	$(LD) -C $(CFG_DIR)/kernal-$(MACHINE).cfg $(KERNAL_OBJS) -o $@ -m $(BUILD_DIR)/kernal.map -Ln $(BUILD_DIR)/kernal.sym
	./scripts/relist.py $(BUILD_DIR)/kernal.map $(BUILD_DIR)/kernal

# Bank 1 : KEYMAP
$(BUILD_DIR)/keymap.bin: $(KEYMAP_OBJS) $(KEYMAP_DEPS) $(CFG_DIR)/keymap-$(MACHINE).cfg
	@mkdir -p $$(dirname $@)
	$(LD) -C $(CFG_DIR)/keymap-$(MACHINE).cfg $(KEYMAP_OBJS) -o $@ -m $(BUILD_DIR)/keymap.map -Ln $(BUILD_DIR)/keymap.sym

# Bank 2 : DOS
$(BUILD_DIR)/dos.bin: $(DOS_OBJS) $(DOS_DEPS) $(CFG_DIR)/dos-$(MACHINE).cfg
	@mkdir -p $$(dirname $@)
	$(LD) -C $(CFG_DIR)/dos-$(MACHINE).cfg $(DOS_OBJS) -o $@ -m $(BUILD_DIR)/dos.map -Ln $(BUILD_DIR)/dos.sym
	./scripts/relist.py $(BUILD_DIR)/dos.map $(BUILD_DIR)/dos

# Bank 3 : GEOS
$(BUILD_DIR)/geos.bin: $(GEOS_OBJS) $(GEOS_DEPS) $(CFG_DIR)/geos-$(MACHINE).cfg
	@mkdir -p $$(dirname $@)
	$(LD) -C $(CFG_DIR)/geos-$(MACHINE).cfg $(GEOS_OBJS) -o $@ -m $(BUILD_DIR)/geos.map -Ln $(BUILD_DIR)/geos.sym
	./scripts/relist.py $(BUILD_DIR)/geos.map $(BUILD_DIR)/geos

# Bank 4 : BASIC
$(BUILD_DIR)/basic.bin: $(GIT_SIGNATURE) $(BASIC_OBJS) $(BASIC_DEPS) $(CFG_DIR)/basic-$(MACHINE).cfg
	@mkdir -p $$(dirname $@)
	$(LD) -C $(CFG_DIR)/basic-$(MACHINE).cfg $(BASIC_OBJS) -o $@ -m $(BUILD_DIR)/basic.map -Ln $(BUILD_DIR)/basic.sym `${BUILD_DIR}/../../findsymbols ${BUILD_DIR}/kernal.sym shflag`
	./scripts/relist.py $(BUILD_DIR)/basic.map $(BUILD_DIR)/basic

# Bank 5 : MONITOR
$(BUILD_DIR)/monitor.bin: $(MONITOR_OBJS) $(MONITOR_DEPS) $(CFG_DIR)/monitor-$(MACHINE).cfg
	@mkdir -p $$(dirname $@)
	$(LD) -C $(CFG_DIR)/monitor-$(MACHINE).cfg $(MONITOR_OBJS) -o $@ -m $(BUILD_DIR)/monitor.map -Ln $(BUILD_DIR)/monitor.sym
	./scripts/relist.py $(BUILD_DIR)/monitor.map $(BUILD_DIR)/monitor

# Bank 6 : CHARSET
$(BUILD_DIR)/charset.bin: $(CHARSET_OBJS) $(CHARSET_DEPS) $(CFG_DIR)/charset-$(MACHINE).cfg
	@mkdir -p $$(dirname $@)
	$(LD) -C $(CFG_DIR)/charset-$(MACHINE).cfg $(CHARSET_OBJS) -o $@ -m $(BUILD_DIR)/charset.map -Ln $(BUILD_DIR)/charset.sym

# Bank 7 : CodeX
$(BUILD_DIR)/codex.bin: $(CFG_DIR)/codex-$(MACHINE).cfg
	(cd codex; make)

# Bank 8 : Graphics
$(BUILD_DIR)/graph.bin: $(GRAPH_OBJS) $(KERNAL_DEPS) $(CFG_DIR)/graph.cfg
	@mkdir -p $$(dirname $@)
	$(LD) -C $(CFG_DIR)/graph.cfg $(GRAPH_OBJS) -o $@ -m $(BUILD_DIR)/graph.map -Ln $(BUILD_DIR)/graph.sym `${BUILD_DIR}/../../findsymbols ${BUILD_DIR}/kernal.sym ptr_fg` `${BUILD_DIR}/../../findsymbols ${BUILD_DIR}/kernal.sym -p k_ kbdbuf_get sprite_set_image sprite_set_position`

# Bank 9 : DEMO
$(BUILD_DIR)/demo.bin: $(DEMO_OBJS) $(DEMO_DEPS) $(CFG_DIR)/demo-$(MACHINE).cfg
	@mkdir -p $$(dirname $@)
	$(LD) -C $(CFG_DIR)/demo-$(MACHINE).cfg $(DEMO_OBJS) -o $@ -m $(BUILD_DIR)/demo.map -Ln $(BUILD_DIR)/demo.sym
	./scripts/relist.py $(BUILD_DIR)/demo.map $(BUILD_DIR)/demo

# Bank A : Audio
$(BUILD_DIR)/audio.bin: $(AUDIO_OBJS) $(AUDIO_DEPS) $(CFG_DIR)/audio-$(MACHINE).cfg
	@mkdir -p $$(dirname $@)
	$(LD) -C $(CFG_DIR)/audio-$(MACHINE).cfg $(AUDIO_OBJS) -o $@ -m $(BUILD_DIR)/audio.map -Ln $(BUILD_DIR)/audio.sym
	./scripts/relist.py $(BUILD_DIR)/audio.map $(BUILD_DIR)/audio

# Bank B : Utilities
$(BUILD_DIR)/util.bin: $(UTIL_OBJS) $(UTIL_DEPS) $(CFG_DIR)/util-$(MACHINE).cfg
	@mkdir -p $$(dirname $@)
	$(LD) -C $(CFG_DIR)/util-$(MACHINE).cfg $(UTIL_OBJS) -o $@ -m $(BUILD_DIR)/util.map -Ln $(BUILD_DIR)/util.sym
	./scripts/relist.py $(BUILD_DIR)/util.map $(BUILD_DIR)/util

# Bank C : BASIC Annex
$(BUILD_DIR)/bannex.bin: $(BANNEX_OBJS) $(BANNEX_DEPS) $(CFG_DIR)/bannex-$(MACHINE).cfg
	@mkdir -p $$(dirname $@)
	$(LD) -C $(CFG_DIR)/bannex-$(MACHINE).cfg $(BANNEX_OBJS) -o $@ -m $(BUILD_DIR)/bannex.map -Ln $(BUILD_DIR)/bannex.sym
	./scripts/relist.py $(BUILD_DIR)/bannex.map $(BUILD_DIR)/bannex


$(BUILD_DIR)/rom_labels.h: $(BANK_BINS)
	./scripts/symbolize.sh 0 build/x16/kernal.sym   > $@
	./scripts/symbolize.sh 1 build/x16/keymap.sym  >> $@
	./scripts/symbolize.sh 2 build/x16/dos.sym     >> $@
	./scripts/symbolize.sh 3 build/x16/geos.sym    >> $@
	./scripts/symbolize.sh 4 build/x16/basic.sym   >> $@
	./scripts/symbolize.sh 5 build/x16/monitor.sym >> $@
	./scripts/symbolize.sh 6 build/x16/charset.sym >> $@
	./scripts/symbolize.sh A build/x16/audio.sym   >> $@
	./scripts/symbolize.sh B build/x16/util.sym    >> $@
	./scripts/symbolize.sh C build/x16/bannex.sym  >> $@

$(BUILD_DIR)/rom_lst.h: $(BANK_BINS)
	./scripts/trace_lst.py 0 `find build/x16/kernal/ -name \*.rlst`   > $@
	./scripts/trace_lst.py 2 `find build/x16/dos/ -name \*.rlst`     >> $@
	./scripts/trace_lst.py 3 `find build/x16/geos/ -name \*.rlst`    >> $@
	./scripts/trace_lst.py 4 `find build/x16/basic/ -name \*.rlst`   >> $@
	./scripts/trace_lst.py 5 `find build/x16/monitor/ -name \*.rlst` >> $@
	./scripts/trace_lst.py A `find build/x16/audio/ -name \*.rlst`   >> $@
	./scripts/trace_lst.py B `find build/x16/util/ -name \*.rlst`    >> $@
	./scripts/trace_lst.py C `find build/x16/bannex/ -name \*.rlst`  >> $@
