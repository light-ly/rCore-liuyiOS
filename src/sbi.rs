pub fn console_putchar(ch: usize) {
    #[allow(deprecated)]
    sbi_rt::legacy::console_putchar(ch);
}

pub fn shutdown(failure: bool) -> ! {
    use sbi_rt::{system_reset, Shutdown, NoReason, SystemFailure};
    if !failure {
        system_reset(Shutdown, NoReason);
    } else {
        system_reset(Shutdown, SystemFailure);
    }
    unreachable!()
}