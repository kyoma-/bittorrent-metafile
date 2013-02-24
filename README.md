bittorrent-metafile
===================

Makes metainfo file of BitTorrent.
So far, it can generate those of web-seeded files without tracker.

Requires
--------

* [ruby-bencode](https://github.com/dasch/ruby-bencode.git)

Example
-------

    require './lib/bittorrent'
    File.open('test.torrent','w') do |f|
      m = BitTorrent::MetainfoFile.new(f, {
                                         'url-list' => ['http://foo.bar/'],
                                         'comment' => 'This is comment...',
                                         'created by' => $0,
                                         'info' => {
                                           'name' => 'path0'
                                         }})
      m << [ '../file.zip', 'path1', 'path2' ]
      m.flush
    end

It creates a metainfo file to point `http://foo.bar/path0/path1/path2/file.zip`.