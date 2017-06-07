SRC=$(wildcard src/*.c)
OBJS=$(SRC:.c=.o)

EXE=peerstreamer-ng

CFLAGS+=-Isrc/ -ILibs/mongoose/ -ILibs/pstreamer/include -ILibs/GRAPES/include -LLibs/GRAPES/src  -LLibs/pstreamer/src 
ifdef DEBUG
CFLAGS+=-g -W -Wall -Wno-unused-function -Wno-unused-parameter -O0
else
CFLAGS+=-O6
endif

LIBS+=Libs/mongoose/mongoose.o Libs/GRAPES/src/libgrapes.a Libs/pstreamer/src/libpstreamer.a
MONGOOSE_OPTS+=-DMG_DISABLE_MQTT -DMG_DISABLE_JSON_RPC -DMG_DISABLE_SOCKETPAIR  -DMG_DISABLE_CGI # -DMG_DISABLE_HTTP_WEBSOCKET
LDFLAGS+=-lpstreamer -lgrapes -lm

all: $(EXE)

$(EXE): $(LIBS) $(OBJS) peerstreamer-ng.c
	$(CC) -o peerstreamer-ng  peerstreamer-ng.c $(OBJS) Libs/mongoose/mongoose.o $(CFLAGS) $(LDFLAGS)

%.o: %.c 
	$(CC) $< -o $@ -c $(CFLAGS) 

Libs/mongoose/mongoose.o:
	git submodule init Libs/mongoose/
	git submodule update Libs/mongoose/
	make -C Libs/mongoose/ CFLAGS="$(CFLAGS)" MONGOOSE_OPTS="$(MONGOOSE_OPTS)"

Libs/GRAPES/src/libgrapes.a:
	git submodule init Libs/GRAPES/
	git submodule update Libs/GRAPES/
	make -C Libs/GRAPES/ 

Libs/pstreamer/src/libpstreamer.a:
	git submodule init Libs/pstreamer/
	git submodule update Libs/pstreamer/
	make -C Libs/pstreamer/ 

tests:
	make -C Test/  # CFLAGS="$(CFLAGS)"
	Test/run_tests.sh

clean:
	make -C Test/ clean
	make -C Libs/mongoose clean
	make -C Libs/GRAPES clean
	make -C Libs/pstreamer clean
	rm -f *.o $(EXE) $(OBJS) $(LIBS)

.PHONY: all clean
