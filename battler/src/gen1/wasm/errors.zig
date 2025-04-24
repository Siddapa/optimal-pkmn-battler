pub const error_t = u8;

pub const Errors = error{
    LoadingTypeMismatch,
    TooManyEnemies,
    OutOfMemory,
    LoadingTypeWithUnknownTag,
};

pub fn to_value(e: anyerror) error_t {
    switch (e) {
        Errors.LoadingTypeMismatch => return 2,
        Errors.TooManyEnemies => return 3,
        Errors.OutOfMemory => return 4,
        Errors.LoadingTypeWithUnknownTag => return 5,
        else => return 1, // Unhandled error
    }
}
