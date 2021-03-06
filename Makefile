CRYSTAL=crystal
REPO=pi-led
# LLVM target platform as obtained by running "crystal ver" on the RPi
TARGET_PLATFORM=arm-unknown-linux-gnueabihf
HOSTNAME=raspberrypi.local
USERNAME=pi
LOGIN=$(USERNAME)@$(HOSTNAME)
CMD_LINE_REPLACEMENTS=s!-o $(CROSS_TARGET)!-o bin/$(REPO)!;s!\S+/libcrystal.a!/opt/crystal/src/ext/libcrystal.a!
CROSS_TARGET=bin/$(REPO)-cross
TARGET_CMD=/tmp/target_cmd

cross-pi: $(CROSS_TARGET) $(TARGET_CMD)
	echo "\
		!mkdir -p ${REPO} \n \
		cd ${REPO} \n \
		put ${TARGET_CMD} \n\
		put ${CROSS_TARGET}.o ./${CROSS_TARGET}.o" \
	| sftp -b - ${LOGIN}
	ssh ${LOGIN} "{ cd ${REPO} && \
									echo $$(sed -E -e '${CMD_LINE_REPLACEMENTS}' ${TARGET_CMD}) && \
											 $$(sed -E -e '${CMD_LINE_REPLACEMENTS}' ${TARGET_CMD}); }"

$(CROSS_TARGET): src/$(REPO).cr
	$(CRYSTAL) build --cross-compile --target=$(TARGET_PLATFORM) $< -o $(CROSS_TARGET) >$(TARGET_CMD)
	cat $(TARGET_CMD)
