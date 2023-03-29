pub fn pow(val: i64) !i64 {
    const res = @mulWithOverflow(val, val);
    return if (!(res[1] == 1)) res[0] else error.Overflow;
}
