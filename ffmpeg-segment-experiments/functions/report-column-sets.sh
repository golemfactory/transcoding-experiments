report_input_file_info_columns=(
    input_video_name
    input_num_streams
    input_video_format
    input_video_codec
    input_bitrate
    input_duration_rounded
    input_frame_count
    input_unique_frame_types
    input_i_frame_count
    input_p_frame_count
    input_b_frame_count
)


report_timestamps_transcode_merge_columns=(
    input_video_name
    input_duration
    output_duration
    merged_duration
    input_video_start_time
    output_video_start_time
    merged_video_start_time
    input_audio_start_time
    output_audio_start_time
    merged_audio_start_time
)


report_frame_types_with_transcoding_columns=(
    input_video_name
    input_frame_count
    output_frame_count
    segment_frame_count
    transcoded_segment_frame_count
    merged_frame_count
    input_unique_frame_types
    output_unique_frame_types
    segment_unique_frame_types
    transcoded_segment_unique_frame_types
    merged_unique_frame_types
    input_i_frame_count
    output_i_frame_count
    segment_i_frame_count
    transcoded_segment_i_frame_count
    merged_i_frame_count
    input_p_frame_count
    output_p_frame_count
    segment_p_frame_count
    transcoded_segment_p_frame_count
    merged_p_frame_count
    input_b_frame_count
    output_b_frame_count
    segment_b_frame_count
    transcoded_segment_b_frame_count
    merged_b_frame_count
    input_same_frame_types_as_output
    output_same_frame_types_as_merged
    input_same_frame_types_as_segments
    segments_same_frame_types_as_merged
)


report_frame_types_without_transcoding_columns=(
    input_video_name
    input_frame_count
    segment_frame_count
    merged_frame_count
    input_unique_frame_types
    segment_unique_frame_types
    merged_unique_frame_types
    input_i_frame_count
    segment_i_frame_count
    merged_i_frame_count
    input_p_frame_count
    segment_p_frame_count
    merged_p_frame_count
    input_b_frame_count
    segment_b_frame_count
    merged_b_frame_count
    input_same_frame_types_as_segments
    segments_same_frame_types_as_merged
)
