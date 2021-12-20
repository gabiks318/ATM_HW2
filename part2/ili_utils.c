#include <asm/desc.h>

void my_store_idt(struct desc_ptr *idtr) {
    asm volatile(
        "sidt %0"
        : "=m"(*idtr)
        :
        :
    );
}

void my_load_idt(struct desc_ptr *idtr) {
    asm volatile(
        "lidt %0"
        : 
        : "m"(*idtr)
        :
    );
}

void my_set_gate_offset(gate_desc *gate, unsigned long addr) {
    gate->offset_low = addr & 0xFFFF;
	gate->offset_middle = (addr >> 16) & 0xFFFF;
	gate->offset_high = addr >> 32;
}

unsigned long my_get_gate_offset(gate_desc *gate) {
    unsigned long addr = 0;
	unsigned long addr_high = gate->offset_high << 32;
    unsigned long addr_mid = gate->offset_middle << 16;
    unsigned long addr_low = gate->offset_low;
    addr = addr_high | addr_mid | addr_low;
	return addr;
}
