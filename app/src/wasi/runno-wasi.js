var ml = Object.defineProperty;
var al = (t, l, V) => l in t ? ml(t, l, { enumerable: !0, configurable: !0, writable: !0, value: V }) : t[l] = V;
var R = (t, l, V) => (al(t, typeof l != "symbol" ? l + "" : l, V), V);
class Xl {
  constructor(l) {
    R(this, "_value", 0);
    if (l < -2147483648 || 2147483647 < l)
      throw new TypeError("Number doesn't fit within range!");
    this._value = l;
  }
  get value() {
    return this._value;
  }
  set value(l) {
    if (l < -2147483648 || 2147483647 < l)
      throw new TypeError("Number doesn't fit within range!");
    this._value = l;
  }
}
class Rl {
  constructor(l) {
    R(this, "_value", 0);
    if (l < 0 || 4294967295 < l)
      throw new TypeError("Number doesn't fit within range!");
    this._value = l;
  }
  get value() {
    return this._value;
  }
  set value(l) {
    if (l < 0 || 4294967295 < l)
      throw new TypeError("Number doesn't fit within range!");
    this._value = l;
  }
}
var c;
(function(t) {
  t[t.SUCCESS = 0] = "SUCCESS", t[t.E2BIG = 1] = "E2BIG", t[t.EACCESS = 2] = "EACCESS", t[t.EADDRINUSE = 3] = "EADDRINUSE", t[t.EADDRNOTAVAIL = 4] = "EADDRNOTAVAIL", t[t.EAFNOSUPPORT = 5] = "EAFNOSUPPORT", t[t.EAGAIN = 6] = "EAGAIN", t[t.EALREADY = 7] = "EALREADY", t[t.EBADF = 8] = "EBADF", t[t.EBADMSG = 9] = "EBADMSG", t[t.EBUSY = 10] = "EBUSY", t[t.ECANCELED = 11] = "ECANCELED", t[t.ECHILD = 12] = "ECHILD", t[t.ECONNABORTED = 13] = "ECONNABORTED", t[t.ECONNREFUSED = 14] = "ECONNREFUSED", t[t.ECONNRESET = 15] = "ECONNRESET", t[t.EDEADLK = 16] = "EDEADLK", t[t.EDESTADDRREQ = 17] = "EDESTADDRREQ", t[t.EDOM = 18] = "EDOM", t[t.EDQUOT = 19] = "EDQUOT", t[t.EEXIST = 20] = "EEXIST", t[t.EFAULT = 21] = "EFAULT", t[t.EFBIG = 22] = "EFBIG", t[t.EHOSTUNREACH = 23] = "EHOSTUNREACH", t[t.EIDRM = 24] = "EIDRM", t[t.EILSEQ = 25] = "EILSEQ", t[t.EINPROGRESS = 26] = "EINPROGRESS", t[t.EINTR = 27] = "EINTR", t[t.EINVAL = 28] = "EINVAL", t[t.EIO = 29] = "EIO", t[t.EISCONN = 30] = "EISCONN", t[t.EISDIR = 31] = "EISDIR", t[t.ELOOP = 32] = "ELOOP", t[t.EMFILE = 33] = "EMFILE", t[t.EMLINK = 34] = "EMLINK", t[t.EMSGSIZE = 35] = "EMSGSIZE", t[t.EMULTIHOP = 36] = "EMULTIHOP", t[t.ENAMETOOLONG = 37] = "ENAMETOOLONG", t[t.ENETDOWN = 38] = "ENETDOWN", t[t.ENETRESET = 39] = "ENETRESET", t[t.ENETUNREACH = 40] = "ENETUNREACH", t[t.ENFILE = 41] = "ENFILE", t[t.ENOBUFS = 42] = "ENOBUFS", t[t.ENODEV = 43] = "ENODEV", t[t.ENOENT = 44] = "ENOENT", t[t.ENOEXEC = 45] = "ENOEXEC", t[t.ENOLCK = 46] = "ENOLCK", t[t.ENOLINK = 47] = "ENOLINK", t[t.ENOMEM = 48] = "ENOMEM", t[t.ENOMSG = 49] = "ENOMSG", t[t.ENOPROTOOPT = 50] = "ENOPROTOOPT", t[t.ENOSPC = 51] = "ENOSPC", t[t.ENOSYS = 52] = "ENOSYS", t[t.ENOTCONN = 53] = "ENOTCONN", t[t.ENOTDIR = 54] = "ENOTDIR", t[t.ENOTEMPTY = 55] = "ENOTEMPTY", t[t.ENOTRECOVERABLE = 56] = "ENOTRECOVERABLE", t[t.ENOTSOCK = 57] = "ENOTSOCK", t[t.ENOTSUP = 58] = "ENOTSUP", t[t.ENOTTY = 59] = "ENOTTY", t[t.ENXIO = 60] = "ENXIO", t[t.EOVERFLOW = 61] = "EOVERFLOW", t[t.EOWNERDEAD = 62] = "EOWNERDEAD", t[t.EPERM = 63] = "EPERM", t[t.EPIPE = 64] = "EPIPE", t[t.EPROTO = 65] = "EPROTO", t[t.EPROTONOSUPPORT = 66] = "EPROTONOSUPPORT", t[t.EPROTOTYPE = 67] = "EPROTOTYPE", t[t.ERANGE = 68] = "ERANGE", t[t.EROFS = 69] = "EROFS", t[t.ESPIPE = 70] = "ESPIPE", t[t.ESRCH = 71] = "ESRCH", t[t.ESTALE = 72] = "ESTALE", t[t.ETIMEDOUT = 73] = "ETIMEDOUT", t[t.ETXTBSY = 74] = "ETXTBSY", t[t.EXDEV = 75] = "EXDEV", t[t.ENOTCAPABLE = 76] = "ENOTCAPABLE";
})(c || (c = {}));
var k;
(function(t) {
  t[t.REALTIME = 0] = "REALTIME", t[t.MONOTONIC = 1] = "MONOTONIC", t[t.PROCESS_CPUTIME_ID = 2] = "PROCESS_CPUTIME_ID", t[t.THREAD_CPUTIME_ID = 3] = "THREAD_CPUTIME_ID";
})(k || (k = {}));
var F;
(function(t) {
  t[t.SET = 0] = "SET", t[t.CUR = 1] = "CUR", t[t.END = 2] = "END";
})(F || (F = {}));
var S;
(function(t) {
  t[t.UNKNOWN = 0] = "UNKNOWN", t[t.BLOCK_DEVICE = 1] = "BLOCK_DEVICE", t[t.CHARACTER_DEVICE = 2] = "CHARACTER_DEVICE", t[t.DIRECTORY = 3] = "DIRECTORY", t[t.REGULAR_FILE = 4] = "REGULAR_FILE", t[t.SOCKET_DGRAM = 5] = "SOCKET_DGRAM", t[t.SOCKET_STREAM = 6] = "SOCKET_STREAM", t[t.SYMBOLIC_LINK = 7] = "SYMBOLIC_LINK";
})(S || (S = {}));
var f;
(function(t) {
  t[t.DIR = 0] = "DIR";
})(f || (f = {}));
var y;
(function(t) {
  t[t.CLOCK = 0] = "CLOCK", t[t.FD_READ = 1] = "FD_READ", t[t.FD_WRITE = 2] = "FD_WRITE";
})(y || (y = {}));
const sl = {
  SYMLINK_FOLLOW: 1
  // As long as the resolved path corresponds to a symbolic
  // link, it is expanded.
}, L = {
  CREAT: 1,
  DIRECTORY: 2,
  EXCL: 4,
  TRUNC: 8
  // Truncate file to size 0.
}, N = {
  APPEND: 1,
  DSYNC: 2,
  NONBLOCK: 4,
  RSYNC: 8,
  SYNC: 16
  // Write according to synchronized I/O file integrity completion. In addition to synchronizing the data stored in the file, the implementation may also synchronously update the file's metadata.
}, b = {
  FD_DATASYNC: BigInt(1) << BigInt(0),
  FD_READ: BigInt(1) << BigInt(1),
  FD_SEEK: BigInt(1) << BigInt(2),
  FD_FDSTAT_SET_FLAGS: BigInt(1) << BigInt(3),
  FD_SYNC: BigInt(1) << BigInt(4),
  FD_TELL: BigInt(1) << BigInt(5),
  FD_WRITE: BigInt(1) << BigInt(6),
  FD_ADVISE: BigInt(1) << BigInt(7),
  FD_ALLOCATE: BigInt(1) << BigInt(8),
  PATH_CREATE_DIRECTORY: BigInt(1) << BigInt(9),
  PATH_CREATE_FILE: BigInt(1) << BigInt(10),
  PATH_LINK_SOURCE: BigInt(1) << BigInt(11),
  PATH_LINK_TARGET: BigInt(1) << BigInt(12),
  PATH_OPEN: BigInt(1) << BigInt(13),
  FD_READDIR: BigInt(1) << BigInt(14),
  PATH_READLINK: BigInt(1) << BigInt(15),
  PATH_RENAME_SOURCE: BigInt(1) << BigInt(16),
  PATH_RENAME_TARGET: BigInt(1) << BigInt(17),
  PATH_FILESTAT_GET: BigInt(1) << BigInt(18),
  PATH_FILESTAT_SET_SIZE: BigInt(1) << BigInt(19),
  PATH_FILESTAT_SET_TIMES: BigInt(1) << BigInt(20),
  FD_FILESTAT_GET: BigInt(1) << BigInt(21),
  FD_FILESTAT_SET_SIZE: BigInt(1) << BigInt(22),
  FD_FILESTAT_SET_TIMES: BigInt(1) << BigInt(23),
  PATH_SYMLINK: BigInt(1) << BigInt(24),
  PATH_REMOVE_DIRECTORY: BigInt(1) << BigInt(25),
  PATH_UNLINK_FILE: BigInt(1) << BigInt(26),
  POLL_FD_READWRITE: BigInt(1) << BigInt(27),
  SOCK_SHUTDOWN: BigInt(1) << BigInt(28),
  SOCK_ACCEPT: BigInt(1) << BigInt(29)
}, T = {
  ATIM: 1,
  ATIM_NOW: 2,
  MTIM: 4,
  MTIM_NOW: 8
  // Adjust the last data modification timestamp to the time of clock clockid::realtime.
}, Zl = {
  SUBSCRIPTION_CLOCK_ABSTIME: 1
  // If set, treat the timestamp provided in subscription_clock::timeout as an absolute timestamp of clock subscription_clock::id. If clear, treat the timestamp provided in subscription_clock::timeout relative to the current time value of clock subscription_clock::id.
}, bl = {
  FD_READWRITE_HANGUP: 1
  // The peer of this socket has closed or disconnected.
}, w = 64, B = 48, H = 32, Ll = /* @__PURE__ */ Object.freeze(/* @__PURE__ */ Object.defineProperty({
  __proto__: null,
  get Clock() {
    return k;
  },
  EVENT_SIZE: H,
  EventReadWriteFlags: bl,
  get EventType() {
    return y;
  },
  FILESTAT_SIZE: w,
  FileDescriptorFlags: N,
  FileStatTimestampFlags: T,
  get FileType() {
    return S;
  },
  LookupFlags: sl,
  OpenFlags: L,
  get PreopenType() {
    return f;
  },
  get Result() {
    return c;
  },
  RightsFlags: b,
  SUBSCRIPTION_SIZE: B,
  SubscriptionClockFlags: Zl,
  get Whence() {
    return F;
  }
}, Symbol.toStringTag, { value: "Module" }));
var Q;
(function(t) {
  t[t.CUR = 0] = "CUR", t[t.END = 1] = "END", t[t.SET = 2] = "SET";
})(Q || (Q = {}));
class Gl {
  constructor(l) {
    R(this, "fs");
    R(this, "args");
    // Program args (like from a terminal program)
    R(this, "env");
    // Environment (like a .env file)
    R(this, "stdin");
    R(this, "stdout");
    R(this, "stderr");
    R(this, "debug");
    R(this, "isTTY");
    this.fs = (l == null ? void 0 : l.fs) ?? {}, this.args = (l == null ? void 0 : l.args) ?? [], this.env = (l == null ? void 0 : l.env) ?? {}, this.stdin = (l == null ? void 0 : l.stdin) ?? (() => null), this.stdout = (l == null ? void 0 : l.stdout) ?? (() => {
    }), this.stderr = (l == null ? void 0 : l.stderr) ?? (() => {
    }), this.debug = l == null ? void 0 : l.debug, this.isTTY = !!(l != null && l.isTTY);
  }
}
class hl {
  constructor(l) {
    R(this, "fs");
    R(this, "nextFD", 10);
    R(this, "openMap", /* @__PURE__ */ new Map());
    this.fs = { ...l }, this.openMap.set(3, new u(this.fs, "/"));
  }
  //
  // Helpers
  //
  openFile(l, V, Z) {
    const d = new W(l, Z);
    V && (d.buffer = new Uint8Array(new ArrayBuffer(1024), 0, 0));
    const i = this.nextFD;
    return this.openMap.set(i, d), this.nextFD++, [c.SUCCESS, i];
  }
  openDir(l, V) {
    const Z = new u(l, V), d = this.nextFD;
    return this.openMap.set(d, Z), this.nextFD++, [c.SUCCESS, d];
  }
  hasDir(l, V) {
    return V === "." ? !0 : l.containsDirectory(V);
  }
  //
  // Public Interface
  //
  open(l, V, Z, d) {
    const i = !!(Z & L.CREAT), n = !!(Z & L.DIRECTORY), m = !!(Z & L.EXCL), e = !!(Z & L.TRUNC), a = this.openMap.get(l);
    if (!(a instanceof u))
      return [c.EBADF];
    if (a.containsFile(V))
      return n ? [c.ENOTDIR] : m ? [c.EEXIST] : this.openFile(a.get(V), e, d);
    if (this.hasDir(a, V)) {
      if (V === ".")
        return this.openDir(this.fs, "/");
      const X = `/${V}/`, s = Object.entries(this.fs).filter(([G]) => G.startsWith(X));
      return this.openDir(Object.fromEntries(s), X);
    } else {
      if (i) {
        const X = a.fullPath(V);
        return this.fs[X] = {
          path: X,
          mode: "binary",
          content: new Uint8Array(),
          timestamps: {
            access: /* @__PURE__ */ new Date(),
            modification: /* @__PURE__ */ new Date(),
            change: /* @__PURE__ */ new Date()
          }
        }, this.openFile(this.fs[X], e, d);
      }
      return [c.ENOTCAPABLE];
    }
  }
  close(l) {
    if (!this.openMap.has(l))
      return c.EBADF;
    const V = this.openMap.get(l);
    return V instanceof W && V.sync(), this.openMap.delete(l), c.SUCCESS;
  }
  read(l, V) {
    const Z = this.openMap.get(l);
    return !Z || Z instanceof u ? [c.EBADF] : [c.SUCCESS, Z.read(V)];
  }
  pread(l, V, Z) {
    const d = this.openMap.get(l);
    return !d || d instanceof u ? [c.EBADF] : [c.SUCCESS, d.pread(V, Z)];
  }
  write(l, V) {
    const Z = this.openMap.get(l);
    return !Z || Z instanceof u ? c.EBADF : (Z.write(V), c.SUCCESS);
  }
  pwrite(l, V, Z) {
    const d = this.openMap.get(l);
    return !d || d instanceof u ? c.EBADF : (d.pwrite(V, Z), c.SUCCESS);
  }
  sync(l) {
    const V = this.openMap.get(l);
    return !V || V instanceof u ? c.EBADF : (V.sync(), c.SUCCESS);
  }
  seek(l, V, Z) {
    const d = this.openMap.get(l);
    return !d || d instanceof u ? [c.EBADF] : [c.SUCCESS, d.seek(V, Z)];
  }
  tell(l) {
    const V = this.openMap.get(l);
    return !V || V instanceof u ? [c.EBADF] : [c.SUCCESS, V.tell()];
  }
  renumber(l, V) {
    return !this.exists(l) || !this.exists(V) ? c.EBADF : (l === V || (this.close(V), this.openMap.set(V, this.openMap.get(l))), c.SUCCESS);
  }
  unlink(l, V) {
    const Z = this.openMap.get(l);
    if (!(Z instanceof u))
      return c.EBADF;
    if (!Z.contains(V))
      return c.ENOENT;
    for (const d of Object.keys(this.fs))
      (d === Z.fullPath(V) || d.startsWith(`${Z.fullPath(V)}/`)) && delete this.fs[d];
    return c.SUCCESS;
  }
  rename(l, V, Z, d) {
    const i = this.openMap.get(l), n = this.openMap.get(Z);
    if (!(i instanceof u) || !(n instanceof u))
      return c.EBADF;
    if (!i.contains(V))
      return c.ENOENT;
    if (n.contains(d))
      return c.EEXIST;
    const m = i.fullPath(V), e = n.fullPath(d);
    for (const a of Object.keys(this.fs))
      if (a.startsWith(m)) {
        const X = a.replace(m, e);
        this.fs[X] = this.fs[a], this.fs[X].path = X, delete this.fs[a];
      }
    return c.SUCCESS;
  }
  list(l) {
    const V = this.openMap.get(l);
    return V instanceof u ? [c.SUCCESS, V.list()] : [c.EBADF];
  }
  stat(l) {
    const V = this.openMap.get(l);
    return V instanceof W ? [c.SUCCESS, V.stat()] : [c.EBADF];
  }
  pathStat(l, V) {
    const Z = this.openMap.get(l);
    if (!(Z instanceof u))
      return [c.EBADF];
    if (Z.containsFile(V)) {
      const d = Z.fullPath(V), i = new W(this.fs[d], 0).stat();
      return [c.SUCCESS, i];
    } else if (this.hasDir(Z, V)) {
      if (V === ".")
        return [c.SUCCESS, new u(this.fs, "/").stat()];
      const d = `/${V}/`, i = Object.entries(this.fs).filter(([m]) => m.startsWith(d)), n = new u(Object.fromEntries(i), d).stat();
      return [c.SUCCESS, n];
    } else
      return [c.ENOTCAPABLE];
  }
  setFlags(l, V) {
    const Z = this.openMap.get(l);
    return Z instanceof W ? (Z.setFlags(V), c.SUCCESS) : c.EBADF;
  }
  setSize(l, V) {
    const Z = this.openMap.get(l);
    return Z instanceof W ? (Z.setSize(Number(V)), c.SUCCESS) : c.EBADF;
  }
  setAccessTime(l, V) {
    const Z = this.openMap.get(l);
    return Z instanceof W ? (Z.setAccessTime(V), c.SUCCESS) : c.EBADF;
  }
  setModificationTime(l, V) {
    const Z = this.openMap.get(l);
    return Z instanceof W ? (Z.setModificationTime(V), c.SUCCESS) : c.EBADF;
  }
  pathSetAccessTime(l, V, Z) {
    const d = this.openMap.get(l);
    if (!(d instanceof u))
      return c.EBADF;
    const i = d.get(V);
    if (!i)
      return c.ENOTCAPABLE;
    const n = new W(i, 0);
    return n.setAccessTime(Z), n.sync(), c.SUCCESS;
  }
  pathSetModificationTime(l, V, Z) {
    const d = this.openMap.get(l);
    if (!(d instanceof u))
      return c.EBADF;
    const i = d.get(V);
    if (!i)
      return c.ENOTCAPABLE;
    const n = new W(i, 0);
    return n.setModificationTime(Z), n.sync(), c.SUCCESS;
  }
  pathCreateDir(l, V) {
    const Z = this.openMap.get(l);
    if (!(Z instanceof u))
      return c.EBADF;
    if (Z.contains(V))
      return c.ENOTCAPABLE;
    const d = `${Z.fullPath(V)}/.runno`;
    return this.fs[d] = {
      path: d,
      timestamps: {
        access: /* @__PURE__ */ new Date(),
        modification: /* @__PURE__ */ new Date(),
        change: /* @__PURE__ */ new Date()
      },
      mode: "string",
      content: ""
    }, c.SUCCESS;
  }
  //
  // Public Helpers
  //
  exists(l) {
    return this.openMap.has(l);
  }
  fileType(l) {
    const V = this.openMap.get(l);
    return V ? V instanceof W ? S.REGULAR_FILE : S.DIRECTORY : S.UNKNOWN;
  }
  fileFdflags(l) {
    const V = this.openMap.get(l);
    return V instanceof W ? V.fdflags : 0;
  }
}
class W {
  constructor(l, V) {
    R(this, "file");
    R(this, "buffer");
    R(this, "_offset", BigInt(0));
    R(this, "isDirty", !1);
    R(this, "fdflags");
    R(this, "flagAppend");
    R(this, "flagDSync");
    R(this, "flagNonBlock");
    R(this, "flagRSync");
    R(this, "flagSync");
    if (this.file = l, this.file.mode === "string") {
      const Z = new TextEncoder();
      this.buffer = Z.encode(this.file.content);
    } else
      this.buffer = this.file.content;
    this.fdflags = V, this.flagAppend = !!(V & N.APPEND), this.flagDSync = !!(V & N.DSYNC), this.flagNonBlock = !!(V & N.NONBLOCK), this.flagRSync = !!(V & N.RSYNC), this.flagSync = !!(V & N.SYNC);
  }
  get offset() {
    return Number(this._offset);
  }
  read(l) {
    const V = this.buffer.subarray(this.offset, this.offset + l);
    return this._offset += BigInt(V.length), V;
  }
  pread(l, V) {
    return this.buffer.subarray(V, V + l);
  }
  write(l) {
    if (this.isDirty = !0, this.flagAppend) {
      const V = this.buffer.length;
      this.resize(V + l.byteLength), this.buffer.set(l, V);
    } else {
      const V = Math.max(this.offset + l.byteLength, this.buffer.byteLength);
      this.resize(V), this.buffer.set(l, this.offset), this._offset += BigInt(l.byteLength);
    }
    (this.flagDSync || this.flagSync) && this.sync();
  }
  pwrite(l, V) {
    if (this.isDirty = !0, this.flagAppend) {
      const Z = this.buffer.length;
      this.resize(Z + l.byteLength), this.buffer.set(l, Z);
    } else {
      const Z = Math.max(V + l.byteLength, this.buffer.byteLength);
      this.resize(Z), this.buffer.set(l, V);
    }
    (this.flagDSync || this.flagSync) && this.sync();
  }
  sync() {
    if (!this.isDirty)
      return;
    if (this.isDirty = !1, this.file.mode === "binary") {
      this.file.content = new Uint8Array(this.buffer);
      return;
    }
    const l = new TextDecoder();
    this.file.content = l.decode(this.buffer);
  }
  seek(l, V) {
    switch (V) {
      case F.SET:
        this._offset = l;
        break;
      case F.CUR:
        this._offset += l;
        break;
      case F.END:
        this._offset = BigInt(this.buffer.length) + l;
        break;
    }
    return this._offset;
  }
  tell() {
    return this._offset;
  }
  stat() {
    return {
      path: this.file.path,
      timestamps: this.file.timestamps,
      type: S.REGULAR_FILE,
      byteLength: this.buffer.length
    };
  }
  setFlags(l) {
    this.fdflags = l;
  }
  setSize(l) {
    this.resize(l);
  }
  setAccessTime(l) {
    this.file.timestamps.access = l;
  }
  setModificationTime(l) {
    this.file.timestamps.modification = l;
  }
  /**
   * Resizes the buffer to be exactly requiredBytes length, while resizing the
   * underlying buffer to be larger if necessary.
   *
   * Resizing will internally double the buffer size to reduce the need for
   * resizing often.
   *
   * @param requiredBytes how many bytes the buffer needs to have available
   */
  resize(l) {
    if (l <= this.buffer.buffer.byteLength) {
      this.buffer = new Uint8Array(this.buffer.buffer, 0, l);
      return;
    }
    let V;
    this.buffer.buffer.byteLength === 0 ? V = new ArrayBuffer(l < 1024 ? 1024 : l * 2) : l > this.buffer.buffer.byteLength * 2 ? V = new ArrayBuffer(l * 2) : V = new ArrayBuffer(this.buffer.buffer.byteLength * 2);
    const Z = new Uint8Array(V, 0, l);
    Z.set(this.buffer), this.buffer = Z;
  }
}
function K(t, l) {
  const V = l.replace(/[/\-\\^$*+?.()|[\]{}]/g, "\\$&"), Z = new RegExp(`^${V}`);
  return t.replace(Z, "");
}
class u {
  // full folder path including /
  constructor(l, V) {
    R(this, "dir");
    R(this, "prefix");
    this.dir = l, this.prefix = V;
  }
  containsFile(l) {
    for (const V of Object.keys(this.dir))
      if (K(V, this.prefix) === l)
        return !0;
    return !1;
  }
  containsDirectory(l) {
    for (const V of Object.keys(this.dir))
      if (K(V, this.prefix).startsWith(`${l}/`))
        return !0;
    return !1;
  }
  contains(l) {
    for (const V of Object.keys(this.dir)) {
      const Z = K(V, this.prefix);
      if (Z === l || Z.startsWith(`${l}/`))
        return !0;
    }
    return !1;
  }
  get(l) {
    return this.dir[this.fullPath(l)];
  }
  fullPath(l) {
    return `${this.prefix}${l}`;
  }
  list() {
    const l = [], V = /* @__PURE__ */ new Set();
    for (const Z of Object.keys(this.dir)) {
      const d = K(Z, this.prefix);
      if (d.includes("/")) {
        const i = d.split("/")[0];
        if (V.has(i))
          continue;
        V.add(i), l.push({ name: i, type: S.DIRECTORY });
      } else
        l.push({
          name: d,
          type: S.REGULAR_FILE
        });
    }
    return l;
  }
  stat() {
    return {
      path: this.prefix,
      timestamps: {
        access: /* @__PURE__ */ new Date(),
        modification: /* @__PURE__ */ new Date(),
        change: /* @__PURE__ */ new Date()
      },
      type: S.DIRECTORY,
      byteLength: 0
    };
  }
}
let D = [];
function E(t) {
  D.push(t);
}
function ul() {
  const t = D;
  return D = [], t;
}
class x extends Error {
}
class j extends Error {
}
class P {
  constructor(l) {
    R(this, "instance");
    R(this, "module");
    R(this, "memory");
    R(this, "context");
    R(this, "drive");
    R(this, "hasBeenInitialized", !1);
    this.context = new Gl(l), this.drive = new hl(this.context.fs);
  }
  /**
   * Start a WASI command.
   *
   */
  static async start(l, V = {}) {
    const Z = new P(V), d = await WebAssembly.instantiateStreaming(l, Z.getImportObject());
    return Z.start(d);
  }
  /**
   * Initialize a WASI reactor.
   *
   * Returns the WebAssembly instance exports.
   */
  static async initialize(l, V = {}) {
    const Z = new P(V), d = await WebAssembly.instantiateStreaming(l, Z.getImportObject());
    return Z.initialize(d), d.instance.exports;
  }
  getImportObject() {
    return {
      wasi_snapshot_preview1: this.getImports("preview1", this.context.debug),
      wasi_unstable: this.getImports("unstable", this.context.debug)
    };
  }
  /**
   * Start a WASI command.
   *
   * See: https://github.com/WebAssembly/WASI/blob/main/legacy/application-abi.md
   */
  start(l, V = {}) {
    if (this.hasBeenInitialized)
      throw new j("This instance has already been initialized");
    if (this.hasBeenInitialized = !0, this.instance = l.instance, this.module = l.module, this.memory = V.memory ?? this.instance.exports.memory, "_initialize" in this.instance.exports)
      throw new x("WebAssembly instance is a reactor and should be started with initialize.");
    if (!("_start" in this.instance.exports))
      throw new x("WebAssembly instance doesn't export _start, it may not be WASI or may be a Reactor.");
    const Z = this.instance.exports._start;
    try {
      Z();
    } catch (d) {
      if (d instanceof A)
        return {
          exitCode: d.code,
          fs: this.drive.fs
        };
      if (d instanceof WebAssembly.RuntimeError)
        return {
          exitCode: 134,
          fs: this.drive.fs
        };
      throw d;
    }
    return {
      exitCode: 0,
      fs: this.drive.fs
    };
  }
  /**
   * Initialize a WASI Reactor.
   *
   * See: https://github.com/WebAssembly/WASI/blob/main/legacy/application-abi.md
   */
  initialize(l, V = {}) {
    if (this.hasBeenInitialized)
      throw new j("This instance has already been initialized");
    if (this.hasBeenInitialized = !0, this.instance = l.instance, this.module = l.module, this.memory = V.memory ?? this.instance.exports.memory, "_start" in this.instance.exports)
      throw new x("WebAssembly instance is a command and should be started with start.");
    if ("_initialize" in this.instance.exports) {
      const Z = this.instance.exports._initialize;
      Z();
    }
  }
  getImports(l, V) {
    const Z = {
      args_get: this.args_get.bind(this),
      args_sizes_get: this.args_sizes_get.bind(this),
      clock_res_get: this.clock_res_get.bind(this),
      clock_time_get: this.clock_time_get.bind(this),
      environ_get: this.environ_get.bind(this),
      environ_sizes_get: this.environ_sizes_get.bind(this),
      proc_exit: this.proc_exit.bind(this),
      random_get: this.random_get.bind(this),
      sched_yield: this.sched_yield.bind(this),
      // File Descriptors
      fd_advise: this.fd_advise.bind(this),
      fd_allocate: this.fd_allocate.bind(this),
      fd_close: this.fd_close.bind(this),
      fd_datasync: this.fd_datasync.bind(this),
      fd_fdstat_get: this.fd_fdstat_get.bind(this),
      fd_fdstat_set_flags: this.fd_fdstat_set_flags.bind(this),
      fd_fdstat_set_rights: this.fd_fdstat_set_rights.bind(this),
      fd_filestat_get: this.fd_filestat_get.bind(this),
      fd_filestat_set_size: this.fd_filestat_set_size.bind(this),
      fd_filestat_set_times: this.fd_filestat_set_times.bind(this),
      fd_pread: this.fd_pread.bind(this),
      fd_prestat_dir_name: this.fd_prestat_dir_name.bind(this),
      fd_prestat_get: this.fd_prestat_get.bind(this),
      fd_pwrite: this.fd_pwrite.bind(this),
      fd_read: this.fd_read.bind(this),
      fd_readdir: this.fd_readdir.bind(this),
      fd_renumber: this.fd_renumber.bind(this),
      fd_seek: this.fd_seek.bind(this),
      fd_sync: this.fd_sync.bind(this),
      fd_tell: this.fd_tell.bind(this),
      fd_write: this.fd_write.bind(this),
      // Paths
      path_filestat_get: this.path_filestat_get.bind(this),
      path_filestat_set_times: this.path_filestat_set_times.bind(this),
      path_open: this.path_open.bind(this),
      path_rename: this.path_rename.bind(this),
      path_unlink_file: this.path_unlink_file.bind(this),
      path_create_directory: this.path_create_directory.bind(this),
      // Unimplemented
      path_link: this.path_link.bind(this),
      path_readlink: this.path_readlink.bind(this),
      path_remove_directory: this.path_remove_directory.bind(this),
      path_symlink: this.path_symlink.bind(this),
      poll_oneoff: this.poll_oneoff.bind(this),
      proc_raise: this.proc_raise.bind(this),
      sock_accept: this.sock_accept.bind(this),
      sock_recv: this.sock_recv.bind(this),
      sock_send: this.sock_send.bind(this),
      sock_shutdown: this.sock_shutdown.bind(this),
      // Unimplemented - WASMEdge compatibility
      sock_open: this.sock_open.bind(this),
      sock_listen: this.sock_listen.bind(this),
      sock_connect: this.sock_connect.bind(this),
      sock_setsockopt: this.sock_setsockopt.bind(this),
      sock_bind: this.sock_bind.bind(this),
      sock_getlocaladdr: this.sock_getlocaladdr.bind(this),
      sock_getpeeraddr: this.sock_getpeeraddr.bind(this),
      sock_getaddrinfo: this.sock_getaddrinfo.bind(this)
    };
    l === "unstable" && (Z.path_filestat_get = this.unstable_path_filestat_get.bind(this), Z.fd_filestat_get = this.unstable_fd_filestat_get.bind(this), Z.fd_seek = this.unstable_fd_seek.bind(this));
    for (const [d, i] of Object.entries(Z))
      Z[d] = function() {
        let n = i.apply(this, arguments);
        if (V) {
          const m = ul();
          n = V(d, [...arguments], n, m) ?? n;
        }
        return n;
      };
    return Z;
  }
  //
  // Helpers
  //
  get envArray() {
    return Object.entries(this.context.env).map(([l, V]) => `${l}=${V}`);
  }
  //
  // WASI Implementation
  //
  /**
   * Read command-line argument data. The size of the array should match that
   * returned by args_sizes_get. Each argument is expected to be \0 terminated.
   */
  args_get(l, V) {
    const Z = new DataView(this.memory.buffer);
    for (const d of this.context.args) {
      Z.setUint32(l, V, !0), l += 4;
      const i = new TextEncoder().encode(`${d}\0`);
      new Uint8Array(this.memory.buffer, V, i.byteLength).set(i), V += i.byteLength;
    }
    return c.SUCCESS;
  }
  /**
   * Return command-line argument data sizes.
   */
  args_sizes_get(l, V) {
    const Z = this.context.args, d = Z.reduce((n, m) => n + new TextEncoder().encode(`${m}\0`).byteLength, 0), i = new DataView(this.memory.buffer);
    return i.setUint32(l, Z.length, !0), i.setUint32(V, d, !0), c.SUCCESS;
  }
  /**
   * Return the resolution of a clock. Implementations are required to provide a
   * non-zero value for supported clocks. For unsupported clocks, return
   * errno::inval. Note: This is similar to clock_getres in POSIX.
   */
  clock_res_get(l, V) {
    switch (l) {
      case k.REALTIME:
      case k.MONOTONIC:
      case k.PROCESS_CPUTIME_ID:
      case k.THREAD_CPUTIME_ID:
        return new DataView(this.memory.buffer).setBigUint64(V, BigInt(1e6), !0), c.SUCCESS;
    }
    return c.EINVAL;
  }
  /**
   * Return the time value of a clock.
   * Note: This is similar to clock_gettime in POSIX.
   */
  clock_time_get(l, V, Z) {
    switch (l) {
      case k.REALTIME:
      case k.MONOTONIC:
      case k.PROCESS_CPUTIME_ID:
      case k.THREAD_CPUTIME_ID:
        return new DataView(this.memory.buffer).setBigUint64(Z, r(/* @__PURE__ */ new Date()), !0), c.SUCCESS;
    }
    return c.EINVAL;
  }
  /**
   * Read environment variable data. The sizes of the buffers should match that
   * returned by environ_sizes_get. Key/value pairs are expected to be joined
   * with =s, and terminated with \0s.
   */
  environ_get(l, V) {
    const Z = new DataView(this.memory.buffer);
    for (const d of this.envArray) {
      Z.setUint32(l, V, !0), l += 4;
      const i = new TextEncoder().encode(`${d}\0`);
      new Uint8Array(this.memory.buffer, V, i.byteLength).set(i), V += i.byteLength;
    }
    return c.SUCCESS;
  }
  /**
   * Return environment variable data sizes.
   */
  environ_sizes_get(l, V) {
    const Z = this.envArray.reduce((i, n) => i + new TextEncoder().encode(`${n}\0`).byteLength, 0), d = new DataView(this.memory.buffer);
    return d.setUint32(l, this.envArray.length, !0), d.setUint32(V, Z, !0), c.SUCCESS;
  }
  /**
   * Terminate the process normally. An exit code of 0 indicates successful
   * termination of the program. The meanings of other values is dependent on
   * the environment.
   */
  proc_exit(l) {
    throw new A(l);
  }
  /**
   * Write high-quality random data into a buffer. This function blocks when the
   * implementation is unable to immediately provide sufficient high-quality
   * random data. This function may execute slowly, so when large mounts of
   * random data are required, it's advisable to use this function to seed a
   * pseudo-random number generator, rather than to provide the random data
   * directly.
   */
  random_get(l, V) {
    const Z = new Uint8Array(this.memory.buffer, l, V);
    return globalThis.crypto.getRandomValues(Z), c.SUCCESS;
  }
  /**
   * Temporarily yield execution of the calling thread.
   * Note: This is similar to sched_yield in POSIX.
   */
  sched_yield() {
    return c.SUCCESS;
  }
  //
  // File Descriptors
  //
  /**
   * Read from a file descriptor. Note: This is similar to readv in POSIX.
   */
  fd_read(l, V, Z, d) {
    if (l === 1 || l === 2)
      return c.ENOTSUP;
    const i = new DataView(this.memory.buffer), n = J(i, V, Z), m = new TextEncoder();
    let e = 0, a = c.SUCCESS;
    for (const X of n) {
      let s;
      if (l === 0) {
        const h = this.context.stdin(X.byteLength);
        if (!h)
          break;
        s = m.encode(h);
      } else {
        const [h, o] = this.drive.read(l, X.byteLength);
        if (h) {
          a = h;
          break;
        } else
          s = o;
      }
      const G = Math.min(X.byteLength, s.byteLength);
      X.set(s.subarray(0, G)), e += G;
    }
    return E({ bytesRead: e }), i.setUint32(d, e, !0), a;
  }
  /**
   * Write to a file descriptor. Note: This is similar to writev in POSIX.
   */
  fd_write(l, V, Z, d) {
    if (l === 0)
      return c.ENOTSUP;
    const i = new DataView(this.memory.buffer), n = J(i, V, Z), m = new TextDecoder();
    let e = 0, a = c.SUCCESS;
    for (const X of n)
      if (X.byteLength !== 0) {
        if (l === 1 || l === 2) {
          const s = l === 1 ? this.context.stdout : this.context.stderr, G = m.decode(X);
          s(G), E({ output: G });
        } else if (a = this.drive.write(l, X), a != c.SUCCESS)
          break;
        e += X.byteLength;
      }
    return i.setUint32(d, e, !0), a;
  }
  /**
   * Provide file advisory information on a file descriptor.
   * Note: This is similar to posix_fadvise in POSIX.
   */
  fd_advise() {
    return c.SUCCESS;
  }
  /**
   * Force the allocation of space in a file.
   * Note: This is similar to posix_fallocate in POSIX.
   */
  fd_allocate(l, V, Z) {
    return this.drive.pwrite(l, new Uint8Array(Number(Z)), Number(V));
  }
  /**
   * Close a file descriptor.
   * Note: This is similar to close in POSIX.
   *
   * @param fd
   */
  fd_close(l) {
    return this.drive.close(l);
  }
  /**
   * Synchronize the data of a file to disk.
   * Note: This is similar to fdatasync in POSIX.
   *
   * @param fd
   */
  fd_datasync(l) {
    return this.drive.sync(l);
  }
  /**
   * Get the attributes of a file descriptor.
   * Note: This returns similar flags to fsync(fd, F_GETFL) in POSIX,
   * as well as additional fields.
   *
   * Returns fdstat - the buffer where the file descriptor's attributes
   * are stored.
   *
   * @returns Result<fdstat, errno>
   */
  fd_fdstat_get(l, V) {
    if (l < 3) {
      let m;
      if (this.context.isTTY) {
        const a = O ^ b.FD_SEEK ^ b.FD_TELL;
        m = g(S.CHARACTER_DEVICE, 0, a);
      } else
        m = g(S.CHARACTER_DEVICE, 0);
      return new Uint8Array(this.memory.buffer, V, m.byteLength).set(m), c.SUCCESS;
    }
    if (!this.drive.exists(l))
      return c.EBADF;
    const Z = this.drive.fileType(l), d = this.drive.fileFdflags(l), i = g(Z, d);
    return new Uint8Array(this.memory.buffer, V, i.byteLength).set(i), c.SUCCESS;
  }
  /**
   * Adjust the flags associated with a file descriptor.
   * Note: This is similar to fcntl(fd, F_SETFL, flags) in POSIX.
   */
  fd_fdstat_set_flags(l, V) {
    return this.drive.setFlags(l, V);
  }
  /**
   * Adjust the rights associated with a file descriptor. This can only be used
   * to remove rights, and returns errno::notcapable if called in a way that
   * would attempt to add rights
   */
  fd_fdstat_set_rights() {
    return c.SUCCESS;
  }
  /**
   * Return the attributes of an open file.
   */
  fd_filestat_get(l, V) {
    return this.shared_fd_filestat_get(l, V, "preview1");
  }
  /**
   * Return the attributes of an open file.
   * This version is used
   */
  unstable_fd_filestat_get(l, V) {
    return this.shared_fd_filestat_get(l, V, "unstable");
  }
  /**
   * Return the attributes of an open file.
   */
  shared_fd_filestat_get(l, V, Z) {
    const d = Z === "unstable" ? $ : _;
    if (l < 3) {
      let a;
      switch (l) {
        case 0:
          a = "/dev/stdin";
          break;
        case 1:
          a = "/dev/stdout";
          break;
        case 2:
          a = "/dev/stderr";
          break;
        default:
          a = "/dev/undefined";
          break;
      }
      const X = d({
        path: a,
        byteLength: 0,
        timestamps: {
          access: /* @__PURE__ */ new Date(),
          modification: /* @__PURE__ */ new Date(),
          change: /* @__PURE__ */ new Date()
        },
        type: S.CHARACTER_DEVICE
      });
      return new Uint8Array(this.memory.buffer, V, X.byteLength).set(X), c.SUCCESS;
    }
    const [i, n] = this.drive.stat(l);
    if (i != c.SUCCESS)
      return i;
    E({ resolvedPath: n.path, stat: n });
    const m = d(n);
    return new Uint8Array(this.memory.buffer, V, m.byteLength).set(m), c.SUCCESS;
  }
  /**
   * Adjust the size of an open file. If this increases the file's size, the
   * extra bytes are filled with zeros. Note: This is similar to ftruncate in
   * POSIX.
   */
  fd_filestat_set_size(l, V) {
    return this.drive.setSize(l, V);
  }
  /**
   * Adjust the timestamps of an open file or directory.
   * Note: This is similar to futimens in POSIX.
   */
  fd_filestat_set_times(l, V, Z, d) {
    let i = null;
    d & T.ATIM && (i = Y(V)), d & T.ATIM_NOW && (i = /* @__PURE__ */ new Date());
    let n = null;
    if (d & T.MTIM && (n = Y(Z)), d & T.MTIM_NOW && (n = /* @__PURE__ */ new Date()), i) {
      const m = this.drive.setAccessTime(l, i);
      if (m != c.SUCCESS)
        return m;
    }
    if (n) {
      const m = this.drive.setModificationTime(l, n);
      if (m != c.SUCCESS)
        return m;
    }
    return c.SUCCESS;
  }
  /**
   * Read from a file descriptor, without using and updating the file
   * descriptor's offset. Note: This is similar to preadv in POSIX.
   */
  fd_pread(l, V, Z, d, i) {
    if (l === 1 || l === 2)
      return c.ENOTSUP;
    if (l === 0)
      return this.fd_read(l, V, Z, i);
    const n = new DataView(this.memory.buffer), m = J(n, V, Z);
    let e = 0, a = c.SUCCESS;
    for (const X of m) {
      const [s, G] = this.drive.pread(l, X.byteLength, Number(d) + e);
      if (s !== c.SUCCESS) {
        a = s;
        break;
      }
      const h = Math.min(X.byteLength, G.byteLength);
      X.set(G.subarray(0, h)), e += h;
    }
    return n.setUint32(i, e, !0), a;
  }
  /**
   * Return a description of the given preopened file descriptor.
   */
  fd_prestat_dir_name(l, V, Z) {
    if (l !== 3)
      return c.EBADF;
    const d = new TextEncoder().encode("/");
    return new Uint8Array(this.memory.buffer, V, Z).set(d.subarray(0, Z)), c.SUCCESS;
  }
  /**
   * Return a description of the given preopened file descriptor.
   */
  fd_prestat_get(l, V) {
    if (l !== 3)
      return c.EBADF;
    const Z = new TextEncoder().encode("."), d = new DataView(this.memory.buffer, V);
    return d.setUint8(0, f.DIR), d.setUint32(4, Z.byteLength, !0), c.SUCCESS;
  }
  /**
   * Write to a file descriptor, without using and updating the file
   * descriptor's offset. Note: This is similar to pwritev in POSIX.
   */
  fd_pwrite(l, V, Z, d, i) {
    if (l === 0)
      return c.ENOTSUP;
    if (l === 1 || l === 2)
      return this.fd_write(l, V, Z, i);
    const n = new DataView(this.memory.buffer), m = J(n, V, Z);
    let e = 0, a = c.SUCCESS;
    for (const X of m)
      if (X.byteLength !== 0) {
        if (a = this.drive.pwrite(l, X, Number(d)), a != c.SUCCESS)
          break;
        e += X.byteLength;
      }
    return n.setUint32(i, e, !0), a;
  }
  /**
   * Read directory entries from a directory. When successful, the contents of
   * the output buffer consist of a sequence of directory entries. Each
   * directory entry consists of a dirent object, followed by dirent::d_namlen
   * bytes holding the name of the directory entry. This function fills the
   * output buffer as much as possible, potentially truncating the last
   * directory entry. This allows the caller to grow its read buffer size in
   * case it's too small to fit a single large directory entry, or skip the
   * oversized directory entry.
   */
  fd_readdir(l, V, Z, d, i) {
    const [n, m] = this.drive.list(l);
    if (n != c.SUCCESS)
      return n;
    let e = [], a = 0;
    for (const { name: p, type: U } of m) {
      const M = ol(p, U, a);
      e.push(M), a++;
    }
    e = e.slice(Number(d));
    const X = e.reduce((p, U) => p + U.byteLength, 0), s = new Uint8Array(X);
    let G = 0;
    for (const p of e)
      s.set(p, G), G += p.byteLength;
    const h = new Uint8Array(this.memory.buffer, V, Z), o = s.subarray(0, Z);
    return h.set(o), new DataView(this.memory.buffer).setUint32(i, o.byteLength, !0), c.SUCCESS;
  }
  /**
   * Atomically replace a file descriptor by renumbering another file
   * descriptor. Due to the strong focus on thread safety, this environment does
   * not provide a mechanism to duplicate or renumber a file descriptor to an
   * arbitrary number, like dup2(). This would be prone to race conditions, as
   * an actual file descriptor with the same number could be allocated by a
   * different thread at the same time. This function provides a way to
   * atomically renumber file descriptors, which would disappear if dup2() were
   * to be removed entirely.
   */
  fd_renumber(l, V) {
    return this.drive.renumber(l, V);
  }
  /**
   * Move the offset of a file descriptor.
   *
   * The offset is specified as a bigint here
   * Note: This is similar to lseek in POSIX.
   *
   * The offset, and return type are FileSize (u64) which is represented by
   * bigint in JavaScript.
   */
  fd_seek(l, V, Z, d) {
    const [i, n] = this.drive.seek(l, V, Z);
    return i !== c.SUCCESS || (E({ newOffset: n.toString() }), new DataView(this.memory.buffer).setBigUint64(d, n, !0)), i;
  }
  unstable_fd_seek(l, V, Z, d) {
    const i = Sl[Z];
    return this.fd_seek(l, V, i, d);
  }
  /**
   * Synchronize the data and metadata of a file to disk.
   * Note: This is similar to fsync in POSIX.
   */
  fd_sync(l) {
    return this.drive.sync(l);
  }
  /**
   * Return the current offset of a file descriptor.
   * Note: This is similar to lseek(fd, 0, SEEK_CUR) in POSIX.
   *
   * The return type is FileSize (u64) which is represented by bigint in JS.
   *
   */
  fd_tell(l, V) {
    const [Z, d] = this.drive.tell(l);
    return Z !== c.SUCCESS || new DataView(this.memory.buffer).setBigUint64(V, d, !0), Z;
  }
  //
  // Paths
  //
  path_filestat_get(l, V, Z, d, i) {
    return this.shared_path_filestat_get(l, V, Z, d, i, "preview1");
  }
  unstable_path_filestat_get(l, V, Z, d, i) {
    return this.shared_path_filestat_get(l, V, Z, d, i, "unstable");
  }
  /**
   * Return the attributes of a file or directory.
   * Note: This is similar to stat in POSIX.
   */
  shared_path_filestat_get(l, V, Z, d, i, n) {
    const m = n === "unstable" ? $ : _, e = new TextDecoder().decode(new Uint8Array(this.memory.buffer, Z, d));
    E({ path: e });
    const [a, X] = this.drive.pathStat(l, e);
    if (a != c.SUCCESS)
      return a;
    const s = m(X);
    return new Uint8Array(this.memory.buffer, i, s.byteLength).set(s), a;
  }
  /**
   * Adjust the timestamps of a file or directory.
   * Note: This is similar to utimensat in POSIX.
   */
  path_filestat_set_times(l, V, Z, d, i, n, m) {
    let e = null;
    m & T.ATIM && (e = Y(i)), m & T.ATIM_NOW && (e = /* @__PURE__ */ new Date());
    let a = null;
    m & T.MTIM && (a = Y(n)), m & T.MTIM_NOW && (a = /* @__PURE__ */ new Date());
    const X = new TextDecoder().decode(new Uint8Array(this.memory.buffer, Z, d));
    if (e) {
      const s = this.drive.pathSetAccessTime(l, X, e);
      if (s != c.SUCCESS)
        return s;
    }
    if (a) {
      const s = this.drive.pathSetModificationTime(l, X, a);
      if (s != c.SUCCESS)
        return s;
    }
    return c.SUCCESS;
  }
  /**
   * Open a file or directory. The returned file descriptor is not guaranteed to
   * be the lowest-numbered file descriptor not currently open; it is randomized
   * to prevent applications from depending on making assumptions about indexes,
   * since this is error-prone in multi-threaded contexts. The returned file
   * descriptor is guaranteed to be less than 2**31.
   * Note: This is similar to openat in POSIX.
   * @param fd: fd
   * @param dirflags: lookupflags Flags determining the method of how the path
   *                  is resolved. Not supported by Runno (symlinks)
   * @param path: string The relative path of the file or directory to open,
   *              relative to the path_open::fd directory.
   * @param oflags: oflags The method by which to open the file.
   * @param fs_rights_base: rights The initial rights of the newly created file
   *                        descriptor. The implementation is allowed to return
   *                        a file descriptor with fewer rights than specified,
   *                        if and only if those rights do not apply to the type
   *                        of file being opened. The base rights are rights
   *                        that will apply to operations using the file
   *                        descriptor itself, while the inheriting rights are
   *                        rights that apply to file descriptors derived from
   *                        it.
   * @param fs_rights_inheriting: rights
   * @param fdflags: fdflags
   *
   */
  path_open(l, V, Z, d, i, n, m, e, a) {
    const X = new DataView(this.memory.buffer), s = C(this.memory, Z, d), G = !!(i & L.CREAT), h = !!(i & L.DIRECTORY), o = !!(i & L.EXCL), I = !!(i & L.TRUNC), p = !!(e & N.APPEND), U = !!(e & N.DSYNC), M = !!(e & N.NONBLOCK), il = !!(e & N.RSYNC), nl = !!(e & N.SYNC);
    E({
      path: s,
      openFlags: {
        createFileIfNone: G,
        failIfNotDir: h,
        failIfFileExists: o,
        truncateFile: I
      },
      fileDescriptorFlags: {
        flagAppend: p,
        flagDSync: U,
        flagNonBlock: M,
        flagRSync: il,
        flagSync: nl
      }
    });
    const [z, el] = this.drive.open(l, s, i, e);
    return z || (X.setUint32(a, el, !0), z);
  }
  /**
   * Rename a file or directory. Note: This is similar to renameat in POSIX.
   */
  path_rename(l, V, Z, d, i, n) {
    const m = C(this.memory, V, Z), e = C(this.memory, i, n);
    return E({ oldPath: m, newPath: e }), this.drive.rename(l, m, d, e);
  }
  /**
   * Unlink a file. Return errno::isdir if the path refers to a directory.
   * Note: This is similar to unlinkat(fd, path, 0) in POSIX.
   */
  path_unlink_file(l, V, Z) {
    const d = C(this.memory, V, Z);
    return E({ path: d }), this.drive.unlink(l, d);
  }
  /**
   * Concurrently poll for the occurrence of a set of events.
   */
  poll_oneoff(l, V, Z, d) {
    for (let n = 0; n < Z; n++) {
      const m = new Uint8Array(this.memory.buffer, l + n * B, B), e = pl(m), a = new Uint8Array(this.memory.buffer, V + n * H, H);
      let X = 0, s = c.SUCCESS;
      switch (e.type) {
        case y.CLOCK:
          for (; /* @__PURE__ */ new Date() < e.timeout; )
            ;
          a.set(Ul(e.userdata, c.SUCCESS));
          break;
        case y.FD_READ:
          if (e.fd < 3)
            e.fd === 0 ? (s = c.SUCCESS, X = 32) : s = c.EBADF;
          else {
            const [G, h] = this.drive.stat(e.fd);
            s = G, X = h ? h.byteLength : 0;
          }
          a.set(q(e.userdata, s, y.FD_READ, BigInt(X)));
          break;
        case y.FD_WRITE:
          if (X = 0, s = c.SUCCESS, e.fd < 3)
            e.fd === 0 ? s = c.EBADF : (s = c.SUCCESS, X = 1024);
          else {
            const [G, h] = this.drive.stat(e.fd);
            s = G, X = h ? h.byteLength : 0;
          }
          a.set(q(e.userdata, s, y.FD_READ, BigInt(X)));
          break;
      }
    }
    return new DataView(this.memory.buffer, d, 4).setUint32(0, Z, !0), c.SUCCESS;
  }
  /**
   * Create a directory. Note: This is similar to mkdirat in POSIX.
   */
  path_create_directory(l, V, Z) {
    const d = C(this.memory, V, Z);
    return this.drive.pathCreateDir(l, d);
  }
  //
  // Unimplemented - these operations are not supported by Runno
  //
  /**
   * Create a hard link. Note: This is similar to linkat in POSIX.
   */
  path_link() {
    return c.ENOSYS;
  }
  /**
   * Read the contents of a symbolic link.
   * Note: This is similar to readlinkat in POSIX.
   */
  path_readlink() {
    return c.ENOSYS;
  }
  /**
   * Remove a directory. Return errno::notempty if the directory is not empty.
   * Note: This is similar to unlinkat(fd, path, AT_REMOVEDIR) in POSIX.
   */
  path_remove_directory() {
    return c.ENOSYS;
  }
  /**
   * Create a symbolic link. Note: This is similar to symlinkat in POSIX.
   */
  path_symlink() {
    return c.ENOSYS;
  }
  /**
   * Send a signal to the process of the calling thread.
   * Note: This is similar to raise in POSIX.
   */
  proc_raise() {
    return c.ENOSYS;
  }
  /**
   * Accept a new incoming connection. Note: This is similar to accept in POSIX.
   */
  sock_accept() {
    return c.ENOSYS;
  }
  /**
   * Receive a message from a socket. Note: This is similar to recv in POSIX,
   * though it also supports reading the data into multiple buffers in the
   * manner of readv.
   */
  sock_recv() {
    return c.ENOSYS;
  }
  /**
   * Send a message on a socket. Note: This is similar to send in POSIX, though
   * it also supports writing the data from multiple buffers in the manner of
   * writev.
   */
  sock_send() {
    return c.ENOSYS;
  }
  /**
   * Shut down socket send and receive channels. Note: This is similar to
   * shutdown in POSIX.
   */
  sock_shutdown() {
    return c.ENOSYS;
  }
  //
  // Unimplemented - these are for compatibility with Wasmedge
  //
  sock_open() {
    return c.ENOSYS;
  }
  sock_listen() {
    return c.ENOSYS;
  }
  sock_connect() {
    return c.ENOSYS;
  }
  sock_setsockopt() {
    return c.ENOSYS;
  }
  sock_bind() {
    return c.ENOSYS;
  }
  sock_getlocaladdr() {
    return c.ENOSYS;
  }
  sock_getpeeraddr() {
    return c.ENOSYS;
  }
  sock_getaddrinfo() {
    return c.ENOSYS;
  }
}
const O = b.FD_DATASYNC | b.FD_READ | b.FD_SEEK | b.FD_FDSTAT_SET_FLAGS | b.FD_SYNC | b.FD_TELL | b.FD_WRITE | b.FD_ADVISE | b.FD_ALLOCATE | b.PATH_CREATE_DIRECTORY | b.PATH_CREATE_FILE | b.PATH_LINK_SOURCE | b.PATH_LINK_TARGET | b.PATH_OPEN | b.FD_READDIR | b.PATH_READLINK | b.PATH_RENAME_SOURCE | b.PATH_RENAME_TARGET | b.PATH_FILESTAT_GET | b.PATH_FILESTAT_SET_SIZE | b.PATH_FILESTAT_SET_TIMES | b.FD_FILESTAT_GET | b.FD_FILESTAT_SET_SIZE | b.FD_FILESTAT_SET_TIMES | b.PATH_SYMLINK | b.PATH_REMOVE_DIRECTORY | b.PATH_UNLINK_FILE | b.POLL_FD_READWRITE | b.SOCK_SHUTDOWN | b.SOCK_ACCEPT;
class A extends Error {
  constructor(V) {
    super();
    R(this, "code");
    this.code = V;
  }
}
function C(t, l, V) {
  return new TextDecoder().decode(new Uint8Array(t.buffer, l, V));
}
function J(t, l, V) {
  let Z = Array(V);
  for (let d = 0; d < V; d++) {
    const i = t.getUint32(l, !0);
    l += 4;
    const n = t.getUint32(l, !0);
    l += 4, Z[d] = new Uint8Array(t.buffer, i, n);
  }
  return Z;
}
function pl(t) {
  const l = new Uint8Array(8);
  l.set(t.subarray(0, 8));
  const V = t[8], Z = new DataView(t.buffer, t.byteOffset + 9);
  switch (V) {
    case y.FD_READ:
    case y.FD_WRITE:
      return {
        userdata: l,
        type: V,
        fd: Z.getUint32(0, !0)
      };
    case y.CLOCK:
      const d = Z.getUint16(24, !0), i = r(/* @__PURE__ */ new Date()), n = Z.getBigUint64(8, !0), m = Z.getBigUint64(16, !0), e = d & Zl.SUBSCRIPTION_CLOCK_ABSTIME ? n : i + n;
      return {
        userdata: l,
        type: V,
        id: Z.getUint32(0, !0),
        timeout: Y(e),
        precision: Y(e + m)
      };
  }
}
function _(t) {
  const l = new Uint8Array(w), V = new DataView(l.buffer);
  return V.setBigUint64(0, BigInt(0), !0), V.setBigUint64(8, BigInt(v(t.path)), !0), V.setUint8(16, t.type), V.setBigUint64(24, BigInt(1), !0), V.setBigUint64(32, BigInt(t.byteLength), !0), V.setBigUint64(40, r(t.timestamps.access), !0), V.setBigUint64(48, r(t.timestamps.modification), !0), V.setBigUint64(56, r(t.timestamps.change), !0), l;
}
function $(t) {
  const l = new Uint8Array(w), V = new DataView(l.buffer);
  return V.setBigUint64(0, BigInt(0), !0), V.setBigUint64(8, BigInt(v(t.path)), !0), V.setUint8(16, t.type), V.setUint32(20, 1, !0), V.setBigUint64(24, BigInt(t.byteLength), !0), V.setBigUint64(32, r(t.timestamps.access), !0), V.setBigUint64(40, r(t.timestamps.modification), !0), V.setBigUint64(48, r(t.timestamps.change), !0), l;
}
function g(t, l, V) {
  const Z = V ?? O, d = V ?? O, i = new Uint8Array(24), n = new DataView(i.buffer, 0, 24);
  return n.setUint8(0, t), n.setUint32(2, l, !0), n.setBigUint64(8, Z, !0), n.setBigUint64(16, d, !0), i;
}
function ol(t, l, V) {
  const Z = new TextEncoder().encode(t), d = 24 + Z.byteLength, i = new Uint8Array(d), n = new DataView(i.buffer);
  return n.setBigUint64(0, BigInt(V + 1), !0), n.setBigUint64(8, BigInt(v(t)), !0), n.setUint32(16, Z.length, !0), n.setUint8(20, l), i.set(Z, 24), i;
}
function Ul(t, l) {
  const V = new Uint8Array(32);
  V.set(t, 0);
  const Z = new DataView(V.buffer);
  return Z.setUint16(8, l, !0), Z.setUint16(10, y.CLOCK, !0), V;
}
function q(t, l, V, Z) {
  const d = new Uint8Array(32);
  d.set(t, 0);
  const i = new DataView(d.buffer);
  return i.setUint16(8, l, !0), i.setUint16(10, V, !0), i.setBigUint64(16, Z, !0), d;
}
function v(t, l = 0) {
  let V = 3735928559 ^ l, Z = 1103547991 ^ l;
  for (let d = 0, i; d < t.length; d++)
    i = t.charCodeAt(d), V = Math.imul(V ^ i, 2654435761), Z = Math.imul(Z ^ i, 1597334677);
  return V = Math.imul(V ^ V >>> 16, 2246822507) ^ Math.imul(Z ^ Z >>> 13, 3266489909), Z = Math.imul(Z ^ Z >>> 16, 2246822507) ^ Math.imul(V ^ V >>> 13, 3266489909), 4294967296 * (2097151 & Z) + (V >>> 0);
}
function r(t) {
  return BigInt(t.getTime()) * BigInt(1e6);
}
function Y(t) {
  return new Date(Number(t / BigInt(1e6)));
}
const Sl = {
  [Q.CUR]: F.CUR,
  [Q.END]: F.END,
  [Q.SET]: F.SET
}, dl = "dmFyIFR0PU9iamVjdC5kZWZpbmVQcm9wZXJ0eTt2YXIgQ3Q9KHMsQyxiKT0+QyBpbiBzP1R0KHMsQyx7ZW51bWVyYWJsZTohMCxjb25maWd1cmFibGU6ITAsd3JpdGFibGU6ITAsdmFsdWU6Yn0pOnNbQ109Yjt2YXIgZD0ocyxDLGIpPT4oQ3Qocyx0eXBlb2YgQyE9InN5bWJvbCI/QysiIjpDLGIpLGIpOyhmdW5jdGlvbigpeyJ1c2Ugc3RyaWN0Ijt2YXIgcz0oZT0+KGVbZS5TVUNDRVNTPTBdPSJTVUNDRVNTIixlW2UuRTJCSUc9MV09IkUyQklHIixlW2UuRUFDQ0VTUz0yXT0iRUFDQ0VTUyIsZVtlLkVBRERSSU5VU0U9M109IkVBRERSSU5VU0UiLGVbZS5FQUREUk5PVEFWQUlMPTRdPSJFQUREUk5PVEFWQUlMIixlW2UuRUFGTk9TVVBQT1JUPTVdPSJFQUZOT1NVUFBPUlQiLGVbZS5FQUdBSU49Nl09IkVBR0FJTiIsZVtlLkVBTFJFQURZPTddPSJFQUxSRUFEWSIsZVtlLkVCQURGPThdPSJFQkFERiIsZVtlLkVCQURNU0c9OV09IkVCQURNU0ciLGVbZS5FQlVTWT0xMF09IkVCVVNZIixlW2UuRUNBTkNFTEVEPTExXT0iRUNBTkNFTEVEIixlW2UuRUNISUxEPTEyXT0iRUNISUxEIixlW2UuRUNPTk5BQk9SVEVEPTEzXT0iRUNPTk5BQk9SVEVEIixlW2UuRUNPTk5SRUZVU0VEPTE0XT0iRUNPTk5SRUZVU0VEIixlW2UuRUNPTk5SRVNFVD0xNV09IkVDT05OUkVTRVQiLGVbZS5FREVBRExLPTE2XT0iRURFQURMSyIsZVtlLkVERVNUQUREUlJFUT0xN109IkVERVNUQUREUlJFUSIsZVtlLkVET009MThdPSJFRE9NIixlW2UuRURRVU9UPTE5XT0iRURRVU9UIixlW2UuRUVYSVNUPTIwXT0iRUVYSVNUIixlW2UuRUZBVUxUPTIxXT0iRUZBVUxUIixlW2UuRUZCSUc9MjJdPSJFRkJJRyIsZVtlLkVIT1NUVU5SRUFDSD0yM109IkVIT1NUVU5SRUFDSCIsZVtlLkVJRFJNPTI0XT0iRUlEUk0iLGVbZS5FSUxTRVE9MjVdPSJFSUxTRVEiLGVbZS5FSU5QUk9HUkVTUz0yNl09IkVJTlBST0dSRVNTIixlW2UuRUlOVFI9MjddPSJFSU5UUiIsZVtlLkVJTlZBTD0yOF09IkVJTlZBTCIsZVtlLkVJTz0yOV09IkVJTyIsZVtlLkVJU0NPTk49MzBdPSJFSVNDT05OIixlW2UuRUlTRElSPTMxXT0iRUlTRElSIixlW2UuRUxPT1A9MzJdPSJFTE9PUCIsZVtlLkVNRklMRT0zM109IkVNRklMRSIsZVtlLkVNTElOSz0zNF09IkVNTElOSyIsZVtlLkVNU0dTSVpFPTM1XT0iRU1TR1NJWkUiLGVbZS5FTVVMVElIT1A9MzZdPSJFTVVMVElIT1AiLGVbZS5FTkFNRVRPT0xPTkc9MzddPSJFTkFNRVRPT0xPTkciLGVbZS5FTkVURE9XTj0zOF09IkVORVRET1dOIixlW2UuRU5FVFJFU0VUPTM5XT0iRU5FVFJFU0VUIixlW2UuRU5FVFVOUkVBQ0g9NDBdPSJFTkVUVU5SRUFDSCIsZVtlLkVORklMRT00MV09IkVORklMRSIsZVtlLkVOT0JVRlM9NDJdPSJFTk9CVUZTIixlW2UuRU5PREVWPTQzXT0iRU5PREVWIixlW2UuRU5PRU5UPTQ0XT0iRU5PRU5UIixlW2UuRU5PRVhFQz00NV09IkVOT0VYRUMiLGVbZS5FTk9MQ0s9NDZdPSJFTk9MQ0siLGVbZS5FTk9MSU5LPTQ3XT0iRU5PTElOSyIsZVtlLkVOT01FTT00OF09IkVOT01FTSIsZVtlLkVOT01TRz00OV09IkVOT01TRyIsZVtlLkVOT1BST1RPT1BUPTUwXT0iRU5PUFJPVE9PUFQiLGVbZS5FTk9TUEM9NTFdPSJFTk9TUEMiLGVbZS5FTk9TWVM9NTJdPSJFTk9TWVMiLGVbZS5FTk9UQ09OTj01M109IkVOT1RDT05OIixlW2UuRU5PVERJUj01NF09IkVOT1RESVIiLGVbZS5FTk9URU1QVFk9NTVdPSJFTk9URU1QVFkiLGVbZS5FTk9UUkVDT1ZFUkFCTEU9NTZdPSJFTk9UUkVDT1ZFUkFCTEUiLGVbZS5FTk9UU09DSz01N109IkVOT1RTT0NLIixlW2UuRU5PVFNVUD01OF09IkVOT1RTVVAiLGVbZS5FTk9UVFk9NTldPSJFTk9UVFkiLGVbZS5FTlhJTz02MF09IkVOWElPIixlW2UuRU9WRVJGTE9XPTYxXT0iRU9WRVJGTE9XIixlW2UuRU9XTkVSREVBRD02Ml09IkVPV05FUkRFQUQiLGVbZS5FUEVSTT02M109IkVQRVJNIixlW2UuRVBJUEU9NjRdPSJFUElQRSIsZVtlLkVQUk9UTz02NV09IkVQUk9UTyIsZVtlLkVQUk9UT05PU1VQUE9SVD02Nl09IkVQUk9UT05PU1VQUE9SVCIsZVtlLkVQUk9UT1RZUEU9NjddPSJFUFJPVE9UWVBFIixlW2UuRVJBTkdFPTY4XT0iRVJBTkdFIixlW2UuRVJPRlM9NjldPSJFUk9GUyIsZVtlLkVTUElQRT03MF09IkVTUElQRSIsZVtlLkVTUkNIPTcxXT0iRVNSQ0giLGVbZS5FU1RBTEU9NzJdPSJFU1RBTEUiLGVbZS5FVElNRURPVVQ9NzNdPSJFVElNRURPVVQiLGVbZS5FVFhUQlNZPTc0XT0iRVRYVEJTWSIsZVtlLkVYREVWPTc1XT0iRVhERVYiLGVbZS5FTk9UQ0FQQUJMRT03Nl09IkVOT1RDQVBBQkxFIixlKSkoc3x8e30pLEM9KGU9PihlW2UuUkVBTFRJTUU9MF09IlJFQUxUSU1FIixlW2UuTU9OT1RPTklDPTFdPSJNT05PVE9OSUMiLGVbZS5QUk9DRVNTX0NQVVRJTUVfSUQ9Ml09IlBST0NFU1NfQ1BVVElNRV9JRCIsZVtlLlRIUkVBRF9DUFVUSU1FX0lEPTNdPSJUSFJFQURfQ1BVVElNRV9JRCIsZSkpKEN8fHt9KSxiPShlPT4oZVtlLlNFVD0wXT0iU0VUIixlW2UuQ1VSPTFdPSJDVVIiLGVbZS5FTkQ9Ml09IkVORCIsZSkpKGJ8fHt9KSxEPShlPT4oZVtlLlVOS05PV049MF09IlVOS05PV04iLGVbZS5CTE9DS19ERVZJQ0U9MV09IkJMT0NLX0RFVklDRSIsZVtlLkNIQVJBQ1RFUl9ERVZJQ0U9Ml09IkNIQVJBQ1RFUl9ERVZJQ0UiLGVbZS5ESVJFQ1RPUlk9M109IkRJUkVDVE9SWSIsZVtlLlJFR1VMQVJfRklMRT00XT0iUkVHVUxBUl9GSUxFIixlW2UuU09DS0VUX0RHUkFNPTVdPSJTT0NLRVRfREdSQU0iLGVbZS5TT0NLRVRfU1RSRUFNPTZdPSJTT0NLRVRfU1RSRUFNIixlW2UuU1lNQk9MSUNfTElOSz03XT0iU1lNQk9MSUNfTElOSyIsZSkpKER8fHt9KSxHPShlPT4oZVtlLkRJUj0wXT0iRElSIixlKSkoR3x8e30pLEE9KGU9PihlW2UuQ0xPQ0s9MF09IkNMT0NLIixlW2UuRkRfUkVBRD0xXT0iRkRfUkVBRCIsZVtlLkZEX1dSSVRFPTJdPSJGRF9XUklURSIsZSkpKEF8fHt9KTtjb25zdCBPPXtDUkVBVDoxLERJUkVDVE9SWToyLEVYQ0w6NCxUUlVOQzo4fSxtPXtBUFBFTkQ6MSxEU1lOQzoyLE5PTkJMT0NLOjQsUlNZTkM6OCxTWU5DOjE2fSxfPXtGRF9EQVRBU1lOQzpCaWdJbnQoMSk8PEJpZ0ludCgwKSxGRF9SRUFEOkJpZ0ludCgxKTw8QmlnSW50KDEpLEZEX1NFRUs6QmlnSW50KDEpPDxCaWdJbnQoMiksRkRfRkRTVEFUX1NFVF9GTEFHUzpCaWdJbnQoMSk8PEJpZ0ludCgzKSxGRF9TWU5DOkJpZ0ludCgxKTw8QmlnSW50KDQpLEZEX1RFTEw6QmlnSW50KDEpPDxCaWdJbnQoNSksRkRfV1JJVEU6QmlnSW50KDEpPDxCaWdJbnQoNiksRkRfQURWSVNFOkJpZ0ludCgxKTw8QmlnSW50KDcpLEZEX0FMTE9DQVRFOkJpZ0ludCgxKTw8QmlnSW50KDgpLFBBVEhfQ1JFQVRFX0RJUkVDVE9SWTpCaWdJbnQoMSk8PEJpZ0ludCg5KSxQQVRIX0NSRUFURV9GSUxFOkJpZ0ludCgxKTw8QmlnSW50KDEwKSxQQVRIX0xJTktfU09VUkNFOkJpZ0ludCgxKTw8QmlnSW50KDExKSxQQVRIX0xJTktfVEFSR0VUOkJpZ0ludCgxKTw8QmlnSW50KDEyKSxQQVRIX09QRU46QmlnSW50KDEpPDxCaWdJbnQoMTMpLEZEX1JFQURESVI6QmlnSW50KDEpPDxCaWdJbnQoMTQpLFBBVEhfUkVBRExJTks6QmlnSW50KDEpPDxCaWdJbnQoMTUpLFBBVEhfUkVOQU1FX1NPVVJDRTpCaWdJbnQoMSk8PEJpZ0ludCgxNiksUEFUSF9SRU5BTUVfVEFSR0VUOkJpZ0ludCgxKTw8QmlnSW50KDE3KSxQQVRIX0ZJTEVTVEFUX0dFVDpCaWdJbnQoMSk8PEJpZ0ludCgxOCksUEFUSF9GSUxFU1RBVF9TRVRfU0laRTpCaWdJbnQoMSk8PEJpZ0ludCgxOSksUEFUSF9GSUxFU1RBVF9TRVRfVElNRVM6QmlnSW50KDEpPDxCaWdJbnQoMjApLEZEX0ZJTEVTVEFUX0dFVDpCaWdJbnQoMSk8PEJpZ0ludCgyMSksRkRfRklMRVNUQVRfU0VUX1NJWkU6QmlnSW50KDEpPDxCaWdJbnQoMjIpLEZEX0ZJTEVTVEFUX1NFVF9USU1FUzpCaWdJbnQoMSk8PEJpZ0ludCgyMyksUEFUSF9TWU1MSU5LOkJpZ0ludCgxKTw8QmlnSW50KDI0KSxQQVRIX1JFTU9WRV9ESVJFQ1RPUlk6QmlnSW50KDEpPDxCaWdJbnQoMjUpLFBBVEhfVU5MSU5LX0ZJTEU6QmlnSW50KDEpPDxCaWdJbnQoMjYpLFBPTExfRkRfUkVBRFdSSVRFOkJpZ0ludCgxKTw8QmlnSW50KDI3KSxTT0NLX1NIVVRET1dOOkJpZ0ludCgxKTw8QmlnSW50KDI4KSxTT0NLX0FDQ0VQVDpCaWdJbnQoMSk8PEJpZ0ludCgyOSl9LE49e0FUSU06MSxBVElNX05PVzoyLE1USU06NCxNVElNX05PVzo4fSxpdD17U1VCU0NSSVBUSU9OX0NMT0NLX0FCU1RJTUU6MX0sVz02NCwkPTQ4LGo9MzI7dmFyIE09KGU9PihlW2UuQ1VSPTBdPSJDVVIiLGVbZS5FTkQ9MV09IkVORCIsZVtlLlNFVD0yXT0iU0VUIixlKSkoTXx8e30pO2NsYXNzIFh7Y29uc3RydWN0b3IodCl7ZCh0aGlzLCJmcyIpO2QodGhpcywiYXJncyIpO2QodGhpcywiZW52Iik7ZCh0aGlzLCJzdGRpbiIpO2QodGhpcywic3Rkb3V0Iik7ZCh0aGlzLCJzdGRlcnIiKTtkKHRoaXMsImRlYnVnIik7ZCh0aGlzLCJpc1RUWSIpO3RoaXMuZnM9KHQ9PW51bGw/dm9pZCAwOnQuZnMpPz97fSx0aGlzLmFyZ3M9KHQ9PW51bGw/dm9pZCAwOnQuYXJncyk/P1tdLHRoaXMuZW52PSh0PT1udWxsP3ZvaWQgMDp0LmVudik/P3t9LHRoaXMuc3RkaW49KHQ9PW51bGw/dm9pZCAwOnQuc3RkaW4pPz8oKCk9Pm51bGwpLHRoaXMuc3Rkb3V0PSh0PT1udWxsP3ZvaWQgMDp0LnN0ZG91dCk/PygoKT0+e30pLHRoaXMuc3RkZXJyPSh0PT1udWxsP3ZvaWQgMDp0LnN0ZGVycik/PygoKT0+e30pLHRoaXMuZGVidWc9dD09bnVsbD92b2lkIDA6dC5kZWJ1Zyx0aGlzLmlzVFRZPSEhKHQhPW51bGwmJnQuaXNUVFkpfX1jbGFzcyBudHtjb25zdHJ1Y3Rvcih0KXtkKHRoaXMsImZzIik7ZCh0aGlzLCJuZXh0RkQiLDEwKTtkKHRoaXMsIm9wZW5NYXAiLG5ldyBNYXApO3RoaXMuZnM9ey4uLnR9LHRoaXMub3Blbk1hcC5zZXQoMyxuZXcgdSh0aGlzLmZzLCIvIikpfW9wZW5GaWxlKHQsaSxuKXtjb25zdCByPW5ldyBJKHQsbik7aSYmKHIuYnVmZmVyPW5ldyBVaW50OEFycmF5KG5ldyBBcnJheUJ1ZmZlcigxMDI0KSwwLDApKTtjb25zdCBhPXRoaXMubmV4dEZEO3JldHVybiB0aGlzLm9wZW5NYXAuc2V0KGEsciksdGhpcy5uZXh0RkQrKyxbcy5TVUNDRVNTLGFdfW9wZW5EaXIodCxpKXtjb25zdCBuPW5ldyB1KHQsaSkscj10aGlzLm5leHRGRDtyZXR1cm4gdGhpcy5vcGVuTWFwLnNldChyLG4pLHRoaXMubmV4dEZEKyssW3MuU1VDQ0VTUyxyXX1oYXNEaXIodCxpKXtyZXR1cm4gaT09PSIuIj8hMDp0LmNvbnRhaW5zRGlyZWN0b3J5KGkpfW9wZW4odCxpLG4scil7Y29uc3QgYT0hIShuJk8uQ1JFQVQpLGY9ISEobiZPLkRJUkVDVE9SWSksYz0hIShuJk8uRVhDTCksbz0hIShuJk8uVFJVTkMpLEU9dGhpcy5vcGVuTWFwLmdldCh0KTtpZighKEUgaW5zdGFuY2VvZiB1KSlyZXR1cm5bcy5FQkFERl07aWYoRS5jb250YWluc0ZpbGUoaSkpcmV0dXJuIGY/W3MuRU5PVERJUl06Yz9bcy5FRVhJU1RdOnRoaXMub3BlbkZpbGUoRS5nZXQoaSksbyxyKTtpZih0aGlzLmhhc0RpcihFLGkpKXtpZihpPT09Ii4iKXJldHVybiB0aGlzLm9wZW5EaXIodGhpcy5mcywiLyIpO2NvbnN0IGg9YC8ke2l9L2AsUz1PYmplY3QuZW50cmllcyh0aGlzLmZzKS5maWx0ZXIoKFtnXSk9Pmcuc3RhcnRzV2l0aChoKSk7cmV0dXJuIHRoaXMub3BlbkRpcihPYmplY3QuZnJvbUVudHJpZXMoUyksaCl9ZWxzZXtpZihhKXtjb25zdCBoPUUuZnVsbFBhdGgoaSk7cmV0dXJuIHRoaXMuZnNbaF09e3BhdGg6aCxtb2RlOiJiaW5hcnkiLGNvbnRlbnQ6bmV3IFVpbnQ4QXJyYXksdGltZXN0YW1wczp7YWNjZXNzOm5ldyBEYXRlLG1vZGlmaWNhdGlvbjpuZXcgRGF0ZSxjaGFuZ2U6bmV3IERhdGV9fSx0aGlzLm9wZW5GaWxlKHRoaXMuZnNbaF0sbyxyKX1yZXR1cm5bcy5FTk9UQ0FQQUJMRV19fWNsb3NlKHQpe2lmKCF0aGlzLm9wZW5NYXAuaGFzKHQpKXJldHVybiBzLkVCQURGO2NvbnN0IGk9dGhpcy5vcGVuTWFwLmdldCh0KTtyZXR1cm4gaSBpbnN0YW5jZW9mIEkmJmkuc3luYygpLHRoaXMub3Blbk1hcC5kZWxldGUodCkscy5TVUNDRVNTfXJlYWQodCxpKXtjb25zdCBuPXRoaXMub3Blbk1hcC5nZXQodCk7cmV0dXJuIW58fG4gaW5zdGFuY2VvZiB1P1tzLkVCQURGXTpbcy5TVUNDRVNTLG4ucmVhZChpKV19cHJlYWQodCxpLG4pe2NvbnN0IHI9dGhpcy5vcGVuTWFwLmdldCh0KTtyZXR1cm4hcnx8ciBpbnN0YW5jZW9mIHU/W3MuRUJBREZdOltzLlNVQ0NFU1Msci5wcmVhZChpLG4pXX13cml0ZSh0LGkpe2NvbnN0IG49dGhpcy5vcGVuTWFwLmdldCh0KTtyZXR1cm4hbnx8biBpbnN0YW5jZW9mIHU/cy5FQkFERjoobi53cml0ZShpKSxzLlNVQ0NFU1MpfXB3cml0ZSh0LGksbil7Y29uc3Qgcj10aGlzLm9wZW5NYXAuZ2V0KHQpO3JldHVybiFyfHxyIGluc3RhbmNlb2YgdT9zLkVCQURGOihyLnB3cml0ZShpLG4pLHMuU1VDQ0VTUyl9c3luYyh0KXtjb25zdCBpPXRoaXMub3Blbk1hcC5nZXQodCk7cmV0dXJuIWl8fGkgaW5zdGFuY2VvZiB1P3MuRUJBREY6KGkuc3luYygpLHMuU1VDQ0VTUyl9c2Vlayh0LGksbil7Y29uc3Qgcj10aGlzLm9wZW5NYXAuZ2V0KHQpO3JldHVybiFyfHxyIGluc3RhbmNlb2YgdT9bcy5FQkFERl06W3MuU1VDQ0VTUyxyLnNlZWsoaSxuKV19dGVsbCh0KXtjb25zdCBpPXRoaXMub3Blbk1hcC5nZXQodCk7cmV0dXJuIWl8fGkgaW5zdGFuY2VvZiB1P1tzLkVCQURGXTpbcy5TVUNDRVNTLGkudGVsbCgpXX1yZW51bWJlcih0LGkpe3JldHVybiF0aGlzLmV4aXN0cyh0KXx8IXRoaXMuZXhpc3RzKGkpP3MuRUJBREY6KHQ9PT1pfHwodGhpcy5jbG9zZShpKSx0aGlzLm9wZW5NYXAuc2V0KGksdGhpcy5vcGVuTWFwLmdldCh0KSkpLHMuU1VDQ0VTUyl9dW5saW5rKHQsaSl7Y29uc3Qgbj10aGlzLm9wZW5NYXAuZ2V0KHQpO2lmKCEobiBpbnN0YW5jZW9mIHUpKXJldHVybiBzLkVCQURGO2lmKCFuLmNvbnRhaW5zKGkpKXJldHVybiBzLkVOT0VOVDtmb3IoY29uc3QgciBvZiBPYmplY3Qua2V5cyh0aGlzLmZzKSkocj09PW4uZnVsbFBhdGgoaSl8fHIuc3RhcnRzV2l0aChgJHtuLmZ1bGxQYXRoKGkpfS9gKSkmJmRlbGV0ZSB0aGlzLmZzW3JdO3JldHVybiBzLlNVQ0NFU1N9cmVuYW1lKHQsaSxuLHIpe2NvbnN0IGE9dGhpcy5vcGVuTWFwLmdldCh0KSxmPXRoaXMub3Blbk1hcC5nZXQobik7aWYoIShhIGluc3RhbmNlb2YgdSl8fCEoZiBpbnN0YW5jZW9mIHUpKXJldHVybiBzLkVCQURGO2lmKCFhLmNvbnRhaW5zKGkpKXJldHVybiBzLkVOT0VOVDtpZihmLmNvbnRhaW5zKHIpKXJldHVybiBzLkVFWElTVDtjb25zdCBjPWEuZnVsbFBhdGgoaSksbz1mLmZ1bGxQYXRoKHIpO2Zvcihjb25zdCBFIG9mIE9iamVjdC5rZXlzKHRoaXMuZnMpKWlmKEUuc3RhcnRzV2l0aChjKSl7Y29uc3QgaD1FLnJlcGxhY2UoYyxvKTt0aGlzLmZzW2hdPXRoaXMuZnNbRV0sdGhpcy5mc1toXS5wYXRoPWgsZGVsZXRlIHRoaXMuZnNbRV19cmV0dXJuIHMuU1VDQ0VTU31saXN0KHQpe2NvbnN0IGk9dGhpcy5vcGVuTWFwLmdldCh0KTtyZXR1cm4gaSBpbnN0YW5jZW9mIHU/W3MuU1VDQ0VTUyxpLmxpc3QoKV06W3MuRUJBREZdfXN0YXQodCl7Y29uc3QgaT10aGlzLm9wZW5NYXAuZ2V0KHQpO3JldHVybiBpIGluc3RhbmNlb2YgST9bcy5TVUNDRVNTLGkuc3RhdCgpXTpbcy5FQkFERl19cGF0aFN0YXQodCxpKXtjb25zdCBuPXRoaXMub3Blbk1hcC5nZXQodCk7aWYoIShuIGluc3RhbmNlb2YgdSkpcmV0dXJuW3MuRUJBREZdO2lmKG4uY29udGFpbnNGaWxlKGkpKXtjb25zdCByPW4uZnVsbFBhdGgoaSksYT1uZXcgSSh0aGlzLmZzW3JdLDApLnN0YXQoKTtyZXR1cm5bcy5TVUNDRVNTLGFdfWVsc2UgaWYodGhpcy5oYXNEaXIobixpKSl7aWYoaT09PSIuIilyZXR1cm5bcy5TVUNDRVNTLG5ldyB1KHRoaXMuZnMsIi8iKS5zdGF0KCldO2NvbnN0IHI9YC8ke2l9L2AsYT1PYmplY3QuZW50cmllcyh0aGlzLmZzKS5maWx0ZXIoKFtjXSk9PmMuc3RhcnRzV2l0aChyKSksZj1uZXcgdShPYmplY3QuZnJvbUVudHJpZXMoYSkscikuc3RhdCgpO3JldHVybltzLlNVQ0NFU1MsZl19ZWxzZSByZXR1cm5bcy5FTk9UQ0FQQUJMRV19c2V0RmxhZ3ModCxpKXtjb25zdCBuPXRoaXMub3Blbk1hcC5nZXQodCk7cmV0dXJuIG4gaW5zdGFuY2VvZiBJPyhuLnNldEZsYWdzKGkpLHMuU1VDQ0VTUyk6cy5FQkFERn1zZXRTaXplKHQsaSl7Y29uc3Qgbj10aGlzLm9wZW5NYXAuZ2V0KHQpO3JldHVybiBuIGluc3RhbmNlb2YgST8obi5zZXRTaXplKE51bWJlcihpKSkscy5TVUNDRVNTKTpzLkVCQURGfXNldEFjY2Vzc1RpbWUodCxpKXtjb25zdCBuPXRoaXMub3Blbk1hcC5nZXQodCk7cmV0dXJuIG4gaW5zdGFuY2VvZiBJPyhuLnNldEFjY2Vzc1RpbWUoaSkscy5TVUNDRVNTKTpzLkVCQURGfXNldE1vZGlmaWNhdGlvblRpbWUodCxpKXtjb25zdCBuPXRoaXMub3Blbk1hcC5nZXQodCk7cmV0dXJuIG4gaW5zdGFuY2VvZiBJPyhuLnNldE1vZGlmaWNhdGlvblRpbWUoaSkscy5TVUNDRVNTKTpzLkVCQURGfXBhdGhTZXRBY2Nlc3NUaW1lKHQsaSxuKXtjb25zdCByPXRoaXMub3Blbk1hcC5nZXQodCk7aWYoIShyIGluc3RhbmNlb2YgdSkpcmV0dXJuIHMuRUJBREY7Y29uc3QgYT1yLmdldChpKTtpZighYSlyZXR1cm4gcy5FTk9UQ0FQQUJMRTtjb25zdCBmPW5ldyBJKGEsMCk7cmV0dXJuIGYuc2V0QWNjZXNzVGltZShuKSxmLnN5bmMoKSxzLlNVQ0NFU1N9cGF0aFNldE1vZGlmaWNhdGlvblRpbWUodCxpLG4pe2NvbnN0IHI9dGhpcy5vcGVuTWFwLmdldCh0KTtpZighKHIgaW5zdGFuY2VvZiB1KSlyZXR1cm4gcy5FQkFERjtjb25zdCBhPXIuZ2V0KGkpO2lmKCFhKXJldHVybiBzLkVOT1RDQVBBQkxFO2NvbnN0IGY9bmV3IEkoYSwwKTtyZXR1cm4gZi5zZXRNb2RpZmljYXRpb25UaW1lKG4pLGYuc3luYygpLHMuU1VDQ0VTU31wYXRoQ3JlYXRlRGlyKHQsaSl7Y29uc3Qgbj10aGlzLm9wZW5NYXAuZ2V0KHQpO2lmKCEobiBpbnN0YW5jZW9mIHUpKXJldHVybiBzLkVCQURGO2lmKG4uY29udGFpbnMoaSkpcmV0dXJuIHMuRU5PVENBUEFCTEU7Y29uc3Qgcj1gJHtuLmZ1bGxQYXRoKGkpfS8ucnVubm9gO3JldHVybiB0aGlzLmZzW3JdPXtwYXRoOnIsdGltZXN0YW1wczp7YWNjZXNzOm5ldyBEYXRlLG1vZGlmaWNhdGlvbjpuZXcgRGF0ZSxjaGFuZ2U6bmV3IERhdGV9LG1vZGU6InN0cmluZyIsY29udGVudDoiIn0scy5TVUNDRVNTfWV4aXN0cyh0KXtyZXR1cm4gdGhpcy5vcGVuTWFwLmhhcyh0KX1maWxlVHlwZSh0KXtjb25zdCBpPXRoaXMub3Blbk1hcC5nZXQodCk7cmV0dXJuIGk/aSBpbnN0YW5jZW9mIEk/RC5SRUdVTEFSX0ZJTEU6RC5ESVJFQ1RPUlk6RC5VTktOT1dOfWZpbGVGZGZsYWdzKHQpe2NvbnN0IGk9dGhpcy5vcGVuTWFwLmdldCh0KTtyZXR1cm4gaSBpbnN0YW5jZW9mIEk/aS5mZGZsYWdzOjB9fWNsYXNzIEl7Y29uc3RydWN0b3IodCxpKXtkKHRoaXMsImZpbGUiKTtkKHRoaXMsImJ1ZmZlciIpO2QodGhpcywiX29mZnNldCIsQmlnSW50KDApKTtkKHRoaXMsImlzRGlydHkiLCExKTtkKHRoaXMsImZkZmxhZ3MiKTtkKHRoaXMsImZsYWdBcHBlbmQiKTtkKHRoaXMsImZsYWdEU3luYyIpO2QodGhpcywiZmxhZ05vbkJsb2NrIik7ZCh0aGlzLCJmbGFnUlN5bmMiKTtkKHRoaXMsImZsYWdTeW5jIik7aWYodGhpcy5maWxlPXQsdGhpcy5maWxlLm1vZGU9PT0ic3RyaW5nIil7Y29uc3Qgbj1uZXcgVGV4dEVuY29kZXI7dGhpcy5idWZmZXI9bi5lbmNvZGUodGhpcy5maWxlLmNvbnRlbnQpfWVsc2UgdGhpcy5idWZmZXI9dGhpcy5maWxlLmNvbnRlbnQ7dGhpcy5mZGZsYWdzPWksdGhpcy5mbGFnQXBwZW5kPSEhKGkmbS5BUFBFTkQpLHRoaXMuZmxhZ0RTeW5jPSEhKGkmbS5EU1lOQyksdGhpcy5mbGFnTm9uQmxvY2s9ISEoaSZtLk5PTkJMT0NLKSx0aGlzLmZsYWdSU3luYz0hIShpJm0uUlNZTkMpLHRoaXMuZmxhZ1N5bmM9ISEoaSZtLlNZTkMpfWdldCBvZmZzZXQoKXtyZXR1cm4gTnVtYmVyKHRoaXMuX29mZnNldCl9cmVhZCh0KXtjb25zdCBpPXRoaXMuYnVmZmVyLnN1YmFycmF5KHRoaXMub2Zmc2V0LHRoaXMub2Zmc2V0K3QpO3JldHVybiB0aGlzLl9vZmZzZXQrPUJpZ0ludChpLmxlbmd0aCksaX1wcmVhZCh0LGkpe3JldHVybiB0aGlzLmJ1ZmZlci5zdWJhcnJheShpLGkrdCl9d3JpdGUodCl7aWYodGhpcy5pc0RpcnR5PSEwLHRoaXMuZmxhZ0FwcGVuZCl7Y29uc3QgaT10aGlzLmJ1ZmZlci5sZW5ndGg7dGhpcy5yZXNpemUoaSt0LmJ5dGVMZW5ndGgpLHRoaXMuYnVmZmVyLnNldCh0LGkpfWVsc2V7Y29uc3QgaT1NYXRoLm1heCh0aGlzLm9mZnNldCt0LmJ5dGVMZW5ndGgsdGhpcy5idWZmZXIuYnl0ZUxlbmd0aCk7dGhpcy5yZXNpemUoaSksdGhpcy5idWZmZXIuc2V0KHQsdGhpcy5vZmZzZXQpLHRoaXMuX29mZnNldCs9QmlnSW50KHQuYnl0ZUxlbmd0aCl9KHRoaXMuZmxhZ0RTeW5jfHx0aGlzLmZsYWdTeW5jKSYmdGhpcy5zeW5jKCl9cHdyaXRlKHQsaSl7aWYodGhpcy5pc0RpcnR5PSEwLHRoaXMuZmxhZ0FwcGVuZCl7Y29uc3Qgbj10aGlzLmJ1ZmZlci5sZW5ndGg7dGhpcy5yZXNpemUobit0LmJ5dGVMZW5ndGgpLHRoaXMuYnVmZmVyLnNldCh0LG4pfWVsc2V7Y29uc3Qgbj1NYXRoLm1heChpK3QuYnl0ZUxlbmd0aCx0aGlzLmJ1ZmZlci5ieXRlTGVuZ3RoKTt0aGlzLnJlc2l6ZShuKSx0aGlzLmJ1ZmZlci5zZXQodCxpKX0odGhpcy5mbGFnRFN5bmN8fHRoaXMuZmxhZ1N5bmMpJiZ0aGlzLnN5bmMoKX1zeW5jKCl7aWYoIXRoaXMuaXNEaXJ0eSlyZXR1cm47aWYodGhpcy5pc0RpcnR5PSExLHRoaXMuZmlsZS5tb2RlPT09ImJpbmFyeSIpe3RoaXMuZmlsZS5jb250ZW50PW5ldyBVaW50OEFycmF5KHRoaXMuYnVmZmVyKTtyZXR1cm59Y29uc3QgdD1uZXcgVGV4dERlY29kZXI7dGhpcy5maWxlLmNvbnRlbnQ9dC5kZWNvZGUodGhpcy5idWZmZXIpfXNlZWsodCxpKXtzd2l0Y2goaSl7Y2FzZSBiLlNFVDp0aGlzLl9vZmZzZXQ9dDticmVhaztjYXNlIGIuQ1VSOnRoaXMuX29mZnNldCs9dDticmVhaztjYXNlIGIuRU5EOnRoaXMuX29mZnNldD1CaWdJbnQodGhpcy5idWZmZXIubGVuZ3RoKSt0O2JyZWFrfXJldHVybiB0aGlzLl9vZmZzZXR9dGVsbCgpe3JldHVybiB0aGlzLl9vZmZzZXR9c3RhdCgpe3JldHVybntwYXRoOnRoaXMuZmlsZS5wYXRoLHRpbWVzdGFtcHM6dGhpcy5maWxlLnRpbWVzdGFtcHMsdHlwZTpELlJFR1VMQVJfRklMRSxieXRlTGVuZ3RoOnRoaXMuYnVmZmVyLmxlbmd0aH19c2V0RmxhZ3ModCl7dGhpcy5mZGZsYWdzPXR9c2V0U2l6ZSh0KXt0aGlzLnJlc2l6ZSh0KX1zZXRBY2Nlc3NUaW1lKHQpe3RoaXMuZmlsZS50aW1lc3RhbXBzLmFjY2Vzcz10fXNldE1vZGlmaWNhdGlvblRpbWUodCl7dGhpcy5maWxlLnRpbWVzdGFtcHMubW9kaWZpY2F0aW9uPXR9cmVzaXplKHQpe2lmKHQ8PXRoaXMuYnVmZmVyLmJ1ZmZlci5ieXRlTGVuZ3RoKXt0aGlzLmJ1ZmZlcj1uZXcgVWludDhBcnJheSh0aGlzLmJ1ZmZlci5idWZmZXIsMCx0KTtyZXR1cm59bGV0IGk7dGhpcy5idWZmZXIuYnVmZmVyLmJ5dGVMZW5ndGg9PT0wP2k9bmV3IEFycmF5QnVmZmVyKHQ8MTAyND8xMDI0OnQqMik6dD50aGlzLmJ1ZmZlci5idWZmZXIuYnl0ZUxlbmd0aCoyP2k9bmV3IEFycmF5QnVmZmVyKHQqMik6aT1uZXcgQXJyYXlCdWZmZXIodGhpcy5idWZmZXIuYnVmZmVyLmJ5dGVMZW5ndGgqMik7Y29uc3Qgbj1uZXcgVWludDhBcnJheShpLDAsdCk7bi5zZXQodGhpcy5idWZmZXIpLHRoaXMuYnVmZmVyPW59fWZ1bmN0aW9uIFAoZSx0KXtjb25zdCBpPXQucmVwbGFjZSgvWy9cLVxcXiQqKz8uKCl8W1xde31dL2csIlxcJCYiKSxuPW5ldyBSZWdFeHAoYF4ke2l9YCk7cmV0dXJuIGUucmVwbGFjZShuLCIiKX1jbGFzcyB1e2NvbnN0cnVjdG9yKHQsaSl7ZCh0aGlzLCJkaXIiKTtkKHRoaXMsInByZWZpeCIpO3RoaXMuZGlyPXQsdGhpcy5wcmVmaXg9aX1jb250YWluc0ZpbGUodCl7Zm9yKGNvbnN0IGkgb2YgT2JqZWN0LmtleXModGhpcy5kaXIpKWlmKFAoaSx0aGlzLnByZWZpeCk9PT10KXJldHVybiEwO3JldHVybiExfWNvbnRhaW5zRGlyZWN0b3J5KHQpe2Zvcihjb25zdCBpIG9mIE9iamVjdC5rZXlzKHRoaXMuZGlyKSlpZihQKGksdGhpcy5wcmVmaXgpLnN0YXJ0c1dpdGgoYCR7dH0vYCkpcmV0dXJuITA7cmV0dXJuITF9Y29udGFpbnModCl7Zm9yKGNvbnN0IGkgb2YgT2JqZWN0LmtleXModGhpcy5kaXIpKXtjb25zdCBuPVAoaSx0aGlzLnByZWZpeCk7aWYobj09PXR8fG4uc3RhcnRzV2l0aChgJHt0fS9gKSlyZXR1cm4hMH1yZXR1cm4hMX1nZXQodCl7cmV0dXJuIHRoaXMuZGlyW3RoaXMuZnVsbFBhdGgodCldfWZ1bGxQYXRoKHQpe3JldHVybmAke3RoaXMucHJlZml4fSR7dH1gfWxpc3QoKXtjb25zdCB0PVtdLGk9bmV3IFNldDtmb3IoY29uc3QgbiBvZiBPYmplY3Qua2V5cyh0aGlzLmRpcikpe2NvbnN0IHI9UChuLHRoaXMucHJlZml4KTtpZihyLmluY2x1ZGVzKCIvIikpe2NvbnN0IGE9ci5zcGxpdCgiLyIpWzBdO2lmKGkuaGFzKGEpKWNvbnRpbnVlO2kuYWRkKGEpLHQucHVzaCh7bmFtZTphLHR5cGU6RC5ESVJFQ1RPUll9KX1lbHNlIHQucHVzaCh7bmFtZTpyLHR5cGU6RC5SRUdVTEFSX0ZJTEV9KX1yZXR1cm4gdH1zdGF0KCl7cmV0dXJue3BhdGg6dGhpcy5wcmVmaXgsdGltZXN0YW1wczp7YWNjZXNzOm5ldyBEYXRlLG1vZGlmaWNhdGlvbjpuZXcgRGF0ZSxjaGFuZ2U6bmV3IERhdGV9LHR5cGU6RC5ESVJFQ1RPUlksYnl0ZUxlbmd0aDowfX19bGV0IHg9W107ZnVuY3Rpb24geShlKXt4LnB1c2goZSl9ZnVuY3Rpb24gcnQoKXtjb25zdCBlPXg7cmV0dXJuIHg9W10sZX1jbGFzcyBZIGV4dGVuZHMgRXJyb3J7fWNsYXNzIFogZXh0ZW5kcyBFcnJvcnt9Y2xhc3Mgdntjb25zdHJ1Y3Rvcih0KXtkKHRoaXMsImluc3RhbmNlIik7ZCh0aGlzLCJtb2R1bGUiKTtkKHRoaXMsIm1lbW9yeSIpO2QodGhpcywiY29udGV4dCIpO2QodGhpcywiZHJpdmUiKTtkKHRoaXMsImhhc0JlZW5Jbml0aWFsaXplZCIsITEpO3RoaXMuY29udGV4dD1uZXcgWCh0KSx0aGlzLmRyaXZlPW5ldyBudCh0aGlzLmNvbnRleHQuZnMpfXN0YXRpYyBhc3luYyBzdGFydCh0LGk9e30pe2NvbnN0IG49bmV3IHYoaSkscj1hd2FpdCBXZWJBc3NlbWJseS5pbnN0YW50aWF0ZVN0cmVhbWluZyh0LG4uZ2V0SW1wb3J0T2JqZWN0KCkpO3JldHVybiBuLnN0YXJ0KHIpfXN0YXRpYyBhc3luYyBpbml0aWFsaXplKHQsaT17fSl7Y29uc3Qgbj1uZXcgdihpKSxyPWF3YWl0IFdlYkFzc2VtYmx5Lmluc3RhbnRpYXRlU3RyZWFtaW5nKHQsbi5nZXRJbXBvcnRPYmplY3QoKSk7cmV0dXJuIG4uaW5pdGlhbGl6ZShyKSxyLmluc3RhbmNlLmV4cG9ydHN9Z2V0SW1wb3J0T2JqZWN0KCl7cmV0dXJue3dhc2lfc25hcHNob3RfcHJldmlldzE6dGhpcy5nZXRJbXBvcnRzKCJwcmV2aWV3MSIsdGhpcy5jb250ZXh0LmRlYnVnKSx3YXNpX3Vuc3RhYmxlOnRoaXMuZ2V0SW1wb3J0cygidW5zdGFibGUiLHRoaXMuY29udGV4dC5kZWJ1Zyl9fXN0YXJ0KHQsaT17fSl7aWYodGhpcy5oYXNCZWVuSW5pdGlhbGl6ZWQpdGhyb3cgbmV3IFooIlRoaXMgaW5zdGFuY2UgaGFzIGFscmVhZHkgYmVlbiBpbml0aWFsaXplZCIpO2lmKHRoaXMuaGFzQmVlbkluaXRpYWxpemVkPSEwLHRoaXMuaW5zdGFuY2U9dC5pbnN0YW5jZSx0aGlzLm1vZHVsZT10Lm1vZHVsZSx0aGlzLm1lbW9yeT1pLm1lbW9yeT8/dGhpcy5pbnN0YW5jZS5leHBvcnRzLm1lbW9yeSwiX2luaXRpYWxpemUiaW4gdGhpcy5pbnN0YW5jZS5leHBvcnRzKXRocm93IG5ldyBZKCJXZWJBc3NlbWJseSBpbnN0YW5jZSBpcyBhIHJlYWN0b3IgYW5kIHNob3VsZCBiZSBzdGFydGVkIHdpdGggaW5pdGlhbGl6ZS4iKTtpZighKCJfc3RhcnQiaW4gdGhpcy5pbnN0YW5jZS5leHBvcnRzKSl0aHJvdyBuZXcgWSgiV2ViQXNzZW1ibHkgaW5zdGFuY2UgZG9lc24ndCBleHBvcnQgX3N0YXJ0LCBpdCBtYXkgbm90IGJlIFdBU0kgb3IgbWF5IGJlIGEgUmVhY3Rvci4iKTtjb25zdCBuPXRoaXMuaW5zdGFuY2UuZXhwb3J0cy5fc3RhcnQ7dHJ5e24oKX1jYXRjaChyKXtpZihyIGluc3RhbmNlb2YgUSlyZXR1cm57ZXhpdENvZGU6ci5jb2RlLGZzOnRoaXMuZHJpdmUuZnN9O2lmKHIgaW5zdGFuY2VvZiBXZWJBc3NlbWJseS5SdW50aW1lRXJyb3IpcmV0dXJue2V4aXRDb2RlOjEzNCxmczp0aGlzLmRyaXZlLmZzfTt0aHJvdyByfXJldHVybntleGl0Q29kZTowLGZzOnRoaXMuZHJpdmUuZnN9fWluaXRpYWxpemUodCxpPXt9KXtpZih0aGlzLmhhc0JlZW5Jbml0aWFsaXplZCl0aHJvdyBuZXcgWigiVGhpcyBpbnN0YW5jZSBoYXMgYWxyZWFkeSBiZWVuIGluaXRpYWxpemVkIik7aWYodGhpcy5oYXNCZWVuSW5pdGlhbGl6ZWQ9ITAsdGhpcy5pbnN0YW5jZT10Lmluc3RhbmNlLHRoaXMubW9kdWxlPXQubW9kdWxlLHRoaXMubWVtb3J5PWkubWVtb3J5Pz90aGlzLmluc3RhbmNlLmV4cG9ydHMubWVtb3J5LCJfc3RhcnQiaW4gdGhpcy5pbnN0YW5jZS5leHBvcnRzKXRocm93IG5ldyBZKCJXZWJBc3NlbWJseSBpbnN0YW5jZSBpcyBhIGNvbW1hbmQgYW5kIHNob3VsZCBiZSBzdGFydGVkIHdpdGggc3RhcnQuIik7aWYoIl9pbml0aWFsaXplImluIHRoaXMuaW5zdGFuY2UuZXhwb3J0cyl7Y29uc3Qgbj10aGlzLmluc3RhbmNlLmV4cG9ydHMuX2luaXRpYWxpemU7bigpfX1nZXRJbXBvcnRzKHQsaSl7Y29uc3Qgbj17YXJnc19nZXQ6dGhpcy5hcmdzX2dldC5iaW5kKHRoaXMpLGFyZ3Nfc2l6ZXNfZ2V0OnRoaXMuYXJnc19zaXplc19nZXQuYmluZCh0aGlzKSxjbG9ja19yZXNfZ2V0OnRoaXMuY2xvY2tfcmVzX2dldC5iaW5kKHRoaXMpLGNsb2NrX3RpbWVfZ2V0OnRoaXMuY2xvY2tfdGltZV9nZXQuYmluZCh0aGlzKSxlbnZpcm9uX2dldDp0aGlzLmVudmlyb25fZ2V0LmJpbmQodGhpcyksZW52aXJvbl9zaXplc19nZXQ6dGhpcy5lbnZpcm9uX3NpemVzX2dldC5iaW5kKHRoaXMpLHByb2NfZXhpdDp0aGlzLnByb2NfZXhpdC5iaW5kKHRoaXMpLHJhbmRvbV9nZXQ6dGhpcy5yYW5kb21fZ2V0LmJpbmQodGhpcyksc2NoZWRfeWllbGQ6dGhpcy5zY2hlZF95aWVsZC5iaW5kKHRoaXMpLGZkX2FkdmlzZTp0aGlzLmZkX2FkdmlzZS5iaW5kKHRoaXMpLGZkX2FsbG9jYXRlOnRoaXMuZmRfYWxsb2NhdGUuYmluZCh0aGlzKSxmZF9jbG9zZTp0aGlzLmZkX2Nsb3NlLmJpbmQodGhpcyksZmRfZGF0YXN5bmM6dGhpcy5mZF9kYXRhc3luYy5iaW5kKHRoaXMpLGZkX2Zkc3RhdF9nZXQ6dGhpcy5mZF9mZHN0YXRfZ2V0LmJpbmQodGhpcyksZmRfZmRzdGF0X3NldF9mbGFnczp0aGlzLmZkX2Zkc3RhdF9zZXRfZmxhZ3MuYmluZCh0aGlzKSxmZF9mZHN0YXRfc2V0X3JpZ2h0czp0aGlzLmZkX2Zkc3RhdF9zZXRfcmlnaHRzLmJpbmQodGhpcyksZmRfZmlsZXN0YXRfZ2V0OnRoaXMuZmRfZmlsZXN0YXRfZ2V0LmJpbmQodGhpcyksZmRfZmlsZXN0YXRfc2V0X3NpemU6dGhpcy5mZF9maWxlc3RhdF9zZXRfc2l6ZS5iaW5kKHRoaXMpLGZkX2ZpbGVzdGF0X3NldF90aW1lczp0aGlzLmZkX2ZpbGVzdGF0X3NldF90aW1lcy5iaW5kKHRoaXMpLGZkX3ByZWFkOnRoaXMuZmRfcHJlYWQuYmluZCh0aGlzKSxmZF9wcmVzdGF0X2Rpcl9uYW1lOnRoaXMuZmRfcHJlc3RhdF9kaXJfbmFtZS5iaW5kKHRoaXMpLGZkX3ByZXN0YXRfZ2V0OnRoaXMuZmRfcHJlc3RhdF9nZXQuYmluZCh0aGlzKSxmZF9wd3JpdGU6dGhpcy5mZF9wd3JpdGUuYmluZCh0aGlzKSxmZF9yZWFkOnRoaXMuZmRfcmVhZC5iaW5kKHRoaXMpLGZkX3JlYWRkaXI6dGhpcy5mZF9yZWFkZGlyLmJpbmQodGhpcyksZmRfcmVudW1iZXI6dGhpcy5mZF9yZW51bWJlci5iaW5kKHRoaXMpLGZkX3NlZWs6dGhpcy5mZF9zZWVrLmJpbmQodGhpcyksZmRfc3luYzp0aGlzLmZkX3N5bmMuYmluZCh0aGlzKSxmZF90ZWxsOnRoaXMuZmRfdGVsbC5iaW5kKHRoaXMpLGZkX3dyaXRlOnRoaXMuZmRfd3JpdGUuYmluZCh0aGlzKSxwYXRoX2ZpbGVzdGF0X2dldDp0aGlzLnBhdGhfZmlsZXN0YXRfZ2V0LmJpbmQodGhpcykscGF0aF9maWxlc3RhdF9zZXRfdGltZXM6dGhpcy5wYXRoX2ZpbGVzdGF0X3NldF90aW1lcy5iaW5kKHRoaXMpLHBhdGhfb3Blbjp0aGlzLnBhdGhfb3Blbi5iaW5kKHRoaXMpLHBhdGhfcmVuYW1lOnRoaXMucGF0aF9yZW5hbWUuYmluZCh0aGlzKSxwYXRoX3VubGlua19maWxlOnRoaXMucGF0aF91bmxpbmtfZmlsZS5iaW5kKHRoaXMpLHBhdGhfY3JlYXRlX2RpcmVjdG9yeTp0aGlzLnBhdGhfY3JlYXRlX2RpcmVjdG9yeS5iaW5kKHRoaXMpLHBhdGhfbGluazp0aGlzLnBhdGhfbGluay5iaW5kKHRoaXMpLHBhdGhfcmVhZGxpbms6dGhpcy5wYXRoX3JlYWRsaW5rLmJpbmQodGhpcykscGF0aF9yZW1vdmVfZGlyZWN0b3J5OnRoaXMucGF0aF9yZW1vdmVfZGlyZWN0b3J5LmJpbmQodGhpcykscGF0aF9zeW1saW5rOnRoaXMucGF0aF9zeW1saW5rLmJpbmQodGhpcykscG9sbF9vbmVvZmY6dGhpcy5wb2xsX29uZW9mZi5iaW5kKHRoaXMpLHByb2NfcmFpc2U6dGhpcy5wcm9jX3JhaXNlLmJpbmQodGhpcyksc29ja19hY2NlcHQ6dGhpcy5zb2NrX2FjY2VwdC5iaW5kKHRoaXMpLHNvY2tfcmVjdjp0aGlzLnNvY2tfcmVjdi5iaW5kKHRoaXMpLHNvY2tfc2VuZDp0aGlzLnNvY2tfc2VuZC5iaW5kKHRoaXMpLHNvY2tfc2h1dGRvd246dGhpcy5zb2NrX3NodXRkb3duLmJpbmQodGhpcyksc29ja19vcGVuOnRoaXMuc29ja19vcGVuLmJpbmQodGhpcyksc29ja19saXN0ZW46dGhpcy5zb2NrX2xpc3Rlbi5iaW5kKHRoaXMpLHNvY2tfY29ubmVjdDp0aGlzLnNvY2tfY29ubmVjdC5iaW5kKHRoaXMpLHNvY2tfc2V0c29ja29wdDp0aGlzLnNvY2tfc2V0c29ja29wdC5iaW5kKHRoaXMpLHNvY2tfYmluZDp0aGlzLnNvY2tfYmluZC5iaW5kKHRoaXMpLHNvY2tfZ2V0bG9jYWxhZGRyOnRoaXMuc29ja19nZXRsb2NhbGFkZHIuYmluZCh0aGlzKSxzb2NrX2dldHBlZXJhZGRyOnRoaXMuc29ja19nZXRwZWVyYWRkci5iaW5kKHRoaXMpLHNvY2tfZ2V0YWRkcmluZm86dGhpcy5zb2NrX2dldGFkZHJpbmZvLmJpbmQodGhpcyl9O3Q9PT0idW5zdGFibGUiJiYobi5wYXRoX2ZpbGVzdGF0X2dldD10aGlzLnVuc3RhYmxlX3BhdGhfZmlsZXN0YXRfZ2V0LmJpbmQodGhpcyksbi5mZF9maWxlc3RhdF9nZXQ9dGhpcy51bnN0YWJsZV9mZF9maWxlc3RhdF9nZXQuYmluZCh0aGlzKSxuLmZkX3NlZWs9dGhpcy51bnN0YWJsZV9mZF9zZWVrLmJpbmQodGhpcykpO2Zvcihjb25zdFtyLGFdb2YgT2JqZWN0LmVudHJpZXMobikpbltyXT1mdW5jdGlvbigpe2xldCBmPWEuYXBwbHkodGhpcyxhcmd1bWVudHMpO2lmKGkpe2NvbnN0IGM9cnQoKTtmPWkocixbLi4uYXJndW1lbnRzXSxmLGMpPz9mfXJldHVybiBmfTtyZXR1cm4gbn1nZXQgZW52QXJyYXkoKXtyZXR1cm4gT2JqZWN0LmVudHJpZXModGhpcy5jb250ZXh0LmVudikubWFwKChbdCxpXSk9PmAke3R9PSR7aX1gKX1hcmdzX2dldCh0LGkpe2NvbnN0IG49bmV3IERhdGFWaWV3KHRoaXMubWVtb3J5LmJ1ZmZlcik7Zm9yKGNvbnN0IHIgb2YgdGhpcy5jb250ZXh0LmFyZ3Mpe24uc2V0VWludDMyKHQsaSwhMCksdCs9NDtjb25zdCBhPW5ldyBUZXh0RW5jb2RlcigpLmVuY29kZShgJHtyfVwwYCk7bmV3IFVpbnQ4QXJyYXkodGhpcy5tZW1vcnkuYnVmZmVyLGksYS5ieXRlTGVuZ3RoKS5zZXQoYSksaSs9YS5ieXRlTGVuZ3RofXJldHVybiBzLlNVQ0NFU1N9YXJnc19zaXplc19nZXQodCxpKXtjb25zdCBuPXRoaXMuY29udGV4dC5hcmdzLHI9bi5yZWR1Y2UoKGYsYyk9PmYrbmV3IFRleHRFbmNvZGVyKCkuZW5jb2RlKGAke2N9XDBgKS5ieXRlTGVuZ3RoLDApLGE9bmV3IERhdGFWaWV3KHRoaXMubWVtb3J5LmJ1ZmZlcik7cmV0dXJuIGEuc2V0VWludDMyKHQsbi5sZW5ndGgsITApLGEuc2V0VWludDMyKGksciwhMCkscy5TVUNDRVNTfWNsb2NrX3Jlc19nZXQodCxpKXtzd2l0Y2godCl7Y2FzZSBDLlJFQUxUSU1FOmNhc2UgQy5NT05PVE9OSUM6Y2FzZSBDLlBST0NFU1NfQ1BVVElNRV9JRDpjYXNlIEMuVEhSRUFEX0NQVVRJTUVfSUQ6cmV0dXJuIG5ldyBEYXRhVmlldyh0aGlzLm1lbW9yeS5idWZmZXIpLnNldEJpZ1VpbnQ2NChpLEJpZ0ludCgxZTYpLCEwKSxzLlNVQ0NFU1N9cmV0dXJuIHMuRUlOVkFMfWNsb2NrX3RpbWVfZ2V0KHQsaSxuKXtzd2l0Y2godCl7Y2FzZSBDLlJFQUxUSU1FOmNhc2UgQy5NT05PVE9OSUM6Y2FzZSBDLlBST0NFU1NfQ1BVVElNRV9JRDpjYXNlIEMuVEhSRUFEX0NQVVRJTUVfSUQ6cmV0dXJuIG5ldyBEYXRhVmlldyh0aGlzLm1lbW9yeS5idWZmZXIpLnNldEJpZ1VpbnQ2NChuLHcobmV3IERhdGUpLCEwKSxzLlNVQ0NFU1N9cmV0dXJuIHMuRUlOVkFMfWVudmlyb25fZ2V0KHQsaSl7Y29uc3Qgbj1uZXcgRGF0YVZpZXcodGhpcy5tZW1vcnkuYnVmZmVyKTtmb3IoY29uc3QgciBvZiB0aGlzLmVudkFycmF5KXtuLnNldFVpbnQzMih0LGksITApLHQrPTQ7Y29uc3QgYT1uZXcgVGV4dEVuY29kZXIoKS5lbmNvZGUoYCR7cn1cMGApO25ldyBVaW50OEFycmF5KHRoaXMubWVtb3J5LmJ1ZmZlcixpLGEuYnl0ZUxlbmd0aCkuc2V0KGEpLGkrPWEuYnl0ZUxlbmd0aH1yZXR1cm4gcy5TVUNDRVNTfWVudmlyb25fc2l6ZXNfZ2V0KHQsaSl7Y29uc3Qgbj10aGlzLmVudkFycmF5LnJlZHVjZSgoYSxmKT0+YStuZXcgVGV4dEVuY29kZXIoKS5lbmNvZGUoYCR7Zn1cMGApLmJ5dGVMZW5ndGgsMCkscj1uZXcgRGF0YVZpZXcodGhpcy5tZW1vcnkuYnVmZmVyKTtyZXR1cm4gci5zZXRVaW50MzIodCx0aGlzLmVudkFycmF5Lmxlbmd0aCwhMCksci5zZXRVaW50MzIoaSxuLCEwKSxzLlNVQ0NFU1N9cHJvY19leGl0KHQpe3Rocm93IG5ldyBRKHQpfXJhbmRvbV9nZXQodCxpKXtjb25zdCBuPW5ldyBVaW50OEFycmF5KHRoaXMubWVtb3J5LmJ1ZmZlcix0LGkpO3JldHVybiBnbG9iYWxUaGlzLmNyeXB0by5nZXRSYW5kb21WYWx1ZXMobikscy5TVUNDRVNTfXNjaGVkX3lpZWxkKCl7cmV0dXJuIHMuU1VDQ0VTU31mZF9yZWFkKHQsaSxuLHIpe2lmKHQ9PT0xfHx0PT09MilyZXR1cm4gcy5FTk9UU1VQO2NvbnN0IGE9bmV3IERhdGFWaWV3KHRoaXMubWVtb3J5LmJ1ZmZlciksZj1rKGEsaSxuKSxjPW5ldyBUZXh0RW5jb2RlcjtsZXQgbz0wLEU9cy5TVUNDRVNTO2Zvcihjb25zdCBoIG9mIGYpe2xldCBTO2lmKHQ9PT0wKXtjb25zdCBUPXRoaXMuY29udGV4dC5zdGRpbihoLmJ5dGVMZW5ndGgpO2lmKCFUKWJyZWFrO1M9Yy5lbmNvZGUoVCl9ZWxzZXtjb25zdFtULHBdPXRoaXMuZHJpdmUucmVhZCh0LGguYnl0ZUxlbmd0aCk7aWYoVCl7RT1UO2JyZWFrfWVsc2UgUz1wfWNvbnN0IGc9TWF0aC5taW4oaC5ieXRlTGVuZ3RoLFMuYnl0ZUxlbmd0aCk7aC5zZXQoUy5zdWJhcnJheSgwLGcpKSxvKz1nfXJldHVybiB5KHtieXRlc1JlYWQ6b30pLGEuc2V0VWludDMyKHIsbywhMCksRX1mZF93cml0ZSh0LGksbixyKXtpZih0PT09MClyZXR1cm4gcy5FTk9UU1VQO2NvbnN0IGE9bmV3IERhdGFWaWV3KHRoaXMubWVtb3J5LmJ1ZmZlciksZj1rKGEsaSxuKSxjPW5ldyBUZXh0RGVjb2RlcjtsZXQgbz0wLEU9cy5TVUNDRVNTO2Zvcihjb25zdCBoIG9mIGYpaWYoaC5ieXRlTGVuZ3RoIT09MCl7aWYodD09PTF8fHQ9PT0yKXtjb25zdCBTPXQ9PT0xP3RoaXMuY29udGV4dC5zdGRvdXQ6dGhpcy5jb250ZXh0LnN0ZGVycixnPWMuZGVjb2RlKGgpO1MoZykseSh7b3V0cHV0Omd9KX1lbHNlIGlmKEU9dGhpcy5kcml2ZS53cml0ZSh0LGgpLEUhPXMuU1VDQ0VTUylicmVhaztvKz1oLmJ5dGVMZW5ndGh9cmV0dXJuIGEuc2V0VWludDMyKHIsbywhMCksRX1mZF9hZHZpc2UoKXtyZXR1cm4gcy5TVUNDRVNTfWZkX2FsbG9jYXRlKHQsaSxuKXtyZXR1cm4gdGhpcy5kcml2ZS5wd3JpdGUodCxuZXcgVWludDhBcnJheShOdW1iZXIobikpLE51bWJlcihpKSl9ZmRfY2xvc2UodCl7cmV0dXJuIHRoaXMuZHJpdmUuY2xvc2UodCl9ZmRfZGF0YXN5bmModCl7cmV0dXJuIHRoaXMuZHJpdmUuc3luYyh0KX1mZF9mZHN0YXRfZ2V0KHQsaSl7aWYodDwzKXtsZXQgYztpZih0aGlzLmNvbnRleHQuaXNUVFkpe2NvbnN0IEU9Vl5fLkZEX1NFRUteXy5GRF9URUxMO2M9SChELkNIQVJBQ1RFUl9ERVZJQ0UsMCxFKX1lbHNlIGM9SChELkNIQVJBQ1RFUl9ERVZJQ0UsMCk7cmV0dXJuIG5ldyBVaW50OEFycmF5KHRoaXMubWVtb3J5LmJ1ZmZlcixpLGMuYnl0ZUxlbmd0aCkuc2V0KGMpLHMuU1VDQ0VTU31pZighdGhpcy5kcml2ZS5leGlzdHModCkpcmV0dXJuIHMuRUJBREY7Y29uc3Qgbj10aGlzLmRyaXZlLmZpbGVUeXBlKHQpLHI9dGhpcy5kcml2ZS5maWxlRmRmbGFncyh0KSxhPUgobixyKTtyZXR1cm4gbmV3IFVpbnQ4QXJyYXkodGhpcy5tZW1vcnkuYnVmZmVyLGksYS5ieXRlTGVuZ3RoKS5zZXQoYSkscy5TVUNDRVNTfWZkX2Zkc3RhdF9zZXRfZmxhZ3ModCxpKXtyZXR1cm4gdGhpcy5kcml2ZS5zZXRGbGFncyh0LGkpfWZkX2Zkc3RhdF9zZXRfcmlnaHRzKCl7cmV0dXJuIHMuU1VDQ0VTU31mZF9maWxlc3RhdF9nZXQodCxpKXtyZXR1cm4gdGhpcy5zaGFyZWRfZmRfZmlsZXN0YXRfZ2V0KHQsaSwicHJldmlldzEiKX11bnN0YWJsZV9mZF9maWxlc3RhdF9nZXQodCxpKXtyZXR1cm4gdGhpcy5zaGFyZWRfZmRfZmlsZXN0YXRfZ2V0KHQsaSwidW5zdGFibGUiKX1zaGFyZWRfZmRfZmlsZXN0YXRfZ2V0KHQsaSxuKXtjb25zdCByPW49PT0idW5zdGFibGUiP3E6SjtpZih0PDMpe2xldCBFO3N3aXRjaCh0KXtjYXNlIDA6RT0iL2Rldi9zdGRpbiI7YnJlYWs7Y2FzZSAxOkU9Ii9kZXYvc3Rkb3V0IjticmVhaztjYXNlIDI6RT0iL2Rldi9zdGRlcnIiO2JyZWFrO2RlZmF1bHQ6RT0iL2Rldi91bmRlZmluZWQiO2JyZWFrfWNvbnN0IGg9cih7cGF0aDpFLGJ5dGVMZW5ndGg6MCx0aW1lc3RhbXBzOnthY2Nlc3M6bmV3IERhdGUsbW9kaWZpY2F0aW9uOm5ldyBEYXRlLGNoYW5nZTpuZXcgRGF0ZX0sdHlwZTpELkNIQVJBQ1RFUl9ERVZJQ0V9KTtyZXR1cm4gbmV3IFVpbnQ4QXJyYXkodGhpcy5tZW1vcnkuYnVmZmVyLGksaC5ieXRlTGVuZ3RoKS5zZXQoaCkscy5TVUNDRVNTfWNvbnN0W2EsZl09dGhpcy5kcml2ZS5zdGF0KHQpO2lmKGEhPXMuU1VDQ0VTUylyZXR1cm4gYTt5KHtyZXNvbHZlZFBhdGg6Zi5wYXRoLHN0YXQ6Zn0pO2NvbnN0IGM9cihmKTtyZXR1cm4gbmV3IFVpbnQ4QXJyYXkodGhpcy5tZW1vcnkuYnVmZmVyLGksYy5ieXRlTGVuZ3RoKS5zZXQoYykscy5TVUNDRVNTfWZkX2ZpbGVzdGF0X3NldF9zaXplKHQsaSl7cmV0dXJuIHRoaXMuZHJpdmUuc2V0U2l6ZSh0LGkpfWZkX2ZpbGVzdGF0X3NldF90aW1lcyh0LGksbixyKXtsZXQgYT1udWxsO3ImTi5BVElNJiYoYT1sKGkpKSxyJk4uQVRJTV9OT1cmJihhPW5ldyBEYXRlKTtsZXQgZj1udWxsO2lmKHImTi5NVElNJiYoZj1sKG4pKSxyJk4uTVRJTV9OT1cmJihmPW5ldyBEYXRlKSxhKXtjb25zdCBjPXRoaXMuZHJpdmUuc2V0QWNjZXNzVGltZSh0LGEpO2lmKGMhPXMuU1VDQ0VTUylyZXR1cm4gY31pZihmKXtjb25zdCBjPXRoaXMuZHJpdmUuc2V0TW9kaWZpY2F0aW9uVGltZSh0LGYpO2lmKGMhPXMuU1VDQ0VTUylyZXR1cm4gY31yZXR1cm4gcy5TVUNDRVNTfWZkX3ByZWFkKHQsaSxuLHIsYSl7aWYodD09PTF8fHQ9PT0yKXJldHVybiBzLkVOT1RTVVA7aWYodD09PTApcmV0dXJuIHRoaXMuZmRfcmVhZCh0LGksbixhKTtjb25zdCBmPW5ldyBEYXRhVmlldyh0aGlzLm1lbW9yeS5idWZmZXIpLGM9ayhmLGksbik7bGV0IG89MCxFPXMuU1VDQ0VTUztmb3IoY29uc3QgaCBvZiBjKXtjb25zdFtTLGddPXRoaXMuZHJpdmUucHJlYWQodCxoLmJ5dGVMZW5ndGgsTnVtYmVyKHIpK28pO2lmKFMhPT1zLlNVQ0NFU1Mpe0U9UzticmVha31jb25zdCBUPU1hdGgubWluKGguYnl0ZUxlbmd0aCxnLmJ5dGVMZW5ndGgpO2guc2V0KGcuc3ViYXJyYXkoMCxUKSksbys9VH1yZXR1cm4gZi5zZXRVaW50MzIoYSxvLCEwKSxFfWZkX3ByZXN0YXRfZGlyX25hbWUodCxpLG4pe2lmKHQhPT0zKXJldHVybiBzLkVCQURGO2NvbnN0IHI9bmV3IFRleHRFbmNvZGVyKCkuZW5jb2RlKCIvIik7cmV0dXJuIG5ldyBVaW50OEFycmF5KHRoaXMubWVtb3J5LmJ1ZmZlcixpLG4pLnNldChyLnN1YmFycmF5KDAsbikpLHMuU1VDQ0VTU31mZF9wcmVzdGF0X2dldCh0LGkpe2lmKHQhPT0zKXJldHVybiBzLkVCQURGO2NvbnN0IG49bmV3IFRleHRFbmNvZGVyKCkuZW5jb2RlKCIuIikscj1uZXcgRGF0YVZpZXcodGhpcy5tZW1vcnkuYnVmZmVyLGkpO3JldHVybiByLnNldFVpbnQ4KDAsRy5ESVIpLHIuc2V0VWludDMyKDQsbi5ieXRlTGVuZ3RoLCEwKSxzLlNVQ0NFU1N9ZmRfcHdyaXRlKHQsaSxuLHIsYSl7aWYodD09PTApcmV0dXJuIHMuRU5PVFNVUDtpZih0PT09MXx8dD09PTIpcmV0dXJuIHRoaXMuZmRfd3JpdGUodCxpLG4sYSk7Y29uc3QgZj1uZXcgRGF0YVZpZXcodGhpcy5tZW1vcnkuYnVmZmVyKSxjPWsoZixpLG4pO2xldCBvPTAsRT1zLlNVQ0NFU1M7Zm9yKGNvbnN0IGggb2YgYylpZihoLmJ5dGVMZW5ndGghPT0wKXtpZihFPXRoaXMuZHJpdmUucHdyaXRlKHQsaCxOdW1iZXIocikpLEUhPXMuU1VDQ0VTUylicmVhaztvKz1oLmJ5dGVMZW5ndGh9cmV0dXJuIGYuc2V0VWludDMyKGEsbywhMCksRX1mZF9yZWFkZGlyKHQsaSxuLHIsYSl7Y29uc3RbZixjXT10aGlzLmRyaXZlLmxpc3QodCk7aWYoZiE9cy5TVUNDRVNTKXJldHVybiBmO2xldCBvPVtdLEU9MDtmb3IoY29uc3R7bmFtZTpVLHR5cGU6Rn1vZiBjKXtjb25zdCBLPWF0KFUsRixFKTtvLnB1c2goSyksRSsrfW89by5zbGljZShOdW1iZXIocikpO2NvbnN0IGg9by5yZWR1Y2UoKFUsRik9PlUrRi5ieXRlTGVuZ3RoLDApLFM9bmV3IFVpbnQ4QXJyYXkoaCk7bGV0IGc9MDtmb3IoY29uc3QgVSBvZiBvKVMuc2V0KFUsZyksZys9VS5ieXRlTGVuZ3RoO2NvbnN0IFQ9bmV3IFVpbnQ4QXJyYXkodGhpcy5tZW1vcnkuYnVmZmVyLGksbikscD1TLnN1YmFycmF5KDAsbik7cmV0dXJuIFQuc2V0KHApLG5ldyBEYXRhVmlldyh0aGlzLm1lbW9yeS5idWZmZXIpLnNldFVpbnQzMihhLHAuYnl0ZUxlbmd0aCwhMCkscy5TVUNDRVNTfWZkX3JlbnVtYmVyKHQsaSl7cmV0dXJuIHRoaXMuZHJpdmUucmVudW1iZXIodCxpKX1mZF9zZWVrKHQsaSxuLHIpe2NvbnN0W2EsZl09dGhpcy5kcml2ZS5zZWVrKHQsaSxuKTtyZXR1cm4gYSE9PXMuU1VDQ0VTU3x8KHkoe25ld09mZnNldDpmLnRvU3RyaW5nKCl9KSxuZXcgRGF0YVZpZXcodGhpcy5tZW1vcnkuYnVmZmVyKS5zZXRCaWdVaW50NjQocixmLCEwKSksYX11bnN0YWJsZV9mZF9zZWVrKHQsaSxuLHIpe2NvbnN0IGE9b3Rbbl07cmV0dXJuIHRoaXMuZmRfc2Vlayh0LGksYSxyKX1mZF9zeW5jKHQpe3JldHVybiB0aGlzLmRyaXZlLnN5bmModCl9ZmRfdGVsbCh0LGkpe2NvbnN0W24scl09dGhpcy5kcml2ZS50ZWxsKHQpO3JldHVybiBuIT09cy5TVUNDRVNTfHxuZXcgRGF0YVZpZXcodGhpcy5tZW1vcnkuYnVmZmVyKS5zZXRCaWdVaW50NjQoaSxyLCEwKSxufXBhdGhfZmlsZXN0YXRfZ2V0KHQsaSxuLHIsYSl7cmV0dXJuIHRoaXMuc2hhcmVkX3BhdGhfZmlsZXN0YXRfZ2V0KHQsaSxuLHIsYSwicHJldmlldzEiKX11bnN0YWJsZV9wYXRoX2ZpbGVzdGF0X2dldCh0LGksbixyLGEpe3JldHVybiB0aGlzLnNoYXJlZF9wYXRoX2ZpbGVzdGF0X2dldCh0LGksbixyLGEsInVuc3RhYmxlIil9c2hhcmVkX3BhdGhfZmlsZXN0YXRfZ2V0KHQsaSxuLHIsYSxmKXtjb25zdCBjPWY9PT0idW5zdGFibGUiP3E6SixvPW5ldyBUZXh0RGVjb2RlcigpLmRlY29kZShuZXcgVWludDhBcnJheSh0aGlzLm1lbW9yeS5idWZmZXIsbixyKSk7eSh7cGF0aDpvfSk7Y29uc3RbRSxoXT10aGlzLmRyaXZlLnBhdGhTdGF0KHQsbyk7aWYoRSE9cy5TVUNDRVNTKXJldHVybiBFO2NvbnN0IFM9YyhoKTtyZXR1cm4gbmV3IFVpbnQ4QXJyYXkodGhpcy5tZW1vcnkuYnVmZmVyLGEsUy5ieXRlTGVuZ3RoKS5zZXQoUyksRX1wYXRoX2ZpbGVzdGF0X3NldF90aW1lcyh0LGksbixyLGEsZixjKXtsZXQgbz1udWxsO2MmTi5BVElNJiYobz1sKGEpKSxjJk4uQVRJTV9OT1cmJihvPW5ldyBEYXRlKTtsZXQgRT1udWxsO2MmTi5NVElNJiYoRT1sKGYpKSxjJk4uTVRJTV9OT1cmJihFPW5ldyBEYXRlKTtjb25zdCBoPW5ldyBUZXh0RGVjb2RlcigpLmRlY29kZShuZXcgVWludDhBcnJheSh0aGlzLm1lbW9yeS5idWZmZXIsbixyKSk7aWYobyl7Y29uc3QgUz10aGlzLmRyaXZlLnBhdGhTZXRBY2Nlc3NUaW1lKHQsaCxvKTtpZihTIT1zLlNVQ0NFU1MpcmV0dXJuIFN9aWYoRSl7Y29uc3QgUz10aGlzLmRyaXZlLnBhdGhTZXRNb2RpZmljYXRpb25UaW1lKHQsaCxFKTtpZihTIT1zLlNVQ0NFU1MpcmV0dXJuIFN9cmV0dXJuIHMuU1VDQ0VTU31wYXRoX29wZW4odCxpLG4scixhLGYsYyxvLEUpe2NvbnN0IGg9bmV3IERhdGFWaWV3KHRoaXMubWVtb3J5LmJ1ZmZlciksUz1CKHRoaXMubWVtb3J5LG4sciksZz0hIShhJk8uQ1JFQVQpLFQ9ISEoYSZPLkRJUkVDVE9SWSkscD0hIShhJk8uRVhDTCksZXQ9ISEoYSZPLlRSVU5DKSxVPSEhKG8mbS5BUFBFTkQpLEY9ISEobyZtLkRTWU5DKSxLPSEhKG8mbS5OT05CTE9DSyksZHQ9ISEobyZtLlJTWU5DKSx1dD0hIShvJm0uU1lOQyk7eSh7cGF0aDpTLG9wZW5GbGFnczp7Y3JlYXRlRmlsZUlmTm9uZTpnLGZhaWxJZk5vdERpcjpULGZhaWxJZkZpbGVFeGlzdHM6cCx0cnVuY2F0ZUZpbGU6ZXR9LGZpbGVEZXNjcmlwdG9yRmxhZ3M6e2ZsYWdBcHBlbmQ6VSxmbGFnRFN5bmM6RixmbGFnTm9uQmxvY2s6SyxmbGFnUlN5bmM6ZHQsZmxhZ1N5bmM6dXR9fSk7Y29uc3RbeixndF09dGhpcy5kcml2ZS5vcGVuKHQsUyxhLG8pO3JldHVybiB6fHwoaC5zZXRVaW50MzIoRSxndCwhMCkseil9cGF0aF9yZW5hbWUodCxpLG4scixhLGYpe2NvbnN0IGM9Qih0aGlzLm1lbW9yeSxpLG4pLG89Qih0aGlzLm1lbW9yeSxhLGYpO3JldHVybiB5KHtvbGRQYXRoOmMsbmV3UGF0aDpvfSksdGhpcy5kcml2ZS5yZW5hbWUodCxjLHIsbyl9cGF0aF91bmxpbmtfZmlsZSh0LGksbil7Y29uc3Qgcj1CKHRoaXMubWVtb3J5LGksbik7cmV0dXJuIHkoe3BhdGg6cn0pLHRoaXMuZHJpdmUudW5saW5rKHQscil9cG9sbF9vbmVvZmYodCxpLG4scil7Zm9yKGxldCBmPTA7ZjxuO2YrKyl7Y29uc3QgYz1uZXcgVWludDhBcnJheSh0aGlzLm1lbW9yeS5idWZmZXIsdCtmKiQsJCksbz1zdChjKSxFPW5ldyBVaW50OEFycmF5KHRoaXMubWVtb3J5LmJ1ZmZlcixpK2YqaixqKTtsZXQgaD0wLFM9cy5TVUNDRVNTO3N3aXRjaChvLnR5cGUpe2Nhc2UgQS5DTE9DSzpmb3IoO25ldyBEYXRlPG8udGltZW91dDspO0Uuc2V0KGZ0KG8udXNlcmRhdGEscy5TVUNDRVNTKSk7YnJlYWs7Y2FzZSBBLkZEX1JFQUQ6aWYoby5mZDwzKW8uZmQ9PT0wPyhTPXMuU1VDQ0VTUyxoPTMyKTpTPXMuRUJBREY7ZWxzZXtjb25zdFtnLFRdPXRoaXMuZHJpdmUuc3RhdChvLmZkKTtTPWcsaD1UP1QuYnl0ZUxlbmd0aDowfUUuc2V0KHR0KG8udXNlcmRhdGEsUyxBLkZEX1JFQUQsQmlnSW50KGgpKSk7YnJlYWs7Y2FzZSBBLkZEX1dSSVRFOmlmKGg9MCxTPXMuU1VDQ0VTUyxvLmZkPDMpby5mZD09PTA/Uz1zLkVCQURGOihTPXMuU1VDQ0VTUyxoPTEwMjQpO2Vsc2V7Y29uc3RbZyxUXT10aGlzLmRyaXZlLnN0YXQoby5mZCk7Uz1nLGg9VD9ULmJ5dGVMZW5ndGg6MH1FLnNldCh0dChvLnVzZXJkYXRhLFMsQS5GRF9SRUFELEJpZ0ludChoKSkpO2JyZWFrfX1yZXR1cm4gbmV3IERhdGFWaWV3KHRoaXMubWVtb3J5LmJ1ZmZlcixyLDQpLnNldFVpbnQzMigwLG4sITApLHMuU1VDQ0VTU31wYXRoX2NyZWF0ZV9kaXJlY3RvcnkodCxpLG4pe2NvbnN0IHI9Qih0aGlzLm1lbW9yeSxpLG4pO3JldHVybiB0aGlzLmRyaXZlLnBhdGhDcmVhdGVEaXIodCxyKX1wYXRoX2xpbmsoKXtyZXR1cm4gcy5FTk9TWVN9cGF0aF9yZWFkbGluaygpe3JldHVybiBzLkVOT1NZU31wYXRoX3JlbW92ZV9kaXJlY3RvcnkoKXtyZXR1cm4gcy5FTk9TWVN9cGF0aF9zeW1saW5rKCl7cmV0dXJuIHMuRU5PU1lTfXByb2NfcmFpc2UoKXtyZXR1cm4gcy5FTk9TWVN9c29ja19hY2NlcHQoKXtyZXR1cm4gcy5FTk9TWVN9c29ja19yZWN2KCl7cmV0dXJuIHMuRU5PU1lTfXNvY2tfc2VuZCgpe3JldHVybiBzLkVOT1NZU31zb2NrX3NodXRkb3duKCl7cmV0dXJuIHMuRU5PU1lTfXNvY2tfb3Blbigpe3JldHVybiBzLkVOT1NZU31zb2NrX2xpc3Rlbigpe3JldHVybiBzLkVOT1NZU31zb2NrX2Nvbm5lY3QoKXtyZXR1cm4gcy5FTk9TWVN9c29ja19zZXRzb2Nrb3B0KCl7cmV0dXJuIHMuRU5PU1lTfXNvY2tfYmluZCgpe3JldHVybiBzLkVOT1NZU31zb2NrX2dldGxvY2FsYWRkcigpe3JldHVybiBzLkVOT1NZU31zb2NrX2dldHBlZXJhZGRyKCl7cmV0dXJuIHMuRU5PU1lTfXNvY2tfZ2V0YWRkcmluZm8oKXtyZXR1cm4gcy5FTk9TWVN9fWNvbnN0IFY9Xy5GRF9EQVRBU1lOQ3xfLkZEX1JFQUR8Xy5GRF9TRUVLfF8uRkRfRkRTVEFUX1NFVF9GTEFHU3xfLkZEX1NZTkN8Xy5GRF9URUxMfF8uRkRfV1JJVEV8Xy5GRF9BRFZJU0V8Xy5GRF9BTExPQ0FURXxfLlBBVEhfQ1JFQVRFX0RJUkVDVE9SWXxfLlBBVEhfQ1JFQVRFX0ZJTEV8Xy5QQVRIX0xJTktfU09VUkNFfF8uUEFUSF9MSU5LX1RBUkdFVHxfLlBBVEhfT1BFTnxfLkZEX1JFQURESVJ8Xy5QQVRIX1JFQURMSU5LfF8uUEFUSF9SRU5BTUVfU09VUkNFfF8uUEFUSF9SRU5BTUVfVEFSR0VUfF8uUEFUSF9GSUxFU1RBVF9HRVR8Xy5QQVRIX0ZJTEVTVEFUX1NFVF9TSVpFfF8uUEFUSF9GSUxFU1RBVF9TRVRfVElNRVN8Xy5GRF9GSUxFU1RBVF9HRVR8Xy5GRF9GSUxFU1RBVF9TRVRfU0laRXxfLkZEX0ZJTEVTVEFUX1NFVF9USU1FU3xfLlBBVEhfU1lNTElOS3xfLlBBVEhfUkVNT1ZFX0RJUkVDVE9SWXxfLlBBVEhfVU5MSU5LX0ZJTEV8Xy5QT0xMX0ZEX1JFQURXUklURXxfLlNPQ0tfU0hVVERPV058Xy5TT0NLX0FDQ0VQVDtjbGFzcyBRIGV4dGVuZHMgRXJyb3J7Y29uc3RydWN0b3IoaSl7c3VwZXIoKTtkKHRoaXMsImNvZGUiKTt0aGlzLmNvZGU9aX19ZnVuY3Rpb24gQihlLHQsaSl7cmV0dXJuIG5ldyBUZXh0RGVjb2RlcigpLmRlY29kZShuZXcgVWludDhBcnJheShlLmJ1ZmZlcix0LGkpKX1mdW5jdGlvbiBrKGUsdCxpKXtsZXQgbj1BcnJheShpKTtmb3IobGV0IHI9MDtyPGk7cisrKXtjb25zdCBhPWUuZ2V0VWludDMyKHQsITApO3QrPTQ7Y29uc3QgZj1lLmdldFVpbnQzMih0LCEwKTt0Kz00LG5bcl09bmV3IFVpbnQ4QXJyYXkoZS5idWZmZXIsYSxmKX1yZXR1cm4gbn1mdW5jdGlvbiBzdChlKXtjb25zdCB0PW5ldyBVaW50OEFycmF5KDgpO3Quc2V0KGUuc3ViYXJyYXkoMCw4KSk7Y29uc3QgaT1lWzhdLG49bmV3IERhdGFWaWV3KGUuYnVmZmVyLGUuYnl0ZU9mZnNldCs5KTtzd2l0Y2goaSl7Y2FzZSBBLkZEX1JFQUQ6Y2FzZSBBLkZEX1dSSVRFOnJldHVybnt1c2VyZGF0YTp0LHR5cGU6aSxmZDpuLmdldFVpbnQzMigwLCEwKX07Y2FzZSBBLkNMT0NLOmNvbnN0IHI9bi5nZXRVaW50MTYoMjQsITApLGE9dyhuZXcgRGF0ZSksZj1uLmdldEJpZ1VpbnQ2NCg4LCEwKSxjPW4uZ2V0QmlnVWludDY0KDE2LCEwKSxvPXImaXQuU1VCU0NSSVBUSU9OX0NMT0NLX0FCU1RJTUU/ZjphK2Y7cmV0dXJue3VzZXJkYXRhOnQsdHlwZTppLGlkOm4uZ2V0VWludDMyKDAsITApLHRpbWVvdXQ6bChvKSxwcmVjaXNpb246bChvK2MpfX19ZnVuY3Rpb24gSihlKXtjb25zdCB0PW5ldyBVaW50OEFycmF5KFcpLGk9bmV3IERhdGFWaWV3KHQuYnVmZmVyKTtyZXR1cm4gaS5zZXRCaWdVaW50NjQoMCxCaWdJbnQoMCksITApLGkuc2V0QmlnVWludDY0KDgsQmlnSW50KFIoZS5wYXRoKSksITApLGkuc2V0VWludDgoMTYsZS50eXBlKSxpLnNldEJpZ1VpbnQ2NCgyNCxCaWdJbnQoMSksITApLGkuc2V0QmlnVWludDY0KDMyLEJpZ0ludChlLmJ5dGVMZW5ndGgpLCEwKSxpLnNldEJpZ1VpbnQ2NCg0MCx3KGUudGltZXN0YW1wcy5hY2Nlc3MpLCEwKSxpLnNldEJpZ1VpbnQ2NCg0OCx3KGUudGltZXN0YW1wcy5tb2RpZmljYXRpb24pLCEwKSxpLnNldEJpZ1VpbnQ2NCg1Nix3KGUudGltZXN0YW1wcy5jaGFuZ2UpLCEwKSx0fWZ1bmN0aW9uIHEoZSl7Y29uc3QgdD1uZXcgVWludDhBcnJheShXKSxpPW5ldyBEYXRhVmlldyh0LmJ1ZmZlcik7cmV0dXJuIGkuc2V0QmlnVWludDY0KDAsQmlnSW50KDApLCEwKSxpLnNldEJpZ1VpbnQ2NCg4LEJpZ0ludChSKGUucGF0aCkpLCEwKSxpLnNldFVpbnQ4KDE2LGUudHlwZSksaS5zZXRVaW50MzIoMjAsMSwhMCksaS5zZXRCaWdVaW50NjQoMjQsQmlnSW50KGUuYnl0ZUxlbmd0aCksITApLGkuc2V0QmlnVWludDY0KDMyLHcoZS50aW1lc3RhbXBzLmFjY2VzcyksITApLGkuc2V0QmlnVWludDY0KDQwLHcoZS50aW1lc3RhbXBzLm1vZGlmaWNhdGlvbiksITApLGkuc2V0QmlnVWludDY0KDQ4LHcoZS50aW1lc3RhbXBzLmNoYW5nZSksITApLHR9ZnVuY3Rpb24gSChlLHQsaSl7Y29uc3Qgbj1pPz9WLHI9aT8/VixhPW5ldyBVaW50OEFycmF5KDI0KSxmPW5ldyBEYXRhVmlldyhhLmJ1ZmZlciwwLDI0KTtyZXR1cm4gZi5zZXRVaW50OCgwLGUpLGYuc2V0VWludDMyKDIsdCwhMCksZi5zZXRCaWdVaW50NjQoOCxuLCEwKSxmLnNldEJpZ1VpbnQ2NCgxNixyLCEwKSxhfWZ1bmN0aW9uIGF0KGUsdCxpKXtjb25zdCBuPW5ldyBUZXh0RW5jb2RlcigpLmVuY29kZShlKSxyPTI0K24uYnl0ZUxlbmd0aCxhPW5ldyBVaW50OEFycmF5KHIpLGY9bmV3IERhdGFWaWV3KGEuYnVmZmVyKTtyZXR1cm4gZi5zZXRCaWdVaW50NjQoMCxCaWdJbnQoaSsxKSwhMCksZi5zZXRCaWdVaW50NjQoOCxCaWdJbnQoUihlKSksITApLGYuc2V0VWludDMyKDE2LG4ubGVuZ3RoLCEwKSxmLnNldFVpbnQ4KDIwLHQpLGEuc2V0KG4sMjQpLGF9ZnVuY3Rpb24gZnQoZSx0KXtjb25zdCBpPW5ldyBVaW50OEFycmF5KDMyKTtpLnNldChlLDApO2NvbnN0IG49bmV3IERhdGFWaWV3KGkuYnVmZmVyKTtyZXR1cm4gbi5zZXRVaW50MTYoOCx0LCEwKSxuLnNldFVpbnQxNigxMCxBLkNMT0NLLCEwKSxpfWZ1bmN0aW9uIHR0KGUsdCxpLG4pe2NvbnN0IHI9bmV3IFVpbnQ4QXJyYXkoMzIpO3Iuc2V0KGUsMCk7Y29uc3QgYT1uZXcgRGF0YVZpZXcoci5idWZmZXIpO3JldHVybiBhLnNldFVpbnQxNig4LHQsITApLGEuc2V0VWludDE2KDEwLGksITApLGEuc2V0QmlnVWludDY0KDE2LG4sITApLHJ9ZnVuY3Rpb24gUihlLHQ9MCl7bGV0IGk9MzczNTkyODU1OV50LG49MTEwMzU0Nzk5MV50O2ZvcihsZXQgcj0wLGE7cjxlLmxlbmd0aDtyKyspYT1lLmNoYXJDb2RlQXQociksaT1NYXRoLmltdWwoaV5hLDI2NTQ0MzU3NjEpLG49TWF0aC5pbXVsKG5eYSwxNTk3MzM0Njc3KTtyZXR1cm4gaT1NYXRoLmltdWwoaV5pPj4+MTYsMjI0NjgyMjUwNyleTWF0aC5pbXVsKG5ebj4+PjEzLDMyNjY0ODk5MDkpLG49TWF0aC5pbXVsKG5ebj4+PjE2LDIyNDY4MjI1MDcpXk1hdGguaW11bChpXmk+Pj4xMywzMjY2NDg5OTA5KSw0Mjk0OTY3Mjk2KigyMDk3MTUxJm4pKyhpPj4+MCl9ZnVuY3Rpb24gdyhlKXtyZXR1cm4gQmlnSW50KGUuZ2V0VGltZSgpKSpCaWdJbnQoMWU2KX1mdW5jdGlvbiBsKGUpe3JldHVybiBuZXcgRGF0ZShOdW1iZXIoZS9CaWdJbnQoMWU2KSkpfWNvbnN0IG90PXtbTS5DVVJdOmIuQ1VSLFtNLkVORF06Yi5FTkQsW00uU0VUXTpiLlNFVH07b25tZXNzYWdlPWFzeW5jIGU9Pntjb25zdCB0PWUuZGF0YTtzd2l0Y2godC50eXBlKXtjYXNlInN0YXJ0Ijp0cnl7Y29uc3QgaT1hd2FpdCBjdCh0LmJpbmFyeVVSTCx0LnN0ZGluQnVmZmVyLHQpO0woe3RhcmdldDoiaG9zdCIsdHlwZToicmVzdWx0IixyZXN1bHQ6aX0pfWNhdGNoKGkpe2xldCBuO2kgaW5zdGFuY2VvZiBFcnJvcj9uPXttZXNzYWdlOmkubWVzc2FnZSx0eXBlOmkuY29uc3RydWN0b3IubmFtZX06bj17bWVzc2FnZTpgdW5rbm93biBlcnJvciAtICR7aX1gLHR5cGU6IlVua25vd24ifSxMKHt0YXJnZXQ6Imhvc3QiLHR5cGU6ImNyYXNoIixlcnJvcjpufSl9YnJlYWt9fTtmdW5jdGlvbiBMKGUpe3Bvc3RNZXNzYWdlKGUpfWFzeW5jIGZ1bmN0aW9uIGN0KGUsdCxpKXtyZXR1cm4gdi5zdGFydChmZXRjaChlKSxuZXcgWCh7Li4uaSxzdGRvdXQ6RXQsc3RkZXJyOmh0LHN0ZGluOm49Pl90KG4sdCksZGVidWc6U3R9KSl9ZnVuY3Rpb24gRXQoZSl7TCh7dGFyZ2V0OiJob3N0Iix0eXBlOiJzdGRvdXQiLHRleHQ6ZX0pfWZ1bmN0aW9uIGh0KGUpe0woe3RhcmdldDoiaG9zdCIsdHlwZToic3RkZXJyIix0ZXh0OmV9KX1mdW5jdGlvbiBTdChlLHQsaSxuKXtyZXR1cm4gbj1KU09OLnBhcnNlKEpTT04uc3RyaW5naWZ5KG4pKSxMKHt0YXJnZXQ6Imhvc3QiLHR5cGU6ImRlYnVnIixuYW1lOmUsYXJnczp0LHJldDppLGRhdGE6bn0pLGl9ZnVuY3Rpb24gX3QoZSx0KXtBdG9taWNzLndhaXQobmV3IEludDMyQXJyYXkodCksMCwwKTtjb25zdCBpPW5ldyBEYXRhVmlldyh0KSxuPWkuZ2V0SW50MzIoMCk7aWYobjwwKXJldHVybiBpLnNldEludDMyKDAsMCksbnVsbDtjb25zdCByPW5ldyBVaW50OEFycmF5KHQsNCxuKSxhPW5ldyBUZXh0RGVjb2RlcigpLmRlY29kZShyLnNsaWNlKDAsZSkpLGY9ci5zbGljZShlLHIubGVuZ3RoKTtyZXR1cm4gaS5zZXRJbnQzMigwLGYuYnl0ZUxlbmd0aCksci5zZXQoZiksYX19KSgpOwo=", ll = typeof window < "u" && window.Blob && new Blob([atob(dl)], { type: "text/javascript;charset=utf-8" });
function Wl() {
  let t;
  try {
    if (t = ll && (window.URL || window.webkitURL).createObjectURL(ll), !t)
      throw "";
    return new Worker(t);
  } catch {
    return new Worker("data:application/javascript;base64," + dl);
  } finally {
    t && (window.URL || window.webkitURL).revokeObjectURL(t);
  }
}
function yl(t, l) {
  t.postMessage(l);
}
class kl extends Error {
}
class Fl {
  constructor(l, V) {
    R(this, "binaryURL");
    // 8kb should be big enough
    R(this, "stdinBuffer", new SharedArrayBuffer(8 * 1024));
    R(this, "context");
    R(this, "result");
    R(this, "worker");
    R(this, "reject");
    this.binaryURL = l, this.context = V;
  }
  async start() {
    if (this.result)
      throw new Error("WASIWorker Host can only be started once");
    return this.result = new Promise((l, V) => {
      this.reject = V, this.worker = new Wl(), this.worker.addEventListener("message", (Z) => {
        var i, n, m, e, a, X;
        const d = Z.data;
        switch (d.type) {
          case "stdout":
            (n = (i = this.context).stdout) == null || n.call(i, d.text);
            break;
          case "stderr":
            (e = (m = this.context).stderr) == null || e.call(m, d.text);
            break;
          case "debug":
            (X = (a = this.context).debug) == null || X.call(a, d.name, d.args, d.ret, d.data);
            break;
          case "result":
            l(d.result);
            break;
          case "crash":
            V(d.error);
            break;
        }
      }), yl(this.worker, {
        target: "client",
        type: "start",
        binaryURL: this.binaryURL,
        stdinBuffer: this.stdinBuffer,
        // Unfortunately can't just splat these because it includes types
        // that can't be sent as a message.
        args: this.context.args,
        env: this.context.env,
        fs: this.context.fs,
        isTTY: this.context.isTTY
      });
    }).then((l) => {
      var V;
      return (V = this.worker) == null || V.terminate(), l;
    }), this.result;
  }
  kill() {
    var l;
    if (!this.worker)
      throw new Error("WASIWorker has not started");
    this.worker.terminate(), (l = this.reject) == null || l.call(this, new kl("WASI Worker was killed"));
  }
  async pushStdin(l) {
    const V = new DataView(this.stdinBuffer);
    for (; V.getInt32(0) !== 0; )
      await new Promise((i) => setTimeout(i, 0));
    const Z = new TextEncoder().encode(l);
    new Uint8Array(this.stdinBuffer, 4).set(Z), V.setInt32(0, Z.byteLength), Atomics.notify(new Int32Array(this.stdinBuffer), 0);
  }
  async pushEOF() {
    const l = new DataView(this.stdinBuffer);
    for (; l.getInt32(0) !== 0; )
      await new Promise((V) => setTimeout(V, 0));
    l.setInt32(0, -1), Atomics.notify(new Int32Array(this.stdinBuffer), 0);
  }
}
const cl = "dmFyIG10PU9iamVjdC5kZWZpbmVQcm9wZXJ0eTt2YXIgT3Q9KHMsYixDKT0+YiBpbiBzP210KHMsYix7ZW51bWVyYWJsZTohMCxjb25maWd1cmFibGU6ITAsd3JpdGFibGU6ITAsdmFsdWU6Q30pOnNbYl09Qzt2YXIgdT0ocyxiLEMpPT4oT3Qocyx0eXBlb2YgYiE9InN5bWJvbCI/YisiIjpiLEMpLEMpOyhmdW5jdGlvbigpeyJ1c2Ugc3RyaWN0Ijt2YXIgcz0oZT0+KGVbZS5TVUNDRVNTPTBdPSJTVUNDRVNTIixlW2UuRTJCSUc9MV09IkUyQklHIixlW2UuRUFDQ0VTUz0yXT0iRUFDQ0VTUyIsZVtlLkVBRERSSU5VU0U9M109IkVBRERSSU5VU0UiLGVbZS5FQUREUk5PVEFWQUlMPTRdPSJFQUREUk5PVEFWQUlMIixlW2UuRUFGTk9TVVBQT1JUPTVdPSJFQUZOT1NVUFBPUlQiLGVbZS5FQUdBSU49Nl09IkVBR0FJTiIsZVtlLkVBTFJFQURZPTddPSJFQUxSRUFEWSIsZVtlLkVCQURGPThdPSJFQkFERiIsZVtlLkVCQURNU0c9OV09IkVCQURNU0ciLGVbZS5FQlVTWT0xMF09IkVCVVNZIixlW2UuRUNBTkNFTEVEPTExXT0iRUNBTkNFTEVEIixlW2UuRUNISUxEPTEyXT0iRUNISUxEIixlW2UuRUNPTk5BQk9SVEVEPTEzXT0iRUNPTk5BQk9SVEVEIixlW2UuRUNPTk5SRUZVU0VEPTE0XT0iRUNPTk5SRUZVU0VEIixlW2UuRUNPTk5SRVNFVD0xNV09IkVDT05OUkVTRVQiLGVbZS5FREVBRExLPTE2XT0iRURFQURMSyIsZVtlLkVERVNUQUREUlJFUT0xN109IkVERVNUQUREUlJFUSIsZVtlLkVET009MThdPSJFRE9NIixlW2UuRURRVU9UPTE5XT0iRURRVU9UIixlW2UuRUVYSVNUPTIwXT0iRUVYSVNUIixlW2UuRUZBVUxUPTIxXT0iRUZBVUxUIixlW2UuRUZCSUc9MjJdPSJFRkJJRyIsZVtlLkVIT1NUVU5SRUFDSD0yM109IkVIT1NUVU5SRUFDSCIsZVtlLkVJRFJNPTI0XT0iRUlEUk0iLGVbZS5FSUxTRVE9MjVdPSJFSUxTRVEiLGVbZS5FSU5QUk9HUkVTUz0yNl09IkVJTlBST0dSRVNTIixlW2UuRUlOVFI9MjddPSJFSU5UUiIsZVtlLkVJTlZBTD0yOF09IkVJTlZBTCIsZVtlLkVJTz0yOV09IkVJTyIsZVtlLkVJU0NPTk49MzBdPSJFSVNDT05OIixlW2UuRUlTRElSPTMxXT0iRUlTRElSIixlW2UuRUxPT1A9MzJdPSJFTE9PUCIsZVtlLkVNRklMRT0zM109IkVNRklMRSIsZVtlLkVNTElOSz0zNF09IkVNTElOSyIsZVtlLkVNU0dTSVpFPTM1XT0iRU1TR1NJWkUiLGVbZS5FTVVMVElIT1A9MzZdPSJFTVVMVElIT1AiLGVbZS5FTkFNRVRPT0xPTkc9MzddPSJFTkFNRVRPT0xPTkciLGVbZS5FTkVURE9XTj0zOF09IkVORVRET1dOIixlW2UuRU5FVFJFU0VUPTM5XT0iRU5FVFJFU0VUIixlW2UuRU5FVFVOUkVBQ0g9NDBdPSJFTkVUVU5SRUFDSCIsZVtlLkVORklMRT00MV09IkVORklMRSIsZVtlLkVOT0JVRlM9NDJdPSJFTk9CVUZTIixlW2UuRU5PREVWPTQzXT0iRU5PREVWIixlW2UuRU5PRU5UPTQ0XT0iRU5PRU5UIixlW2UuRU5PRVhFQz00NV09IkVOT0VYRUMiLGVbZS5FTk9MQ0s9NDZdPSJFTk9MQ0siLGVbZS5FTk9MSU5LPTQ3XT0iRU5PTElOSyIsZVtlLkVOT01FTT00OF09IkVOT01FTSIsZVtlLkVOT01TRz00OV09IkVOT01TRyIsZVtlLkVOT1BST1RPT1BUPTUwXT0iRU5PUFJPVE9PUFQiLGVbZS5FTk9TUEM9NTFdPSJFTk9TUEMiLGVbZS5FTk9TWVM9NTJdPSJFTk9TWVMiLGVbZS5FTk9UQ09OTj01M109IkVOT1RDT05OIixlW2UuRU5PVERJUj01NF09IkVOT1RESVIiLGVbZS5FTk9URU1QVFk9NTVdPSJFTk9URU1QVFkiLGVbZS5FTk9UUkVDT1ZFUkFCTEU9NTZdPSJFTk9UUkVDT1ZFUkFCTEUiLGVbZS5FTk9UU09DSz01N109IkVOT1RTT0NLIixlW2UuRU5PVFNVUD01OF09IkVOT1RTVVAiLGVbZS5FTk9UVFk9NTldPSJFTk9UVFkiLGVbZS5FTlhJTz02MF09IkVOWElPIixlW2UuRU9WRVJGTE9XPTYxXT0iRU9WRVJGTE9XIixlW2UuRU9XTkVSREVBRD02Ml09IkVPV05FUkRFQUQiLGVbZS5FUEVSTT02M109IkVQRVJNIixlW2UuRVBJUEU9NjRdPSJFUElQRSIsZVtlLkVQUk9UTz02NV09IkVQUk9UTyIsZVtlLkVQUk9UT05PU1VQUE9SVD02Nl09IkVQUk9UT05PU1VQUE9SVCIsZVtlLkVQUk9UT1RZUEU9NjddPSJFUFJPVE9UWVBFIixlW2UuRVJBTkdFPTY4XT0iRVJBTkdFIixlW2UuRVJPRlM9NjldPSJFUk9GUyIsZVtlLkVTUElQRT03MF09IkVTUElQRSIsZVtlLkVTUkNIPTcxXT0iRVNSQ0giLGVbZS5FU1RBTEU9NzJdPSJFU1RBTEUiLGVbZS5FVElNRURPVVQ9NzNdPSJFVElNRURPVVQiLGVbZS5FVFhUQlNZPTc0XT0iRVRYVEJTWSIsZVtlLkVYREVWPTc1XT0iRVhERVYiLGVbZS5FTk9UQ0FQQUJMRT03Nl09IkVOT1RDQVBBQkxFIixlKSkoc3x8e30pLGI9KGU9PihlW2UuUkVBTFRJTUU9MF09IlJFQUxUSU1FIixlW2UuTU9OT1RPTklDPTFdPSJNT05PVE9OSUMiLGVbZS5QUk9DRVNTX0NQVVRJTUVfSUQ9Ml09IlBST0NFU1NfQ1BVVElNRV9JRCIsZVtlLlRIUkVBRF9DUFVUSU1FX0lEPTNdPSJUSFJFQURfQ1BVVElNRV9JRCIsZSkpKGJ8fHt9KSxDPShlPT4oZVtlLlNFVD0wXT0iU0VUIixlW2UuQ1VSPTFdPSJDVVIiLGVbZS5FTkQ9Ml09IkVORCIsZSkpKEN8fHt9KSxBPShlPT4oZVtlLlVOS05PV049MF09IlVOS05PV04iLGVbZS5CTE9DS19ERVZJQ0U9MV09IkJMT0NLX0RFVklDRSIsZVtlLkNIQVJBQ1RFUl9ERVZJQ0U9Ml09IkNIQVJBQ1RFUl9ERVZJQ0UiLGVbZS5ESVJFQ1RPUlk9M109IkRJUkVDVE9SWSIsZVtlLlJFR1VMQVJfRklMRT00XT0iUkVHVUxBUl9GSUxFIixlW2UuU09DS0VUX0RHUkFNPTVdPSJTT0NLRVRfREdSQU0iLGVbZS5TT0NLRVRfU1RSRUFNPTZdPSJTT0NLRVRfU1RSRUFNIixlW2UuU1lNQk9MSUNfTElOSz03XT0iU1lNQk9MSUNfTElOSyIsZSkpKEF8fHt9KSwkPShlPT4oZVtlLkRJUj0wXT0iRElSIixlKSkoJHx8e30pLG09KGU9PihlW2UuQ0xPQ0s9MF09IkNMT0NLIixlW2UuRkRfUkVBRD0xXT0iRkRfUkVBRCIsZVtlLkZEX1dSSVRFPTJdPSJGRF9XUklURSIsZSkpKG18fHt9KTtjb25zdCB3PXtDUkVBVDoxLERJUkVDVE9SWToyLEVYQ0w6NCxUUlVOQzo4fSxPPXtBUFBFTkQ6MSxEU1lOQzoyLE5PTkJMT0NLOjQsUlNZTkM6OCxTWU5DOjE2fSxfPXtGRF9EQVRBU1lOQzpCaWdJbnQoMSk8PEJpZ0ludCgwKSxGRF9SRUFEOkJpZ0ludCgxKTw8QmlnSW50KDEpLEZEX1NFRUs6QmlnSW50KDEpPDxCaWdJbnQoMiksRkRfRkRTVEFUX1NFVF9GTEFHUzpCaWdJbnQoMSk8PEJpZ0ludCgzKSxGRF9TWU5DOkJpZ0ludCgxKTw8QmlnSW50KDQpLEZEX1RFTEw6QmlnSW50KDEpPDxCaWdJbnQoNSksRkRfV1JJVEU6QmlnSW50KDEpPDxCaWdJbnQoNiksRkRfQURWSVNFOkJpZ0ludCgxKTw8QmlnSW50KDcpLEZEX0FMTE9DQVRFOkJpZ0ludCgxKTw8QmlnSW50KDgpLFBBVEhfQ1JFQVRFX0RJUkVDVE9SWTpCaWdJbnQoMSk8PEJpZ0ludCg5KSxQQVRIX0NSRUFURV9GSUxFOkJpZ0ludCgxKTw8QmlnSW50KDEwKSxQQVRIX0xJTktfU09VUkNFOkJpZ0ludCgxKTw8QmlnSW50KDExKSxQQVRIX0xJTktfVEFSR0VUOkJpZ0ludCgxKTw8QmlnSW50KDEyKSxQQVRIX09QRU46QmlnSW50KDEpPDxCaWdJbnQoMTMpLEZEX1JFQURESVI6QmlnSW50KDEpPDxCaWdJbnQoMTQpLFBBVEhfUkVBRExJTks6QmlnSW50KDEpPDxCaWdJbnQoMTUpLFBBVEhfUkVOQU1FX1NPVVJDRTpCaWdJbnQoMSk8PEJpZ0ludCgxNiksUEFUSF9SRU5BTUVfVEFSR0VUOkJpZ0ludCgxKTw8QmlnSW50KDE3KSxQQVRIX0ZJTEVTVEFUX0dFVDpCaWdJbnQoMSk8PEJpZ0ludCgxOCksUEFUSF9GSUxFU1RBVF9TRVRfU0laRTpCaWdJbnQoMSk8PEJpZ0ludCgxOSksUEFUSF9GSUxFU1RBVF9TRVRfVElNRVM6QmlnSW50KDEpPDxCaWdJbnQoMjApLEZEX0ZJTEVTVEFUX0dFVDpCaWdJbnQoMSk8PEJpZ0ludCgyMSksRkRfRklMRVNUQVRfU0VUX1NJWkU6QmlnSW50KDEpPDxCaWdJbnQoMjIpLEZEX0ZJTEVTVEFUX1NFVF9USU1FUzpCaWdJbnQoMSk8PEJpZ0ludCgyMyksUEFUSF9TWU1MSU5LOkJpZ0ludCgxKTw8QmlnSW50KDI0KSxQQVRIX1JFTU9WRV9ESVJFQ1RPUlk6QmlnSW50KDEpPDxCaWdJbnQoMjUpLFBBVEhfVU5MSU5LX0ZJTEU6QmlnSW50KDEpPDxCaWdJbnQoMjYpLFBPTExfRkRfUkVBRFdSSVRFOkJpZ0ludCgxKTw8QmlnSW50KDI3KSxTT0NLX1NIVVRET1dOOkJpZ0ludCgxKTw8QmlnSW50KDI4KSxTT0NLX0FDQ0VQVDpCaWdJbnQoMSk8PEJpZ0ludCgyOSl9LE49e0FUSU06MSxBVElNX05PVzoyLE1USU06NCxNVElNX05PVzo4fSxzdD17U1VCU0NSSVBUSU9OX0NMT0NLX0FCU1RJTUU6MX0saj02NCxYPTQ4LFo9MzI7dmFyIFA9KGU9PihlW2UuQ1VSPTBdPSJDVVIiLGVbZS5FTkQ9MV09IkVORCIsZVtlLlNFVD0yXT0iU0VUIixlKSkoUHx8e30pO2NsYXNzIFF7Y29uc3RydWN0b3IodCl7dSh0aGlzLCJmcyIpO3UodGhpcywiYXJncyIpO3UodGhpcywiZW52Iik7dSh0aGlzLCJzdGRpbiIpO3UodGhpcywic3Rkb3V0Iik7dSh0aGlzLCJzdGRlcnIiKTt1KHRoaXMsImRlYnVnIik7dSh0aGlzLCJpc1RUWSIpO3RoaXMuZnM9KHQ9PW51bGw/dm9pZCAwOnQuZnMpPz97fSx0aGlzLmFyZ3M9KHQ9PW51bGw/dm9pZCAwOnQuYXJncyk/P1tdLHRoaXMuZW52PSh0PT1udWxsP3ZvaWQgMDp0LmVudik/P3t9LHRoaXMuc3RkaW49KHQ9PW51bGw/dm9pZCAwOnQuc3RkaW4pPz8oKCk9Pm51bGwpLHRoaXMuc3Rkb3V0PSh0PT1udWxsP3ZvaWQgMDp0LnN0ZG91dCk/PygoKT0+e30pLHRoaXMuc3RkZXJyPSh0PT1udWxsP3ZvaWQgMDp0LnN0ZGVycik/PygoKT0+e30pLHRoaXMuZGVidWc9dD09bnVsbD92b2lkIDA6dC5kZWJ1Zyx0aGlzLmlzVFRZPSEhKHQhPW51bGwmJnQuaXNUVFkpfX1jbGFzcyBhdHtjb25zdHJ1Y3Rvcih0KXt1KHRoaXMsImZzIik7dSh0aGlzLCJuZXh0RkQiLDEwKTt1KHRoaXMsIm9wZW5NYXAiLG5ldyBNYXApO3RoaXMuZnM9ey4uLnR9LHRoaXMub3Blbk1hcC5zZXQoMyxuZXcgZCh0aGlzLmZzLCIvIikpfW9wZW5GaWxlKHQsaSxuKXtjb25zdCByPW5ldyBEKHQsbik7aSYmKHIuYnVmZmVyPW5ldyBVaW50OEFycmF5KG5ldyBBcnJheUJ1ZmZlcigxMDI0KSwwLDApKTtjb25zdCBhPXRoaXMubmV4dEZEO3JldHVybiB0aGlzLm9wZW5NYXAuc2V0KGEsciksdGhpcy5uZXh0RkQrKyxbcy5TVUNDRVNTLGFdfW9wZW5EaXIodCxpKXtjb25zdCBuPW5ldyBkKHQsaSkscj10aGlzLm5leHRGRDtyZXR1cm4gdGhpcy5vcGVuTWFwLnNldChyLG4pLHRoaXMubmV4dEZEKyssW3MuU1VDQ0VTUyxyXX1oYXNEaXIodCxpKXtyZXR1cm4gaT09PSIuIj8hMDp0LmNvbnRhaW5zRGlyZWN0b3J5KGkpfW9wZW4odCxpLG4scil7Y29uc3QgYT0hIShuJncuQ1JFQVQpLGY9ISEobiZ3LkRJUkVDVE9SWSksYz0hIShuJncuRVhDTCksbz0hIShuJncuVFJVTkMpLEU9dGhpcy5vcGVuTWFwLmdldCh0KTtpZighKEUgaW5zdGFuY2VvZiBkKSlyZXR1cm5bcy5FQkFERl07aWYoRS5jb250YWluc0ZpbGUoaSkpcmV0dXJuIGY/W3MuRU5PVERJUl06Yz9bcy5FRVhJU1RdOnRoaXMub3BlbkZpbGUoRS5nZXQoaSksbyxyKTtpZih0aGlzLmhhc0RpcihFLGkpKXtpZihpPT09Ii4iKXJldHVybiB0aGlzLm9wZW5EaXIodGhpcy5mcywiLyIpO2NvbnN0IGg9YC8ke2l9L2AsUz1PYmplY3QuZW50cmllcyh0aGlzLmZzKS5maWx0ZXIoKFtnXSk9Pmcuc3RhcnRzV2l0aChoKSk7cmV0dXJuIHRoaXMub3BlbkRpcihPYmplY3QuZnJvbUVudHJpZXMoUyksaCl9ZWxzZXtpZihhKXtjb25zdCBoPUUuZnVsbFBhdGgoaSk7cmV0dXJuIHRoaXMuZnNbaF09e3BhdGg6aCxtb2RlOiJiaW5hcnkiLGNvbnRlbnQ6bmV3IFVpbnQ4QXJyYXksdGltZXN0YW1wczp7YWNjZXNzOm5ldyBEYXRlLG1vZGlmaWNhdGlvbjpuZXcgRGF0ZSxjaGFuZ2U6bmV3IERhdGV9fSx0aGlzLm9wZW5GaWxlKHRoaXMuZnNbaF0sbyxyKX1yZXR1cm5bcy5FTk9UQ0FQQUJMRV19fWNsb3NlKHQpe2lmKCF0aGlzLm9wZW5NYXAuaGFzKHQpKXJldHVybiBzLkVCQURGO2NvbnN0IGk9dGhpcy5vcGVuTWFwLmdldCh0KTtyZXR1cm4gaSBpbnN0YW5jZW9mIEQmJmkuc3luYygpLHRoaXMub3Blbk1hcC5kZWxldGUodCkscy5TVUNDRVNTfXJlYWQodCxpKXtjb25zdCBuPXRoaXMub3Blbk1hcC5nZXQodCk7cmV0dXJuIW58fG4gaW5zdGFuY2VvZiBkP1tzLkVCQURGXTpbcy5TVUNDRVNTLG4ucmVhZChpKV19cHJlYWQodCxpLG4pe2NvbnN0IHI9dGhpcy5vcGVuTWFwLmdldCh0KTtyZXR1cm4hcnx8ciBpbnN0YW5jZW9mIGQ/W3MuRUJBREZdOltzLlNVQ0NFU1Msci5wcmVhZChpLG4pXX13cml0ZSh0LGkpe2NvbnN0IG49dGhpcy5vcGVuTWFwLmdldCh0KTtyZXR1cm4hbnx8biBpbnN0YW5jZW9mIGQ/cy5FQkFERjoobi53cml0ZShpKSxzLlNVQ0NFU1MpfXB3cml0ZSh0LGksbil7Y29uc3Qgcj10aGlzLm9wZW5NYXAuZ2V0KHQpO3JldHVybiFyfHxyIGluc3RhbmNlb2YgZD9zLkVCQURGOihyLnB3cml0ZShpLG4pLHMuU1VDQ0VTUyl9c3luYyh0KXtjb25zdCBpPXRoaXMub3Blbk1hcC5nZXQodCk7cmV0dXJuIWl8fGkgaW5zdGFuY2VvZiBkP3MuRUJBREY6KGkuc3luYygpLHMuU1VDQ0VTUyl9c2Vlayh0LGksbil7Y29uc3Qgcj10aGlzLm9wZW5NYXAuZ2V0KHQpO3JldHVybiFyfHxyIGluc3RhbmNlb2YgZD9bcy5FQkFERl06W3MuU1VDQ0VTUyxyLnNlZWsoaSxuKV19dGVsbCh0KXtjb25zdCBpPXRoaXMub3Blbk1hcC5nZXQodCk7cmV0dXJuIWl8fGkgaW5zdGFuY2VvZiBkP1tzLkVCQURGXTpbcy5TVUNDRVNTLGkudGVsbCgpXX1yZW51bWJlcih0LGkpe3JldHVybiF0aGlzLmV4aXN0cyh0KXx8IXRoaXMuZXhpc3RzKGkpP3MuRUJBREY6KHQ9PT1pfHwodGhpcy5jbG9zZShpKSx0aGlzLm9wZW5NYXAuc2V0KGksdGhpcy5vcGVuTWFwLmdldCh0KSkpLHMuU1VDQ0VTUyl9dW5saW5rKHQsaSl7Y29uc3Qgbj10aGlzLm9wZW5NYXAuZ2V0KHQpO2lmKCEobiBpbnN0YW5jZW9mIGQpKXJldHVybiBzLkVCQURGO2lmKCFuLmNvbnRhaW5zKGkpKXJldHVybiBzLkVOT0VOVDtmb3IoY29uc3QgciBvZiBPYmplY3Qua2V5cyh0aGlzLmZzKSkocj09PW4uZnVsbFBhdGgoaSl8fHIuc3RhcnRzV2l0aChgJHtuLmZ1bGxQYXRoKGkpfS9gKSkmJmRlbGV0ZSB0aGlzLmZzW3JdO3JldHVybiBzLlNVQ0NFU1N9cmVuYW1lKHQsaSxuLHIpe2NvbnN0IGE9dGhpcy5vcGVuTWFwLmdldCh0KSxmPXRoaXMub3Blbk1hcC5nZXQobik7aWYoIShhIGluc3RhbmNlb2YgZCl8fCEoZiBpbnN0YW5jZW9mIGQpKXJldHVybiBzLkVCQURGO2lmKCFhLmNvbnRhaW5zKGkpKXJldHVybiBzLkVOT0VOVDtpZihmLmNvbnRhaW5zKHIpKXJldHVybiBzLkVFWElTVDtjb25zdCBjPWEuZnVsbFBhdGgoaSksbz1mLmZ1bGxQYXRoKHIpO2Zvcihjb25zdCBFIG9mIE9iamVjdC5rZXlzKHRoaXMuZnMpKWlmKEUuc3RhcnRzV2l0aChjKSl7Y29uc3QgaD1FLnJlcGxhY2UoYyxvKTt0aGlzLmZzW2hdPXRoaXMuZnNbRV0sdGhpcy5mc1toXS5wYXRoPWgsZGVsZXRlIHRoaXMuZnNbRV19cmV0dXJuIHMuU1VDQ0VTU31saXN0KHQpe2NvbnN0IGk9dGhpcy5vcGVuTWFwLmdldCh0KTtyZXR1cm4gaSBpbnN0YW5jZW9mIGQ/W3MuU1VDQ0VTUyxpLmxpc3QoKV06W3MuRUJBREZdfXN0YXQodCl7Y29uc3QgaT10aGlzLm9wZW5NYXAuZ2V0KHQpO3JldHVybiBpIGluc3RhbmNlb2YgRD9bcy5TVUNDRVNTLGkuc3RhdCgpXTpbcy5FQkFERl19cGF0aFN0YXQodCxpKXtjb25zdCBuPXRoaXMub3Blbk1hcC5nZXQodCk7aWYoIShuIGluc3RhbmNlb2YgZCkpcmV0dXJuW3MuRUJBREZdO2lmKG4uY29udGFpbnNGaWxlKGkpKXtjb25zdCByPW4uZnVsbFBhdGgoaSksYT1uZXcgRCh0aGlzLmZzW3JdLDApLnN0YXQoKTtyZXR1cm5bcy5TVUNDRVNTLGFdfWVsc2UgaWYodGhpcy5oYXNEaXIobixpKSl7aWYoaT09PSIuIilyZXR1cm5bcy5TVUNDRVNTLG5ldyBkKHRoaXMuZnMsIi8iKS5zdGF0KCldO2NvbnN0IHI9YC8ke2l9L2AsYT1PYmplY3QuZW50cmllcyh0aGlzLmZzKS5maWx0ZXIoKFtjXSk9PmMuc3RhcnRzV2l0aChyKSksZj1uZXcgZChPYmplY3QuZnJvbUVudHJpZXMoYSkscikuc3RhdCgpO3JldHVybltzLlNVQ0NFU1MsZl19ZWxzZSByZXR1cm5bcy5FTk9UQ0FQQUJMRV19c2V0RmxhZ3ModCxpKXtjb25zdCBuPXRoaXMub3Blbk1hcC5nZXQodCk7cmV0dXJuIG4gaW5zdGFuY2VvZiBEPyhuLnNldEZsYWdzKGkpLHMuU1VDQ0VTUyk6cy5FQkFERn1zZXRTaXplKHQsaSl7Y29uc3Qgbj10aGlzLm9wZW5NYXAuZ2V0KHQpO3JldHVybiBuIGluc3RhbmNlb2YgRD8obi5zZXRTaXplKE51bWJlcihpKSkscy5TVUNDRVNTKTpzLkVCQURGfXNldEFjY2Vzc1RpbWUodCxpKXtjb25zdCBuPXRoaXMub3Blbk1hcC5nZXQodCk7cmV0dXJuIG4gaW5zdGFuY2VvZiBEPyhuLnNldEFjY2Vzc1RpbWUoaSkscy5TVUNDRVNTKTpzLkVCQURGfXNldE1vZGlmaWNhdGlvblRpbWUodCxpKXtjb25zdCBuPXRoaXMub3Blbk1hcC5nZXQodCk7cmV0dXJuIG4gaW5zdGFuY2VvZiBEPyhuLnNldE1vZGlmaWNhdGlvblRpbWUoaSkscy5TVUNDRVNTKTpzLkVCQURGfXBhdGhTZXRBY2Nlc3NUaW1lKHQsaSxuKXtjb25zdCByPXRoaXMub3Blbk1hcC5nZXQodCk7aWYoIShyIGluc3RhbmNlb2YgZCkpcmV0dXJuIHMuRUJBREY7Y29uc3QgYT1yLmdldChpKTtpZighYSlyZXR1cm4gcy5FTk9UQ0FQQUJMRTtjb25zdCBmPW5ldyBEKGEsMCk7cmV0dXJuIGYuc2V0QWNjZXNzVGltZShuKSxmLnN5bmMoKSxzLlNVQ0NFU1N9cGF0aFNldE1vZGlmaWNhdGlvblRpbWUodCxpLG4pe2NvbnN0IHI9dGhpcy5vcGVuTWFwLmdldCh0KTtpZighKHIgaW5zdGFuY2VvZiBkKSlyZXR1cm4gcy5FQkFERjtjb25zdCBhPXIuZ2V0KGkpO2lmKCFhKXJldHVybiBzLkVOT1RDQVBBQkxFO2NvbnN0IGY9bmV3IEQoYSwwKTtyZXR1cm4gZi5zZXRNb2RpZmljYXRpb25UaW1lKG4pLGYuc3luYygpLHMuU1VDQ0VTU31wYXRoQ3JlYXRlRGlyKHQsaSl7Y29uc3Qgbj10aGlzLm9wZW5NYXAuZ2V0KHQpO2lmKCEobiBpbnN0YW5jZW9mIGQpKXJldHVybiBzLkVCQURGO2lmKG4uY29udGFpbnMoaSkpcmV0dXJuIHMuRU5PVENBUEFCTEU7Y29uc3Qgcj1gJHtuLmZ1bGxQYXRoKGkpfS8ucnVubm9gO3JldHVybiB0aGlzLmZzW3JdPXtwYXRoOnIsdGltZXN0YW1wczp7YWNjZXNzOm5ldyBEYXRlLG1vZGlmaWNhdGlvbjpuZXcgRGF0ZSxjaGFuZ2U6bmV3IERhdGV9LG1vZGU6InN0cmluZyIsY29udGVudDoiIn0scy5TVUNDRVNTfWV4aXN0cyh0KXtyZXR1cm4gdGhpcy5vcGVuTWFwLmhhcyh0KX1maWxlVHlwZSh0KXtjb25zdCBpPXRoaXMub3Blbk1hcC5nZXQodCk7cmV0dXJuIGk/aSBpbnN0YW5jZW9mIEQ/QS5SRUdVTEFSX0ZJTEU6QS5ESVJFQ1RPUlk6QS5VTktOT1dOfWZpbGVGZGZsYWdzKHQpe2NvbnN0IGk9dGhpcy5vcGVuTWFwLmdldCh0KTtyZXR1cm4gaSBpbnN0YW5jZW9mIEQ/aS5mZGZsYWdzOjB9fWNsYXNzIER7Y29uc3RydWN0b3IodCxpKXt1KHRoaXMsImZpbGUiKTt1KHRoaXMsImJ1ZmZlciIpO3UodGhpcywiX29mZnNldCIsQmlnSW50KDApKTt1KHRoaXMsImlzRGlydHkiLCExKTt1KHRoaXMsImZkZmxhZ3MiKTt1KHRoaXMsImZsYWdBcHBlbmQiKTt1KHRoaXMsImZsYWdEU3luYyIpO3UodGhpcywiZmxhZ05vbkJsb2NrIik7dSh0aGlzLCJmbGFnUlN5bmMiKTt1KHRoaXMsImZsYWdTeW5jIik7aWYodGhpcy5maWxlPXQsdGhpcy5maWxlLm1vZGU9PT0ic3RyaW5nIil7Y29uc3Qgbj1uZXcgVGV4dEVuY29kZXI7dGhpcy5idWZmZXI9bi5lbmNvZGUodGhpcy5maWxlLmNvbnRlbnQpfWVsc2UgdGhpcy5idWZmZXI9dGhpcy5maWxlLmNvbnRlbnQ7dGhpcy5mZGZsYWdzPWksdGhpcy5mbGFnQXBwZW5kPSEhKGkmTy5BUFBFTkQpLHRoaXMuZmxhZ0RTeW5jPSEhKGkmTy5EU1lOQyksdGhpcy5mbGFnTm9uQmxvY2s9ISEoaSZPLk5PTkJMT0NLKSx0aGlzLmZsYWdSU3luYz0hIShpJk8uUlNZTkMpLHRoaXMuZmxhZ1N5bmM9ISEoaSZPLlNZTkMpfWdldCBvZmZzZXQoKXtyZXR1cm4gTnVtYmVyKHRoaXMuX29mZnNldCl9cmVhZCh0KXtjb25zdCBpPXRoaXMuYnVmZmVyLnN1YmFycmF5KHRoaXMub2Zmc2V0LHRoaXMub2Zmc2V0K3QpO3JldHVybiB0aGlzLl9vZmZzZXQrPUJpZ0ludChpLmxlbmd0aCksaX1wcmVhZCh0LGkpe3JldHVybiB0aGlzLmJ1ZmZlci5zdWJhcnJheShpLGkrdCl9d3JpdGUodCl7aWYodGhpcy5pc0RpcnR5PSEwLHRoaXMuZmxhZ0FwcGVuZCl7Y29uc3QgaT10aGlzLmJ1ZmZlci5sZW5ndGg7dGhpcy5yZXNpemUoaSt0LmJ5dGVMZW5ndGgpLHRoaXMuYnVmZmVyLnNldCh0LGkpfWVsc2V7Y29uc3QgaT1NYXRoLm1heCh0aGlzLm9mZnNldCt0LmJ5dGVMZW5ndGgsdGhpcy5idWZmZXIuYnl0ZUxlbmd0aCk7dGhpcy5yZXNpemUoaSksdGhpcy5idWZmZXIuc2V0KHQsdGhpcy5vZmZzZXQpLHRoaXMuX29mZnNldCs9QmlnSW50KHQuYnl0ZUxlbmd0aCl9KHRoaXMuZmxhZ0RTeW5jfHx0aGlzLmZsYWdTeW5jKSYmdGhpcy5zeW5jKCl9cHdyaXRlKHQsaSl7aWYodGhpcy5pc0RpcnR5PSEwLHRoaXMuZmxhZ0FwcGVuZCl7Y29uc3Qgbj10aGlzLmJ1ZmZlci5sZW5ndGg7dGhpcy5yZXNpemUobit0LmJ5dGVMZW5ndGgpLHRoaXMuYnVmZmVyLnNldCh0LG4pfWVsc2V7Y29uc3Qgbj1NYXRoLm1heChpK3QuYnl0ZUxlbmd0aCx0aGlzLmJ1ZmZlci5ieXRlTGVuZ3RoKTt0aGlzLnJlc2l6ZShuKSx0aGlzLmJ1ZmZlci5zZXQodCxpKX0odGhpcy5mbGFnRFN5bmN8fHRoaXMuZmxhZ1N5bmMpJiZ0aGlzLnN5bmMoKX1zeW5jKCl7aWYoIXRoaXMuaXNEaXJ0eSlyZXR1cm47aWYodGhpcy5pc0RpcnR5PSExLHRoaXMuZmlsZS5tb2RlPT09ImJpbmFyeSIpe3RoaXMuZmlsZS5jb250ZW50PW5ldyBVaW50OEFycmF5KHRoaXMuYnVmZmVyKTtyZXR1cm59Y29uc3QgdD1uZXcgVGV4dERlY29kZXI7dGhpcy5maWxlLmNvbnRlbnQ9dC5kZWNvZGUodGhpcy5idWZmZXIpfXNlZWsodCxpKXtzd2l0Y2goaSl7Y2FzZSBDLlNFVDp0aGlzLl9vZmZzZXQ9dDticmVhaztjYXNlIEMuQ1VSOnRoaXMuX29mZnNldCs9dDticmVhaztjYXNlIEMuRU5EOnRoaXMuX29mZnNldD1CaWdJbnQodGhpcy5idWZmZXIubGVuZ3RoKSt0O2JyZWFrfXJldHVybiB0aGlzLl9vZmZzZXR9dGVsbCgpe3JldHVybiB0aGlzLl9vZmZzZXR9c3RhdCgpe3JldHVybntwYXRoOnRoaXMuZmlsZS5wYXRoLHRpbWVzdGFtcHM6dGhpcy5maWxlLnRpbWVzdGFtcHMsdHlwZTpBLlJFR1VMQVJfRklMRSxieXRlTGVuZ3RoOnRoaXMuYnVmZmVyLmxlbmd0aH19c2V0RmxhZ3ModCl7dGhpcy5mZGZsYWdzPXR9c2V0U2l6ZSh0KXt0aGlzLnJlc2l6ZSh0KX1zZXRBY2Nlc3NUaW1lKHQpe3RoaXMuZmlsZS50aW1lc3RhbXBzLmFjY2Vzcz10fXNldE1vZGlmaWNhdGlvblRpbWUodCl7dGhpcy5maWxlLnRpbWVzdGFtcHMubW9kaWZpY2F0aW9uPXR9cmVzaXplKHQpe2lmKHQ8PXRoaXMuYnVmZmVyLmJ1ZmZlci5ieXRlTGVuZ3RoKXt0aGlzLmJ1ZmZlcj1uZXcgVWludDhBcnJheSh0aGlzLmJ1ZmZlci5idWZmZXIsMCx0KTtyZXR1cm59bGV0IGk7dGhpcy5idWZmZXIuYnVmZmVyLmJ5dGVMZW5ndGg9PT0wP2k9bmV3IEFycmF5QnVmZmVyKHQ8MTAyND8xMDI0OnQqMik6dD50aGlzLmJ1ZmZlci5idWZmZXIuYnl0ZUxlbmd0aCoyP2k9bmV3IEFycmF5QnVmZmVyKHQqMik6aT1uZXcgQXJyYXlCdWZmZXIodGhpcy5idWZmZXIuYnVmZmVyLmJ5dGVMZW5ndGgqMik7Y29uc3Qgbj1uZXcgVWludDhBcnJheShpLDAsdCk7bi5zZXQodGhpcy5idWZmZXIpLHRoaXMuYnVmZmVyPW59fWZ1bmN0aW9uIHYoZSx0KXtjb25zdCBpPXQucmVwbGFjZSgvWy9cLVxcXiQqKz8uKCl8W1xde31dL2csIlxcJCYiKSxuPW5ldyBSZWdFeHAoYF4ke2l9YCk7cmV0dXJuIGUucmVwbGFjZShuLCIiKX1jbGFzcyBke2NvbnN0cnVjdG9yKHQsaSl7dSh0aGlzLCJkaXIiKTt1KHRoaXMsInByZWZpeCIpO3RoaXMuZGlyPXQsdGhpcy5wcmVmaXg9aX1jb250YWluc0ZpbGUodCl7Zm9yKGNvbnN0IGkgb2YgT2JqZWN0LmtleXModGhpcy5kaXIpKWlmKHYoaSx0aGlzLnByZWZpeCk9PT10KXJldHVybiEwO3JldHVybiExfWNvbnRhaW5zRGlyZWN0b3J5KHQpe2Zvcihjb25zdCBpIG9mIE9iamVjdC5rZXlzKHRoaXMuZGlyKSlpZih2KGksdGhpcy5wcmVmaXgpLnN0YXJ0c1dpdGgoYCR7dH0vYCkpcmV0dXJuITA7cmV0dXJuITF9Y29udGFpbnModCl7Zm9yKGNvbnN0IGkgb2YgT2JqZWN0LmtleXModGhpcy5kaXIpKXtjb25zdCBuPXYoaSx0aGlzLnByZWZpeCk7aWYobj09PXR8fG4uc3RhcnRzV2l0aChgJHt0fS9gKSlyZXR1cm4hMH1yZXR1cm4hMX1nZXQodCl7cmV0dXJuIHRoaXMuZGlyW3RoaXMuZnVsbFBhdGgodCldfWZ1bGxQYXRoKHQpe3JldHVybmAke3RoaXMucHJlZml4fSR7dH1gfWxpc3QoKXtjb25zdCB0PVtdLGk9bmV3IFNldDtmb3IoY29uc3QgbiBvZiBPYmplY3Qua2V5cyh0aGlzLmRpcikpe2NvbnN0IHI9dihuLHRoaXMucHJlZml4KTtpZihyLmluY2x1ZGVzKCIvIikpe2NvbnN0IGE9ci5zcGxpdCgiLyIpWzBdO2lmKGkuaGFzKGEpKWNvbnRpbnVlO2kuYWRkKGEpLHQucHVzaCh7bmFtZTphLHR5cGU6QS5ESVJFQ1RPUll9KX1lbHNlIHQucHVzaCh7bmFtZTpyLHR5cGU6QS5SRUdVTEFSX0ZJTEV9KX1yZXR1cm4gdH1zdGF0KCl7cmV0dXJue3BhdGg6dGhpcy5wcmVmaXgsdGltZXN0YW1wczp7YWNjZXNzOm5ldyBEYXRlLG1vZGlmaWNhdGlvbjpuZXcgRGF0ZSxjaGFuZ2U6bmV3IERhdGV9LHR5cGU6QS5ESVJFQ1RPUlksYnl0ZUxlbmd0aDowfX19bGV0IFY9W107ZnVuY3Rpb24gbChlKXtWLnB1c2goZSl9ZnVuY3Rpb24gZnQoKXtjb25zdCBlPVY7cmV0dXJuIFY9W10sZX1jbGFzcyBIIGV4dGVuZHMgRXJyb3J7fWNsYXNzIEogZXh0ZW5kcyBFcnJvcnt9Y2xhc3Mga3tjb25zdHJ1Y3Rvcih0KXt1KHRoaXMsImluc3RhbmNlIik7dSh0aGlzLCJtb2R1bGUiKTt1KHRoaXMsIm1lbW9yeSIpO3UodGhpcywiY29udGV4dCIpO3UodGhpcywiZHJpdmUiKTt1KHRoaXMsImhhc0JlZW5Jbml0aWFsaXplZCIsITEpO3RoaXMuY29udGV4dD1uZXcgUSh0KSx0aGlzLmRyaXZlPW5ldyBhdCh0aGlzLmNvbnRleHQuZnMpfXN0YXRpYyBhc3luYyBzdGFydCh0LGk9e30pe2NvbnN0IG49bmV3IGsoaSkscj1hd2FpdCBXZWJBc3NlbWJseS5pbnN0YW50aWF0ZVN0cmVhbWluZyh0LG4uZ2V0SW1wb3J0T2JqZWN0KCkpO3JldHVybiBuLnN0YXJ0KHIpfXN0YXRpYyBhc3luYyBpbml0aWFsaXplKHQsaT17fSl7Y29uc3Qgbj1uZXcgayhpKSxyPWF3YWl0IFdlYkFzc2VtYmx5Lmluc3RhbnRpYXRlU3RyZWFtaW5nKHQsbi5nZXRJbXBvcnRPYmplY3QoKSk7cmV0dXJuIG4uaW5pdGlhbGl6ZShyKSxyLmluc3RhbmNlLmV4cG9ydHN9Z2V0SW1wb3J0T2JqZWN0KCl7cmV0dXJue3dhc2lfc25hcHNob3RfcHJldmlldzE6dGhpcy5nZXRJbXBvcnRzKCJwcmV2aWV3MSIsdGhpcy5jb250ZXh0LmRlYnVnKSx3YXNpX3Vuc3RhYmxlOnRoaXMuZ2V0SW1wb3J0cygidW5zdGFibGUiLHRoaXMuY29udGV4dC5kZWJ1Zyl9fXN0YXJ0KHQsaT17fSl7aWYodGhpcy5oYXNCZWVuSW5pdGlhbGl6ZWQpdGhyb3cgbmV3IEooIlRoaXMgaW5zdGFuY2UgaGFzIGFscmVhZHkgYmVlbiBpbml0aWFsaXplZCIpO2lmKHRoaXMuaGFzQmVlbkluaXRpYWxpemVkPSEwLHRoaXMuaW5zdGFuY2U9dC5pbnN0YW5jZSx0aGlzLm1vZHVsZT10Lm1vZHVsZSx0aGlzLm1lbW9yeT1pLm1lbW9yeT8/dGhpcy5pbnN0YW5jZS5leHBvcnRzLm1lbW9yeSwiX2luaXRpYWxpemUiaW4gdGhpcy5pbnN0YW5jZS5leHBvcnRzKXRocm93IG5ldyBIKCJXZWJBc3NlbWJseSBpbnN0YW5jZSBpcyBhIHJlYWN0b3IgYW5kIHNob3VsZCBiZSBzdGFydGVkIHdpdGggaW5pdGlhbGl6ZS4iKTtpZighKCJfc3RhcnQiaW4gdGhpcy5pbnN0YW5jZS5leHBvcnRzKSl0aHJvdyBuZXcgSCgiV2ViQXNzZW1ibHkgaW5zdGFuY2UgZG9lc24ndCBleHBvcnQgX3N0YXJ0LCBpdCBtYXkgbm90IGJlIFdBU0kgb3IgbWF5IGJlIGEgUmVhY3Rvci4iKTtjb25zdCBuPXRoaXMuaW5zdGFuY2UuZXhwb3J0cy5fc3RhcnQ7dHJ5e24oKX1jYXRjaChyKXtpZihyIGluc3RhbmNlb2YgcSlyZXR1cm57ZXhpdENvZGU6ci5jb2RlLGZzOnRoaXMuZHJpdmUuZnN9O2lmKHIgaW5zdGFuY2VvZiBXZWJBc3NlbWJseS5SdW50aW1lRXJyb3IpcmV0dXJue2V4aXRDb2RlOjEzNCxmczp0aGlzLmRyaXZlLmZzfTt0aHJvdyByfXJldHVybntleGl0Q29kZTowLGZzOnRoaXMuZHJpdmUuZnN9fWluaXRpYWxpemUodCxpPXt9KXtpZih0aGlzLmhhc0JlZW5Jbml0aWFsaXplZCl0aHJvdyBuZXcgSigiVGhpcyBpbnN0YW5jZSBoYXMgYWxyZWFkeSBiZWVuIGluaXRpYWxpemVkIik7aWYodGhpcy5oYXNCZWVuSW5pdGlhbGl6ZWQ9ITAsdGhpcy5pbnN0YW5jZT10Lmluc3RhbmNlLHRoaXMubW9kdWxlPXQubW9kdWxlLHRoaXMubWVtb3J5PWkubWVtb3J5Pz90aGlzLmluc3RhbmNlLmV4cG9ydHMubWVtb3J5LCJfc3RhcnQiaW4gdGhpcy5pbnN0YW5jZS5leHBvcnRzKXRocm93IG5ldyBIKCJXZWJBc3NlbWJseSBpbnN0YW5jZSBpcyBhIGNvbW1hbmQgYW5kIHNob3VsZCBiZSBzdGFydGVkIHdpdGggc3RhcnQuIik7aWYoIl9pbml0aWFsaXplImluIHRoaXMuaW5zdGFuY2UuZXhwb3J0cyl7Y29uc3Qgbj10aGlzLmluc3RhbmNlLmV4cG9ydHMuX2luaXRpYWxpemU7bigpfX1nZXRJbXBvcnRzKHQsaSl7Y29uc3Qgbj17YXJnc19nZXQ6dGhpcy5hcmdzX2dldC5iaW5kKHRoaXMpLGFyZ3Nfc2l6ZXNfZ2V0OnRoaXMuYXJnc19zaXplc19nZXQuYmluZCh0aGlzKSxjbG9ja19yZXNfZ2V0OnRoaXMuY2xvY2tfcmVzX2dldC5iaW5kKHRoaXMpLGNsb2NrX3RpbWVfZ2V0OnRoaXMuY2xvY2tfdGltZV9nZXQuYmluZCh0aGlzKSxlbnZpcm9uX2dldDp0aGlzLmVudmlyb25fZ2V0LmJpbmQodGhpcyksZW52aXJvbl9zaXplc19nZXQ6dGhpcy5lbnZpcm9uX3NpemVzX2dldC5iaW5kKHRoaXMpLHByb2NfZXhpdDp0aGlzLnByb2NfZXhpdC5iaW5kKHRoaXMpLHJhbmRvbV9nZXQ6dGhpcy5yYW5kb21fZ2V0LmJpbmQodGhpcyksc2NoZWRfeWllbGQ6dGhpcy5zY2hlZF95aWVsZC5iaW5kKHRoaXMpLGZkX2FkdmlzZTp0aGlzLmZkX2FkdmlzZS5iaW5kKHRoaXMpLGZkX2FsbG9jYXRlOnRoaXMuZmRfYWxsb2NhdGUuYmluZCh0aGlzKSxmZF9jbG9zZTp0aGlzLmZkX2Nsb3NlLmJpbmQodGhpcyksZmRfZGF0YXN5bmM6dGhpcy5mZF9kYXRhc3luYy5iaW5kKHRoaXMpLGZkX2Zkc3RhdF9nZXQ6dGhpcy5mZF9mZHN0YXRfZ2V0LmJpbmQodGhpcyksZmRfZmRzdGF0X3NldF9mbGFnczp0aGlzLmZkX2Zkc3RhdF9zZXRfZmxhZ3MuYmluZCh0aGlzKSxmZF9mZHN0YXRfc2V0X3JpZ2h0czp0aGlzLmZkX2Zkc3RhdF9zZXRfcmlnaHRzLmJpbmQodGhpcyksZmRfZmlsZXN0YXRfZ2V0OnRoaXMuZmRfZmlsZXN0YXRfZ2V0LmJpbmQodGhpcyksZmRfZmlsZXN0YXRfc2V0X3NpemU6dGhpcy5mZF9maWxlc3RhdF9zZXRfc2l6ZS5iaW5kKHRoaXMpLGZkX2ZpbGVzdGF0X3NldF90aW1lczp0aGlzLmZkX2ZpbGVzdGF0X3NldF90aW1lcy5iaW5kKHRoaXMpLGZkX3ByZWFkOnRoaXMuZmRfcHJlYWQuYmluZCh0aGlzKSxmZF9wcmVzdGF0X2Rpcl9uYW1lOnRoaXMuZmRfcHJlc3RhdF9kaXJfbmFtZS5iaW5kKHRoaXMpLGZkX3ByZXN0YXRfZ2V0OnRoaXMuZmRfcHJlc3RhdF9nZXQuYmluZCh0aGlzKSxmZF9wd3JpdGU6dGhpcy5mZF9wd3JpdGUuYmluZCh0aGlzKSxmZF9yZWFkOnRoaXMuZmRfcmVhZC5iaW5kKHRoaXMpLGZkX3JlYWRkaXI6dGhpcy5mZF9yZWFkZGlyLmJpbmQodGhpcyksZmRfcmVudW1iZXI6dGhpcy5mZF9yZW51bWJlci5iaW5kKHRoaXMpLGZkX3NlZWs6dGhpcy5mZF9zZWVrLmJpbmQodGhpcyksZmRfc3luYzp0aGlzLmZkX3N5bmMuYmluZCh0aGlzKSxmZF90ZWxsOnRoaXMuZmRfdGVsbC5iaW5kKHRoaXMpLGZkX3dyaXRlOnRoaXMuZmRfd3JpdGUuYmluZCh0aGlzKSxwYXRoX2ZpbGVzdGF0X2dldDp0aGlzLnBhdGhfZmlsZXN0YXRfZ2V0LmJpbmQodGhpcykscGF0aF9maWxlc3RhdF9zZXRfdGltZXM6dGhpcy5wYXRoX2ZpbGVzdGF0X3NldF90aW1lcy5iaW5kKHRoaXMpLHBhdGhfb3Blbjp0aGlzLnBhdGhfb3Blbi5iaW5kKHRoaXMpLHBhdGhfcmVuYW1lOnRoaXMucGF0aF9yZW5hbWUuYmluZCh0aGlzKSxwYXRoX3VubGlua19maWxlOnRoaXMucGF0aF91bmxpbmtfZmlsZS5iaW5kKHRoaXMpLHBhdGhfY3JlYXRlX2RpcmVjdG9yeTp0aGlzLnBhdGhfY3JlYXRlX2RpcmVjdG9yeS5iaW5kKHRoaXMpLHBhdGhfbGluazp0aGlzLnBhdGhfbGluay5iaW5kKHRoaXMpLHBhdGhfcmVhZGxpbms6dGhpcy5wYXRoX3JlYWRsaW5rLmJpbmQodGhpcykscGF0aF9yZW1vdmVfZGlyZWN0b3J5OnRoaXMucGF0aF9yZW1vdmVfZGlyZWN0b3J5LmJpbmQodGhpcykscGF0aF9zeW1saW5rOnRoaXMucGF0aF9zeW1saW5rLmJpbmQodGhpcykscG9sbF9vbmVvZmY6dGhpcy5wb2xsX29uZW9mZi5iaW5kKHRoaXMpLHByb2NfcmFpc2U6dGhpcy5wcm9jX3JhaXNlLmJpbmQodGhpcyksc29ja19hY2NlcHQ6dGhpcy5zb2NrX2FjY2VwdC5iaW5kKHRoaXMpLHNvY2tfcmVjdjp0aGlzLnNvY2tfcmVjdi5iaW5kKHRoaXMpLHNvY2tfc2VuZDp0aGlzLnNvY2tfc2VuZC5iaW5kKHRoaXMpLHNvY2tfc2h1dGRvd246dGhpcy5zb2NrX3NodXRkb3duLmJpbmQodGhpcyksc29ja19vcGVuOnRoaXMuc29ja19vcGVuLmJpbmQodGhpcyksc29ja19saXN0ZW46dGhpcy5zb2NrX2xpc3Rlbi5iaW5kKHRoaXMpLHNvY2tfY29ubmVjdDp0aGlzLnNvY2tfY29ubmVjdC5iaW5kKHRoaXMpLHNvY2tfc2V0c29ja29wdDp0aGlzLnNvY2tfc2V0c29ja29wdC5iaW5kKHRoaXMpLHNvY2tfYmluZDp0aGlzLnNvY2tfYmluZC5iaW5kKHRoaXMpLHNvY2tfZ2V0bG9jYWxhZGRyOnRoaXMuc29ja19nZXRsb2NhbGFkZHIuYmluZCh0aGlzKSxzb2NrX2dldHBlZXJhZGRyOnRoaXMuc29ja19nZXRwZWVyYWRkci5iaW5kKHRoaXMpLHNvY2tfZ2V0YWRkcmluZm86dGhpcy5zb2NrX2dldGFkZHJpbmZvLmJpbmQodGhpcyl9O3Q9PT0idW5zdGFibGUiJiYobi5wYXRoX2ZpbGVzdGF0X2dldD10aGlzLnVuc3RhYmxlX3BhdGhfZmlsZXN0YXRfZ2V0LmJpbmQodGhpcyksbi5mZF9maWxlc3RhdF9nZXQ9dGhpcy51bnN0YWJsZV9mZF9maWxlc3RhdF9nZXQuYmluZCh0aGlzKSxuLmZkX3NlZWs9dGhpcy51bnN0YWJsZV9mZF9zZWVrLmJpbmQodGhpcykpO2Zvcihjb25zdFtyLGFdb2YgT2JqZWN0LmVudHJpZXMobikpbltyXT1mdW5jdGlvbigpe2xldCBmPWEuYXBwbHkodGhpcyxhcmd1bWVudHMpO2lmKGkpe2NvbnN0IGM9ZnQoKTtmPWkocixbLi4uYXJndW1lbnRzXSxmLGMpPz9mfXJldHVybiBmfTtyZXR1cm4gbn1nZXQgZW52QXJyYXkoKXtyZXR1cm4gT2JqZWN0LmVudHJpZXModGhpcy5jb250ZXh0LmVudikubWFwKChbdCxpXSk9PmAke3R9PSR7aX1gKX1hcmdzX2dldCh0LGkpe2NvbnN0IG49bmV3IERhdGFWaWV3KHRoaXMubWVtb3J5LmJ1ZmZlcik7Zm9yKGNvbnN0IHIgb2YgdGhpcy5jb250ZXh0LmFyZ3Mpe24uc2V0VWludDMyKHQsaSwhMCksdCs9NDtjb25zdCBhPW5ldyBUZXh0RW5jb2RlcigpLmVuY29kZShgJHtyfVwwYCk7bmV3IFVpbnQ4QXJyYXkodGhpcy5tZW1vcnkuYnVmZmVyLGksYS5ieXRlTGVuZ3RoKS5zZXQoYSksaSs9YS5ieXRlTGVuZ3RofXJldHVybiBzLlNVQ0NFU1N9YXJnc19zaXplc19nZXQodCxpKXtjb25zdCBuPXRoaXMuY29udGV4dC5hcmdzLHI9bi5yZWR1Y2UoKGYsYyk9PmYrbmV3IFRleHRFbmNvZGVyKCkuZW5jb2RlKGAke2N9XDBgKS5ieXRlTGVuZ3RoLDApLGE9bmV3IERhdGFWaWV3KHRoaXMubWVtb3J5LmJ1ZmZlcik7cmV0dXJuIGEuc2V0VWludDMyKHQsbi5sZW5ndGgsITApLGEuc2V0VWludDMyKGksciwhMCkscy5TVUNDRVNTfWNsb2NrX3Jlc19nZXQodCxpKXtzd2l0Y2godCl7Y2FzZSBiLlJFQUxUSU1FOmNhc2UgYi5NT05PVE9OSUM6Y2FzZSBiLlBST0NFU1NfQ1BVVElNRV9JRDpjYXNlIGIuVEhSRUFEX0NQVVRJTUVfSUQ6cmV0dXJuIG5ldyBEYXRhVmlldyh0aGlzLm1lbW9yeS5idWZmZXIpLnNldEJpZ1VpbnQ2NChpLEJpZ0ludCgxZTYpLCEwKSxzLlNVQ0NFU1N9cmV0dXJuIHMuRUlOVkFMfWNsb2NrX3RpbWVfZ2V0KHQsaSxuKXtzd2l0Y2godCl7Y2FzZSBiLlJFQUxUSU1FOmNhc2UgYi5NT05PVE9OSUM6Y2FzZSBiLlBST0NFU1NfQ1BVVElNRV9JRDpjYXNlIGIuVEhSRUFEX0NQVVRJTUVfSUQ6cmV0dXJuIG5ldyBEYXRhVmlldyh0aGlzLm1lbW9yeS5idWZmZXIpLnNldEJpZ1VpbnQ2NChuLFUobmV3IERhdGUpLCEwKSxzLlNVQ0NFU1N9cmV0dXJuIHMuRUlOVkFMfWVudmlyb25fZ2V0KHQsaSl7Y29uc3Qgbj1uZXcgRGF0YVZpZXcodGhpcy5tZW1vcnkuYnVmZmVyKTtmb3IoY29uc3QgciBvZiB0aGlzLmVudkFycmF5KXtuLnNldFVpbnQzMih0LGksITApLHQrPTQ7Y29uc3QgYT1uZXcgVGV4dEVuY29kZXIoKS5lbmNvZGUoYCR7cn1cMGApO25ldyBVaW50OEFycmF5KHRoaXMubWVtb3J5LmJ1ZmZlcixpLGEuYnl0ZUxlbmd0aCkuc2V0KGEpLGkrPWEuYnl0ZUxlbmd0aH1yZXR1cm4gcy5TVUNDRVNTfWVudmlyb25fc2l6ZXNfZ2V0KHQsaSl7Y29uc3Qgbj10aGlzLmVudkFycmF5LnJlZHVjZSgoYSxmKT0+YStuZXcgVGV4dEVuY29kZXIoKS5lbmNvZGUoYCR7Zn1cMGApLmJ5dGVMZW5ndGgsMCkscj1uZXcgRGF0YVZpZXcodGhpcy5tZW1vcnkuYnVmZmVyKTtyZXR1cm4gci5zZXRVaW50MzIodCx0aGlzLmVudkFycmF5Lmxlbmd0aCwhMCksci5zZXRVaW50MzIoaSxuLCEwKSxzLlNVQ0NFU1N9cHJvY19leGl0KHQpe3Rocm93IG5ldyBxKHQpfXJhbmRvbV9nZXQodCxpKXtjb25zdCBuPW5ldyBVaW50OEFycmF5KHRoaXMubWVtb3J5LmJ1ZmZlcix0LGkpO3JldHVybiBnbG9iYWxUaGlzLmNyeXB0by5nZXRSYW5kb21WYWx1ZXMobikscy5TVUNDRVNTfXNjaGVkX3lpZWxkKCl7cmV0dXJuIHMuU1VDQ0VTU31mZF9yZWFkKHQsaSxuLHIpe2lmKHQ9PT0xfHx0PT09MilyZXR1cm4gcy5FTk9UU1VQO2NvbnN0IGE9bmV3IERhdGFWaWV3KHRoaXMubWVtb3J5LmJ1ZmZlciksZj14KGEsaSxuKSxjPW5ldyBUZXh0RW5jb2RlcjtsZXQgbz0wLEU9cy5TVUNDRVNTO2Zvcihjb25zdCBoIG9mIGYpe2xldCBTO2lmKHQ9PT0wKXtjb25zdCBUPXRoaXMuY29udGV4dC5zdGRpbihoLmJ5dGVMZW5ndGgpO2lmKCFUKWJyZWFrO1M9Yy5lbmNvZGUoVCl9ZWxzZXtjb25zdFtULExdPXRoaXMuZHJpdmUucmVhZCh0LGguYnl0ZUxlbmd0aCk7aWYoVCl7RT1UO2JyZWFrfWVsc2UgUz1MfWNvbnN0IGc9TWF0aC5taW4oaC5ieXRlTGVuZ3RoLFMuYnl0ZUxlbmd0aCk7aC5zZXQoUy5zdWJhcnJheSgwLGcpKSxvKz1nfXJldHVybiBsKHtieXRlc1JlYWQ6b30pLGEuc2V0VWludDMyKHIsbywhMCksRX1mZF93cml0ZSh0LGksbixyKXtpZih0PT09MClyZXR1cm4gcy5FTk9UU1VQO2NvbnN0IGE9bmV3IERhdGFWaWV3KHRoaXMubWVtb3J5LmJ1ZmZlciksZj14KGEsaSxuKSxjPW5ldyBUZXh0RGVjb2RlcjtsZXQgbz0wLEU9cy5TVUNDRVNTO2Zvcihjb25zdCBoIG9mIGYpaWYoaC5ieXRlTGVuZ3RoIT09MCl7aWYodD09PTF8fHQ9PT0yKXtjb25zdCBTPXQ9PT0xP3RoaXMuY29udGV4dC5zdGRvdXQ6dGhpcy5jb250ZXh0LnN0ZGVycixnPWMuZGVjb2RlKGgpO1MoZyksbCh7b3V0cHV0Omd9KX1lbHNlIGlmKEU9dGhpcy5kcml2ZS53cml0ZSh0LGgpLEUhPXMuU1VDQ0VTUylicmVhaztvKz1oLmJ5dGVMZW5ndGh9cmV0dXJuIGEuc2V0VWludDMyKHIsbywhMCksRX1mZF9hZHZpc2UoKXtyZXR1cm4gcy5TVUNDRVNTfWZkX2FsbG9jYXRlKHQsaSxuKXtyZXR1cm4gdGhpcy5kcml2ZS5wd3JpdGUodCxuZXcgVWludDhBcnJheShOdW1iZXIobikpLE51bWJlcihpKSl9ZmRfY2xvc2UodCl7cmV0dXJuIHRoaXMuZHJpdmUuY2xvc2UodCl9ZmRfZGF0YXN5bmModCl7cmV0dXJuIHRoaXMuZHJpdmUuc3luYyh0KX1mZF9mZHN0YXRfZ2V0KHQsaSl7aWYodDwzKXtsZXQgYztpZih0aGlzLmNvbnRleHQuaXNUVFkpe2NvbnN0IEU9Ul5fLkZEX1NFRUteXy5GRF9URUxMO2M9SyhBLkNIQVJBQ1RFUl9ERVZJQ0UsMCxFKX1lbHNlIGM9SyhBLkNIQVJBQ1RFUl9ERVZJQ0UsMCk7cmV0dXJuIG5ldyBVaW50OEFycmF5KHRoaXMubWVtb3J5LmJ1ZmZlcixpLGMuYnl0ZUxlbmd0aCkuc2V0KGMpLHMuU1VDQ0VTU31pZighdGhpcy5kcml2ZS5leGlzdHModCkpcmV0dXJuIHMuRUJBREY7Y29uc3Qgbj10aGlzLmRyaXZlLmZpbGVUeXBlKHQpLHI9dGhpcy5kcml2ZS5maWxlRmRmbGFncyh0KSxhPUsobixyKTtyZXR1cm4gbmV3IFVpbnQ4QXJyYXkodGhpcy5tZW1vcnkuYnVmZmVyLGksYS5ieXRlTGVuZ3RoKS5zZXQoYSkscy5TVUNDRVNTfWZkX2Zkc3RhdF9zZXRfZmxhZ3ModCxpKXtyZXR1cm4gdGhpcy5kcml2ZS5zZXRGbGFncyh0LGkpfWZkX2Zkc3RhdF9zZXRfcmlnaHRzKCl7cmV0dXJuIHMuU1VDQ0VTU31mZF9maWxlc3RhdF9nZXQodCxpKXtyZXR1cm4gdGhpcy5zaGFyZWRfZmRfZmlsZXN0YXRfZ2V0KHQsaSwicHJldmlldzEiKX11bnN0YWJsZV9mZF9maWxlc3RhdF9nZXQodCxpKXtyZXR1cm4gdGhpcy5zaGFyZWRfZmRfZmlsZXN0YXRfZ2V0KHQsaSwidW5zdGFibGUiKX1zaGFyZWRfZmRfZmlsZXN0YXRfZ2V0KHQsaSxuKXtjb25zdCByPW49PT0idW5zdGFibGUiP2V0OnR0O2lmKHQ8Myl7bGV0IEU7c3dpdGNoKHQpe2Nhc2UgMDpFPSIvZGV2L3N0ZGluIjticmVhaztjYXNlIDE6RT0iL2Rldi9zdGRvdXQiO2JyZWFrO2Nhc2UgMjpFPSIvZGV2L3N0ZGVyciI7YnJlYWs7ZGVmYXVsdDpFPSIvZGV2L3VuZGVmaW5lZCI7YnJlYWt9Y29uc3QgaD1yKHtwYXRoOkUsYnl0ZUxlbmd0aDowLHRpbWVzdGFtcHM6e2FjY2VzczpuZXcgRGF0ZSxtb2RpZmljYXRpb246bmV3IERhdGUsY2hhbmdlOm5ldyBEYXRlfSx0eXBlOkEuQ0hBUkFDVEVSX0RFVklDRX0pO3JldHVybiBuZXcgVWludDhBcnJheSh0aGlzLm1lbW9yeS5idWZmZXIsaSxoLmJ5dGVMZW5ndGgpLnNldChoKSxzLlNVQ0NFU1N9Y29uc3RbYSxmXT10aGlzLmRyaXZlLnN0YXQodCk7aWYoYSE9cy5TVUNDRVNTKXJldHVybiBhO2woe3Jlc29sdmVkUGF0aDpmLnBhdGgsc3RhdDpmfSk7Y29uc3QgYz1yKGYpO3JldHVybiBuZXcgVWludDhBcnJheSh0aGlzLm1lbW9yeS5idWZmZXIsaSxjLmJ5dGVMZW5ndGgpLnNldChjKSxzLlNVQ0NFU1N9ZmRfZmlsZXN0YXRfc2V0X3NpemUodCxpKXtyZXR1cm4gdGhpcy5kcml2ZS5zZXRTaXplKHQsaSl9ZmRfZmlsZXN0YXRfc2V0X3RpbWVzKHQsaSxuLHIpe2xldCBhPW51bGw7ciZOLkFUSU0mJihhPUIoaSkpLHImTi5BVElNX05PVyYmKGE9bmV3IERhdGUpO2xldCBmPW51bGw7aWYociZOLk1USU0mJihmPUIobikpLHImTi5NVElNX05PVyYmKGY9bmV3IERhdGUpLGEpe2NvbnN0IGM9dGhpcy5kcml2ZS5zZXRBY2Nlc3NUaW1lKHQsYSk7aWYoYyE9cy5TVUNDRVNTKXJldHVybiBjfWlmKGYpe2NvbnN0IGM9dGhpcy5kcml2ZS5zZXRNb2RpZmljYXRpb25UaW1lKHQsZik7aWYoYyE9cy5TVUNDRVNTKXJldHVybiBjfXJldHVybiBzLlNVQ0NFU1N9ZmRfcHJlYWQodCxpLG4scixhKXtpZih0PT09MXx8dD09PTIpcmV0dXJuIHMuRU5PVFNVUDtpZih0PT09MClyZXR1cm4gdGhpcy5mZF9yZWFkKHQsaSxuLGEpO2NvbnN0IGY9bmV3IERhdGFWaWV3KHRoaXMubWVtb3J5LmJ1ZmZlciksYz14KGYsaSxuKTtsZXQgbz0wLEU9cy5TVUNDRVNTO2Zvcihjb25zdCBoIG9mIGMpe2NvbnN0W1MsZ109dGhpcy5kcml2ZS5wcmVhZCh0LGguYnl0ZUxlbmd0aCxOdW1iZXIocikrbyk7aWYoUyE9PXMuU1VDQ0VTUyl7RT1TO2JyZWFrfWNvbnN0IFQ9TWF0aC5taW4oaC5ieXRlTGVuZ3RoLGcuYnl0ZUxlbmd0aCk7aC5zZXQoZy5zdWJhcnJheSgwLFQpKSxvKz1UfXJldHVybiBmLnNldFVpbnQzMihhLG8sITApLEV9ZmRfcHJlc3RhdF9kaXJfbmFtZSh0LGksbil7aWYodCE9PTMpcmV0dXJuIHMuRUJBREY7Y29uc3Qgcj1uZXcgVGV4dEVuY29kZXIoKS5lbmNvZGUoIi8iKTtyZXR1cm4gbmV3IFVpbnQ4QXJyYXkodGhpcy5tZW1vcnkuYnVmZmVyLGksbikuc2V0KHIuc3ViYXJyYXkoMCxuKSkscy5TVUNDRVNTfWZkX3ByZXN0YXRfZ2V0KHQsaSl7aWYodCE9PTMpcmV0dXJuIHMuRUJBREY7Y29uc3Qgbj1uZXcgVGV4dEVuY29kZXIoKS5lbmNvZGUoIi4iKSxyPW5ldyBEYXRhVmlldyh0aGlzLm1lbW9yeS5idWZmZXIsaSk7cmV0dXJuIHIuc2V0VWludDgoMCwkLkRJUiksci5zZXRVaW50MzIoNCxuLmJ5dGVMZW5ndGgsITApLHMuU1VDQ0VTU31mZF9wd3JpdGUodCxpLG4scixhKXtpZih0PT09MClyZXR1cm4gcy5FTk9UU1VQO2lmKHQ9PT0xfHx0PT09MilyZXR1cm4gdGhpcy5mZF93cml0ZSh0LGksbixhKTtjb25zdCBmPW5ldyBEYXRhVmlldyh0aGlzLm1lbW9yeS5idWZmZXIpLGM9eChmLGksbik7bGV0IG89MCxFPXMuU1VDQ0VTUztmb3IoY29uc3QgaCBvZiBjKWlmKGguYnl0ZUxlbmd0aCE9PTApe2lmKEU9dGhpcy5kcml2ZS5wd3JpdGUodCxoLE51bWJlcihyKSksRSE9cy5TVUNDRVNTKWJyZWFrO28rPWguYnl0ZUxlbmd0aH1yZXR1cm4gZi5zZXRVaW50MzIoYSxvLCEwKSxFfWZkX3JlYWRkaXIodCxpLG4scixhKXtjb25zdFtmLGNdPXRoaXMuZHJpdmUubGlzdCh0KTtpZihmIT1zLlNVQ0NFU1MpcmV0dXJuIGY7bGV0IG89W10sRT0wO2Zvcihjb25zdHtuYW1lOnAsdHlwZTpNfW9mIGMpe2NvbnN0IEc9Y3QocCxNLEUpO28ucHVzaChHKSxFKyt9bz1vLnNsaWNlKE51bWJlcihyKSk7Y29uc3QgaD1vLnJlZHVjZSgocCxNKT0+cCtNLmJ5dGVMZW5ndGgsMCksUz1uZXcgVWludDhBcnJheShoKTtsZXQgZz0wO2Zvcihjb25zdCBwIG9mIG8pUy5zZXQocCxnKSxnKz1wLmJ5dGVMZW5ndGg7Y29uc3QgVD1uZXcgVWludDhBcnJheSh0aGlzLm1lbW9yeS5idWZmZXIsaSxuKSxMPVMuc3ViYXJyYXkoMCxuKTtyZXR1cm4gVC5zZXQoTCksbmV3IERhdGFWaWV3KHRoaXMubWVtb3J5LmJ1ZmZlcikuc2V0VWludDMyKGEsTC5ieXRlTGVuZ3RoLCEwKSxzLlNVQ0NFU1N9ZmRfcmVudW1iZXIodCxpKXtyZXR1cm4gdGhpcy5kcml2ZS5yZW51bWJlcih0LGkpfWZkX3NlZWsodCxpLG4scil7Y29uc3RbYSxmXT10aGlzLmRyaXZlLnNlZWsodCxpLG4pO3JldHVybiBhIT09cy5TVUNDRVNTfHwobCh7bmV3T2Zmc2V0OmYudG9TdHJpbmcoKX0pLG5ldyBEYXRhVmlldyh0aGlzLm1lbW9yeS5idWZmZXIpLnNldEJpZ1VpbnQ2NChyLGYsITApKSxhfXVuc3RhYmxlX2ZkX3NlZWsodCxpLG4scil7Y29uc3QgYT1odFtuXTtyZXR1cm4gdGhpcy5mZF9zZWVrKHQsaSxhLHIpfWZkX3N5bmModCl7cmV0dXJuIHRoaXMuZHJpdmUuc3luYyh0KX1mZF90ZWxsKHQsaSl7Y29uc3RbbixyXT10aGlzLmRyaXZlLnRlbGwodCk7cmV0dXJuIG4hPT1zLlNVQ0NFU1N8fG5ldyBEYXRhVmlldyh0aGlzLm1lbW9yeS5idWZmZXIpLnNldEJpZ1VpbnQ2NChpLHIsITApLG59cGF0aF9maWxlc3RhdF9nZXQodCxpLG4scixhKXtyZXR1cm4gdGhpcy5zaGFyZWRfcGF0aF9maWxlc3RhdF9nZXQodCxpLG4scixhLCJwcmV2aWV3MSIpfXVuc3RhYmxlX3BhdGhfZmlsZXN0YXRfZ2V0KHQsaSxuLHIsYSl7cmV0dXJuIHRoaXMuc2hhcmVkX3BhdGhfZmlsZXN0YXRfZ2V0KHQsaSxuLHIsYSwidW5zdGFibGUiKX1zaGFyZWRfcGF0aF9maWxlc3RhdF9nZXQodCxpLG4scixhLGYpe2NvbnN0IGM9Zj09PSJ1bnN0YWJsZSI/ZXQ6dHQsbz1uZXcgVGV4dERlY29kZXIoKS5kZWNvZGUobmV3IFVpbnQ4QXJyYXkodGhpcy5tZW1vcnkuYnVmZmVyLG4scikpO2woe3BhdGg6b30pO2NvbnN0W0UsaF09dGhpcy5kcml2ZS5wYXRoU3RhdCh0LG8pO2lmKEUhPXMuU1VDQ0VTUylyZXR1cm4gRTtjb25zdCBTPWMoaCk7cmV0dXJuIG5ldyBVaW50OEFycmF5KHRoaXMubWVtb3J5LmJ1ZmZlcixhLFMuYnl0ZUxlbmd0aCkuc2V0KFMpLEV9cGF0aF9maWxlc3RhdF9zZXRfdGltZXModCxpLG4scixhLGYsYyl7bGV0IG89bnVsbDtjJk4uQVRJTSYmKG89QihhKSksYyZOLkFUSU1fTk9XJiYobz1uZXcgRGF0ZSk7bGV0IEU9bnVsbDtjJk4uTVRJTSYmKEU9QihmKSksYyZOLk1USU1fTk9XJiYoRT1uZXcgRGF0ZSk7Y29uc3QgaD1uZXcgVGV4dERlY29kZXIoKS5kZWNvZGUobmV3IFVpbnQ4QXJyYXkodGhpcy5tZW1vcnkuYnVmZmVyLG4scikpO2lmKG8pe2NvbnN0IFM9dGhpcy5kcml2ZS5wYXRoU2V0QWNjZXNzVGltZSh0LGgsbyk7aWYoUyE9cy5TVUNDRVNTKXJldHVybiBTfWlmKEUpe2NvbnN0IFM9dGhpcy5kcml2ZS5wYXRoU2V0TW9kaWZpY2F0aW9uVGltZSh0LGgsRSk7aWYoUyE9cy5TVUNDRVNTKXJldHVybiBTfXJldHVybiBzLlNVQ0NFU1N9cGF0aF9vcGVuKHQsaSxuLHIsYSxmLGMsbyxFKXtjb25zdCBoPW5ldyBEYXRhVmlldyh0aGlzLm1lbW9yeS5idWZmZXIpLFM9Rih0aGlzLm1lbW9yeSxuLHIpLGc9ISEoYSZ3LkNSRUFUKSxUPSEhKGEmdy5ESVJFQ1RPUlkpLEw9ISEoYSZ3LkVYQ0wpLHJ0PSEhKGEmdy5UUlVOQykscD0hIShvJk8uQVBQRU5EKSxNPSEhKG8mTy5EU1lOQyksRz0hIShvJk8uTk9OQkxPQ0spLEl0PSEhKG8mTy5SU1lOQyksRHQ9ISEobyZPLlNZTkMpO2woe3BhdGg6UyxvcGVuRmxhZ3M6e2NyZWF0ZUZpbGVJZk5vbmU6ZyxmYWlsSWZOb3REaXI6VCxmYWlsSWZGaWxlRXhpc3RzOkwsdHJ1bmNhdGVGaWxlOnJ0fSxmaWxlRGVzY3JpcHRvckZsYWdzOntmbGFnQXBwZW5kOnAsZmxhZ0RTeW5jOk0sZmxhZ05vbkJsb2NrOkcsZmxhZ1JTeW5jOkl0LGZsYWdTeW5jOkR0fX0pO2NvbnN0W1csQXRdPXRoaXMuZHJpdmUub3Blbih0LFMsYSxvKTtyZXR1cm4gV3x8KGguc2V0VWludDMyKEUsQXQsITApLFcpfXBhdGhfcmVuYW1lKHQsaSxuLHIsYSxmKXtjb25zdCBjPUYodGhpcy5tZW1vcnksaSxuKSxvPUYodGhpcy5tZW1vcnksYSxmKTtyZXR1cm4gbCh7b2xkUGF0aDpjLG5ld1BhdGg6b30pLHRoaXMuZHJpdmUucmVuYW1lKHQsYyxyLG8pfXBhdGhfdW5saW5rX2ZpbGUodCxpLG4pe2NvbnN0IHI9Rih0aGlzLm1lbW9yeSxpLG4pO3JldHVybiBsKHtwYXRoOnJ9KSx0aGlzLmRyaXZlLnVubGluayh0LHIpfXBvbGxfb25lb2ZmKHQsaSxuLHIpe2ZvcihsZXQgZj0wO2Y8bjtmKyspe2NvbnN0IGM9bmV3IFVpbnQ4QXJyYXkodGhpcy5tZW1vcnkuYnVmZmVyLHQrZipYLFgpLG89b3QoYyksRT1uZXcgVWludDhBcnJheSh0aGlzLm1lbW9yeS5idWZmZXIsaStmKlosWik7bGV0IGg9MCxTPXMuU1VDQ0VTUztzd2l0Y2goby50eXBlKXtjYXNlIG0uQ0xPQ0s6Zm9yKDtuZXcgRGF0ZTxvLnRpbWVvdXQ7KTtFLnNldChFdChvLnVzZXJkYXRhLHMuU1VDQ0VTUykpO2JyZWFrO2Nhc2UgbS5GRF9SRUFEOmlmKG8uZmQ8MylvLmZkPT09MD8oUz1zLlNVQ0NFU1MsaD0zMik6Uz1zLkVCQURGO2Vsc2V7Y29uc3RbZyxUXT10aGlzLmRyaXZlLnN0YXQoby5mZCk7Uz1nLGg9VD9ULmJ5dGVMZW5ndGg6MH1FLnNldChpdChvLnVzZXJkYXRhLFMsbS5GRF9SRUFELEJpZ0ludChoKSkpO2JyZWFrO2Nhc2UgbS5GRF9XUklURTppZihoPTAsUz1zLlNVQ0NFU1Msby5mZDwzKW8uZmQ9PT0wP1M9cy5FQkFERjooUz1zLlNVQ0NFU1MsaD0xMDI0KTtlbHNle2NvbnN0W2csVF09dGhpcy5kcml2ZS5zdGF0KG8uZmQpO1M9ZyxoPVQ/VC5ieXRlTGVuZ3RoOjB9RS5zZXQoaXQoby51c2VyZGF0YSxTLG0uRkRfUkVBRCxCaWdJbnQoaCkpKTticmVha319cmV0dXJuIG5ldyBEYXRhVmlldyh0aGlzLm1lbW9yeS5idWZmZXIsciw0KS5zZXRVaW50MzIoMCxuLCEwKSxzLlNVQ0NFU1N9cGF0aF9jcmVhdGVfZGlyZWN0b3J5KHQsaSxuKXtjb25zdCByPUYodGhpcy5tZW1vcnksaSxuKTtyZXR1cm4gdGhpcy5kcml2ZS5wYXRoQ3JlYXRlRGlyKHQscil9cGF0aF9saW5rKCl7cmV0dXJuIHMuRU5PU1lTfXBhdGhfcmVhZGxpbmsoKXtyZXR1cm4gcy5FTk9TWVN9cGF0aF9yZW1vdmVfZGlyZWN0b3J5KCl7cmV0dXJuIHMuRU5PU1lTfXBhdGhfc3ltbGluaygpe3JldHVybiBzLkVOT1NZU31wcm9jX3JhaXNlKCl7cmV0dXJuIHMuRU5PU1lTfXNvY2tfYWNjZXB0KCl7cmV0dXJuIHMuRU5PU1lTfXNvY2tfcmVjdigpe3JldHVybiBzLkVOT1NZU31zb2NrX3NlbmQoKXtyZXR1cm4gcy5FTk9TWVN9c29ja19zaHV0ZG93bigpe3JldHVybiBzLkVOT1NZU31zb2NrX29wZW4oKXtyZXR1cm4gcy5FTk9TWVN9c29ja19saXN0ZW4oKXtyZXR1cm4gcy5FTk9TWVN9c29ja19jb25uZWN0KCl7cmV0dXJuIHMuRU5PU1lTfXNvY2tfc2V0c29ja29wdCgpe3JldHVybiBzLkVOT1NZU31zb2NrX2JpbmQoKXtyZXR1cm4gcy5FTk9TWVN9c29ja19nZXRsb2NhbGFkZHIoKXtyZXR1cm4gcy5FTk9TWVN9c29ja19nZXRwZWVyYWRkcigpe3JldHVybiBzLkVOT1NZU31zb2NrX2dldGFkZHJpbmZvKCl7cmV0dXJuIHMuRU5PU1lTfX1jb25zdCBSPV8uRkRfREFUQVNZTkN8Xy5GRF9SRUFEfF8uRkRfU0VFS3xfLkZEX0ZEU1RBVF9TRVRfRkxBR1N8Xy5GRF9TWU5DfF8uRkRfVEVMTHxfLkZEX1dSSVRFfF8uRkRfQURWSVNFfF8uRkRfQUxMT0NBVEV8Xy5QQVRIX0NSRUFURV9ESVJFQ1RPUll8Xy5QQVRIX0NSRUFURV9GSUxFfF8uUEFUSF9MSU5LX1NPVVJDRXxfLlBBVEhfTElOS19UQVJHRVR8Xy5QQVRIX09QRU58Xy5GRF9SRUFERElSfF8uUEFUSF9SRUFETElOS3xfLlBBVEhfUkVOQU1FX1NPVVJDRXxfLlBBVEhfUkVOQU1FX1RBUkdFVHxfLlBBVEhfRklMRVNUQVRfR0VUfF8uUEFUSF9GSUxFU1RBVF9TRVRfU0laRXxfLlBBVEhfRklMRVNUQVRfU0VUX1RJTUVTfF8uRkRfRklMRVNUQVRfR0VUfF8uRkRfRklMRVNUQVRfU0VUX1NJWkV8Xy5GRF9GSUxFU1RBVF9TRVRfVElNRVN8Xy5QQVRIX1NZTUxJTkt8Xy5QQVRIX1JFTU9WRV9ESVJFQ1RPUll8Xy5QQVRIX1VOTElOS19GSUxFfF8uUE9MTF9GRF9SRUFEV1JJVEV8Xy5TT0NLX1NIVVRET1dOfF8uU09DS19BQ0NFUFQ7Y2xhc3MgcSBleHRlbmRzIEVycm9ye2NvbnN0cnVjdG9yKGkpe3N1cGVyKCk7dSh0aGlzLCJjb2RlIik7dGhpcy5jb2RlPWl9fWZ1bmN0aW9uIEYoZSx0LGkpe3JldHVybiBuZXcgVGV4dERlY29kZXIoKS5kZWNvZGUobmV3IFVpbnQ4QXJyYXkoZS5idWZmZXIsdCxpKSl9ZnVuY3Rpb24geChlLHQsaSl7bGV0IG49QXJyYXkoaSk7Zm9yKGxldCByPTA7cjxpO3IrKyl7Y29uc3QgYT1lLmdldFVpbnQzMih0LCEwKTt0Kz00O2NvbnN0IGY9ZS5nZXRVaW50MzIodCwhMCk7dCs9NCxuW3JdPW5ldyBVaW50OEFycmF5KGUuYnVmZmVyLGEsZil9cmV0dXJuIG59ZnVuY3Rpb24gb3QoZSl7Y29uc3QgdD1uZXcgVWludDhBcnJheSg4KTt0LnNldChlLnN1YmFycmF5KDAsOCkpO2NvbnN0IGk9ZVs4XSxuPW5ldyBEYXRhVmlldyhlLmJ1ZmZlcixlLmJ5dGVPZmZzZXQrOSk7c3dpdGNoKGkpe2Nhc2UgbS5GRF9SRUFEOmNhc2UgbS5GRF9XUklURTpyZXR1cm57dXNlcmRhdGE6dCx0eXBlOmksZmQ6bi5nZXRVaW50MzIoMCwhMCl9O2Nhc2UgbS5DTE9DSzpjb25zdCByPW4uZ2V0VWludDE2KDI0LCEwKSxhPVUobmV3IERhdGUpLGY9bi5nZXRCaWdVaW50NjQoOCwhMCksYz1uLmdldEJpZ1VpbnQ2NCgxNiwhMCksbz1yJnN0LlNVQlNDUklQVElPTl9DTE9DS19BQlNUSU1FP2Y6YStmO3JldHVybnt1c2VyZGF0YTp0LHR5cGU6aSxpZDpuLmdldFVpbnQzMigwLCEwKSx0aW1lb3V0OkIobykscHJlY2lzaW9uOkIobytjKX19fWZ1bmN0aW9uIHR0KGUpe2NvbnN0IHQ9bmV3IFVpbnQ4QXJyYXkoaiksaT1uZXcgRGF0YVZpZXcodC5idWZmZXIpO3JldHVybiBpLnNldEJpZ1VpbnQ2NCgwLEJpZ0ludCgwKSwhMCksaS5zZXRCaWdVaW50NjQoOCxCaWdJbnQoeihlLnBhdGgpKSwhMCksaS5zZXRVaW50OCgxNixlLnR5cGUpLGkuc2V0QmlnVWludDY0KDI0LEJpZ0ludCgxKSwhMCksaS5zZXRCaWdVaW50NjQoMzIsQmlnSW50KGUuYnl0ZUxlbmd0aCksITApLGkuc2V0QmlnVWludDY0KDQwLFUoZS50aW1lc3RhbXBzLmFjY2VzcyksITApLGkuc2V0QmlnVWludDY0KDQ4LFUoZS50aW1lc3RhbXBzLm1vZGlmaWNhdGlvbiksITApLGkuc2V0QmlnVWludDY0KDU2LFUoZS50aW1lc3RhbXBzLmNoYW5nZSksITApLHR9ZnVuY3Rpb24gZXQoZSl7Y29uc3QgdD1uZXcgVWludDhBcnJheShqKSxpPW5ldyBEYXRhVmlldyh0LmJ1ZmZlcik7cmV0dXJuIGkuc2V0QmlnVWludDY0KDAsQmlnSW50KDApLCEwKSxpLnNldEJpZ1VpbnQ2NCg4LEJpZ0ludCh6KGUucGF0aCkpLCEwKSxpLnNldFVpbnQ4KDE2LGUudHlwZSksaS5zZXRVaW50MzIoMjAsMSwhMCksaS5zZXRCaWdVaW50NjQoMjQsQmlnSW50KGUuYnl0ZUxlbmd0aCksITApLGkuc2V0QmlnVWludDY0KDMyLFUoZS50aW1lc3RhbXBzLmFjY2VzcyksITApLGkuc2V0QmlnVWludDY0KDQwLFUoZS50aW1lc3RhbXBzLm1vZGlmaWNhdGlvbiksITApLGkuc2V0QmlnVWludDY0KDQ4LFUoZS50aW1lc3RhbXBzLmNoYW5nZSksITApLHR9ZnVuY3Rpb24gSyhlLHQsaSl7Y29uc3Qgbj1pPz9SLHI9aT8/UixhPW5ldyBVaW50OEFycmF5KDI0KSxmPW5ldyBEYXRhVmlldyhhLmJ1ZmZlciwwLDI0KTtyZXR1cm4gZi5zZXRVaW50OCgwLGUpLGYuc2V0VWludDMyKDIsdCwhMCksZi5zZXRCaWdVaW50NjQoOCxuLCEwKSxmLnNldEJpZ1VpbnQ2NCgxNixyLCEwKSxhfWZ1bmN0aW9uIGN0KGUsdCxpKXtjb25zdCBuPW5ldyBUZXh0RW5jb2RlcigpLmVuY29kZShlKSxyPTI0K24uYnl0ZUxlbmd0aCxhPW5ldyBVaW50OEFycmF5KHIpLGY9bmV3IERhdGFWaWV3KGEuYnVmZmVyKTtyZXR1cm4gZi5zZXRCaWdVaW50NjQoMCxCaWdJbnQoaSsxKSwhMCksZi5zZXRCaWdVaW50NjQoOCxCaWdJbnQoeihlKSksITApLGYuc2V0VWludDMyKDE2LG4ubGVuZ3RoLCEwKSxmLnNldFVpbnQ4KDIwLHQpLGEuc2V0KG4sMjQpLGF9ZnVuY3Rpb24gRXQoZSx0KXtjb25zdCBpPW5ldyBVaW50OEFycmF5KDMyKTtpLnNldChlLDApO2NvbnN0IG49bmV3IERhdGFWaWV3KGkuYnVmZmVyKTtyZXR1cm4gbi5zZXRVaW50MTYoOCx0LCEwKSxuLnNldFVpbnQxNigxMCxtLkNMT0NLLCEwKSxpfWZ1bmN0aW9uIGl0KGUsdCxpLG4pe2NvbnN0IHI9bmV3IFVpbnQ4QXJyYXkoMzIpO3Iuc2V0KGUsMCk7Y29uc3QgYT1uZXcgRGF0YVZpZXcoci5idWZmZXIpO3JldHVybiBhLnNldFVpbnQxNig4LHQsITApLGEuc2V0VWludDE2KDEwLGksITApLGEuc2V0QmlnVWludDY0KDE2LG4sITApLHJ9ZnVuY3Rpb24geihlLHQ9MCl7bGV0IGk9MzczNTkyODU1OV50LG49MTEwMzU0Nzk5MV50O2ZvcihsZXQgcj0wLGE7cjxlLmxlbmd0aDtyKyspYT1lLmNoYXJDb2RlQXQociksaT1NYXRoLmltdWwoaV5hLDI2NTQ0MzU3NjEpLG49TWF0aC5pbXVsKG5eYSwxNTk3MzM0Njc3KTtyZXR1cm4gaT1NYXRoLmltdWwoaV5pPj4+MTYsMjI0NjgyMjUwNyleTWF0aC5pbXVsKG5ebj4+PjEzLDMyNjY0ODk5MDkpLG49TWF0aC5pbXVsKG5ebj4+PjE2LDIyNDY4MjI1MDcpXk1hdGguaW11bChpXmk+Pj4xMywzMjY2NDg5OTA5KSw0Mjk0OTY3Mjk2KigyMDk3MTUxJm4pKyhpPj4+MCl9ZnVuY3Rpb24gVShlKXtyZXR1cm4gQmlnSW50KGUuZ2V0VGltZSgpKSpCaWdJbnQoMWU2KX1mdW5jdGlvbiBCKGUpe3JldHVybiBuZXcgRGF0ZShOdW1iZXIoZS9CaWdJbnQoMWU2KSkpfWNvbnN0IGh0PXtbUC5DVVJdOkMuQ1VSLFtQLkVORF06Qy5FTkQsW1AuU0VUXTpDLlNFVH07bGV0IHksbnQ7b25tZXNzYWdlPWFzeW5jIGU9Pntjb25zdCB0PWUuZGF0YTtzd2l0Y2godC50eXBlKXtjYXNlImluaXRpYWxpemUiOnk9YXdhaXQgay5pbml0aWFsaXplKGZldGNoKHQuYmluYXJ5VVJMKSxuZXcgUSh7c3Rkb3V0OmJ0LHN0ZGVycjpDdH0pKSxudD10Lm1lbW9yeV9zdGFydF9pbmRleCxZKHt0YXJnZXQ6Imhvc3QiLHR5cGU6ImluaXRpYWxpemVkIixleHBvcnRzOk9iamVjdC5rZXlzKHkpfSk7YnJlYWs7Y2FzZSJjYWxsIjpsZXQgaT1udDt0LmFyZ3MuZm9yRWFjaChhPT57aT1TdChhLGkpfSksbmV3IERhdGFWaWV3KHkubWVtb3J5LmJ1ZmZlcikuc2V0VWludDgoaSwtMSksaSs9MTtjb25zdCByPXlbdC5tZXRob2RdLmFwcGx5KG51bGwsW10pO1koe3RhcmdldDoiaG9zdCIsdHlwZToicmVzdWx0IixjYWxsX2lkOnQuY2FsbF9pZCxtZW1vcnk6eS5tZW1vcnkuYnVmZmVyLGVycl9jb2RlOnJ9KX19O2Z1bmN0aW9uIFN0KGUsdCl7c3dpdGNoKGUudHlwZSl7Y2FzZSJJbnQzMiI6cmV0dXJuIF90KGUuZGF0YS5fdmFsdWUseS5tZW1vcnkuYnVmZmVyLHQpO2Nhc2UiVWludDMyIjpyZXR1cm4gdXQoZS5kYXRhLl92YWx1ZSx5Lm1lbW9yeS5idWZmZXIsdCk7Y2FzZSJzdHJpbmciOnJldHVybiBkdChlLmRhdGEseS5tZW1vcnkuYnVmZmVyLHQpO2Nhc2UiSW50MzJBcnJheSI6cmV0dXJuIGd0KGUuZGF0YSx5Lm1lbW9yeS5idWZmZXIsdCk7Y2FzZSJVaW50MzJBcnJheSI6cmV0dXJuIFR0KGUuZGF0YSx5Lm1lbW9yeS5idWZmZXIsdCk7ZGVmYXVsdDp0aHJvdyBuZXcgVHlwZUVycm9yKGBVbnN1cHBvcnRlZCBUeXBlIEdpdmVuOiAke2UudHlwZX0hYCl9fWNvbnN0IEk9MTtmdW5jdGlvbiBfdChlLHQsaSl7Y29uc3Qgbj1uZXcgRGF0YVZpZXcodCk7bi5zZXRJbnQ4KGksMSksbi5zZXRJbnQzMihpK0ksZSwhMCk7Y29uc3Qgcj00O3JldHVybiBpK0krcn1mdW5jdGlvbiB1dChlLHQsaSl7Y29uc3Qgbj1uZXcgRGF0YVZpZXcodCk7bi5zZXRJbnQ4KGksMiksbi5zZXRVaW50MzIoaStJLGUsITApO2NvbnN0IHI9NDtyZXR1cm4gaStJK3J9ZnVuY3Rpb24gZHQoZSx0LGkpe2NvbnN0IHI9bmV3IERhdGFWaWV3KHQpO3Iuc2V0SW50OChpLDMpO2NvbnN0IGE9bmV3IFRleHRFbmNvZGVyKCkuZW5jb2RlKGUpLGY9YS5ieXRlTGVuZ3RoO3JldHVybiByLnNldFVpbnQzMihpK0ksZiwhMCksbmV3IFVpbnQ4QXJyYXkodCxpK0krNCxmKS5zZXQoYSksaStJKzQrZn1mdW5jdGlvbiBndChlLHQsaSl7Y29uc3Qgcj1uZXcgRGF0YVZpZXcodCk7ci5zZXRJbnQ4KGksNCksci5zZXRVaW50MzIoaStJLGUuYnl0ZUxlbmd0aC80LCEwKTtsZXQgYT0wO2Zvcihjb25zdCBmIG9mIGUpci5zZXRJbnQzMihpK0krNCthLGYsITApLGErPTQ7cmV0dXJuIGkrSSs0K2F9ZnVuY3Rpb24gVHQoZSx0LGkpe2NvbnN0IHI9bmV3IERhdGFWaWV3KHQpO3Iuc2V0SW50OChpLDUpLHIuc2V0VWludDMyKGkrSSxlLmJ5dGVMZW5ndGgvNCwhMCk7bGV0IGE9MDtmb3IoY29uc3QgZiBvZiBlKXIuc2V0VWludDMyKGkrSSs0K2EsZiwhMCksYSs9NDtyZXR1cm4gaStJKzQrYX1mdW5jdGlvbiBZKGUpe3Bvc3RNZXNzYWdlKGUpfWZ1bmN0aW9uIGJ0KGUpe1koe3RhcmdldDoiaG9zdCIsdHlwZToic3Rkb3V0Iix0ZXh0OmV9KX1mdW5jdGlvbiBDdChlKXtZKHt0YXJnZXQ6Imhvc3QiLHR5cGU6InN0ZGVyciIsdGV4dDplfSl9fSkoKTsK", tl = typeof window < "u" && window.Blob && new Blob([atob(cl)], { type: "text/javascript;charset=utf-8" });
function Nl() {
  let t;
  try {
    if (t = tl && (window.URL || window.webkitURL).createObjectURL(tl), !t)
      throw "";
    return new Worker(t);
  } catch {
    return new Worker("data:application/javascript;base64," + cl);
  } finally {
    t && (window.URL || window.webkitURL).revokeObjectURL(t);
  }
}
function Vl(t, l) {
  t.postMessage(l);
}
class El {
  constructor(l, V = 0, Z, d) {
    R(this, "binaryURL");
    R(this, "context");
    R(this, "worker");
    R(this, "exports", {});
    R(this, "memory_start_index");
    R(this, "callbacks", {});
    this.binaryURL = l, this.memory_start_index = V, this.context = Z, window.addEventListener("unhandledrejection", (i) => d(i.reason));
  }
  initialize() {
    return new Promise((l, V) => {
      this.worker = new Nl(), this.worker.addEventListener("message", (Z) => {
        var i, n, m, e, a, X;
        const d = Z.data;
        switch (d.type) {
          case "stdout":
            (n = (i = this.context).stdout) == null || n.call(i, d.text);
            break;
          case "stderr":
            (e = (m = this.context).stderr) == null || e.call(m, d.text);
            break;
          case "debug":
            (X = (a = this.context).debug) == null || X.call(a, d.name, d.args, d.ret, d.data);
            break;
          case "initialized":
            d.exports.forEach((G, h) => {
              G !== "memory" && (this.exports[G] = (...o) => {
                let I = [];
                return o.forEach((p) => {
                  let U;
                  switch (!0) {
                    case p instanceof Xl:
                      U = "Int32";
                      break;
                    case p instanceof Rl:
                      U = "Uint32";
                      break;
                    case typeof p == "string":
                      U = "string";
                      break;
                    case p instanceof Int32Array:
                      U = "Int32Array";
                      break;
                    case p instanceof Uint32Array:
                      U = "Uint32Array";
                      break;
                  }
                  I.push({ type: U, data: p });
                }), new Promise((p, U) => {
                  Vl(this.worker, {
                    target: "client",
                    type: "call",
                    call_id: h,
                    method: G,
                    args: I
                  }), this.callbacks[h] = {
                    resolve: p,
                    reject: U
                  };
                });
              });
            }), l();
            break;
          case "result":
            if (d.err_code === 0) {
              let G = [], h = this.memory_start_index;
              for (; ; ) {
                const [o, I] = this.parseArg(h, d.memory);
                if (o === null)
                  break;
                G.push(o), h = I;
              }
              this.callbacks[d.call_id].resolve(G);
            } else
              this.callbacks[d.call_id].reject(d.err_code);
            new Uint8Array(d.memory, this.memory_start_index, length).fill(0);
            break;
        }
      }), Vl(this.worker, {
        target: "client",
        type: "initialize",
        binaryURL: this.binaryURL,
        memory_start_index: this.memory_start_index,
        args: this.context.args,
        env: this.context.env,
        fs: this.context.fs,
        isTTY: this.context.isTTY
      });
    });
  }
  parseArg(l, V) {
    const Z = new DataView(V), d = !0, i = Z.getInt8(l);
    l += 1;
    let n;
    switch (i) {
      case -1:
        n = null;
        break;
      case 1:
        n = Z.getInt32(l, d), l += 4;
        break;
      case 2:
        n = Z.getUint32(l, d), l += 4;
        break;
      case 3:
        const m = Z.getUint32(l, d);
        l += 4;
        const e = new Uint8Array(V, l, m);
        l += m, n = new TextDecoder().decode(e);
        break;
      case 4:
        const a = Z.getUint32(l, d);
        l += 4;
        let X = [], s = 0;
        for (; s < a; )
          X.push(Z.getInt32(l, d)), s += 1, l += 4;
        n = new Int32Array(X);
        break;
      case 5:
        const G = Z.getUint32(l, d);
        l += 4;
        let h = [], o = 0;
        for (; o < G; )
          h.push(Z.getUint32(l, d)), o += 1, l += 4;
        n = new Uint32Array(h);
        break;
      default:
        throw new TypeError(`Unsupported Type Read From Buffer: ${i}, ${l}!`);
    }
    return [n, l];
  }
}
export {
  j as InitializationError,
  Xl as Int32,
  x as InvalidInstanceError,
  Rl as Uint32,
  P as WASI,
  Gl as WASIContext,
  El as WASIReactorWorkerHost,
  Ll as WASISnapshotPreview1,
  Fl as WASIWorkerHost,
  kl as WASIWorkerHostKilledError
};
