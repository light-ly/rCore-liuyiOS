#![feature(panic_info_message)]
#![no_main]
#![no_std]
mod lang_item;
mod sbi;
#[macro_use]
mod console;

use core::arch::global_asm;

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
    println!("[kernel] Hello, world!");
    panic!("[kernel] Program Done! Shutdown Machine!")
}
