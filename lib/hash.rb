class Hash
  def merge_deep( other, &block )
    merge( other ) do |key, self_val, other_val|
      if block
        block.call( key, self_val, other_val )
      else
        if self_val.is_a?( Hash )
          self_val.merge_deep( other_val )
        else
          other_val
        end
      end
    end
  end
end
