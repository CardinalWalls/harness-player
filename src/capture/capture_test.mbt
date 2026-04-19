///|
test "runtime events normalize into capture records with provenance linkage" {
  let event = @capture.runtime_event(
    "skill-export-requested", "session-1", "channel-1", "default", "hermes", "payload://checkpoint-1/story-distiller",
  )
  let metadata = @provenance.checkpoint_metadata(
    "checkpoint-1",
    "story-distiller@v1",
    "main",
    "session-1",
    "channel-1",
    "projection-1",
    @provenance.snapshot_ref("snapshot-1"),
    @provenance.commit_ref("commit-9"),
    "checkpoint-0",
  )
  let record = @capture.normalize_runtime_event(event, metadata)

  inspect(
    @capture.runtime_event_key(event),
    content="hermes|default|session-1|channel-1|skill-export-requested|payload://checkpoint-1/story-distiller",
  )
  inspect(
    @capture.capture_record_key(record),
    content="capture://hermes|session-1|channel-1|skill-export-requested|payload://checkpoint-1/story-distiller|default|checkpoint-1|commit-9",
  )
  inspect(@capture.capture_links_to_provenance(record), content="true")
  inspect(@capture.capture_checkpoint_id(record), content="checkpoint-1")
  inspect(@capture.capture_durable_ref(record), content="commit-9")
}

///|
test "capture normalization fails provenance linkage checks when metadata is empty" {
  let record = @capture.normalize_runtime_event(
    @capture.runtime_event(
      "checkpoint-created", "session-2", "channel-2", "default", "hermes", "payload://checkpoint-2/story-loop",
    ),
    @provenance.checkpoint_metadata(
      "",
      "story-loop@v1",
      "main",
      "session-2",
      "channel-2",
      "projection-2",
      @provenance.snapshot_ref("snapshot-2"),
      @provenance.commit_ref(""),
      "",
    ),
  )

  inspect(@capture.capture_links_to_provenance(record), content="false")
}
