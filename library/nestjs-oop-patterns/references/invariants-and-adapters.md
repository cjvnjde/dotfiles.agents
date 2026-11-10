# Invariant and adapter reasoning

## A transition earns a state owner

A reservation has a capacity and confirmed seats. The business invariant is
`0 <= confirmed <= capacity`, with safe-integer counts. Confirming seats either
changes the count by the requested positive amount or fails without mutation.

Reason through the design before choosing a class:

1. A read-only capacity summary is data; a function can calculate remaining seats.
2. If callers independently mutate `confirmed`, the check and write can drift apart.
   A cohesive `confirmSeats(count)` operation can protect the in-memory transition.
3. Validate the request and computed next count before assignment. Checking only
   constructor inputs misses later overflow and over-capacity transitions.
4. Rehydration must restore a valid state or report invalid stored data according to
   the existing policy. Do not assume an ORM invokes the normal domain constructor.
5. Expose the count or a safe view, not a mutable object that lets callers bypass
   the transition. Avoid defensive copies when an immutable scalar suffices.
6. If two requests read the same remaining capacity, both object instances may pass
   their checks. The persistence owner still needs the existing atomic update,
   version check, constraint, or locking mechanism that establishes the invariant.

Useful cases are exactly full capacity, one seat beyond capacity, zero/negative
requests, unsafe integers, overflow, and unchanged state after rejection. This does
not justify introducing rich entities into every CRUD module or a generic base
aggregate. A pure transition function may be enough if the state owner can enforce
that every write uses it.

## Two processors, one behavioral capability

Consider a text-extraction capability backed by two external protocols. One reports
text chunks and a terminal reason; the other reports page events and a final
message. A useful contract exposes normalized content and the outcomes consumers
need, not both vendor event unions.

Start from these questions and resolve them from the repository's accepted behavior:

| Contract question | Failure that a matching signature would miss |
| --- | --- |
| What establishes successful completion? | An interrupted stream yields partial content and is reported as complete. |
| What happens on caller cancellation? | The caller stops waiting but the adapter keeps sending, charging, or invoking callbacks. |
| Are late events observable? | A callback mutates a result already rejected or canceled. |
| What does missing usage metadata mean? | An unknown quantity becomes zero and looks like measured free work. |
| Are counters incremental or cumulative? | Summing cumulative values or overwriting deltas produces wrong totals. |
| Which failures cross the capability boundary? | Vendor exceptions expose credentials/payloads or force business callers to inspect SDK codes. |
| Which operations are actually supported? | An implementation throws “unsupported” for ordinary contract inputs. |

Normalize protocol differences in each adapter. Share a pure translation helper
only where semantics truly match; do not force unlike protocols into inheritance
hooks just because both use a stream. The shared operation owner may enforce
common bounds and cancellation handling, while adapters propagate the signal and
translate terminal reasons. Keep that division explicit so neither assumes the
other handled a failure.

Substitution means a new implementation does not make its callers branch on the
vendor to distinguish success, errors, or cancellation. If one implementation
cannot meet a required capability, narrow/split the contract for a real consumer
need or reject the configuration; do not silently weaken the promised behavior.

## Protocol completion is not business acceptance

A processor can complete normally yet return content that lacks required fields,
violates a domain rule, or was requested before authority was revoked. The adapter
owns protocol decoding and boundary validation. The business owner decides whether
the normalized result is acceptable and still authorized before committing or
publishing it. Successful transport is evidence of neither decision.

Contract tests should run equivalent scenarios against both implementations at the
external boundary: ordinary completion, missing metadata, truncation, malformed
content, provider failure, cancellation before/during execution, and late output
when the protocol permits it. Keep provider-specific fixtures for differing event
and counter semantics. Test domain rejection independently from protocol failure.
Do not add retries, fallback vendors, or background machinery merely to exercise
a pattern; preserve the operation's established effect and recovery contract.
