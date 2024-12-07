#![no_main]
#![no_std]
mod lang_item;

use core::arch::global_asm;
use core::ptr::write_volatile;

global_asm!(include_str!("entry.asm"));

fn clean_bss() {
    extern "C" {
        static start_bss: u64;
        static end_bss: u64;
    }
    unsafe {
        (start_bss..end_bss).for_each(|addr| {
            (addr as *mut u8).write_volatile(0);
        })
    }
}

#[no_mangle]
fn rust_main() -> ! {
    clean_bss();
    loop {}
}
