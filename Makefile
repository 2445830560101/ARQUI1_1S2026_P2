CC = aarch64-linux-gnu-gcc
AS = aarch64-linux-gnu-as
LD = aarch64-linux-gnu-ld

CFLAGS = -static
ASFLAGS = 
LDFLAGS = 

OBJS = main.o io.o matriz.o identidad.o traspuesta.o gauss.o gauss_jordan.o inversa.o aritmetica.o determinante.o  memoria.o

TARGET = algebra_lineal

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $^

%.o: %.s
	$(AS) $(ASFLAGS) $< -o $@

clean:
	rm -f $(OBJS) $(TARGET)

run: $(TARGET)
	qemu-aarch64 -L /usr/aarch64-linux-gnu ./$(TARGET)

install-deps:
	sudo apt update
	sudo apt install -y gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu qemu-user qemu-user-static

.PHONY: all clean run install-deps