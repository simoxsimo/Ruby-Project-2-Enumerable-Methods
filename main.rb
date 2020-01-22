# frozen_string_literal: true

# This module contains all the custom made Enumerable methods
module Enumerable
  # contains "my_each, my_each_with_index, my_select, my_all?" methods
  module EnumerableInside1
    def my_each
      me = self
      me.size.times do |i|
        yield(me[i]) if block_given? && me.is_a?(Array)
        yield(me.keys[i], me.values[i]) if block_given? && me.is_a?(Hash)
        return to_enum(:my_each) unless block_given?
      end
      me
    end

    def my_each_with_index
      me = self
      me.size.times do |i|
        yield(me[i], i) if block_given? && me.is_a?(Array)
        yield(me.values[i], i) if block_given? && me.is_a?(Hash)
        return to_enum(:my_each_with_index) unless block_given?
      end
      me
    end

    def my_select
      me = self
      temp = me.is_a?(Array) ? [] : {}
      return to_enum(:my_select) unless block_given?

      if me.is_a?(Array)
        me.my_each { |x| temp << x if yield(x) }
      else # if me.is_a?(Hash)
        me.my_each { |x, y| temp[x] = y if yield(x, y) }
      end
      temp
    end

    def my_all_block?(mee)
      if mee.is_a?(Array)
        mee.my_each { |x| return false unless yield(x) }
      else # if mee.is_a?(Hash)
        mee.my_each { |x, y| return false unless yield(x, y) }
      end
      true
    end

    def my_all_array_value_or_no_parameter?(mee, arg = [])
      return true if arg == []

      mee.my_each { |x| return false unless x == arg }
      true
    end

    def my_all_array_parameter?(mee, arg = [])
      ret = true
      if arg.class == Class
        mee.my_each { |x| ret = false unless x.class == arg }
      elsif arg.class == Regexp
        mee.my_each { |x| ret = false unless arg.match? x.to_s }
      else
        ret = my_all_array_value_or_no_parameter?(mee, arg)
      end
      ret
    end

    def my_all?(arg = [])
      me = self
      ret = true
      if block_given?
        ret = my_all_block?(me) { |x, y| yield(x, y) }
      else
        return false if me.is_a?(Hash)

        me.my_each { |x| return false if [false, nil].include? x }
        ret = my_all_array_parameter?(me, arg)
      end
      ret
    end
  end

  # contains "my_any?, my_none?" methods
  module EnumerableInside2
    def my_any_block?(mee)
      if mee.is_a?(Array)
        mee.my_each { |x| return true if yield(x) }
      else # if mee.is_a?(Hash)
        mee.my_each { |x, y| return true if yield(x, y) }
      end
      false
    end

    def my_any_array_value_or_no_parameter?(mee, arg = [])
      if arg == []
        i = 0
        mee.my_each { |x| i += 1 if [false, nil].include? x }
        return (i != mee.size) # no arg (all are false) = flase
      else
        mee.my_each { |x| return true if x == arg }
      end
      false
    end

    def my_any_array_parameter?(mee, arg = [])
      ret = false
      if arg.class == Class
        mee.my_each { |x| ret = true if x.class == arg }
      elsif arg.class == Regexp
        mee.my_each { |x| ret = true if arg.match? x.to_s }
      else
        ret = my_any_array_value_or_no_parameter?(mee, arg)
      end
      ret
    end

    def my_any?(arg = [])
      me = self
      ret = false
      if block_given?
        ret = my_any_block?(me) { |x, y| yield(x, y) }
      else
        return false if me.is_a?(Hash)

        ret = my_any_array_parameter?(me, arg)
      end
      ret
    end

    def my_none_block?(mee)
      if mee.is_a?(Array)
        mee.my_each { |x| return false if yield(x) }
      else # if mee.is_a?(Hash)
        mee.my_each { |x, y| return false if yield(x, y) }
      end
      true
    end

    def my_none_array_value_or_no_parameter?(mee, arg = [])
      if arg == []
        mee.my_each { |x| return false if x } # false until all val are false
      else
        mee.my_each { |x| return false if x == arg }
      end
      true
    end

    def my_none_array_parameter?(mee, arg = [])
      ret = true
      if arg.class == Class
        mee.my_each { |x| ret = false if x.class == arg }
      elsif arg.class == Regexp
        mee.my_each { |x| ret = false if arg.match? x.to_s }
      else
        ret = my_none_array_value_or_no_parameter?(mee, arg)
      end
      ret
    end

    def my_none?(arg = [])
      me = self
      ret = true
      if block_given?
        ret = my_none_block?(me) { |x, y| yield(x, y) }
      else
        return false if me.is_a?(Hash)

        ret = my_none_array_parameter?(me, arg)
      end
      ret
    end
  end

  # contains "my_count, my_map" methods
  module EnumerableInside3
    # my_count_block_array
    def a_c1(mee, counter)
      mee.my_each { |x| counter += 1 if yield(x) }
      counter
    end

    # my_count_block_hash
    def h_c1(mee, counter)
      mee.my_each { |x, y| counter += 1 if yield(x, y) }
      counter
    end

    # my_count_parameter_array
    def a_c2(mee, counter, par)
      mee.my_each { |x| counter += 1 if x == par }
      counter
    end

    # my_count_parameter_hash
    def h_c2(mee, counter, par)
      mee.my_each { |_x, y| counter += 1 if y == par }
      counter
    end

    def my_count(val = nil)
      me = self
      c = 0
      return me.size if val.nil? && block_given? == false

      c = if me.is_a?(Array)
            block_given? ? a_c1(me, c) { |x| yield(x) } : a_c2(me, c, val)
          else # if me.is_a?(Hash)
            block_given? ? h_c1(me, c) { |x, y| yield(x, y) } : h_c2(me, c, val)
          end
      c
    end

    def my_map_array(mee, &procs)
      temp = []
      i = 0
      mee.my_each do |x|
        temp[i] = procs.call(x)
        temp[i] = yield(x) if block_given?
        i += 1
      end
      temp
    end

    def my_map_hash(mee, &procs)
      temp = []
      i = 0
      mee.my_each do |x, y|
        temp[i] = procs.call(x, y)
        temp[i] = yield(x, y) if block_given?
        i += 1
      end
      temp
    end

    def my_map
      me = self
      return to_enum(:my_map) unless block_given?

      if me.is_a?(Array)
        my_map_array(me) { |x| yield(x) }
      else # if me.is_a?(Hash)
        my_map_hash(me) { |x, y| yield(x, y) }
      end
    end
  end

  # contains "my_inject" method
  module EnumerableInside4
    def my_inject_hash(mee)
      temp = []
      i = 0
      mee.my_each do |x, y|
        temp[i] = x
        temp[i + 1] = y
        i += 2
      end
      temp
    end

    def my_inject_array_block(mee, start = nil)
      if start.nil?
        start = mee.first
        mee.my_each { |x| start = yield(start, x) if mee.first != x }
      else
        mee.my_each { |x| start = yield(start, x) }
      end
      start
    end

    def my_inject_array_proc(mee, start = nil, opr = {})
      if start.is_a?(Symbol) # no block only second argument "operator"
        opr = start
        opr = opr.to_proc
        start = mee.first
        mee.my_each { |x| start = opr.call(start, x) if mee.first != x }
      else
        opr = opr.to_proc
        mee.my_each { |x| start = opr.call(start, x) }
      end
      start
    end

    def my_inject(start = nil, operator = {})
      me = self
      # when we use hashes with inject it will convert the hash into array
      return my_inject_hash(me) { |x, y| } unless me.is_a?(Array)

      start = if block_given?
                my_inject_array_block(me, start) { |tot, x| yield(tot, x) }
              else
                my_inject_array_proc(me, start, operator)
              end
      start
    end
  end
end

def multiply_els(array)
  array.my_inject(:*)
  # array.my_inject() {|tot, x| tot*x} # is working too
end

# include Enumerable
# include EnumerableInside1
# include EnumerableInside2
# include EnumerableInside3
# include EnumerableInside4
