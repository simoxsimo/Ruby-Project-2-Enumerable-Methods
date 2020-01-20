# frozen_string_literal: true

# This class contains all the custom made Enumerable methods
# rubocop: disable Metrics/ModuleLength
module Enumerable
  def my_each
    me = self
    me.size.times do |i|
      yield(me[i]) if block_given? && me.is_a?(Array)
      yield(me.keys[i], me.values[i]) if block_given? && me.is_a?(Hash)
    end
    me
  end

  def my_each_with_index
    me = self
    me.size.times do |i|
      yield(me[i], i) if block_given? && me.is_a?(Array)
      yield(me.values[i], i) if block_given? && me.is_a?(Hash)
    end
    me
  end

  def my_select
    me = self
    temp = me.is_a?(Array) ? [] : {}
    if me.is_a?(Array)
      me.my_each { |x| temp << x if yield(x) }
    else # if me.is_a?(Hash)
      me.my_each { |x, y| temp[x] = y if yield(x, y) }
    end
    temp
  end

  def my_all?
    me = self
    if me.is_a?(Array)
      me.my_each { |x| return false unless yield(x) }
    else # if me.is_a?(Hash)
      me.my_each { |x, y| return false unless yield(x, y) }
    end
    true
  end

  def my_any?
    me = self
    if me.is_a?(Array)
      me.my_each { |x| return true if yield(x) }
    else # if me.is_a?(Hash)
      me.my_each { |x, y| return true if yield(x, y) }
    end
    false
  end

  def my_none?
    me = self
    if me.is_a?(Array)
      me.my_each { |x| return false if yield(x) }
    else # if me.is_a?(Hash)
      me.my_each { |x, y| return false if yield(x, y) }
    end
    true
  end

  # my_count_block_array
  def array_c1(mee, counter)
    mee.my_each { |x| counter += 1 if yield(x) }
    counter
  end

  # my_count_block_hash
  def h_c1(mee, counter)
    mee.my_each { |x, y| counter += 1 if yield(x, y) }
    counter
  end

  # my_count_parameter_array
  def array_c2(mee, counter, par)
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
          block_given? ? array_c1(me, c) { |x| yield(x) } : array_c2(me, c, val)
        else # if me.is_a?(Hash)
          block_given? ? h_c1(me, c) { |x, y| yield(x, y) } : h_c2(me, c, val)
        end
    c
  end

  # rubocop: disable Metrics/MethodLength
  def my_map(&procs)
    me = self
    temp = []
    i = 0
    if me.is_a?(Array)
      me.my_each do |x|
        temp[i] = procs.call(x)
        temp[i] = yield(x) if block_given?
        i += 1
      end
    else # if me.is_a?(Hash)
      me.my_each do |x, y|
        temp[i] = procs.call(x, y)
        temp[i] = yield(x, y) if block_given?
        i += 1
      end
    end
    temp
  end

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
  # rubocop: enable Metrics/MethodLength

  def multiply_els(array)
    array.my_inject(:*)
    # array.my_inject() {|tot, x| tot*x} # is working too
  end
end
# rubocop: enable Metrics/ModuleLength

# Test
#
# Array => arr = [1,4,5,6,7,8,9]
# Hash =>  hash_num = {one: 1, two: 2, nine: 9, seven: 7, four: 4}

# Testing my_each VS each
#
# ********************************************************
# *     ===============-Array Test-===============       *
# *     print arr.my_each { |x| x*2 }.to_s + "\n"        *
# *     puts"-----------------------"                    *
# *     print arr.each{|x| x*2}                          *
# *     ===============-Hash Test-===============        *
# *     print hash_num.each{|x, y| y*2}                  *
# *     puts"\n--------------"                           *
# *     print hash_num.my_each {|x, y| y*2}              *
# ********************************************************

