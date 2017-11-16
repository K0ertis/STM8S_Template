
BIN = main
INC_DIR = include/
SRC_DIR = src/
LIB_DIR = lib/
BUILD_DIR = build/
DEBUG_DIR = debug/
OUTPUT = $(BUILD_DIR)$(BIN)
OUTPUT_DEBUG= $(DEBUG_DIR)$(BIN)
OBJ_DIR = obj/

MAIN_FILE = $(SRC_DIR)$(BIN).c
SRC_ALL = $(shell find -L $(SRC_DIR) -name '*.c')
#SRC_ALL += $(shell find -L $(LIB_DIR)$(SRC_DIR) -name '*.c')
$(info $$SRC_ALL is [${SRC_ALL}])
SRC = $(filter-out $(SRC_DIR)$(BIN).c,$(SRC_ALL))
INC = $(INC_DIR)
#INC += $(LIB_DIR)$(INC_DIR)
$(info $$INC is [${INC}])
STM8_INCLUDES = $(INC:%=-I%)
LD_LIBS= -lstm8
#LD_LIBS= 
DEBUGFLAG =--out-fmt-elf --all-callee-saves --debug --verbose --stack-auto --fverbose-asm  --float-reent --no-peep 
REL = $(SRC:%.c=%.rel)
STM8_CC=sdcc
STM8_LD=sdld
CCVERSION = $(shell $(STM8_CC) --version )
STM8_CFLAGS= -mstm8 $(STM8_INCLUDES) --std-sdcc11  -D STM8S103
$(info $$CFLAG is [${STM8_CFLAGS}])
#$(info $$MAIN_FILE is [${MAIN_FILE}])


.PHONY:  release all 
all: release start $(TEST_TARGET)
	$(RUN_TEST_TARGET)
    
.PHONY: flash release stm8_debug

stm8_debug: $(OUTPUT_DEBUG)
	@echo compile .elf under $(DEBUG_DIR)!

$(OUTPUT_DEBUG):$(MAIN_FILE) $(REL)
	$(STM8_CC) $(STM8_CFLAGS) $(DEBUGFLAG)  $(MAIN_FILE) $(REL) $(LD_LIBS) -o $@.elf

%.rel:%.c
	@echo Build .c.rel "$@"
	$(STM8_CC) $(STM8_CFLAGS) -c $< -o $@ $(LD_LIBS)
release: $(OUTPUT)
	@echo compile .ihx under $(BUILD_DIR)! with \\n $(CCVERSION) \\n
	@echo Successful!!\\n\\n

$(OUTPUT):$(MAIN_FILE) $(REL)
	$(STM8_CC) $(STM8_CFLAGS) --out-fmt-ihx $(MAIN_FILE) $(REL) $(LD_LIBS) -o $@.ihx

%.rel: %.c
	@echo Build .c.rel "$@"
	$(STM8_CC) $(STM8_CFLAGS) -c $< -o $@

flash: 
	@stm8flash -cstlink -pstm8s003?3 -w $(OUTPUT).ihx
