import os
import m3u8

def create_and_dump_m3u8(path, segment):
    [basename, _] = os.path.splitext(segment.uri)
    filename = basename + ".m3u8"
    file = open(filename, 'w')
    file.write("#EXTM3U\n")
    file.write("#EXT-X-VERSION:3\n")
    file.write("#EXT-X-TARGETDURATION:{}\n".format(segment.duration))
    file.write("#EXT-X-MEDIA-SEQUENCE:0\n")
    file.write("#EXTINF:{},\n".format(segment.duration))
    file.write("{}\n".format(segment.uri))
    file.write("#EXT-X-ENDLIST\n")
    file.close()
    return filename

def join_playlists(playlists):
    base = m3u8.load(playlists[0])
    for pl in playlists[1:]:
        playlist = m3u8.load(pl)
        for segment in playlist.segments:
            base.add_segment(segment)
    return base