# Testing my_each_with_index VS each_with_index
#
# ********************************************************
# *     ===============-Array Test-===============       *
# *     arr.my_each_with_index { |x, y| print y }        *
# *     puts"\n-----------------------"                  *
# *     arr.each_with_index{|x, y| print y}              *
# *     ===============-Hash Test-===============        *
# *     hash_num.my_each_with_index { |x, y| print y }   *
# *     puts"\n-----------------------"                  *
# *     hash_num.each_with_index{|x, y| print y}         *
# ********************************************************

# Testing my_select VS select
#
# ********************************************************
# *     ===============-Array Test-===============       *
# *     print arr.my_select{ |x| x>4 }                   *
# *     puts"\n-----------------------"                  *
# *     print arr.select{|x| x>4}                        *
# *     ===============-Hash Test-===============        *
# *     print hash_num.my_select{|x, y| y>4}             *
# *     puts"\n-----------------------"                  *
# *     print hash_num.select{|x, y| y>4}                *
# ********************************************************

# Testing my_all? VS all?
#
# ********************************************************
# *     ===============-Array Test-===============       *
# *     print arr.all?{ |x| x<=9 }                       *
# *     puts"\n-----------------------"                  *
# *     print arr.my_all?{|x| x<=9}                      *
# *     ===============-Hash Test-===============        *
# *     print hash_num.my_all?{|x, y| y.is_a? Integer}   *
# *     puts"\n-----------------------"                  *
# *     print hash_num.all?{|x, y| y.is_a? Integer}      *
# ********************************************************

# Testing my_any? VS any?
#
# ********************************************************
# *     ===============-Array Test-===============       *
# *     print arr.any?{ |x| x>9 }                        *
# *     puts"\n-----------------------"                  *
# *     print arr.my_any?{|x| x>9}                       *
# *     ===============-Hash Test-===============        *
# *     print hash_num.my_any?{|x, y| y>1}               *
# *     puts"\n-----------------------"                  *
# *     print hash_num.any?{|x, y| y>1}                  *
# ********************************************************

# Testing my_none? VS none?
#
# ********************************************************
# *     ===============-Array Test-===============       *
# *     print arr.none?{ |x| x>9 }                       *
# *     puts"\n-----------------------"                  *
# *     print arr.my_none?{|x| x>9}                      *
# *     ===============-Hash Test-===============        *
# *     print hash_num.my_none?{|x, y| y.is_a? String}   *
# *     puts"\n-----------------------"                  *
# *     print hash_num.none?{|x, y| y.is_a? String}      *
# ********************************************************

# Testing my_count VS count
#
# ********************************************************
# *     ===============-Array Test-===============       *
# *     print arr.count{ |x| x.even? }                   *
# *     puts"\n-----------------------"                  *
# *     print arr.my_count{|x| x.even?}                  *
# *     puts"\n$$$$$$$$$$$$$$$$$$$$$$$"                  *
# *     print arr.count(7)                               *
# *     puts"\n-----------------------"                  *
# *     print arr.my_count(7)                            *
# *     ===============-Hash Test-===============        *
# *     print hash_num.my_count{|x, y| y.odd?}           *
# *     puts"\n-----------------------"                  *
# *     print hash_num.count{|x, y| y.odd?}              *
# *     puts"\n$$$$$$$$$$$$$$$$$$$$$$$"                  *
# *     print hash_num.my_count{|x, y| x==:one}          *
# *     puts"\n-----------------------"                  *
# *     print hash_num.count{|x, y| x==:one}             *
# ********************************************************

