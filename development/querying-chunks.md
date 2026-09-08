# Querying Chunks

To find a chunk on the network, start with its absolute weave offset, check
which peers advertise the data, and request the chunk from those peers. This
guide explains the availability records and chunk endpoints. Unpacking
`replica.2.9` data is outside its scope.

## Chunk Offsets

Chunk requests use an absolute weave offset greater than the chunk's start
boundary and less than or equal to its end boundary:
`ChunkStart < Offset <= ChunkEnd`. The chunk's absolute end offset can
therefore be used directly. See [Fetching Chunks](debugging.md#fetching-chunks)
for examples.

### Transaction Offsets

If you have a transaction ID rather than a weave offset, request its position
from a peer that indexes the transaction:

```http
GET /tx/{TransactionID}/offset
```

Example response:

```json
{
  "offset": "377144069562431",
  "size": "2031433"
}
```

For the rest of this guide, `Start` and `End` refer to the transaction's
first and last byte positions, both inclusive:

```text
Start = offset - size + 1 = 377144067530999
End = offset = 377144069562431
```

The transaction therefore occupies `[Start, End]`. `Start` is the first
included byte, not the exclusive start boundary used in the chunk rule above.

`Offset` refers to the particular byte being queried. The following examples
use `Offset = Start` to locate and retrieve the transaction's first chunk.

Transaction metadata and chunk storage are independent: a peer can serve a
chunk without indexing its transaction metadata. The absolute offset
identifies the same weave position regardless of which peer is queried.
See the [HTTP API](../server/http-api.md) for more information about
transaction endpoints.

## Finding Peers

Request the peer list from a known Arweave node:

```http
GET /peers
```

The response is an array of peer addresses:

```json
["203.0.113.10:1984", "203.0.113.11:1984"]
```

These addresses are illustrative. Each peer has its own peer list, so
requesting `GET /peers` from another peer may reveal additional nodes.
A peer list is not a complete directory of the network. `GET /info` identifies
the network a peer belongs to.

## Checking Availability

There are two availability records:

- `GET /data_sync_record/{Offset}/{Limit}` returns weave-byte intervals.
- `GET /footprints/{Partition}/{Footprint}` returns chunk positions within
  the footprint record.

Check both records. Storage packed as `replica.2.9` is excluded from the
public data sync record and advertised through footprint records instead.
An empty data sync record therefore does not establish that the peer lacks
the chunk. This behavior is defined by the
[global sync record implementation](https://github.com/ArweaveTeam/arweave/blob/master/apps/arweave/src/ar_global_sync_record.erl).

### Data Sync Record

To check the transaction's first byte, request one interval at
`Start = 377144067530999`:

```text
GET /data_sync_record/{Start}/1
```

With the example value substituted, the request is:

```http
GET /data_sync_record/377144067530999/1
Content-Type: application/json
```

The first path value is the byte position to check; the second, `1`, is
the maximum number of intervals to return. All request paths are relative to
the peer being queried.

The request header `Content-Type: application/json` selects JSON, even
though the GET request has no body. Without this header, the endpoint returns
Erlang External Term Format. An `Accept` header alone does not select JSON.

Example response:

```json
[{"377145663201526":"377138901983478"}]
```

Each object represents an advertised interval in the form
`{"IntervalEnd":"IntervalStart"}`. These are the peer's interval boundaries,
not the transaction's `Start` and `End`. The lower boundary is excluded and
the upper boundary is included.

The peer advertises the transaction's first byte when
`IntervalStart < Start <= IntervalEnd`. In this example:

```text
377138901983478 < 377144067530999 <= 377145663201526
```

Checking `Start` alone does not establish availability of the whole
transaction. A single returned interval covers the whole transaction when
`IntervalStart < Start` and `End <= IntervalEnd`. Here,
`End = 377144069562431` also lies within the interval, so the peer advertises
the entire transaction range.

The endpoint returns intervals starting with the first whose end is at or
beyond the requested offset. One interval is therefore enough for a
single-offset check: it either contains the offset or starts after it.
An empty list means there is no such interval.

`Limit` counts intervals, not bytes or chunks. The endpoint without a start
and limit, `GET /data_sync_record`, returns a random subset and should not
be used to check a specific offset. See the
[interval serializer](https://github.com/ArweaveTeam/arweave/blob/master/apps/arweave/src/ar_intervals.erl)
for the response representation.

### Footprint Record

A footprint groups chunks spread across an entropy partition. Adjacent
positions in a footprint do not generally represent adjacent weave bytes.
To query this record, map the weave offset to an entropy partition, a
footprint number, and an offset in the footprint record.

The mapping below applies to mainnet offsets above `30607159107830`, the
strict data split threshold. Earlier data can contain small chunks that do
not map precisely to individual footprint positions; use the data sync
record and direct chunk requests for that data. Other networks may use
different constants.

#### Mapping an Offset

The source of truth for the `replica.2.9` entropy-to-chunk mapping is
[`ar_replica_2_9.erl`](https://github.com/ArweaveTeam/arweave/blob/master/apps/arweave/src/ar_replica_2_9.erl).
Its glossary distinguishes a **recall partition**, the 3.6 TB range used for
mining, from an **entropy partition**, which contains the entropies used for
packing. The function `get_entropy_partition/1` selects the entropy partition
from the chunk's bucket; its boundaries do not exactly match recall partition
boundaries.

[`ar_footprint_record.erl`](https://github.com/ArweaveTeam/arweave/blob/master/apps/arweave/src/ar_footprint_record.erl)
defines how chunk positions are represented in the footprint record.
Its `get_offset/1` function uses the entropy partition to calculate the
global record offset. The calculation below follows that function's
terminology; `RecordOffset` names its final result.

Use these [mainnet constants](https://github.com/ArweaveTeam/arweave/blob/master/apps/arweave/include/ar_consensus.hrl):

| Symbol | Meaning | Value |
| --- | --- | --- |
| `C` | Chunk size, in bytes | 262,144 |
| `P` | Recall partition size, in bytes | 3,600,000,000,000 |
| `T` | Strict data split threshold | 30,607,159,107,830 |
| `F` | Footprints per entropy partition | 13,412 |
| `S` | Footprint size, in chunk positions | 1,024 |
| `N` | Record positions reserved per entropy partition | 13,733,888 |

There are 429,184 `replica.2.9` entropies per entropy partition and 32
sub-chunks per chunk, giving `F = 429184 / 32 = 13412` footprints.
The record reserves `N = ceil(P / (C * S)) * S` chunk positions per
entropy partition, called `ChunksPerPartition` in `get_offset/1`.

Use the same queried byte for the footprint calculation:
`Offset = Start = 377144067530999`. In the equations below, `floor`
rounds down, `ceil` rounds up, and `mod` is the remainder after division.

First, obtain the padded offset with `ar_block:get_chunk_padded_offset/1`.
Above the strict split threshold, this rounds up to a chunk boundary
relative to that threshold. The entropy partition then follows
`ar_replica_2_9:get_entropy_partition/1`:

```text
PaddedOffset = T + ceil((Offset - T) / C) * C
BucketStart = floor((PaddedOffset - C) / C) * C
Partition = floor(BucketStart / P)
```

Here, `BucketStart` follows `get_entropy_bucket_start/1`: a bucket is a
zero-based, 256 KiB-aligned range. This alignment is why dividing the original
offset by the recall partition size does not always give the entropy partition.

Next, `ar_footprint_record:get_offset/1` calculates `PartitionOffset`,
the chunk position used by the record, and separates it into a footprint
number and a position within that footprint:

```text
PartitionOffset = floor((PaddedOffset - Partition * P) / C) - 1
Footprint = PartitionOffset mod F
FootprintOffset = floor(PartitionOffset / F)
```

`FootprintOffset` is the zero-based position within the selected footprint.
The global record offset also accounts for the preceding partitions and
footprints:

```text
RecordStart = Partition * N + Footprint * S
RecordOffset = RecordStart + FootprintOffset + 1
```

The addition of `1` gives the offset used to test membership in the record's
`(IntervalStart, IntervalEnd]` intervals.

For `Offset = Start`, the results are:

```text
PaddedOffset = 377144067793142
Partition = 104
PartitionOffset = 10467786
Footprint = 6426
FootprintOffset = 780
RecordStart = 1434904576
RecordOffset = 1434905357
```

#### Querying the Record

Use `Partition` and `Footprint` in the request path:

```http
GET /footprints/104/6426
```

Example response:

```json
{
  "intervals": [
    ["1434904576", "1434905600"]
  ]
}
```

Each pair has the form `["IntervalStart","IntervalEnd"]`, unlike the
`{"IntervalEnd":"IntervalStart"}` objects in the data sync record. Here the
interval boundaries are global footprint-record offsets, not weave-byte
offsets or positions relative to the footprint. They are distinct from the
transaction's `Start` and `End`.

The peer advertises the target chunk bucket when any interval satisfies
`IntervalStart < RecordOffset <= IntervalEnd`. In this example:

```text
1434904576 < 1434905357 <= 1434905600
```

The response advertises all 1,024 positions in this footprint. A partially
filled footprint may return several intervals.

Footprint records can include packing formats other than `replica.2.9`.
The response contains `intervals` without identifying the packing. Read the
packing from the chunk response instead.

### Interpreting the Results

A matching interval in either record means the peer advertises the target
data. No matching interval means that record does not advertise it.

Advertisements and retrieval are separate. Records may be stale or incomplete,
so advertised data may not be retrievable, and a chunk request may succeed even
without a matching advertisement. A failed availability request does not show
whether the peer has the data.

## Requesting a Chunk

Use the `x-packing: any` request header to accept the packing a peer can
serve from storage. This requests one representation of the chunk, not every
packing the peer holds.

Without this header, the request defaults to `unpacked`. A peer holding
only packed data may fail that request even though it has the chunk.

The requests below continue to use `Offset = Start = 377144067530999` to
retrieve the transaction's first chunk.

### Binary Response

`GET /chunk2/{Offset}` returns a binary response without the base64 expansion
of the JSON endpoint:

```http
GET /chunk2/377144067530999
x-packing: any
```

The response contains the chunk, its transaction and data proof paths, and
the packing descriptor. It is not just the raw chunk bytes. The
[chunk serializer](https://github.com/ArweaveTeam/arweave/blob/master/apps/arweave/src/ar_serialize.erl)
defines the binary format.

### JSON Response

`GET /chunk/{Offset}` returns the same chunk and proof fields as JSON:

```http
GET /chunk/377144067530999
x-packing: any
```

Example response, with the encoded data abbreviated:

```json
{
  "chunk": "<base64url-encoded chunk>",
  "tx_path": "<base64url-encoded transaction path>",
  "data_path": "<base64url-encoded data path>",
  "packing": "unpacked",
  "absolute_end_offset": "377144067793142",
  "chunk_size": "262144"
}
```

The `chunk`, `tx_path`, and `data_path` fields are base64url-encoded.
The `absolute_end_offset` and `chunk_size` fields describe the chunk's actual
end and unpadded size; these fields may be absent on older peers. The end
offset may also appear in an `Arweave-Absolute-End-Offset` response header.
An offset used to request a chunk is not necessarily its end offset.

The transaction and data paths are Merkle proofs. Verifying that the returned
data is the correct chunk requires checking these proofs against trusted
chain data and unpacking the chunk when necessary.

### Packing Formats

The response identifies the packing actually returned. Examples include:

- `unpacked` - unpacked chunk data.
- `unpacked_padded` - unpacked data with padding.
- `spora_2_5` or `spora_2_6_<MiningAddress>` - SPoRA packing.
- `replica_2_9_<MiningAddress>` - `replica.2.9` packing.

The API uses `replica_2_9_` in the descriptor for `replica.2.9`. Its
address suffix identifies the mining address the chunk is packed to.

Decoding base64url or extracting the chunk field from a binary response only
removes the transport encoding. It does not unpack the chunk. Packed byte
counts can include padding and are not necessarily the original payload size.

### Padded Offsets

For an ordinary chunk request, use an offset inside the actual data or the
actual absolute chunk end. If the offset instead refers to a padded bucket,
include both headers:

```http
GET /chunk2/{Offset}
x-packing: any
x-bucket-based-offset: true
```

Above the strict split threshold, this requests the chunk ending in that
bucket rather than treating the offset as necessarily belonging to real data.
Without the header, an offset that falls in padding may return `404` even
when the peer stores the chunk. The
[HTTP handler](https://github.com/ArweaveTeam/arweave/blob/master/apps/arweave/src/ar_http_iface_middleware.erl)
defines this behavior.

## Unpacking `replica.2.9`

Unpacking `replica.2.9` requires the protocol's entropy generation and
RandomX-based unpacking operations. It is separate from decoding the response
format and is not covered by this guide.

The mining address used for packing is public. Unpacking does not require
the miner's private key.

To request plaintext instead, use `x-packing: unpacked` with a peer able and
willing to serve it. Failure of that request does not establish that the
packed chunk is absent. See [Syncing and Packing](../mining/overview/syncing-and-packing.md)
for background and the [packing implementation](https://github.com/ArweaveTeam/arweave/blob/master/apps/arweave/src/ar_packing_server.erl)
for the unpacking operations.
