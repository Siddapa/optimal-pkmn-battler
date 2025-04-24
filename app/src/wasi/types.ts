export type WASMArg = Int32 | Uint32 | string | Int32Array | Uint32Array;

export class Int32 {
    private _value: number = 0;
    constructor(newValue: number) {
        if (newValue < -2147483648 || 2147483647 < newValue) {
            throw new TypeError("Number doesn't fit within range!");
        }
        this._value = newValue;
    }
    get value(): number {
        return this._value;
    }
    set value(newValue: number) {
        if (newValue < -2147483648 || 2147483647 < newValue) {
            throw new TypeError("Number doesn't fit within range!");
        }
        this._value = newValue;
    }
}

export class Uint32 {
    private _value: number = 0;
    constructor(newValue: number) {
        if (newValue < 0 || 4294967295 < newValue) {
            throw new TypeError("Number doesn't fit within range!");
        }
        this._value = newValue;
    }
    get value(): number {
        return this._value;
    }
    set value(newValue: number) {
        if (newValue < 0 || 4294967295 < newValue) {
            throw new TypeError("Number doesn't fit within range!");
        }
        this._value = newValue;
    }
}
