pub const error_t = u8;

pub const Errors = error{
    TypeMismatch,
    TooManyEnemies,
    OutOfMemory,
    TypeWithUnkownTag,
};

pub fn to_value(e: anyerror) error_t {
    switch (e) {
        Errors.TypeMismatch => return 2,
        Errors.TooManyEnemies => return 3,
        Errors.OutOfMemory => return 4,
        Errors.TypeWithUnkownTag => return 5,
        else => return 1, // Unhandled error
    }
}
