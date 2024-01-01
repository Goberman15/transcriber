locals {
  project_name = "transcriber_hsi"
  tags = {
    Project : local.project_name
  }
  function_name = {
    start_transcription = "start_transcription_fn"
  }
  transcript_prefix = "transcripts"
}
