module Enumerable
	def my_each
		i=-1
		(self.size).times { 
			i+=1
			yield(self[i]) if block_given?
		}
		self
	end

	def my_each_with_index
		for i in (0..self.size-1)
			yield(self[i], i) if block_given?
		end
		self
	end
end





include Enumerable
# Test Array
# => arr = [1,4,5,6,7,8,9]


# Testing my_each VS each
# ***************************************************
# *		print arr.my_each { |x| x*2 }.to_s + "\n"	*
# *		puts"-----------------------"				*
# *		print arr.each{|x| x*2}						*
# ***************************************************

# Testing my_each_with_index VS each_with_index
# ***************************************************************
# *		arr.my_each_with_index { |x, y| print y }				*
# *		puts"\n-----------------------"							*
# *		arr.each_with_index{|x, y| print y}						*
# ***************************************************************

arr = [1,4,5,6,7,8,9]	
arr.my_each_with_index { |x, y| print y }
puts"\n-----------------------"
arr.each_with_index{|x, y| print y}