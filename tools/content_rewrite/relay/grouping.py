"""How lessons are split into batches. No dependencies, so every item type can use it."""
import collections


def split_sizes(count, high):
    """Sizes of the smallest number of batches of at most `high`, as even as possible.

    split_sizes(10, 4) is [4, 3, 3] and split_sizes(5, 4) is [3, 2]. A count of 5 cannot be split
    into batches of 3 or 4, so it gives 3 and 2: a batch under the minimum is allowed only then,
    and when a topic has fewer lessons than the minimum.
    """
    if count <= 0:
        return []
    batches = -(-count // high)
    base, extra = divmod(count, batches)
    return [base + 1] * extra + [base] * (batches - extra)


def group_by_topic(keys, topic_of):
    """{topic: [keys]} keeping the order in which topics first appear and the order of keys."""
    groups = collections.OrderedDict()
    for key in keys:
        groups.setdefault(topic_of(key), []).append(key)
    return groups


def chunk(keys, sizes):
    out, start = [], 0
    for size in sizes:
        out.append(keys[start:start + size])
        start += size
    return out
