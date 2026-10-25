"""The batch item type registry.

Each kind of batch (rewrite, read, and later solve, settle, qcheck, qfix, figbrief) is one module
in this folder named type_<name>.py. It defines a subclass of ItemType and calls register() on it.
Nothing else needs to change: this module imports every type_*.py it finds, and the planner,
prompt builder, hand-in script and page all work through the registry.

What a type provides:
  name, prefix           "rewrite" and "RW": batch ids are RW-001, RW-002, ...
  file_ext               extension of the file the chat saves for each item
  commit_verb            first word of the commit message: "rewrite: RW-001 id id"
  priority               lower numbers are offered first on the page (reads before rewrites)
  plan(ctx)              new batches to add, as dicts {"lessons": [item keys], ...}
  items(batch)           the item keys of a batch
  prompt(ctx, batch)     the prompt Aedwon pastes into a chat
  target_paths(batch, key)   repo paths a hand-in may write for one item
  check_item(ctx, batch, key, raw)   returns an ItemResult
Python 3.9 standard library only.
"""
import importlib

import rw_lib

REGISTRY = {}


class ItemResult:
    """What a type's check says about one handed-in item.

    reasons  why it is rejected (an empty list means accepted); never lesson text
    notes    flags for the lead that do not block, for example uncovered changes
    files    {repo path: bytes} to place when accepted
    record   extra fields saved with the accepted record
    readable False when the saved file could not be read at all (a transport slip)
    """

    def __init__(self, reasons=None, notes=None, files=None, record=None, readable=True):
        self.reasons = list(reasons or [])
        self.notes = list(notes or [])
        self.files = dict(files or {})
        self.record = dict(record or {})
        self.readable = readable


class ItemType:
    name = ""
    prefix = ""
    file_ext = ""
    commit_verb = ""
    priority = 5   # which type the page offers first when several have a batch waiting; lower goes first

    def plan(self, ctx):
        raise NotImplementedError

    def items(self, batch):
        return list(batch["lessons"])

    def prompt(self, ctx, batch):
        raise NotImplementedError

    def target_paths(self, batch, key):
        raise NotImplementedError

    def check_item(self, ctx, batch, key, raw):
        raise NotImplementedError

    def inbox_name(self, key):
        return key + self.file_ext


def register(item_type):
    if item_type.name in REGISTRY:
        raise rw_lib.RewriteError("item type %s is registered twice" % item_type.name)
    REGISTRY[item_type.name] = item_type
    return item_type


def get(name):
    if name not in REGISTRY:
        raise rw_lib.RewriteError("unknown item type %s" % name)
    return REGISTRY[name]


def by_prefix(prefix):
    for item_type in REGISTRY.values():
        if item_type.prefix == prefix:
            return item_type
    raise rw_lib.RewriteError("no item type uses the prefix %s" % prefix)


def load_types():
    for path in sorted(rw_lib.RELAY_DIR.glob("type_*.py")):
        importlib.import_module(path.stem)


load_types()
