module Enumerable
	def my_each
		(self.size).times { |i|
			yield(self[i]) if (block_given? && self.is_a?(Array))
			yield(self.keys[i], self.values[i]) if (block_given? && self.is_a?(Hash))
		}
		self
	end

	def my_each_with_index
		for i in (0..self.size-1)
			yield(self[i], i) if (block_given? && self.is_a?(Array))
			yield(self.values[i], i) if (block_given? && self.is_a?(Hash))
		end
		self
	end

	def my_select
		if self.is_a?(Array)
			temp = []
			i=0
			self.my_each { |x|
				if yield(x)
					temp[i] = x
					i+=1
				end
			}
			temp
		else #if self.is_a?(Hash)
			temp = {}
			self.my_each { |x, y| temp[x] = y if yield(x, y)}
			temp
		end
	end

	def my_all?
		if self.is_a?(Array)
			self.my_each{ |x| return false unless yield(x)}  
			true
		else #if self.is_a?(Hash)
			self.my_each{ |x, y| return false unless yield(x, y)}
			true
		end
	end

	def my_any?
		if self.is_a?(Array)
			self.my_each{ |x| return true if yield(x)}
			false
		else #if self.is_a?(Hash)
			self.my_each{ |x, y| return true if yield(x, y)}
			false
		end
	end

	def my_none?
		if self.is_a?(Array)
			self.my_each { |x| return false if yield(x)}
			true
		else #if self.is_a?(Hash)
			self.my_each { |x, y| return false if yield(x, y)}
			true
		end
	end

	def my_count(test=nil)
		counter = 0
		if self.is_a?(Array)
			self.my_each { |x| counter += 1 if ((x == test unless test.nil?) || (yield(x) if block_given?) )}
			counter
		else #if self.is_a?(Hash)
			self.my_each { |x, y| counter += 1 if ((y == test unless test.nil?) || (yield(x, y) if block_given?) )} # when passing value per argument in the original method 'count' it doesn't work for example try this: "print hash_num.count(7)" it will return 0 but in my_count method it will count the number of 7
			counter
		end
	end

	def my_map
		temp = []
		i=0
		if self.is_a?(Array)
			self.my_each { |x| 
				temp[i] = yield(x) if block_given? 
				i+=1
			}
			
		else #if self.is_a?(Hash)
			self.my_each { |x, y| 
				temp[i] = yield(x, y) if block_given? 
				i+=1
			}
		end
		temp
	end

	def operator (n)
		#Fill this shit
	end

	def my_inject(start_point=nil, operator={})
		start_point = self.first if start_point.nil? 
		if block_given?
			self.my_each {|x| start_point = yield(start_point, x)}
		else #not using block but rather parameters
			if start_point.is_a?(Symbol) # in case I run my_inject with only one argument which is the operator
				operator = start_point
				operator = operator.to_proc
				start_point = self.first
				self.my_each {|x| start_point = operator.call(start_point, x) if self.first != x}
			else
				operator = operator.to_proc
				self.my_each {|x| start_point = operator.call(start_point, x)} 
			end
		end
		start_point
	end
end

include Enumerable

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
# *     print arr.my_map {|x| x*2}                       *
# *     puts"\n-----------------------"                  *
# *     print arr.map {|x| x*2}                          *
# *     puts"\n-----------------------"                  *
# *     print arr                                        *
# *     ===============-Hash Test-===============        *
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
# ********************************************************

hash_num = {one: 1, two: 2, nine: 9, seven: 7, four: 4}
arr = [1,4,5,6,7,8,9]
# print arr.my_inject{ |tot, x| tot*x}
# puts"\n-----------------------"          
# print arr.inject{ |tot, x| tot*x}
# puts"\n-----------------------"
# print arr

# print arr.my_inject(0){|tot, x| tot-x}
# puts"\n-----------------------"          
# print arr.inject(0){|tot, x| tot-x}
# puts"\n-----------------------"
# print arr

# print arr.my_inject(:-)
# puts"\n-----------------------"          
# print arr.inject(:-)
# puts"\n-----------------------"
# print arr

# print arr.my_inject(5,:-)
# puts"\n-----------------------"          
# print arr.inject(5,:-)
# puts"\n-----------------------"
# print arr