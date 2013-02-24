module BitTorrent

  #
  # Metainfo file of BitTorrent.
  #
  class MetainfoFile

    DEFAULT_OPTS = {
      'url-list' => [],
      'comment' => '',
      'creation date' => nil, # Time.now.to_i will be given at #flush
      'created by' => '',
      'info' => {
        'name' => '',
        'private' => 0,
        'piece length' => 262_144
      }
    }

    #
    # io ::      IO into which the metainfo will be written
    # options :: See ::DEFAULT_OPTS
    #
    def initialize( io, options = {} )
      @io = io

      @contents = DEFAULT_OPTS.merge_deep( options )
      unless @contents['info']['piece length'].to_i > 0
        raise "Invalid piece length: #{@contents['info']['piece length']}"
      end

      if @contents['info'].has_key?( 'files' )
        raise "Invalid options['info']['files']: #{@contents['info']['files']}"
      end
      @contents['info']['files'] = []

      if @contents['info'].has_key?( 'pieces' )
        raise "Invalid options['info']['pieces']: #{@contents['info']['pieces']}"
      end
      @contents['info']['pieces'] = ''

      @carry_over = nil
    end

    #
    # Adds a given file to the metainfo.
    #
    # file_path :: file name to add, and optional path in the metainfo
    #
    def <<( file_path )
      if file_path.is_a?( Array )
        file = file_path.shift
        path = file_path
      else
        file = file_path
        path = []
      end
      File.open( file ) do |file_io|
        while( piece = file_io.read( @contents['info']['piece length'] - ( @carry_over ? @carry_over.length : 0 ) ) ) do
          if @carry_over
            piece = @carry_over + piece
            @carry_over = nil
          end
          if piece.length < @contents['info']['piece length']
            @carry_over = piece
          else
            @contents['info']['pieces'] << Digest::SHA1.digest( piece )
          end
        end
        @contents['info']['files'] << {
          'path' => [ path, File.basename( file ) ].flatten,
          'length' => file_io.pos
        }
      end
      self
    end

    #
    # Flushes and calls IO#flush for given _io_.
    #
    def flush
      if @carry_over
        @contents['info']['pieces'] << Digest::SHA1.digest( @carry_over )
      end
      unless @contents['creation date']
        @contents['creation date'] = Time.now.tv_sec
      end
      @io << @contents.bencode
      @io.flush
      self
    end
  end
end