# Testing my_map VS map
#
# ********************************************************
# *     ===============-Array Test-===============       *
# *                                                      *
# *     1 - Passing a block                              *
# *     ##########################################       *
# *     print arr.my_map {|x| x*2}                       *
# *     puts"\n-----------------------"                  *
# *     print arr.map {|x| x*2}                          *
# *     puts"\n-----------------------"                  *
# *     print arr                                        *
# *     2 - Passing a proc                               *
# *     ##########################################       *
# *     procs = Proc.new { |x| x*2 }                     *
# *     print arr.my_map(&procs)                         *
# *     puts"\n-----------------------"                  *
# *     print arr.map(&procs)                            *
# *     puts"\n-----------------------"                  *
# *     print arr                                        *
# *                                                      *
# *     ===============-Hash Test-===============        *
# *                                                      *
# *     1 - Passing a block                              *
# *     ##########################################       *
# *     print hash_num.my_map { |x, y| x.to_s}           *
# *     puts"\n-----------------------"                  *
# *     print hash_num.map { |x, y| x.to_s}              *
# *     puts"\n-----------------------"                  *
# *     print hash_num                                   *
# *     puts"\n$$$$$$$$$$$$$$$$$$$$$$$"                  *
# *     print hash_num.my_map { |x, y| y*2}              *
# *     puts"\n-----------------------"                  *
# *     print hash_num.map { |x, y| y*2}                 *
# *     puts"\n-----------------------"                  *
# *     print hash_num                                   *
# *     2 - Passing a proc                               *
# *     ##########################################       *
# *     procs1 = Proc.new { |x, y| x.to_s }              *
# *     procs2 = Proc.new { |x, y| y*2 }                 *
# *     print hash_num.my_map(&procs1)                   *
# *     puts"\n-----------------------"                  *
# *     print hash_num.map(&procs1)                      *
# *     puts"\n-----------------------"                  *
# *     print hash_num                                   *
# *     puts"\n$$$$$$$$$$$$$$$$$$$$$$$"                  *
# *     print hash_num.my_map(&procs2)                   *
# *     puts"\n-----------------------"                  *
# *     print hash_num.map(&procs2)                      *
# *     puts"\n-----------------------"                  *
# *     print hash_num                                   *
# ********************************************************

# Testing my_inject VS inject
#
# ********************************************************
# *     ===============-Array Test-===============       *
# *                                                      *
# *     1-test case: Passing a block                     *
# *     ##########################################       *
# *     print arr.my_inject{ |tot, x| tot*x}             *
# *     puts"\n-----------------------"                  *
# *     print arr.inject{ |tot, x| tot*x}                *
# *     puts"\n-----------------------"                  *
# *     print arr                                        *
# *     2-test case: block with the first parameter      *
# *     ##########################################       *
# *     print arr.my_inject(0){|tot, x| tot-x}           *
# *     puts"\n-----------------------"                  *
# *     print arr.inject(0){|tot, x| tot-x}              *
# *     puts"\n-----------------------"                  *
# *     print arr                                        *
# *     3-test case: Passing only the second parameter   *
# *     ##########################################       *
# *     print arr.my_inject(:-)                          *
# *     puts"\n-----------------------"                  *
# *     print arr.inject(:-)                             *
# *     puts"\n-----------------------"                  *
# *     print arr                                        *
# *     4-test case: Passing both of the two parameters  *
# *     ##########################################       *
# *     print arr.my_inject(5,:-)                        *
# *     puts"\n-----------------------"                  *
# *     print arr.inject(5,:-)                           *
# *     puts"\n-----------------------"                  *
# *     print arr                                        *
# *                                                      *
# *     ===============-Hash Test-===============        *
# *     print hash_num.my_inject{ |tot, x| tot+x}        *
# *     puts"\n-----------------------"                  *
# *     print hash_num.inject{ |tot, x| tot+x}           *
# *     puts"\n-----------------------"                  *
# *     print hash_num                                   *
# ********************************************************

# hash_num = {one: 1, two: 2, nine: 9, seven: 7, four: 4}
# arr = [1,4,5,6,7,8,9]
# arr2 = [2,4,5]
# procs = Proc.new { |x| x*2 }
# procs1 = Proc.new { |x, y| x.to_s }
# procs2 = Proc.new { |x, y| y*2 }
